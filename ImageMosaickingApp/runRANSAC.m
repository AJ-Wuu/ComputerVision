function [inliers_id, H] = runRANSAC(Xs, Xd, ransac_n, eps)
    % reference: https://www.researchgate.net/figure/RANSAC-Algorithm-written-in-pseudocode_fig2_283850340
    num_pts = size(Xs, 1);
    pts_id = 0;
    inliers_id = [];
    
    for iter = 1:ransac_n
        inds = randperm(num_pts, 4); % inds is a vector of 4 random unique integers in [1, num_pts]
        Xs_random = Xs(inds, :);
        Xd_random = Xd(inds, :);
        
        % fit the model into the randomly generated samples
        H_temp = computeHomography(Xs_random, Xd_random);
        Xd_temp = applyHomography(H_temp, Xs);
        dist = sqrt((Xd(:,1) - Xd_temp(:,1)).^2 + (Xd(:,2) - Xd_temp(:,2)).^2);        
        
        temp = find(dist < eps);
        if length(temp) > pts_id
            pts_id = length(temp);
            inliers_id = temp;
            H = H_temp;
        end
    end    
end
