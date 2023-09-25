
%%
% Title: Main Function for 2D CEST Data Generation

% Description: This is the main MATLAB script responsible for generating 2D CEST data. 
% Initially, random 2D phantoms are created; based on these phantoms, scanner, and pool parameters, 
% this script determines the Z-spectra for each pixel following the framework developed by Zaiss et al. 
% Each resulting Z-spectrum is saved as a Nifti file. This script is crucial for the evaluation 
% and analysis of synthetic data in CEST imaging studies, enabling detailed examination of 
% image processing and analysis techniques.
%%
% clc;
clear all;
close all;
rng('shuffle');

% Define root data folder in a system-independent way
currentPath = pwd;
root_data_folder = fullfile(pwd, 'Generate_data');
try
    rmdir(root_data_folder, 's');
catch
end
mkdir(root_data_folder);

numIterations = 400;
h = waitbar(0, 'Initializing...');

for k = 1:numIterations
    % Generate random scanner parameters
    Scanner_parameter.tp = randi([20,100]);          % tp = 20 - 100 ms;
    Scanner_parameter.TE = randi([20,40]) / 1000;    % TE in seconds
    Scanner_parameter.TR = randi([60,120]) / 1000;   % TR in seconds
    Scanner_parameter.B1 = randi([20,80]) / 100;     % B1 = 0.4 - 2.2 µT
    Scanner_parameter.Trec = randi([20,30]) / 10;    % Trec in seconds
    Scanner_parameter.n = randi([8,20]);             % Number of excitations
    Scanner_parameter.ppm_range = randi([3,6]);      % Chemical shift range in ppm
    
    [A, B, C, D, E, mask] = generate_pool_params(128); % Generate pool parameters
    dyn = 100; % Assuming dyn is a constant, you need to specify its value
    image = zeros(size(A.R1,1), size(A.R1,2), 1, dyn);
    
    for j = 1:max(max(mask))
        [x, y] = find(mask == j);
        CEST_Parameter = generate_Params(5, Scanner_parameter.ppm_range);
        
        for i = 1:numel(x)
            pixel_CEST_Parameter = update_pixel_params(CEST_Parameter, A, B, C, D, E, x(i), y(i));
            
            % Updating pool parameters for each pixel
            [A, B, C, D, E] = update_pools(A, B, C, D, E, pixel_CEST_Parameter, x(i), y(i));
            
            [Z, ppm] = generate_Z_spectrum(Scanner_parameter, pixel_CEST_Parameter, dyn);
            image(x(i), y(i), 1, :) = Z;
        end
    end
    
    % Save data for each iteration
    if k < 100
        iteration_folder = fullfile(root_data_folder, num2str(k));
        mkdir(iteration_folder);
        save_maps(A, B, C, D, E, mask, iteration_folder);
    end
    
    niftiwrite(int16(image * 4016), fullfile(root_data_folder, [num2str(k) '.nii']), 'Compressed', false);
    waitbar(k / numIterations, h, sprintf('Processing iteration %d of %d', k, numIterations));
end
close(h)
