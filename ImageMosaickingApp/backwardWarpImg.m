function [mask, result_img] = backwardWarpImg(src_img, resultToSrc_H, dest_canvas_width_height)
	src_height = size(src_img, 1);
	src_width = size(src_img, 2);
    src_channels = size(src_img, 3);
    dest_width = dest_canvas_width_height(1);
	dest_height	= dest_canvas_width_height(2);
    
    result_img = zeros(dest_height, dest_width, src_channels);
    mask = false(dest_height, dest_width);
    
    % the overall region covered by result_img
    [dest_X, dest_Y] = meshgrid(1:dest_width, 1:dest_height);
    
    % map result_img region to src_img coordinate system using the given homography
    src_pts = applyHomography(resultToSrc_H, [dest_X(:), dest_Y(:)]);
    src_X = reshape(src_pts(:,1), dest_height, dest_width);
    src_Y = reshape(src_pts(:,2), dest_height, dest_width);
    
    % set 'mask' to the correct values based on src_pts
    % interp2(): interpolation for 2-D gridded data in meshgrid format -- need to split the picture by color to make src_img as several 2-D sets
    red = interp2(1:src_width, 1:src_height, src_img(:,:,1), src_X ,src_Y);
    green = interp2(1:src_width, 1:src_height, src_img(:,:,2), src_X ,src_Y);
    blue = interp2(1:src_width, 1:src_height, src_img(:,:,3), src_X ,src_Y);

    % fill the right region in 'result_img' with the src_img
    % add the new area
    result_img(:,:,1) = red;
    result_img(:,:,2) = green;
    result_img(:,:,3) = blue;
    % keep the rest part
    result_img(isnan(result_img)) = 0;
    
    % update the mask
    for i = 1:dest_height
        for j = 1:dest_width
            if sum(result_img(i,j,:)) ~= 0
                % if result_img has color on this pixel, we need to keep it valid on the mask
                mask(i,j) = 1;
            end
        end
    end
end