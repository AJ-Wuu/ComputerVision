function line_detected_img = lineFinder(orig_img, hough_img, hough_threshold)
    fig = figure();
    imshow(orig_img);
    
    [H, W] = size(orig_img);    
    [N_rho, N_theta] = size(hough_img);
	
    % get rid of weak votes
    hough_img(hough_img < hough_threshold) = 0;

    % find peaks
    strong_hough_img = hough_img;
    [hough_img_H, hough_img_W] = size(hough_img);
	window_H = round((4 * N_rho) / max(H, W)); % coefficient are gained from trials
    window_W = round((6 * N_theta) / 360);
    peaks = zeros(size(hough_img));
    for i = 1:hough_img_H
        for j = 1:hough_img_W
            if hough_img(i, j) > 0
                top = max(i - window_W, 1);
                bottom = min(i + window_W, hough_img_H);
                left = max(j - window_H, 1);
                right = min(j + window_H, hough_img_W);
                window_temp = hough_img(top:bottom, left:right);
                peaks(i, j) = verifyPeak(window_temp, i - top + 1, j - left + 1);
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
	
    for i = 1:N_rho
        for j = 1:N_theta
            if strong_hough_img(i, j) > 0
            	% map to corresponding line parameters
                rho = rho_min + rho_range * i;
                theta = theta_min + theta_range * j;
            	
            	% generate some points for the line
                if (theta == 0) % horizontal
                    x1 = x_min;
                    y1 = rho;
                    x2 = x_max;
                    y2 = rho;
                else % non-horizontal
                    y1 = y_min;
                    x1 = (y1 * cos(theta) - rho) / sin(theta);
                    y2 = y_max;
                    x2 = (y2 * cos(theta) - rho) / sin(theta);
                end

                % move to the center
                x1 = x1 + x_center;
                x2 = x2 + x_center;
                y1 = y1 + y_center;
                y2 = y2 + y_center;
            	
            	% draw on the figure
            	hold on
                line([x1, x2], [y1, y2], 'Color', 'red', 'LineWidth', 3);
            end
        end
    end

    % saveAnnotatedImg() is copied below from demoMATLABTricksFun.m
    line_detected_img = saveAnnotatedImg(fig);
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
