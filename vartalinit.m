function [ring_flag, obj_del, bndrs, num_objects, mean_inten_all, mean_inten, min_inten, max_inten, temp, ...
    dataC, data1, int_rings_tab, B6, B6_nucl, labeled_image, ...
    dmode_l_im, ring_number, Iout_ncirc, Iout_circ, temp_Iout_ncirc, temp_Iout_circ, ir_rings, ...
    add_overlay, add_overlay_ir, ring_diameter, G_tal] = vartalinit

% FLAGS & ITERATORS
ring_flag = 0; %0 - unable to proceed with counting intensities withing rings of given diameter, 1 - proceed with counting
ring_number = 1; %number of chosen ring for display, counting from cell border towards cell interior

% NUMERIC DATA
obj_del = []; %object labels to be deleted during label merging
bndrs = []; %object borders by pixel coordinates, 1st column: rows in the image, 2nd column: cols in the image
num_objects = 0; %number of objects found in the image
ring_diameter = 1; %size of ring diameter, during intensity count through the rings from outer part of cell to the inside (on user ROI)

mean_inten_all = []; %mean intensity for all found structures together
mean_inten = []; %array of mean intensities for all found objects
min_inten = []; %minimal intensity found in all objects in the image (background excluded)
max_inten = []; %maximal intensity found in all objects in the image
temp = []; %main structure filled with data regarding objects: area, centroid, major & minor axis length, orientation, circularity, perimeter, weighted centroid, GoI, status (included / excluded in ncirc image)
int_rings_tab = []; %structure preserving the data about intensities and areas of cell perimeters of given width [ring_diameter] while eroding into the inside

% IMAGES
dataC = zeros([2048,2048], 'uint16'); %stage 0 original image, all channels
data1 = zeros([2048,2048], 'double'); %stage 2 selected image channel after contrast adjustment

%B1 = zeros([2048,2048], 'double'); %stage 3 image after NN-assisted denoising
%B3 = zeros([2048,2048], 'double'); %stage 4 image after despeckling (and background subtraction if ON)
G_tal = zeros([2048,2048], 'double'); %stage 5 image after filtering
%J = zeros([2048,2048], 'double'); %stage 6 image with enhanced fibers (width can be adjusted), Hessian-based multiscaled filtering

add_overlay = zeros([2048,2048], 'double'); %display of cell area and chosen binary map overlay
add_overlay_ir = zeros([2048,2048], 'double'); %overlay of cell area and chosen binary mask of chosen ring area, with number of ring area being [ring_number]

% BINARY MAPS
B6 = zeros([2048,2048], 'logical'); %stage 3 binary map after applying user ROI to segmentation image
B6_nucl = zeros([2048,2048], 'logical'); %stage 3 binary map after applying user ROI for cell nucleus to segmentation image

Iout_ncirc = zeros([2048,2048], 'logical'); %stage 4 binary map after segmentation and assessment of non-circular objects, main binary mask
Iout_circ = zeros([2048,2048], 'logical'); %stage 4 binary map of circular objects assigned for removal from main mask
temp_Iout_ncirc = zeros([2048,2048], 'logical'); %stage 4 binary map, copy of Iout_ncirc mask for UNDO / REDO operations
temp_Iout_circ = zeros([2048,2048], 'logical'); %stage 4 binary map, copy of Iout_circ mask for UNDO / REDO operations
labeled_image = zeros([2048,2048], 'logical'); %stage 4 label map
dmode_l_im = zeros([2048,2048], 'logical'); %stage 4 label map with black background

ir_rings = []; %3D array of binary maps assigned for consecutive ring areas - number of Z-axis layer is attributed to [ring_number] value

disp("Variables for FOCAL ADHESIONS add-on initialised.");

end