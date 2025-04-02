from _1_video_to_frames import video_to_frames
from _2_modify_frames import modify_frames
from _3_aligner import aligner
from _4_video_regenerator import video_regenerator
from _5_avi_to_mp4 import avi_to_mp4
import time

start = time.perf_counter()

frame_interval = 12
fps = 30
alignment_sources = None

# print("Converting video to frames...")
# fps = video_to_frames(frame_interval)
# print(f"FPS: {fps}")
#
# print("Modifying frames...")
# modify_frames()

print("Aligning frames...")
alignment_sources = aligner()

print("Regenerating video...")
video_regenerator(fps, frame_interval=frame_interval, alignment_sources=alignment_sources)

print("Converting to mp4")
avi_to_mp4(fps)

taken = time.perf_counter() - start
print(f"Completed in {taken:.2f} seconds")
