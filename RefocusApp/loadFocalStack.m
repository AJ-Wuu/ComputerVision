function [rgb_stack, gray_stack] = loadFocalStack(focal_stack_dir)
    % dir lists files and folders in the current folder
    % fullfile returns the full path to the file
    listing = dir(fullfile(focal_stack_dir, '*.jpg'));
    pics = {listing.name};
    total = length(pics);
    [height, width, ~] = size(imread(fullfile(focal_stack_dir, pics{1})));

    rgb_stack = uint8(zeros(height, width, 3 * total));
    gray_stack = uint8(zeros(height, width, total));
    for i = 1:total
        pic = imread(fullfile(focal_stack_dir, pics{i}));
        rgb_stack(:, :, 3*(i-1)+1 : 3*i) = pic;
        gray_stack(:, :, i) = rgb2gray(pic);
    end
end
