function hough_img = generateHoughAccumulator(img, theta_num_bins, rho_num_bins)
	% initialize H(d,θ) = 0
    hough_img = zeros(rho_num_bins, theta_num_bins);
	
    [H, W] = size(img);
	% coordinate system, move to the center
    [x, y] = meshgrid(1:W, 1:H);
    centre_x = floor(W/2);
    centre_y = floor(H/2);
    x = x - centre_x;
    y = y - centre_y;

    % img is an edge image
    x_edge = x(img > 0);
    y_edge = y(img > 0);
    
    % calculate rho and theta for the edge pixels
    thetas = linspace(-pi/2, pi/2, theta_num_bins); % radiation pi
    rho_max = sqrt(H^2 + W^2) / 2; % image diagnol
    rho_min = -rho_max;

    % get rho_edges by x * sin(θ) - y * cos(θ) + ρ = 0
    sincos = [sin(thetas); cos(thetas)];
    xy_edges = [-x_edge, y_edge];
    rho_edges = xy_edges * sincos;

    % get rho_votes
    rho_vote_bins = round((rho_edges - rho_min) * (rho_num_bins - 1) / (rho_max - rho_min)) + 1;

    theta_vote_bins = 1:1:theta_num_bins;
    for i = 1:size(rho_vote_bins, 1)
        % map to corresponding index in the hough_img array and accumulate votes
        ind = sub2ind(size(hough_img), rho_vote_bins(i,:), theta_vote_bins); % ind = sub2ind(sz,row,col)
        hough_img(ind) = hough_img(ind) + 1;
    end
end