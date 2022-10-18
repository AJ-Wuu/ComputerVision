# HW2
## Walkthrough is fine
## Edge Detection
I tried sobel and canny, and finally I decided to use sobel as the result looks better to me.  
I used canny in the later part of the homework though.  

## Hough Transform
I used 800 as rho_nums_bins to relate to the diagonal size of the picture (640 x 426 -> diagnol is around 768, and I round it up to a full hundred).  
For theta_nums_bins, I chose 500 as it is large enough to contains the shorter edge (426, in this case).  
To perform voting from each edge pixel, I chose to have each (rho, theta) pair with one vote.  
Rho is calculated with its corresponding proportion of the current rho value out of rho_range (= rho_max - rho_min).  
Theta is gained as linspace, which is inspired by the official documentation.  
According to some search on StackOverflow, it seems possible to use sub2ind() to get the indices on hough_img.  
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
For each possible segment we got, we process it by three steps.  
First, we need to verify if the points are actually on the image -- ignore those that are not, and keep the topmost ones that are.  
This helps remove the redundant part of the line drawn in the previous part.  
Second, we try to remove the noise around the line and detect the real segment, that is, remove the segments that are too short or only contain a few pixels.  
Third, we go ahead and split the real segment out and get its two endpoints.  
With the endpoints, we could draw the segment accordingly.  

## Review
I have tried various methods to eliminate the vertical line on the right most part of the second and third picture.  
However, I didn't get any luck in doing so, and I am still trying to figure out why such line is captured by the program.  