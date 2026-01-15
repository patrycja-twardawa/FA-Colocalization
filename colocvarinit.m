function [name2CH, dataC2CH, info2CH, read_flag2CH, filepath2CH, data12CH, data12CH_ctr, data12CH_nucl, ...
    B6col, B6col_nucl, sum_map, sum_map_nucl, RGB_coloc, RGB_coloc_nucl, h, h_nucl, data_subtracted, ...
    data_subtracted_nucl, R_pearson, R_pearson_nucleus, R_spearman, R_spearman_nucleus, T, cMap1, ...
    cMap2, G_col] = colocvarinit

% BINARY MAPS
B6col = zeros([2048,2048], 'logical'); %stage 3 binary map after applying user ROI to segmentation image
B6col_nucl = zeros([2048,2048], 'logical'); %stage 3 binary map after applying user ROI for cell nucleus to segmentation image

% FLAGS & ITERATORS
read_flag2CH = [0, 0]; %0 - 1st/2nd channel image is empty, 1 - 1st/2nd channel image has been read

% IMAGES
dataC2CH = zeros([2048,2048,2], 'double'); %original image data for the 1st and 2nd chosen image channels
data12CH_ctr = zeros([2048,2048,2], 'double'); %image data before contrast adjustment for the 1st and 2nd chosen image channels
data12CH = zeros([2048,2048,2], 'double'); %image data after processing for the 1st and 2nd chosen image channels
data12CH_nucl = zeros([2048,2048], 'double'); %image of CELL NUCLEUS ROI after processing for the 1st and 2nd chosen image channels
G_col = zeros([2048,2048,2], 'double'); %image after filtering

sum_map = zeros([2048,2048], 'double'); %sum colocalisation map
sum_map_nucl = zeros([2048,2048], 'double'); %sum colocalisation map of cell nucleus
RGB_coloc = zeros([2048,2048], 'double'); %RGB colocalisation map
RGB_coloc_nucl = zeros([2048,2048], 'double'); %RGB colocalisation map of cell nucleus
h = zeros([2048,2048], 'double'); %hue colocalisation map
h_nucl = zeros([2048,2048], 'double'); %hue colocalisation map of cell nucleus
data_subtracted = zeros([2048,2048], 'double'); %subtraction colocalisation map
data_subtracted_nucl = zeros([2048,2048], 'double'); %subtraction colocalisation map of cell nucleus

% METADATA
info2CH = []; %metadata information for the 1st and 2nd chosen image channels

% NUMERIC DATA
R_pearson = 0; %Pearson's correlation coefficient for colocalisation detected on cell ROI area
R_pearson_nucleus = 0; %Pearson's correlation coefficient for colocalisation detected on cell nucleus area
R_spearman = 0; %Spearman's correlation coefficient for colocalisation detected on cell ROI area
R_spearman_nucleus = 0; %Spearman's correlation coefficient for colocalisation detected on cell nucleus area
T = []; %table with correlation coefficients for writing in target file

[cMap1, cMap2] = colormapprep; %colormap preparation for map legends

% STRING VARIABLES (NAMES, PATHS)
name2CH = ["", ""]; %names of files for the 1st and 2nd chosen image channels
filepath2CH = ""; %file paths for the 1st and 2nd chosen image channels

disp("Variables for COLOCALISATION add-on initialised.");

end