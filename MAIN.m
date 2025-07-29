% FOCAL ADHESIONS & COLOCALIZATION
%
% Run accordingly with section order. Modifications in user sections are optional but may improve script operation. 
% Default values adjusted for enhancement of long fibers and cells with low number of small FA / NA structures.
%
% Choose the operation mode below, to enable selected script add-ons.
%
% Insert modifications only by changing values of parameters. Please, do
% not modify parameter names, or any statements outside of "USER INPUT"
% sections, or parameters labeled as non-modifiable within the "USER INPUT" sections.

%% BEGIN HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VARIABLE INITIALIZATION / RESET (non-adjustable variables)

clc; clear; close all; %RESET

[filepath, save_default_name, fn, fp, info, read_flag, param_flag, binaryImage, binaryImage2, ...
    temp_binaryImage, px_size, px_flag, add_map, temp_add_map, lh_lim_count, matfileread_flag] = varinit;

[ring_flag, obj_del, bndrs, num_objects, mean_inten_all, mean_inten, min_inten, max_inten, temp, ...
    dataC, data1, int_rings_tab, B6, B6_nucl, labeled_image, ...
    dmode_l_im, ring_number, Iout_ncirc, Iout_circ, temp_Iout_ncirc, temp_Iout_circ, ir_rings, ...
    add_overlay, add_overlay_ir, ring_diameter, G_tal] = vartalinit;

[name2CH, dataC2CH, info2CH, read_flag2CH, filepath2CH, data12CH, data12CH_nucl, B6col, B6col_nucl, ...
    sum_map, sum_map_nucl, RGB_coloc, RGB_coloc_nucl, h, h_nucl, data_subtracted, data_subtracted_nucl, ...
    R_pearson, R_pearson_nucleus, R_spearman, R_spearman_nucleus, T, cMap1, cMap2, G_col] = colocvarinit;

%% ADJUSTABLE PARAMETER VALUES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ADD-ON CHOICE (USER INPUT)
% Please ensure that at least one add-on is selected. 
% Without making any selection, script will not proceed correctly.

FA = 1;                 %FOCAL ADHESIONS ADD-ON (ON/OFF): 0 - focal adhesions segmentation and feature extraction OFF, 1 - focal adhesions segmentation and feature extraction ON (1 image channel required)
colocalization = 1;     %COLOCALIZATION ADD-ON (ON/OFF): 0 - colocalization maps preparation OFF, 1 - colocalization maps preparation ON (2 image channels required)

%% OPTIONS (USER INPUT)
% Only variables needed to proceed sections attributed for selected add-ons will be written into workspace.

% COMMON FEATURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% METHOD EXECUTION FLAGS (ON / OFF)
auto_roi_flag = 1;          %Extraction of ROI method (AUTO [1]/ USER [0]): 0 - choose cell ROI manually, 1 - choose cell ROI automatically
contrast_flag = 0;          %Contrast adjustment method (AUTO [0-1] / USER [2]): 0 - applied automated limits for image analysis (independent of visualisation for ROI selection), 1 - applied automated Otsu contrast limits for image analysis, 2 - applied user-chosen contrast limits for contrast adjustment
contrast_visual_flag = 0;   %0 – contrast settings defined by automated adjustment or specified in lh_lim_tal or lh_lim_coloc will be used for both calculations and visualization; 1 – contrast settings defined in lh_lim_tal_user or lh_lim_coloc_user will be used for visualization only, while those in lh_lim_tal or lh_lim_coloc / automatic contrast will be used for calculations
denoise_flag = 1;           %0 - denoising OFF, 1 - CNN-assisted denoising ON (denoising helps in achieving better effects, but radically increases operation time of script); 2 - morphological operations-based denoising ON
rb_flag = 0;                %0 - background subtraction OFF, 1 - background subtraction ON
filt_flag = 2;              %0 - bilateral filtering with high smoothing degree, 1 - Gaussian filtering, 2 - bilateral filtering with degree of smoothing larger than variance of the noise, 3 - Savitzky-Golay filtering with low order and small frame
manualcorr_flag = 0;        %0 - all user's additions to the ROI override the classificator condition and are included in final map, 1 - user's additions to the ROI undergo classification and are excluded from label map if not meeting classification criteria
ring_hole_flag = 0;         %0 - holes in the cell body will be ignored and included in the 'ring areas', 1 - holes in the cell body will be enveloped by the 'ring areas'

