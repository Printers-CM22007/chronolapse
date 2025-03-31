import os
import shutil
import sys
import subprocess
import time

shell = None
single_test = None
if len(sys.argv) == 2:
    if sys.argv[1].lower() != 'all':
        single_test = sys.argv[1]
elif len(sys.argv) == 3:
    shell = sys.argv[2]
    if sys.argv[1].lower() != 'all':
        single_test = sys.argv[1]

def run_command(command, allow_failure=False, run_between=None):
    global shell
    print(f"Running command `{command}`")
    if shell is not None:
        process = subprocess.Popen([shell, "-c", " ".join(command)])
    else:
        process = subprocess.Popen(command)

    if run_between is not None:
        while process.poll() is None:
            run_between_code = run_between()
            if run_between_code != 0:
                process.kill()
                exit(run_between_code)
            time.sleep(0.1)

    exit_code = process.wait()
    if not allow_failure and exit_code != 0:
        print(f"Exiting because `{command}` exited with code {exit_code}")
        exit(exit_code)

def adb_grant_permissions():
    global shell
    permissions = ["CAMERA", "RECORD_AUDIO"]
    for p in permissions:
        command = ["adb", "shell", "pm", "grant", "com.example.chronolapse", f"android.permission.{p}"]
        if shell is not None:
            exit_code = subprocess.run([shell, "-c", " ".join(command)], stdout=subprocess.DEVNULL).returncode
        else:
            exit_code = subprocess.run(command, stdout=subprocess.DEVNULL).returncode
        if exit_code != 0:
            print(f"Exiting because `{command}` exited with code {exit_code}")
            return exit_code
    return 0

def open_file(file_path):
    try:
        if sys.platform == "win32":
            os.startfile(file_path)  # Windows
        elif sys.platform == "darwin":
            os.system(f"open {file_path}")  # macOS
        else:
            os.system(f"xdg-open {file_path}")  # Linux
    except Exception as e:
        print(f"Error opening file: {e}")


def is_part_of(file_path):
    with open(f"lib/{file_path}", "r") as f:
        contents = f.read()
        return "\npart of" in contents or contents.startswith("part of")

if single_test is not None:
    run_command(
        ["flutter", "test", single_test],
        run_between=adb_grant_permissions
    )
    exit(0)

print("YOU MUST HAVE LCOV INSTALLED")
print("INTEGRATION TESTS WILL FAIL WITHOUT A RUNNING EMULATOR / CONNECTED DEVICE")

if os.path.isdir("coverage"):
    shutil.rmtree("coverage")

if os.path.isdir("assets/test_assets"):
    shutil.rmtree("assets/test_assets")

if os.path.isdir("test_assets"):
    shutil.copytree("test_assets", "assets/test_assets")

FILE_LOADER = "file_loader_5zwgxh9q6a8y_test.dart"
if os.path.isfile(f"test/{FILE_LOADER}"): os.remove(f"test/{FILE_LOADER}")
with open(f"test/{FILE_LOADER}", "w+") as f:
    contents = "// ignore_for_file: unused_import\n"
    dart_files = [os.path.join(root[4:], file) for root, _, files in os.walk("lib") for file in files if file.endswith(".dart") and not file.endswith(".g.dart")]
    dart_files = filter(lambda p: not is_part_of(p), dart_files)
    for df in dart_files:
        contents += f"import 'package:chronolapse/{df}';\n"
    contents += "void main() {}"
    f.write(contents)

unit_test_files = [os.path.join(root, file) for root, _, files in os.walk("test") for file in files if file.endswith(".dart") and file.endswith(".dart") and not "mocks" in root]
integration_test_files = [os.path.join(root, file) for root, _, files in os.walk("integration_test") for file in files if file.endswith(".dart") and file.endswith(".dart") and not "mocks" in root]

print(f"Unit tests: {', '.join(unit_test_files)}")
print(f"Integration tests: {', '.join(integration_test_files)}")

all_tests = [(t, 'unit') for t in unit_test_files] + [(t, 'int') for t in integration_test_files]

for i, (test, test_type) in enumerate(all_tests):
    run_command(
        ["flutter", "test", test, "--coverage"],
        allow_failure=test == f"test/{FILE_LOADER}",
        run_between=adb_grant_permissions if test_type == 'int' else None
    )
    shutil.move("coverage/lcov.info", f"coverage/lcov-{i}.info")

os.remove(f"test/{FILE_LOADER}")
if os.path.isdir("assets/test_assets"):
    shutil.rmtree("assets/test_assets")

combine_files = map(lambda x: 'coverage/lcov-' + str(x) + '.info', range(len(all_tests)))
combine_files_command_section = []
for i, f in enumerate(combine_files):
    if i != 0:
        combine_files_command_section.append("-a")
    combine_files_command_section.append(f)

run_command(
    [
        "lcov",
        "--add-tracefile"
    ] +
    combine_files_command_section +
    [
        "-o",
        "coverage/lcov-combined.info",
        "--ignore-errors",
        "empty"
    ]
)

run_command(["lcov", "--remove", "coverage/lcov-combined.info", "-o", "coverage/lcov-filtered.info", "'*.g.dart'"])

run_command(["genhtml", "coverage/lcov-filtered.info", "-o", "coverage/html"])

open_file("coverage/html/index.html")
