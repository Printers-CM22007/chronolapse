import os
import shutil
import sys
import subprocess
import time

shell = None

def adb_grant_permissions():
    global shell
    permissions = ["CAMERA", "RECORD_AUDIO"]
    for p in permissions:
        command = ["adb", "shell", "pm", "grant", "com.example.chronolapse", f"android.permission.{p}"]
        if shell is not None:
            exit_code = subprocess.run([shell, "-c", " ".join(command)], stdout=subprocess.DEVNULL).returncode
        else:
            exit_code = subprocess.run(command, stdout=subprocess.DEVNULL).returncode


while True:
    adb_grant_permissions()
    time.sleep(1)