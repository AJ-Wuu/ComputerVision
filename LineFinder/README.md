# HW2
## Walkthrough is fine
## Edge Detection
I tried sobel and canny, and finally I decided to use sobel as the result looks better to me.  
I used canny in the later part of the homework though.  

## Hough Transform
I used 800 as rho_nums_bins to relate to the diagonal size of the picture (640 x 426 -> diagnol is around 768, and I round it up to a full hundred).  
For theta_nums_bins, I tried a few numbers (between 200 to 600) and chose 500 as it looks the best to me.  
To perform voting from each edge pixel, I chose to have each (rho, theta) pair with one vote.  
This might not be the most accurate method, but it's easy to implement and the result is good enough.  

## Find Peaks
I used the threshold method, and all thresholds are gained by trials.  
To find the peaks, I sliced the picture into multiple very small windows.  
Within each window, if its center weighs the most of the whole window, then it is concerned to be a peak.  
After finding the peak, by using the corresponding (rho, theta), we could get two points (x1, y1) and (x2, y2) on each line.  
Linking the two points with a solid line, we could get the result as desired.  

## Line Segments
I used the threshold method again, and all thresholds are gained by trials.  
After we got line image and edge image, the whole manipulation was appyied to edge image.  
For each point we got, we need to verify if they are actually on the image -- ignore those that are not, and keep the topmost ones that are.  
This helps remove the redundant part of the line drawn in the previous part.  
Note that I searched online and found the median filter method to remove the "noise", which is the noisy lines around the edges in this case.  
With all the points we have so far, we need to detect the actual end-points on each segment.  
To do this, I looped through all points and added another experimental threshold to check if the density is above that threshold.  
If there are enough points to make the density beyond the threshold, then we could be certain that there is a segment there.  
Therefore, we could draw the segment accordingly.  

## Review
I have tried various methods to eliminate the vertical line on the right most part of the second and third picture.  
However, I didn't get any luck in doing so, and I am still trying to figure out why such line is captured by the program.  