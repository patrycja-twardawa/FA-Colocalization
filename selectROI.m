function binaryImage = selectROI(data1, str, data12CH, ch_coloc, ROI_main_ch, ...
    lh_lim_user, lh_lim_coloc_user, contrast_visual_flag, FA, colocalization)

try
    if (colocalization && any(ch_coloc == ROI_main_ch)) || (~colocalization && FA)
        disp("Manual ROI extraction started...")
        
        rgb_nam_tab = ["R", "G", "B"];
        d1_flag = 0;
        if FA
            data1ext = data1;
            disp("Image used for FOCAL ADHESIONS add-on will be used for manual ROI extraction.");
            if ~contrast_visual_flag
                data1disp = imadjust(data1, lh_lim_user);
                disp("Image with user contrast settings will be used for display.");
            end
            d1_flag = 1;
        elseif colocalization
            data1ext = data12CH(:,:,ROI_main_ch);
            disp(strcat("Image used for COLOCALIZATION add-on (main channel: ", rgb_nam_tab(ROI_main_ch), ") will be used for manual ROI extraction."));
            if ~contrast_visual_flag
                data1disp = imadjust(data12CH(:,:,ROI_main_ch), lh_lim_coloc_user);
                disp("Image with user contrast settings will be used for display.");
            end
            d1_flag = 1;
        end
    
        if d1_flag       
            prpt = strcat("Select ROI for ", str, ".");
            disp(prpt{:});

            figure(3);
            if ~contrast_visual_flag
                imshow(data1disp);
            else
                imshow(data1ext);
            end
            hFH = imfreehand();
            binaryImage = hFH.createMask();
            xy = hFH.getPosition;

            prpt2 = strcat("ROI ",  str, " chosen properly.");
            disp(prpt2{:});
            
            figure(1);
            imshow(binaryImage);
            title(strcat(str, " ROI extracted manually"));
            figure(2);
            add_overlay_ROI = cat(3, im2uint16(binaryImage), im2uint16(data1ext), im2uint16(binaryImage));
            imshow(add_overlay_ROI);
            title(strcat(str, "ROI over the cell image after contrast adjustment"));
        else
            binaryImage = [];
            disp("(E5) ERROR: No add-on selected. Choose either FOCAL ADHESIONS, COLOCALIZATION, or both. Check USER INPUT variables.");
        end     
    else
        binaryImage = [];
        disp("(E7) ERROR: Chosen channel for ROI extraction is not read due to USER'S choice. Please check USER INPUT variable section ('ROI_main_ch' variable).");
    end
catch
    binaryImage = [];
    prpt = strcat("(E10) ERROR: Failed attempt of ", str, " ROI choice. Check data and try again before proceeding further.");
    disp(prpt{:});
end

end