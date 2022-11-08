function refocusApp(rgb_stack, depth_map)
    [height, width] = size(depth_map);
    
    fig = figure('Name', 'refocusApp');
    imshow(rgb_stack(:, :, 1:3));
    
    [y, x] = ginput(1);
    x = round(x); % need to round from float to integer (as it's used as index)
    y = round(y);
    while x > 0 && x <= height && y > 0 && y <= width
        idx = depth_map(x, y);
        imshow(rgb_stack(:, :, 3*(idx-1)+1 : 3*idx));
        
        [y, x] = ginput(1);
        x = round(x);
        y = round(y);
    end

    close(fig);
end