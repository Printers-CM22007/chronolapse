import os
import shutil
import sys
import subprocess

shell = None if len(sys.argv) < 2 else sys.argv[1]

def run_command(command, allow_failure=False):
    global shell
    print(f"Running command `{command}`")
    shell_prefix = [] if shell is None else [shell, "-c"]
    exit_code = subprocess.run(shell_prefix + [command]).returncode
    if not allow_failure and exit_code != 0:
        print(f"Exiting because `{command}` exited with code {exit_code}")
        exit(exit_code)


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

exit()

all_tests = unit_test_files + integration_test_files

for i, test in enumerate(all_tests):
    run_command(f"flutter test {test} --coverage", allow_failure=test == f"test/{FILE_LOADER}")
    shutil.move("coverage/lcov.info", f"coverage/lcov-{i}.info")

os.remove(f"test/{FILE_LOADER}")
if os.path.isdir("assets/test_assets"):
    shutil.rmtree("assets/test_assets")

run_command(f"lcov --add-tracefile {' -a '.join(map(lambda x: 'coverage/lcov-' + str(x) + '.info', range(len(all_tests))))} -o coverage/lcov-combined.info --ignore-errors empty")

run_command(f"lcov --remove coverage/lcov-combined.info -o coverage/lcov-filtered.info '*.g.dart'")

run_command("genhtml coverage/lcov-filtered.info -o coverage/html")

open_file("coverage/html/index.html")
