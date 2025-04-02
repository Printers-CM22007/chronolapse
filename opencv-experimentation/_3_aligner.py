import math
import os
import shutil

import numpy as np
import cv2

from util import get_id


def align_image(match_against, frame, f):
    # Convert images to grayscale
    original_gray = cv2.cvtColor(match_against, cv2.COLOR_BGR2GRAY)

    frame_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Use ORB detector to find keypoints and descriptors
    orb = cv2.ORB_create()
    kp1, descriptors1 = orb.detectAndCompute(original_gray, None)
    kp2, descriptors2 = orb.detectAndCompute(frame_gray, None)

    # Use BFMatcher to find matches
    bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True)
    matches = bf.match(descriptors1, descriptors2)
    matches = sorted(matches, key=lambda x: x.distance)

    max_proportions = 0.4
    max_dist_x, max_dist_y = match_against.shape[0]*max_proportions, match_against.shape[1]*max_proportions
    filtered_matches = []
    for m in matches:
        pt1 = np.array(kp1[m.queryIdx].pt)
        pt2 = np.array(kp2[m.trainIdx].pt)

        dist = np.abs(pt1 - pt2)

        if dist[0] < max_dist_y and dist[1] < max_dist_x:
            filtered_matches.append(m)

    # Select good matches
    num_good_matches = 12
    if len(filtered_matches) < num_good_matches:
        # print("\n",len(filtered_matches), len(matches))
        return False
    good_matches = matches[:num_good_matches]

    # Extract location of good matches
    src_pts = np.float32([kp1[m.queryIdx].pt for m in good_matches]).reshape(-1, 1, 2)
    dst_pts = np.float32([kp2[m.trainIdx].pt for m in good_matches]).reshape(-1, 1, 2)

    # Compute homography matrix
    H, mask = cv2.findHomography(dst_pts, src_pts, cv2.RANSAC, 5.0)

    # Warp the image to align with original
    height, width = match_against.shape[:2]
    aligned_frame = cv2.warpPerspective(frame, H, (width, height))

    cv2.imwrite("a_frames/a_" + f.split("_")[1], aligned_frame)

    return True

def get_hist(img):
    img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    hist = cv2.calcHist([img_hsv], [0, 1], None, [50, 60], [0, 180, 0, 256])
    cv2.normalize(hist, hist, 0, 1, cv2.NORM_MINMAX)
    return hist

def best_match(hists, img):
    best = 0
    best_val = cv2.compareHist(hists[0], get_hist(img), cv2.HISTCMP_CORREL)

    for i, h in enumerate(hists):
        if i == 0: continue
        val = cv2.compareHist(h, get_hist(img), cv2.HISTCMP_CORREL)
        if abs(1 - val) < abs(1 - best_val):
            best_val = val
            best = i

    return best

def aligner():
    if os.path.exists("a_frames"):
        print("Removing existing frames...")
        shutil.rmtree("a_frames")

    os.makedirs("a_frames")

    alignment_sources = []
    matched_sample_names = ["f_0.jpg"]
    matched_samples = [cv2.imread("frames/f_0.jpg")]
    matched_histograms = [get_hist(matched_samples[0])]
    frames = [f for f in os.listdir("m_frames") if not f.endswith("npy") and os.path.isfile(os.path.join("m_frames", f))]
    frames.sort(key=lambda x: int(get_id(x)))

    interval = math.ceil(len(frames) / 100)
    percent = 0

    i = 0
    while i < len(frames):
        f = frames[i]
        frame = cv2.imread("m_frames/" + f)
        if i % interval == 0:
            print(f"\rAligning: {percent}%", end="")
            percent += 1

        best_hist = best_match(matched_histograms, frame)
        success = align_image(matched_samples[best_hist], frame, f)
        if not success:
            print("\nCreated new reference alignment")
            matched_histograms.append(get_hist(frame))
            matched_sample_names.append(f"f_{get_id(f)}.jpg")
            alignment_sources.append(matched_sample_names[-1])
            matched_samples.append(cv2.imread(f"frames/f_{get_id(f)}.jpg"))
            success = align_image(matched_samples[-1], frame, f)
            if not success:
                print("Failed to match against self!")
                cv2.imwrite("a_frames/a_" + f.split("_")[1], np.zeros_like(matched_samples[-1], dtype=np.uint8))
        else:
            alignment_sources.append(matched_sample_names[best_hist])

        i += 1

    print(f"\nDone with {len(matched_samples)} reference alignments")

    return alignment_sources

if __name__ == "__main__":
    aligner()