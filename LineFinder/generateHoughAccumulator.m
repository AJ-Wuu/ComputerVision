function hough_img = generateHoughAccumulator(img, theta_num_bins, rho_num_bins)
    % references:
    % https://towardsdatascience.com/lines-detection-with-hough-transform-84020b3b1549
    % https://web.ipac.caltech.edu/staff/fmasci/home/astro_refs/HoughTrans_lines_09.pdf

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
    
    % calculate rho and theta for the edge pixels when the image is centered
    % Note that: all lines can be represented when θ ∈ [0, 180] ([-90, 90]) and r ∈ R, or θ ∈ [0, 360] and r ≥ 0
    %{
                y ↑                           ρ ↑
              ____|____ a                       | ← rho_max (a)
             |    |    |                        |
        ---------------------→ x      ---------------------→ θ
             |____|____| H/2           ↑ -pi/2  |        ↑ pi/2
            b     | W/2                         | ← rho_min (b)
        
    %}
    rho_max = sqrt(H^2 + W^2) / 2; % positive half of image diagnol
    rho_min = -sqrt(H^2 + W^2) / 2; % negative half of image diagnol
    rho_range = (rho_max - rho_min) / (rho_num_bins - 1); % get the proportion
    thetas = linspace(-pi/2, pi/2, theta_num_bins);

    % get rho_edges by x * sin(θ) - y * cos(θ) + ρ = 0 -> ρ = - x * sin(θ) + y * cos(θ)
    xy_edges = [-x_edge, y_edge];
    sincos = [sin(thetas); cos(thetas)];
    rho_edges = xy_edges * sincos;

    % get rho_votes by the current rho's proportion in rho_range
    % the value is at least one
    rho_vote_bins = round((rho_edges - rho_min) / rho_range) + 1;

    % get theta_votes
    % mimicing documentation with correct size: [H,T,R] = hough(BW,'RhoResolution',0.5,'Theta',-90:0.5:89);
    theta_vote_bins = 1:1:theta_num_bins;

    % map to corresponding index in the hough_img array and accumulate votes
    % rho -> row; theta -> column
    for i = 1:size(rho_vote_bins, 1)
        ind = sub2ind(size(hough_img), rho_vote_bins(i,:), theta_vote_bins); % ind = sub2ind(sz,row,col)
        hough_img(ind) = hough_img(ind) + 1;
    end
end