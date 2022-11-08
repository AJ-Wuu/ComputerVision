function index_map = generateIndexMap(gray_stack, w_size)
    [H, W, N] = size(gray_stack);
    
    % Compute the focus measure -- the sum-modified laplacian
    %
    % horizontal Laplacian kernel
    Kx = [0.25 0 0.25;...
           1  -3   1; ...
          0.25 0 0.25];
    Ky = Kx';   % vertical version
    
    % horizontal and vertical Laplacian responses
    Lx = zeros(H, W, N);
    Ly = zeros(H, W, N);
    for n = 1:N
        I = im2double(gray_stack(:,:,n));
        Lx(:,:,n) = imfilter(I, Kx, 'replicate', 'same', 'corr');
        Ly(:,:,n) = imfilter(I, Ky, 'replicate', 'same', 'corr');
    end
    
    % sum-modified Laplacian
    SML = (abs(Lx) .^ 2) + (abs(Ly) .^ 2);
    % can also use the absolute value itself
    % this is probably more well-known
    % SML = abs(Lx) + abs(Ly);
    
    % find the layer with the maximal focus measure for each scene point
    index_map = uint8(zeros(H,W));
    smooth = movmean(SML, 0.4); % using moving average filter to remove noise
    [rows, cols, nums] = size(SML);
    for i = 1:rows
        for j = 1:cols
            max_index = 1; % choose the maximum focus measure as the best focused layer
            for k = 1:nums
                if (smooth(i,j,k) > smooth(i,j,max_index))
                    max_index = k;
                end
            end
            index_map(i,j) = max_index;
        end
    end
end