%%
% Title: CEST Pool Parameter Generation

% Description: This MATLAB script generates a set of CEST parameters for 
% up to five different pools, each with varying properties. 
% The script utilizes the previously developed phantom image generation 
% function to create a morphological image, which is then processed to 
% generate parameters for each pool. This is useful for simulating 
% different pool conditions and comparing their properties.

% Author: Ludger Radke

% Last modified: 23rd March 2023
%%
% Function to generate pool parameters
function [A, B, C, D, E, mask] = generate_pool_params(size)
    % Initialize an empty cell array for phantom images
    phantom = {};

    % Generate a morphological phantom image
    [morphological, ~] = generate_phantom([size, size], 200, 0);

    % Generate parameters for water pool A
    [A, mask] = gen_param(morphological, 0);
    morphological(mask == 0) = 0; 
    % Generate parameters for pools B, C, D, and E
    [B, ~] = gen_param(morphological, 0);
    [C, ~] = gen_param(morphological, 0);
    [D, ~] = gen_param(morphological, 0);
    [E, ~] = gen_param(morphological, 0);
end

% Function to generate pool parameters based on morphological phantom image
function [params, mask] = gen_param(morphological, water)
    % Initialize an empty struct to store pool parameters
    params = {};

    [img1, ~] = generate_phantom(size(morphological), 200, 1);
    img1(morphological == 0) = 0;
    % Loop through five iterations to generate R1, R2, kA, dw, and f parameters
    for i = 1:5

            img2 = img1;
            % Shift the intensity values of the phantom image to start from 0
    
            m = min(min(img1(img1 >0)));
            img2(img2 > 0) = img2(img2 > 0) - m;
            
            % Binarize the shifted image into 7 intensity levels
            m =  max(max(img2));
            img2(img2 > round(0.9 * m)) = 1;
            img2(img2 > round(0.7 * m)) = 2;
            img2(img2 > round(0.5 * m)) = 3;
            img2(img2 > round(0.4 * m)) = 4;
            img2(img2 > round(0.3 * m)) = 5;
            img2(img2 > round(0.2 * m)) = 6;
            img2(img2 > 6) = 7;
            % Randomly permute the binarized image
            v = randperm(7);
            mask = img2;
            for j = 1:7
                mask(img2 == j) = v(j);
            end
            mask(mask == 7) = 0;

            % Compute the parameter for each iteration
            param = (morphological .* (mask ./ 7)) + 1;
            if water
               param =  normalize(param, 0.1);
            else
                param =  normalize(param, 1);
            end
            param(param <0) = 0;
            % Assign the parameter to the struct using dynamic field assignment
            switch i
                case 1
                    params.R1 = param;
                case 2
                    params.R2 = 1 + 0.2 * param;
                case 3
                    params.kA = 1 + 0.2 * param;
                case 4
                    params.dw = 1 + 0.1 * param;
                case 5
                    params.f = param;
            end
   end
end

function array = normalize(array, std_target)
    % Compute the mean of non-zero elements in the array
    m = mean(array(array ~= 0));
    
    % Compute the standard deviation of non-zero elements in the array
    s = std(array(array ~= 0));

    % Normalize the non-zero elements in the array
    array(array ~= 0) = 1 + std_target * (array(array ~= 0) - m) / s;
end