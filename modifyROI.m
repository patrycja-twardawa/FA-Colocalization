function [Iout_ncirc, temp_Iout_ncirc, l, add_map, temp_add_map, varargout] = ...
    modifyROI(data1, data12CH, ROI_main_ch, ch_coloc, Iout_ncirc, mod_flag, add_map, temp_add_map, ...
    FA, colocalization, contrast_visual_flag, lh_lim_user, lh_lim_coloc_user, varargin)

try
    if (colocalization && any(ch_coloc == ROI_main_ch)) || (~colocalization && FA)
        disp("Manual ROI modification started...")

        rgb_nam_tab = ["R", "G", "B"];
        d1_flag = 0;
        if FA
            data1ext = data1;
            disp("Image used for FOCAL ADHESIONS add-on will be used for ROI modification.");
            if ~contrast_visual_flag
                data1disp = imadjust(data1, lh_lim_user);
                disp("Image with user contrast settings will be used for display.");
            end
            d1_flag = 1;
        elseif colocalization
            data1ext = data12CH(:,:,ROI_main_ch);
            if ~contrast_visual_flag
                data1disp = imadjust(data12CH(:,:,ROI_main_ch), lh_lim_coloc_user);
                disp("Image with user contrast settings will be used for display.");
            end
            disp(strcat("Image used for COLOCALIZATION add-on (main channel: ", rgb_nam_tab(ROI_main_ch), ") will be used for ROI modification."));
            d1_flag = 1;
        end

        if d1_flag       

            h = figure;
            loop_count = 1;
            set(h, 'WindowKeyPressFcn', {@KeyPressed, h}); 
            l = 1;
            break_flag = 0;
            temp_Iout_ncirc = Iout_ncirc;
            temp_add_map = add_map;
            if isempty(add_map)
                add_map = zeros(size(data1ext));
            end
            if ~isempty(varargin)
                Iout_circ = varargin{1}; 
                temp_Iout_circ = Iout_circ; 
                varargout{1} = Iout_circ;
                varargout{2} = temp_Iout_circ;
                s_del1 = "Choose area to be DELETED from ROI.";
                s_del2 = "Area has been DELETED from ROI.";
                s_add1 = "Choose area to be ADDED to ROI.";
                s_add2 = "Area has been ADDED to ROI.";
                s_fin = "ROI has been modified. Changes saved.";
                s_exc = "WARNING: ROI has not been modified. Check data and try again.";
            else
                s_del1 = "Choose area to be DELETED from CELL ROI (cell outline).";
                s_del2 = "Area has been DELETED from CELL ROI (cell outline).";
                s_add1 = "Choose area to be ADDED to CELL ROI (cell outline).";
                s_add2 = "Area has been ADDED to CELL ROI (cell outline).";
                s_fin = "CELL ROI (cell outline) has been modified. Changes saved.";
                s_exc = "WARNING: CELL ROI (cell outline) has not been modified. Check data and try again.";
            end

            if mod_flag
                disp(s_del1); 
            else
                disp(s_add1);
            end

            while loop_count
                add_overlay = cat(3, im2uint16(Iout_ncirc), im2uint16(data1ext), im2uint16(Iout_ncirc));
                if ~contrast_visual_flag
                   add_overlay_disp = cat(3, im2uint16(Iout_ncirc), im2uint16(data1disp), ...
                       im2uint16(Iout_ncirc));
                   imshow(add_overlay_disp); hold on;
                else
                   imshow(add_overlay); hold on;
                end
                roi = images.roi.AssistedFreehand('Color', 'y', 'MarkerSize', 3, ...
                    'LineWidth', 2);
                draw(roi);
                break_flag = 1;

                if mod_flag
                    Iout_ncirc(createMask(roi)) = 0;
                    add_map(createMask(roi)) = 0;
                    if ~isempty(varargin)
                        varargout{3} = add_overlay;
                    end
                    disp(s_del2);
                else
                    Iout_ncirc(createMask(roi)) = 1; 
                    add_map(createMask(roi)) = 1;
                    if ~isempty(varargin)
                        varargout{3} = add_overlay;
                    end
                    disp(s_add2);  
                end
            end
        else
            temp_Iout_ncirc = Iout_ncirc;
            l = [];
            disp("(E5) ERROR: No add-on selected. Choose either FA, COLOCALIZATION, or both. Check USER INPUT variables.");
        end
    else
        temp_Iout_ncirc = Iout_ncirc;
        l = [];
        disp("(E7) ERROR: Chosen channel for ROI extraction is not read due to USER'S choice. Please check USER INPUT variable section ('ROI_main_ch' variable).");
    end
        
catch
    if break_flag
        disp(s_fin);
    else
        disp(s_exc);
    end
end

end