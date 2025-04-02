1. Assume user has taken image with a reasonable degree of accuracy - discard keypoints matches with too much distance between them
2. Reject the match if:
   1. There are too few keypoints
   2. The resulting transformation is too extreme
3. Else - show adjusted image immediately to the user for them to accept/reject
4. If rejected, allow the user to retake the image or allow them to place the keypoints with high detail