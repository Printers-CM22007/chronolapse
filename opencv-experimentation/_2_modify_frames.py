import math
import shutil

import cv2
import os
from dataclasses import dataclass
import numpy as np

def modify_frames():
    if os.path.exists("m_frames"):
        print("Removing existing frames...")
        shutil.rmtree("m_frames")

    os.makedirs("m_frames")

    frames = [f for f in os.listdir("frames") if os.path.isfile(os.path.join("frames", f))]

    interval = math.ceil(len(frames) / 100)
    percent = 0

    for i, f in enumerate(frames):
        if i % interval == 0:
            print(f"\rProcessing: {percent}%", end="")
            percent += 1

        img = cv2.imread(f"frames/{f}")

        def random_homography(width, height, scale=0.1, rotation=5, translation=0.1, scale_min=1.1):
            t_factor = 1 - (1 / scale_min)
            tb_x = (width / 2) * t_factor
            tb_y = (height / 2) * t_factor

            sx = scale_min + np.random.uniform(-scale, scale)
            sy = scale_min + np.random.uniform(-scale, scale)

            angle = np.random.uniform(-rotation, rotation)
            cos_a, sin_a = np.cos(np.radians(angle)), np.sin(np.radians(angle))

            tx = (np.random.uniform(-translation, translation) * width) - tb_x
            ty = (np.random.uniform(-translation, translation) * height) - tb_y

            H_affine = np.array([
                [sx * cos_a, -sin_a, tx],
                [sin_a, sy * cos_a, ty],
                [0, 0, 1]
            ], dtype=np.float32)

            return H_affine

        m = random_homography(img.shape[1], img.shape[0])

        # tl, tr, bl, br = [m @ np.array(v) for v in [[0, 0, 1], [img.shape[1], 0, 1], [0, img.shape[0], 1], [img.shape[1], img.shape[0], 1]]]

        h, w = img.shape[:2]
        corners = np.array([
            [0, 0],  # Top-left
            [w, 0],  # Top-right
            [0, h],  # Bottom-left
            [w, h]  # Bottom-right
        ], dtype=np.float32)

        # Reshape to homogeneous coordinates (Nx1x2)
        corners = corners.reshape(-1, 1, 2)

        # Apply the perspective transformation
        tl, tr, bl, br = [x[0] for x in cv2.perspectiveTransform(corners, m)]

        t_img = cv2.warpPerspective(img, m, (img.shape[1], img.shape[0]))

        cropped = t_img[int(max(tl[1], tr[1], 0)):int(min(br[1], bl[1], img.shape[0])), int(max(tl[0], bl[0], 0)):int(min(tr[0], br[0], img.shape[1])), :]

        cv2.imwrite(f"m_frames/m{f}", cropped)
        # np.save(f"m_frames/m{f}.npy", m)

    print("\nDone")

if __name__ == "__main__":
    modify_frames()