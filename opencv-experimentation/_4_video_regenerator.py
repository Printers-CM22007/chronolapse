import math

import cv2
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.figure import Figure

from util import get_id

def get_hists(f, bottom):
    plt.clf()
    fig = plt.figure(figsize=(19.2, 10.8), clear=True)
    color = ('b', 'g', 'r')
    for j, col in enumerate(color):
        histr = cv2.calcHist([bottom], [j], None, [256], [0, 256])
        plt.plot(histr, color=col)
        plt.xlim([0, 256])
    plt.savefig(f"frames/h_{get_id(f)}.jpg")
    hist1 = cv2.imread(f"frames/h_{get_id(f)}.jpg")
    plt.close(fig)

    plt.clf()
    bottom_hsv = cv2.cvtColor(bottom, cv2.COLOR_BGR2HSV)
    fig = plt.figure(figsize=(19.2, 10.8), clear=True)
    color = ('b', 'g', 'r')
    for j, col in enumerate(color):
        histr = cv2.calcHist([bottom_hsv], [j], None, [256], [0, 256])
        plt.plot(histr, color=col)
        plt.xlim([0, 256])
    plt.savefig(f"frames/hvsh_{get_id(f)}.jpg")
    hist2 = cv2.imread(f"frames/hvsh_{get_id(f)}.jpg")
    plt.close(fig)

    # Intensity Histogram
    # plt.clf()
    # bottom_gray = cv2.cvtColor(bottom, cv2.COLOR_BGR2GRAY)
    # fig = plt.figure(figsize=(19.2, 10.8), clear=True)
    # histr = cv2.calcHist([bottom_gray], [0], None, [256], [0, 256])
    # plt.plot(histr, color=col)
    # plt.xlim([0, 256])
    # plt.savefig(f"frames/gh_{get_id(f)}.jpg")
    # hist2 = cv2.imread(f"frames/gh_{get_id(f)}.jpg")
    # plt.close(fig)

    return hist1, hist2

def video_regenerator(fps = 60, frame_interval=1, alignment_sources = None):
    frames = [img for img in os.listdir("a_frames")]
    frames.sort(key=lambda x: int(get_id(x)))

    frame = cv2.imread(os.path.join("a_frames", frames[0]))
    height, width, layers = frame.shape
    hist_w = get_hists(frames[0], frame)[0].shape[1]

    video = cv2.VideoWriter("r_video.avi", 0, (fps / frame_interval), (width + hist_w, height * 2))

    interval = math.ceil(len(frames) / 100)
    percent = 0

    prev_frame = None

    for i, f in enumerate(frames):
        if i % interval == 0:
            print(f"\rWrote {percent}% of frames (with histograms) to video", end="")
            percent += 1

        top = cv2.imread(os.path.join("a_frames", f))
        if alignment_sources is not None:
            bottom = cv2.imread(os.path.join("frames", alignment_sources[i]))
        else:
            bottom = cv2.imread(os.path.join("frames", f"f_{get_id(f)}.jpg"))

        (hist1, hist2) = get_hists(f, bottom)
        # hist = cv2.resize(hist, (hist.shape[1], height * 2))
        hist = np.vstack((hist1, hist2))

        joined_image = np.vstack((top, bottom))
        joined_image = np.hstack((joined_image, hist))

        # if prev_frame is not None:
        #     video.write(np.uint8((np.float32(joined_image) + np.float32(prev_frame)) / 2))

        video.write(joined_image)
        # prev_frame = joined_image

    print("\nDone")

if __name__ == '__main__':
    video_regenerator()