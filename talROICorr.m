function roi_matrix = talROICorr(data1, data12CH, ROI_main_ch, ch_coloc, itsty_lvl, roi_matrix, FA, colocalisation)

try
if any(ch_coloc == ROI_main_ch) 
    disp("ROI extraction started...")
    
    rgb_nam_tab = ["R", "G", "B"];
    d1_flag = 0;
    if FA
        data1ext = data1;
        disp("Image used for FA add-on will be used for automated ROI extraction.");
        d1_flag = 1;
    elseif colocalisation
        data1ext = data12CH(:,:,ROI_main_ch);
        disp(strcat("Image used for COLOCALIZATION add-on (main channel: ", rgb_nam_tab(ROI_main_ch), ") will be used for automated ROI extraction."));
        d1_flag = 1;
    else
        disp("(E5) ERROR: No add-on selected. Choose either FOCAL ADHESIONS, COLOCALIZATION, or both. Check USER INPUT variables.");
    end
    
    if d1_flag && (size(data1ext,1) > 10 && size(data1ext,2) > 10)
        sq = strel('sphere', 5);
        cond = itsty_lvl * max(mean(data1ext)); 
        if isempty(roi_matrix)
            roi_matrix = zeros(size(data1ext));
        end

        for i = 1 : size(data1ext,1) 
            for j = 1 : size(data1ext,2) 

                sq_dim = [5, 5, 5, 5]; 
                if (i <= 5) 
                    sq_dim(1) = i - 1;
                elseif (i > (size(data1ext,1) - 5))
                    sq_dim(2) = size(data1ext,1) - i;
                end	
                if (j <= 5)
                    sq_dim(3) = j - 1;
                elseif (j > (size(data1ext,2) - 5))
                    sq_dim(4) = size(data1ext,2) - j;
                end

                num_hits = numel(find(data1ext( i-sq_dim(1):i+sq_dim(2) , j-sq_dim(3):j+sq_dim(4) ) > ...
                    (itsty_lvl * cond) )); 

                if ( num_hits < (0.65 * sum(sq_dim(1:2)) * sum(sq_dim(3:4))) )
                    roi_matrix(i,j) = 0; 
                else
                    roi_matrix(i,j) = 1; 
                end

            end
        end

        roi_matrix = imfill(and(bwareaopen(roi_matrix,1), bwareaopen(roi_matrix, 500)), 'holes'); 
        roi_matrix = imclose(roi_matrix, sq); 

        [bndrs, labeled_image] = bwboundaries(roi_matrix, 'noholes');
        num_objects = max(max(labeled_image));

        if num_objects > 0
            area_measurement = regionprops('table', labeled_image, 'Area', 'Centroid');
            cell_loc = find([area_measurement.Area] == max([area_measurement.Area]));
            if numel(area_measurement) > 1
                rgb = label2rgb(labeled_image, 'hsv', [.5 .5 .5]);
                fig101 = figure(101); imshow(rgb); hold on;
                c_centr = [area_measurement.Centroid(:,2), area_measurement.Centroid(:,1)];
                plotetqts(c_centr, size(area_measurement, 1), 1);
                title("Choose cell area to be accepted as automatically selected CELL ROI."); 
                cell_loc = uint8(input("Select area number: "));
                if ( (cell_loc >= 1) && (cell_loc <= size(area_measurement, 1)) )
                    disp(strcat("You chose area No. ", num2str(cell_loc), " as CELL ROI."));
                else
                    cell_loc = find([area_measurement.Area] == max([area_measurement.Area]));
                    disp("(W5) WARNING: Your chosen CELL ROI area could not be accepted. Biggest area was chosen instead.");
                end
            end
            roi_matrix = imfill(and(roi_matrix, labeled_image == cell_loc), 'holes');
        else
            throw(exception);
        end

        figure(1);
        imshow(roi_matrix);
        title("CELL ROI extracted automatically");
        figure(2);
        add_overlay_ROI = cat(3, im2uint16(roi_matrix), im2uint16(data1ext), im2uint16(roi_matrix));
        imshow(add_overlay_ROI);
        title("CELL ROI and cell image after contrast adjustment comparison.");

        disp("Automated CELL ROI extraction has been performed successfully. Apply eventual changes manually, if necessary.");
    else
        roi_matrix = [];
        if dl_flag
            disp("(E6) ERROR: Image is too small for automated ROI correction. Try to perform CELL ROI choice manually.");
        end
    end
else
    disp("(E7) ERROR: Chosen channel for ROI extraction is not read due to USER'S choice. Please check USER INPUT variable section ('ROI_main_ch' variable).");
    roi_matrix = [];
end
catch
    roi_matrix = [];
    disp("(E9) ERROR: No object found. Automated CELL ROI extraction failed. Please, choose CELL ROI manually and check image data beforehand.");
end

end