function cropped_line_img = lineSegmentFinder(orig_img, hough_img, hough_threshold, canny_threshold)
    % references:
    % https://github.com/Rad-hi/crop_line_detector_cv/blob/master/scripts/cropLineDetector.py
    % https://www.mathworks.com/help/signal/ug/remove-spikes-from-a-signal.html

    fig = figure();
    imshow(orig_img);

    [H, W] = size(orig_img);
    [N_rho, N_theta] = size(hough_img);

    % get rid of weak votes
    hough_img(hough_img < hough_threshold) = 0;

    % find peaks
    strong_hough_img = hough_img;
    [hough_img_H, hough_img_W] = size(hough_img);
	window_H = 4; % try to make window_H : window_W = hough_img_H : hough_img_W
    window_W = 6;
    peaks = zeros(size(hough_img));
    for i = 1:hough_img_H
        for j = 1:hough_img_W
            if hough_img(i, j) > 0
                x_low = max(j - window_H, 1);
                x_high = min(j + window_H, hough_img_W);
                y_low = min(i + window_W, hough_img_H);
                y_high = max(i - window_W, 1);
                window_temp = hough_img(y_high:y_low, x_low:x_high);
                peaks(i, j) = verifyPeak(window_temp, i - y_high + 1, j - x_low + 1);
            end
        end
    end
    strong_hough_img(~peaks) = 0; % remove non-peaks

    % get theta and rho
    rho_min = -sqrt(H^2 + W^2) / 2;
    rho_max = sqrt(H^2 + W^2) / 2;
    rho_range = (rho_max - rho_min) / (N_rho - 1);
    theta_min = -pi/2;
    theta_max = pi/2;
    theta_range = (theta_max - theta_min) / (N_theta - 1);

    % get center and bounds
    [x_center, x_min, x_max] = getCenterBound(W);
    [y_center, y_min, y_max] = getCenterBound(H);

    % detect edges with canny
    edges = edge(orig_img, 'canny', canny_threshold);
	
    for i = 1:N_rho
        for j = 1:N_theta
            if strong_hough_img(i, j) > 0
            	% map to corresponding line parameters
                rho = rho_min + rho_range * (i-1);
                theta = theta_min + theta_range * (j-1);
            	
            	% generate some points for the line
                if (theta == 0) % horizontal
                    x1_temp = x_min;
                    y1_temp = rho;
                    x2_temp = x_max;
                    y2_temp = rho;
                else % not horizontal
                    y1_temp = y_min;
                    x1_temp = (y1_temp * cos(theta) - rho) / sin(theta);
                    y2_temp = y_max;
                    x2_temp = (y2_temp * cos(theta) - rho) / sin(theta);
                end

                % move to the center
                x1 = x1_temp + x_center;
                x2 = x2_temp + x_center;
                y1 = y1_temp + y_center;
                y2 = y2_temp + y_center;
            	
                % find the top point that is the beginning of the segment
                if (theta ~= 0)
                    [x1, y1] = checkSegment(x1_temp, x1, y1, x_min, x_max, theta, rho, x_center, y_center);
                    [x2, y2] = checkSegment(x2_temp, x2, y2, x_min, x_max, theta, rho, x_center, y_center);
                end
                
                % get points on the segment
                distance = round(sqrt((x1-x2)^2 + (y1-y2)^2)) + 1;
                range = linspace(0, 1, distance);
                points = zeros(distance, 2);
                for d = 1:distance
                    points(d,:) = round((1-range(d)) * [x1, y1] + range(d) * [x2, y2]);
                end

                % get the points' indices from edges
                seg_ind = sub2ind(size(edges), points(:,2), points(:,1));
                seg_edge = edges(seg_ind);
                [has_segment, segment] = splitSegment(distance, seg_edge);

                % [M,I] = max(___) returns the index into the operating dimension that corresponds to the maximum value
                [~, point_index] = max(segment(:));
                [point1, point2] = ind2sub(size(segment), point_index);
                x1 = points(point1, 1);
                x2 = points(point2, 1);
                y1 = points(point1, 2);
                y2 = points(point2, 2);
                if has_segment
                    % draw on the figure
            	    hold on
                    line([x1, x2], [y1, y2], 'Color', 'red', 'LineWidth', 3);
                end
            end
        end
    end

    % saveAnnotatedImg() is copied below from demoMATLABTricksFun.m
    cropped_line_img = saveAnnotatedImg(fig);
    close(fig);
end

function isPeak = verifyPeak(window, i, j)
    center = window(i, j);
    if (center == 0) % a peak cannot be 0
        isPeak = false;
    else
        % verify center is the peak of this window
        isPeak = (sum(find(window - center)) == 0); % find() returns a vector containing the linear indices of each nonzero element in its array
    end
end

function [x_center, x_min, x_max] = getCenterBound(W)
    x_center = floor(W/2);
    x_min = 1 - x_center;
    x_max = W - x_center;
end

function [x,y] = checkSegment(x1_temp, x1, y1, x_min, x_max, theta, rho, x_center, y_center)
    x = x1;
    y = y1;
    if x1_temp < x_min || x1_temp > x_max
        if x1_temp < x_min
            x1_temp = x_min;
        else
            x1_temp = x_max;
        end

        y1_temp = (x1_temp * sin(theta) + rho) / cos(theta);
        x = x1_temp + x_center;
        y = y1_temp + y_center;
    end
end

function [has_segment, segment] = splitSegment(distance, seg_edge)
    % remove noise with the median values around each point
    seg_edge = medfilt1(single(seg_edge), 13); % value gained by trials

    has_segment = false;
    segment = zeros(distance, distance);
    for i = 1:distance
        for j = (i+1):distance
            if seg_edge(i) ~= 0 && seg_edge(j) ~= 0                             
                if sum(seg_edge(i:j)) > (j - i) / 2
                    % enough pixels to be a segment, rather than a dot or something else
                    has_segment = true;
                    segment(i, j) = j - i;
                end
            end
        end
    end
end

function annotated_img = saveAnnotatedImg(fh)
    figure(fh); % Shift the focus back to the figure fh

    % The figure needs to be undocked
    set(fh, 'WindowStyle', 'normal');

    % The following two lines just to make the figure true size to the
    % displayed image. The reason will become clear later.
    img = getimage(fh);
    truesize(fh, [size(img, 1), size(img, 2)]);

    % getframe does a screen capture of the figure window, as a result, the
    % displayed figure has to be in true size. 
    frame = getframe(fh);
    pause(0.5); 
    % Because getframe tries to perform a screen capture. it somehow 
    % has some platform depend issues. we should calling
    % getframe twice in a row and adding a pause afterwards make getframe work
    % as expected. This is just a walkaround. 
    annotated_img = frame.cdata;
end
