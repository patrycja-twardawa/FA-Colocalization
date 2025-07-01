function binaryImage = selectROI(data1, str, data12CH, ch_coloc, ROI_main_ch, FA, colocalization)

try
    if (colocalization && any(ch_coloc == ROI_main_ch)) || (~colocalization && FA)
        disp("Manual ROI extraction started...")
        
        rgb_nam_tab = ["R", "G", "B"];
        d1_flag = 0;
        if FA
            data1ext = data1;
            disp("Image used for FOCAL ADHESIONS add-on will be used for manual ROI extraction.");
            d1_flag = 1;
        elseif colocalization
            data1ext = data12CH(:,:,ROI_main_ch);
            disp(strcat("Image used for COLOCALIZATION add-on (main channel: ", rgb_nam_tab(ROI_main_ch), ") will be used for manual ROI extraction."));
            d1_flag = 1;
        end
    
        if d1_flag       
            prpt = strcat("Select ROI for ", str, ".");
            disp(prpt{:});

            figure(3);
            imshow(data1ext);
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
            title(strcat(str, "ROI and cell image after contrast adjustment comparison"));
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