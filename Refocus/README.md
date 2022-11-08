# Refocus App
## Load Stack
To load the stack, we need to use some commands like dir and fullfile to interact with the file system.  
There are multiple attributes we could extract with dir, including name, date, bytes, etc.  

## Index Map
Noticed that the computed focus measure could be noisy, so we use movmean() to smooth all the measure.  
Here we simply choose the layer with the maximum focus measure as the best focused layer, as instructed.  

## Refocus
I tried to use figure() as the "container" of displaying the image, but it's totally fine to use imshow() directly.  
A key to the correctness is to modify the input from user to integer, as the coordinates are used as indices.  
This float to integer casting could be done with round(), ceil(), etc.  
Rounding up or down doesn't really matter.  