% METHOD VARIANT CHOICE
binarization_met = 3; %0 - adaptive segmentation (low sensitivity); 1 - global segmentation (user threshold); 2 - adaptive segmentation (auto sensitivity); 3 - global segmentation (auto Otsu threshold)
rb_method = 0; %0 - rolling ball radius method, 1 - morph. opening method

% IMAGE PROCESSING PARAMETERS
se = strel('disk', 2); %structural element size for morphological operations - smaller window gives less of "structure shape deluge"
gauss_sd = 3; %standard deviation for square structural element (Gaussian filtration)
rb_thresh = 2; %size of radius for rolling ball radius background subtraction algorithm (higher values - more visible structures, less px assigned to background)

% SEGMENTATION & CLASSIFICATION PARAMETERS
segm_threshold = 0.45; %threshold for global segmentation (cutoff below segm_threshold * 100% max intensity)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FOCAL ADHESIONS ADD-ON %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMAGE CHANNEL CHOICE
ch_tal = 2; %Channel of choice: 1 - R, 2 - G, 3 - B (1 image channel required, variable used in the case of RGB image input)

% IMAGE PROCESSING PARAMETERS
lh_lim_tal = [0.02, 0.45]; %lower and upper intensity limits (0-1), under or over which intensities are scaled as min / max
lh_lim_tal_user = [0.02, 0.45]; %lower and upper intensity limits (0-1), used only for USER display
ring_diameter_um = 1; %default size of the ring width in um

