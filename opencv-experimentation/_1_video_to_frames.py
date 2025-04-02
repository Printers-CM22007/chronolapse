import shutil

import cv2
import os

def video_to_frames(frame_interval = 1):
    if os.path.exists("frames"):
        print("Removing existing frames...")
        shutil.rmtree("frames")

    os.makedirs("frames")

    video_name = "video.mp4"
    vidcap = cv2.VideoCapture(video_name)
    success,image = vidcap.read()
    count = 0
    while success:
        if count % 100 == 0:
            print(f"\rProcessed {count} frames", end="")
        if count % frame_interval == 0:
            cv2.imwrite(f"frames/f_{count}.jpg", image)
        success,image = vidcap.read()
        count += 1
    print("\nDone")
    return vidcap.get(cv2.CAP_PROP_FPS)

if __name__ == "__main__":
    video_to_frames(6)