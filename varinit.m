function [filepath, save_default_name, fn, fp, info, read_flag, param_flag, binaryImage, binaryImage2, ...
    temp_binaryImage, px_size, px_flag, add_map, temp_add_map, lh_lim_count, matfileread_flag] = varinit

% STRING VARIABLES (NAMES, PATHS)
filepath = ""; %default file path for data save after execution of script
save_default_name = ""; %default name suffix for data save after execution of script
fn = ""; %name of read image file
fp = ""; %path to the directory of read image file

info = []; %info about TIFF file, if provided

% FLAGS & ITERATORS
matfileread_flag = 0; %0 - no .MAT data repository included, 1 - data read from .MAT repository
param_flag = 0; %0 - unable to proceed with labelling (after image processing), 1 - proceed with labelling
px_flag = 0; %0 - disallow recounting from px to real distance units, 1 - allow recounting from px to real distance units
read_flag = 0; %0 - image file not read, 1 - image file read

% NUMERIC DATA
lh_lim_count = [0.1, 0.9]; %contrast limit default for automated contrast detection
px_size = []; %size of pixel expressed in um (scale information)

% BINARY MAPS
binaryImage = zeros(2048,2048); %stage 0 binary map of all structures in ROI
binaryImage2 = zeros(2048,2048); %stage 0 binary map of all structures in cell nucleus ROI
temp_binaryImage = zeros(2048,2048); %stage 0 binary map, copy of binaryImage for UNDO / REDO operations
add_map = zeros(2048,2048); %binary map representing the places added by user
temp_add_map = zeros(2048,2048); %copy of add_map for UNDO / REDO operations

disp("Common variables initialised.");

end