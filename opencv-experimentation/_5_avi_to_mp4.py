import os

def avi_to_mp4(fps = 60):
    if os.path.exists("r_video.mp4"):
        os.remove("r_video.mp4")

    bitrate = 80_000_000 / (len(os.listdir("frames")) / fps)

    print(f"Using bitrate {int(bitrate/1000)}k")

    os.system(f"ffmpeg -i r_video.avi -c:v libx264 -preset slow -b:v {int(bitrate/1000)}k -c:a aac -strict -2 r_video.mp4")

    print("Done")

if __name__ == "__main__":
    avi_to_mp4()