% SEGMENTATION & CLASSIFICATION PARAMETERS
obj_area_thresh_itsty = 110; %minimal number of px assigned to objects (object selection), for objects of intensity above set level [itsty_lvl]
obj_area_thresh_circ_itsty = 130; %minimal number of px assigned to larger circular objects (object selection), for objects of intensity above set level [itsty_lvl]
obj_area_thresh = 150; %minimal number of px assigned to objects (object selection, regardless of other factor)
circ_param = 0.7; %circularity threshold (lower value - more of circular objects accepted in fiber "ncirc" map; 0.7 is the default value to cut single pixels but not 2-px and larger fibers)
itsty_lvl = 0.8; %intensity threshold (elimination of objects based on the intensity criterium, cutoff below values < itsty_lvl * 100% max intensity)
itsty_lvl_ROI = 0.4; %minimal intensity level threshold for pixel acceptance to count as neighborhood in CELL ROI
ratio_lvl = 2.0; %object dimensional ratio threshold (elimination based on the ratio of dimensions, cutoff for largest "diameter" divided by smallest "diameter < ratio_lvl

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% COLOCALIZATION ADD-ON %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% IMAGE CHANNELS CHOICE
ch_coloc = [1, 2]; %1 - R, 2 - G, 3 - B (2 image channels required, variable used in the case of RGB image input)
ROI_main_ch = 2; %number of channel for which CELL ROI will be extracted, if focal adhesions add-on is off

% IMAGE PROCESSING PARAMETERS
lh_lim_coloc = [0.02, 0.6, 0.02, 0.6]; %lower and upper intensity limits (0-1) [1st image low & high, 2nd image low & high], under or over which intensities are scaled as min / max
lh_lim_coloc_user = [0.02, 0.6; 0.02, 0.6]; %lower and upper intensity limits (0-1) [1st image low & high, 2nd image low & high], used only for USER display

% DISPLAY FEATURES
labels_cbar = {'CH1 intensity MAX', 'Equal intensity', 'CH2 intensity MAX'}; %label for tested proteins (G channel on left, R on right - names will be displayed for map legends)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTICE: After this section you can proceed with either .MAT file data read or image read.
% NOTICE: All sections below can proceed autonomously without user input 
% (if auto-ROI choice is selected), however the cell nucleus area 
% will not be extracted automatically and related images will turn empty.

disp("USER INPUT variables initialized."); %do not modify this statement

% END OF SECTION FOR MODIFICATION / USER INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% IMAGE DATA READ
% WARNING: Please, re-initialize the variables in the sections above before the new image read.
% WARNING (focal adhesions add-on): Run DATA READ FROM .MAT FILE only in the case when workspace variable copy 
% from previous analysis exists. Image read may not be necessary. 

[name2CH, info2CH, read_flag2CH, filepath2CH, dataC2CH, data12CH, sum_map, ...
    save_default_name, info, read_flag, filepath, dataC, data1, px_size, px_flag, ring_diameter] = ...
        readfilext(ch_coloc, read_flag, ch_tal, ring_diameter_um, name2CH, info2CH, ...
        read_flag2CH, filepath2CH, dataC2CH, data12CH, sum_map, save_default_name, info, ...
        read_flag, filepath, dataC, data1, px_size, px_flag, ring_diameter, FA, colocalization);

%% CONTRAST ADJUSTMENT
% NOTICE: Section execution may be repeated many times before proceeding.
% Each change demands reloading and changing contrast settings in the sections above.

[data12CH, data1] = contrAdjust(lh_lim, lh_lim_user, lh_lim_coloc, lh_lim_coloc_user, ...
    data12CH, data1, contrast_flag, contrast_visual_flag, FA, colocalization); %do not modify this statement, or the statements below

%% AUTO CHOICE OF ROI
% WARNING: Cell nucleus ROI is not extracted with the automated procedure. If you
% intend to add this, use manual clause in the section below.

binaryImage = talROICorr(data1, data12CH, ROI_main_ch, ch_coloc, itsty_lvl, binaryImage, FA, colocalization); %do not modify this statement, or the statements below

%% USER INPUT SECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CELL ROI CHOICE / MODIFICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTICE: If automatic USER ROI choice fails or gives unsatisfactory results, user may choose cell outline 
% manually (MANUAL CHOICE OF ROI section) and correct the choice afterwards.
% NOTICE: DO NOT MODIFY the entries to functions or statements below.
% Interact with script only by running certain sections and operating on displayed windows.

%% CELL ROI CHOICE: MANUAL CHOICE OF CELL ROI
% Use this section to choose CELL ROI, if AUTO CHOICE OF ROI gave unsatisfactory results.
% WARNING: Selecting this section will overwrite automatically chosen CELL
% ROI. You can run AUTO CHOICE OF ROI section again to retrieve former result.

binaryImage = selectROI(data1, "CELL", data12CH, ch_coloc, ROI_main_ch, ...
    lh_lim_user, lh_lim_coloc_user, contrast_visual_flag, FA, colocalization); %do not modify this statement, or the statements below

%% CELL ROI CHOICE: MANUAL CHOICE OF CELL NUCLEUS ROI
% Use this section to choose CELL NUCLEUS ROI.
% WARNING: The cell nucleus area can be extracted only manually.

binaryImage2 = selectROI(data1, "CELL NUCLEUS", data12CH, ch_coloc, ROI_main_ch, ...
    lh_lim_user, lh_lim_coloc_user, contrast_visual_flag, FA, colocalization); %do not modify this statement, or the statements below

%% CELL ROI MODIFICATION: MANUAL CORRECTION OF ROI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTICE: During one session (one window opening) user can add or subtract multiple areas from CELL ROI 
% (double LM button click). During UNDO / REDO operation, only objects from last session of adding / 
% subtracting will be removed / added again.

%% DELETE OBJECTS FROM CELL ROI
% Use this section to delete chosen areas from CELL ROI.
% INFO: PRESS ANY KEY TO CLOSE THE WINDOW AND SAVE RESULTS

[binaryImage, temp_binaryImage, l, add_map, temp_add_map] = modifyROI(data1, data12CH, ...
    ROI_main_ch, ch_coloc, binaryImage, 1, add_map, temp_add_map, FA, colocalization, ...
    contrast_visual_flag, lh_lim_user, lh_lim_coloc_user); %do not modify this statement, or the statements above / below

%% ADD OBJECTS TO CELL ROI
% Use this section to add chosen areas to CELL ROI.
% INFO: PRESS ANY KEY TO CLOSE THE WINDOW AND SAVE RESULTS

[binaryImage, temp_binaryImage, l, add_map, temp_add_map] = modifyROI(data1, data12CH, ...
    ROI_main_ch, ch_coloc, binaryImage, 0, add_map, temp_add_map, FA, colocalization, ...
    contrast_visual_flag, lh_lim_user, lh_lim_coloc_user); %do not modify this statement, or the statements above / below

%% UNDO / REDO CELL ROI MANUAL CHANGES
% When you run this section and last operation was UNDO, the next will be REDO.
% You can UNDO and REDO only the last session of deleting / adding objects to ROI multiple times
% After making new selections for DELETING or ADDING objects, data undergoes reset and previous steps 
% will not be available anymore. 

[binaryImage, temp_binaryImage, l, add_map, temp_add_map] = ...
    talUndoRepeat(data1, data12CH, ROI_main_ch, ch_coloc, binaryImage, temp_binaryImage, l, ...
    add_map, temp_add_map, FA, colocalization, contrast_visual_flag, lh_lim_user, ...
    lh_lim_coloc_user); %do not modify this statement, or the statements above / below

% END OF SECTION FOR MODIFICATION / USER INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% IMAGE PROCESSING, SEGMENTATION

[B6, B6_nucl, param_flag, B6col, B6col_nucl, G_tal, G_col] = ...
    tcimprocess(data1, data12CH, ch_coloc, se, denoise_flag, filt_flag, rb_flag, rb_method, ...
    rb_thresh, gauss_sd, binarization_met, segm_threshold, binaryImage, binaryImage2, B6, B6_nucl, ...
    B6col, B6col_nucl, FA, colocalization, param_flag); %do not modify this statement, or the statements above / below

%% COLOCALIZATION ADD-ON | MAP PREPARATION & SEGMENTATION 
% NOTICE: Feature available only for COLOCALIZATION add-on.

if colocalization
    [sum_map, sum_map_nucl, RGB, RGB_nucl, h, h_nucl, data_subtracted, data_subtracted_nucl] = ...
        colocPrepareMaps(data12CH, ch_coloc, B6col, B6col_nucl, name2CH, filepath2CH, ...
        cMap1, cMap2, labels_cbar); %do not modify this statement, or the statements above / below
end

%% COLOCALIZATION ADD-ON | CORRELATION COEFFICIENT CALCULATION
% NOTICE: Feature available only for COLOCALIZATION add-on.

if colocalization
    [R_pearson, R_pearson_nucleus, R_spearman, R_spearman_nucleus, T] = ...
        colCoefCalc(data12CH, ch_coloc, B6col, B6col_nucl, filepath2CH, name2CH); %do not modify this statement, or the statements above / below
end

%% FOCAL ADHESIONS ADD-ON | COUNTING INTENSITY IN THE BANDS OF GIVEN DIAMETER
% NOTICE: Feature available only for FOCAL ADHESIONS add-on.

if FA
    [int_rings_tab, ir_rings] = talCountIntRings(binaryImage, dataC, int_rings_tab, ring_diameter, 1, []); %do not modify this statement, or the statements above / below
end

%% FOCAL ADHESIONS ADD-ON | USER CHOICE: DISPLAY CHOSEN RING AREA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTICE: Feature available only for FOCAL ADHESIONS add-on.
% NOTICE: Choose ring number to be displayed. By default, first ring (for outer cell border) 
% is displayed. Change [ring_number] variable to move closer to the interior.
% WARNING: Maximal [ring_number] is size of z-dimension of [ir_rings]. Going over max size will result in exception throw.

% HERE: add number of ring designation for faster initialization display
if FA
    talDispRings(data1, ir_rings, ring_number, contrast_visual_flag, lh_lim_user); %do not modify this statement, or the statements above / below
end

% END OF SECTION FOR MODIFICATION / USER INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% FOCAL ADHESIONS ADD-ON | OBJECT SELECTION & PARAMETER ESTIMATION (1)
% NOTICE: Feature available only for FOCAL ADHESIONS add-on.
% NOTICE: Gradient is understood as ratio of intensity difference between intensity
% centroid and closest edge intensity to distance between centroid and closest edge.

if FA
    [bndrs, dmode_l_im, num_objects, temp, t_centr, mean_inten_all, mean_inten, min_inten, max_inten, ...
        Iout_ncirc, Iout_circ, labeled_im, labeled_im_circ, obj_del, distances, labeled_im_nucleus, ...
        labeled_im_cytoplasm] = ...
        talCountParams(dataC, G_tal, imclose(B6, strel('sphere', 1)), binaryImage2, param_flag, ...
        circ_param, obj_area_thresh_circ_itsty, itsty_lvl, obj_area_thresh_itsty, obj_area_thresh, ...
        add_map, manualcorr_flag); %do not modify this statement, or the statements above / below
end

%% FOCAL ADHESIONS ADD-ON | ROI MODIFICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTICE: Feature available only for FOCAL ADHESIONS add-on.
% NOTICE: During one session user can add or subtract multiple areas from SEGMENTATION ROI 
% (double LM button click). During UNDO / REDO operation, only objects from last session of adding / 
% subtracting will be removed / added again.
% NOTICE: All steps below this section have to be repeated if user decides to modify ROI again.

% PRESS ANY KEY TO CLOSE THE WINDOW AND SAVE RESULTS

%% FOCAL ADHESIONS ADD-ON | DELETE OBJECTS FROM SEGMENTATION ROI
% Use this section to delete chosen areas from SEGMENTATION ROI.
% INFO: PRESS ANY KEY TO CLOSE THE WINDOW AND SAVE RESULTS

if FA
    [Iout_ncirc, temp_Iout_ncirc, l, add_map, temp_add_map, Iout_circ, temp_Iout_circ, add_overlay] = ...
        modifyROI(data1, data12CH, ROI_main_ch, ch_coloc, Iout_ncirc, 1, add_map, temp_add_map, ...
        FA, colocalization, Iout_circ); %do not modify this statement, or the statements above / below
end

%% FOCAL ADHESIONS ADD-ON | ADD OBJECTS TO SEGMENTATION ROI
% Use this section to add chosen areas to SEGMENTATION ROI.
% INFO: PRESS ANY KEY TO CLOSE THE WINDOW AND SAVE RESULTS

if FA
    [Iout_ncirc, temp_Iout_ncirc, l, add_map, temp_add_map, Iout_circ, temp_Iout_circ, add_overlay] = ...
        modifyROI(data1, data12CH, ROI_main_ch, ch_coloc, Iout_ncirc, 0, add_map, temp_add_map, ...
        FA, colocalization, Iout_circ); %do not modify this statement, or the statements above / below
end

%% FOCAL ADHESIONS ADD-ON | UNDO / REDO FOR SEGMENTATION ROI
% When you run this section and last operation was UNDO, the next will be REDO.
% You can UNDO and REDO only the last session of deleting / adding objects to ROI multiple times
% After making new selections for DELETING or ADDING objects, data undergoes reset and previous steps 
% will not be available anymore. 

if FA
    [Iout_ncirc, temp_Iout_ncirc, l, add_map, temp_add_map, Iout_circ, temp_Iout_circ, add_overlay] = ...
        talUndoRepeat(data1, data12CH, ROI_main_ch, ch_coloc, Iout_ncirc, temp_Iout_ncirc, l, add_map, ...
        temp_add_map, FA, colocalization, Iout_circ, temp_Iout_circ); %do not modify this statement, or the statements above / below
end

% END OF SECTION FOR MODIFICATION / USER INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% FOCAL ADHESIONS ADD-ON | OBJECT SELECTION & PARAMETER ESTIMATION (2)
% IMPORTANT NOTICE: Use if you made manual corrections to SEGMENTATION ROI.
% NOTICE: Feature available only for FOCAL ADHESIONS add-on.
% NOTICE: Gradient is understood as ratio of intensity difference between intensity
% centroid and closest edge intensity to distance between centroid and closest edge.

if FA
    [bndrs, dmode_l_im, num_objects, temp, t_centr, mean_inten_all, mean_inten, min_inten, max_inten, ...
        Iout_ncirc, Iout_circ, labeled_im, labeled_im_circ, obj_del, distances, labeled_im_nucleus, ...
        labeled_im_cytoplasm] = ...
        talCountParams(dataC, G_tal, Iout_ncirc, binaryImage2, param_flag, circ_param, ...
        obj_area_thresh_circ_itsty, itsty_lvl, obj_area_thresh_itsty, obj_area_thresh, add_map, ...
        manualcorr_flag); %do not modify this statement, or the statements above / below
end

%% FOCAL ADHESIONS ADD-ON | LABELS MODIFICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTICE: Feature available only for FOCAL ADHESIONS add-on.
% NOTICE: You can merge labels multiple times until satisfactory effect is reached.
% NOTICE: As of current version YOU CANNOT UNDO label merge results. 
% To begin anew, run OBJECT PARAMETER ESTIMATION (2).

% PRESS ANY KEY TO CLOSE THE WINDOW AND SAVE RESULTS

%% FOCAL ADHESIONS ADD-ON | CONNECTING LABELS / MERGING OBJECTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use this section to merge labels of objects that have been divided after segmentation.
% INFO: PRESS ANY KEY TO CLOSE THE WINDOW AND SAVE RESULTS

if FA
    [labeled_im, bndrs, obj_del, temp, mean_inten, max_inten, min_inten, mean_inten_all, t_centr, ...
        num_objects] = talLabelConnect(temp, G_tal, labeled_im, bndrs, dataC, [], mean_inten, max_inten, ...
        min_inten, mean_inten_all, num_objects, []); %do not modify this statement, or the statements above / below

    [distances, temp] = talRatioGoI(num_objects, bndrs, temp, dataC); %do not modify this statement, or the statements above / below

    [labeled_im_nucleus, labeled_im_cytoplasm, temp] = talFindAboveNucleus(labeled_im, ...
        num_objects, binaryImage2, temp); %do not modify this statement, or the statements above / below
end

% END OF SECTION FOR MODIFICATION / USER INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% FOCAL ADHESIONS ADD-ON | COUNT NUMBER OF OBJECTS CUTTING THROUGH BANDS OF GIVEN DIAMETER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use this section to count the number of objects that cut through the estimated "rings", to obtain 
% the statistics for objects located at certain distance from cell interior
% (along with their intensity assessment in relation to distance from cell interior).
% NOTICE: Feature available only for FOCAL ADHESIONS add-on.

if FA
    [int_rings_tab] = talCountIntRings(binaryImage, dataC, int_rings_tab, ...
        ring_diameter, 0, labeled_im, Iout_ncirc); %do not modify this statement, or the statements above / below
end

%% FOCAL ADHESIONS ADD-ON | CHANGE PX DISTANCES TO REAL SIZE UNITS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use this section to convert the distances in PX to real size units based on pixel size 
% read from image file metadata.
% NOTICE: Operation can be called only once. Be sure to proceed if all necessary corrections have been made. 
% NOTICE: Feature available only for FOCAL ADHESIONS add-on.

if FA
    [px_size, px_flag, temp, int_rings_tab] = talPxTransfer(temp, int_rings_tab, px_size, px_flag); %do not modify this statement, or the statements above / below
end

%% FOCAL ADHESIONS ADD-ON | RESULTS DISPLAY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use this section to display the images and binary / label maps.
% NOTICE: You can run section multiple times / after label or ROI corrections. Data will be overwritten.
% NOTICE: Feature available only for FOCAL ADHESIONS add-on.

if FA
    talDisplayAll(data1, ch_tal, Iout_circ, Iout_ncirc, bndrs, temp, labeled_im, int_rings_tab, ...
        ring_diameter, px_size, t_centr, labeled_im_nucleus, labeled_im_cytoplasm, filepath, ...
        save_default_name); %do not modify this statement, or the statements above / below
end

%% FOCAL ADHESIONS ADD-ON | SAVE RESULTS TO SPREADSHEET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use this section to write all numeric data to MS EXCEL spreadsheet.
% NOTICE: You can run section multiple times / after label or ROI corrections. Data will be overwritten.
% NOTICE: Feature available only for FOCAL ADHESIONS add-on.

%HERE only fa addon?
if FA
    writetable(temp, strcat(filepath, save_default_name, ".xlsx"), 'Sheet', 'Object data');
    writetable(int_rings_tab, strcat(filepath, save_default_name, ".xlsx"), 'Sheet', 'Ring data');
    save(strcat(filepath, 'BinaryMaps-', save_default_name)); %do not modify this statement, or the statements above / below

    disp(strcat("Result file has been written to MS Excel file. Filename: ", filepath, save_default_name, ".xlsx")); %do not modify this statement, or the statements above / below
end

%% END OF SCRIPT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%