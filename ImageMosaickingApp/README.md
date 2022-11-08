# Image Mosaicking App
## Vectorization
MATLAB is optimized for operations involving matrices and vectors.  
Avoid using loops (e.g., for, while) in MATLAB whenever possible – looping can result in long-running code.  
Instead, you should vectorize loops to optimize your code for performance.  
In many cases, [vectorization](https://www.mathworks.com/help/matlab/matlab_prog/vectorization.html) also results in more compact code (fewer lines to write!).  
If you are new to MATLAB, refer to [this article](https://www.mathworks.com/help/matlab/matlab_prog/techniques-for-improving-performance.html) for some ideas on how to optimize MATLAB code.

## Warping
1. We need to fill in the portrait_pts and bg_pts, which correspond to src_pts and dest_pts in debug1.
   As the protrait_small.png is of 327 x 400, we will directly use its corner points in protrait_pts.
   Similiar to the bg_pts, we will just use the while blank's corner points -- these coordinates are gained with getPointsFromUser(bg_img, 4, 'Click any 4 points').
2. To fill in the "Warp Image Here", we need to split the Van Gogh picture by RGB to fit in interp2().  
   Also, we need to update the mask and keep the rest bg_img in the result_img.  

## RANSAC
Follow the given pseudocode (and online reference) and parameter.  
I am curious about how to use pts_id. I don't think I'm using it in the expected way as I actually modified its initial value.  

## Blending
The Euclidean distance transform is easy, but it does take me quite a while of debugging.  
It is important to realize that we need to update the total_weighted_mask from 0 to 1 as we will divide it to make the whole thing sums to one.   

## Stitching
I followed the comments to use the previous parts step by step.  
I kept some parameters in the beginning to make it easier for modification.  
bbox_crop() looks cool to remove excess padding from the output.  
