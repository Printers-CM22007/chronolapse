import os
import shutil
import sys


def run_command(command):
    exit_code = os.system(command)
    if exit_code != 0:
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


unit_test_files = [f for f in map(lambda f: "test/"+f, os.listdir("test")) if os.path.isfile(f) and f.endswith(".dart")]
integration_test_files = [f for f in map(lambda f: "integration_test/"+f, os.listdir("integration_test")) if os.path.isfile(f) and f.endswith(".dart")]

print(f"Unit tests: {', '.join(unit_test_files)}")
print(f"Integration tests: {', '.join(integration_test_files)}")
print("YOU MUST HAVE LCOV INSTALLED")
print("INTEGRATION TESTS WILL FAIL WITHOUT A RUNNING EMULATOR / CONNECTED DEVICE")

shutil.rmtree("coverage")

all_tests = unit_test_files + integration_test_files

for i, test in enumerate(all_tests):
    run_command(f"flutter test {test} --coverage")
    shutil.move("coverage/lcov.info", f"coverage/lcov-{i}.info")


run_command(f"lcov --add-tracefile {' -a '.join(map(lambda x: 'coverage/lcov-' + str(x) + '.info', range(len(all_tests))))} -o coverage/lcov-combined.info")

run_command("genhtml coverage/lcov-combined.info -o coverage/html")

open_file("coverage/html/index.html")
