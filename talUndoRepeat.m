function [Iout_ncirc, temp_Iout_ncirc, l, add_map, temp_add_map, varargout] = ...
    talUndoRepeat(data1, data12CH, ROI_main_ch, ch_coloc, Iout_ncirc_old, temp_Iout_ncirc_old, l, ...
    add_map_old, temp_add_map_old, FA, colocalization, contrast_visual_flag, lh_lim_user, ...
    lh_lim_coloc_user, varargin)

try
    if (colocalization && any(ch_coloc == ROI_main_ch)) || (~colocalization && FA)

        d1_flag = 0;
        if FA
            data1ext = data1;
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
            d1_flag = 1;
        end

        if d1_flag      

            temp_Iout_ncirc = Iout_ncirc_old;
            Iout_ncirc = temp_Iout_ncirc_old;
            temp_add_map = add_map_old;
            add_map = temp_add_map_old;

            if ~isempty(varargin)
                varargout{1} = varargin{2};
                varargout{2} = varargin{1};
            end
            l = not(l);

            fig202 = figure(202);
            add_overlay = cat(3, im2uint16(Iout_ncirc), im2uint16(data1ext), im2uint16(Iout_ncirc));
            if ~contrast_visual_flag
               add_overlay_disp = cat(3, im2uint16(Iout_ncirc), im2uint16(data1disp), ...
                   im2uint16(Iout_ncirc));
               imshow(add_overlay_disp); hold on;
            else
               imshow(add_overlay); hold on;
            end
            if ~isempty(varargin)
                varargout{3} = add_overlay;
            end

            if l
                title(fig202, "REDO processed");
                disp("REDO operation processed. Binary maps prepared during previous USER-assisted modification were retrieved.");
            else
                title(fig202, "UNDO processed");
                disp("UNDO operation processed. Binary maps from before USER-assisted modification were retrieved.");
            end
        else
            Iout_ncirc = Iout_ncirc_old;
            temp_Iout_ncirc = temp_Iout_ncirc_old;
            add_map = add_map_old;
            temp_add_map = temp_add_map_old;
            
            disp("(E5) FOCAL ADHESIONS ADD-ON | ERROR: No add-on selected. Choose either FA, COLOCALIZATION, or both. Check USER INPUT variables.");
        end
    else
        Iout_ncirc = Iout_ncirc_old;
        temp_Iout_ncirc = temp_Iout_ncirc_old;
        add_map = add_map_old;
        temp_add_map = temp_add_map_old;
        
        disp("(E8) FOCAL ADHESIONS ADD-ON | ERROR: Chosen channel for UNDO / REDO operations is not read due to USER'S choice. Please check USER INPUT variable section ('ROI_main_ch' variable).");
    end
    
catch
    disp("(W6) FOCAL ADHESIONS ADD-ON | WARNING: UNDO / REDO operation could not be performed. No changes have been applied.");
end

end