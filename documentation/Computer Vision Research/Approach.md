[Back](Computer%20Vision%20Research.md)

# Approach

> > [!warning] Liable to change

## Observations
1. Just feature detection not stable enough to deal with different weather
2. Feature detection failure correlates with a change in image histogram from original image used to match too

## Approach
1. Assume user has taken image with a reasonable degree of accuracy - discard keypoints matches with too much distance between them  
2. Reject the match if:  
   1. There are too few keypoints  
   2. The resulting transformation is too extreme  
3. Else - show adjusted image immediately to the user fading back and forth to the image matched to for review 
4. If rejected, allow the user to retake the image or allow them to place the keypoints with high detail. This image is added to a pool of manually reviewed images. The reviewed image with the closest histogram match is used to match to images
   > Potentially try all reviewed images from most histogram-matching to least until a non-automatically-rejected match is found 