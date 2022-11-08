function refocusApp(rgb_stack, depth_map)
    [height, width] = size(depth_map); % depth_map is the index_map computed previously
    
    % step 1: display an image in the focal stack
    fig = figure('Name', 'refocusApp');
    imshow(rgb_stack(:, :, 1:3));
    
    % step 2: ask the user to choose a scene point
    [y, x] = ginput(1);
    x = round(x); % need to round from float to integer (as it's used as index)
    y = round(y);
    while x > 0 && x <= height && y > 0 && y <= width
        % step 3: refocus the image so that the scene point is focused
        idx = depth_map(x, y);
        imshow(rgb_stack(:, :, 3*(idx-1)+1 : 3*idx));
        
        [y, x] = ginput(1);
        x = round(x);
        y = round(y);
    end

    close(fig);
end