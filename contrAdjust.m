function [data12CH, data12CH_ctr, data1] = contrAdjust(lh_lim_tal, lh_lim_tal_user, lh_lim_coloc, ...
    lh_lim_coloc_user, data12CH, data12CH_ctr, data1, contrast_flag, contrast_visual_flag, FA, ...
    colocalization)

try
    if colocalization
        if ~contrast_flag
            data12CH(:,:,1) = imadjust(data12CH_ctr(:,:,1));
            data12CH(:,:,2) = imadjust(data12CH_ctr(:,:,2));
            disp("Automatic contrast limits applied for analysis in COLOCALIZATION add-on.");
        elseif contrast_flag                         
            T = graythresh(data12CH_ctr(:,:,1));   
            lh_lim_coloc_temp = [T*0.2, T];             
            data12CH(:,:,1) = imadjust(data12CH_ctr(:,:,1), lh_lim_coloc_temp);                          
            T = graythresh(data12CH(:,:,2));                 
            lh_lim_coloc_temp = [T*0.2, T];                      
            data12CH(:,:,2) = imadjust(data12CH(:,:,2), lh_lim_coloc_temp);                         
            disp("Automatic contrast limits applied for analysis in COLOCALIZATION add-on (Otsu method).");
        else
            data12CH(:,:,1) = imadjust(data12CH_ctr(:,:,1), lh_lim_coloc(1:2));
            data12CH(:,:,2) = imadjust(data12CH_ctr(:,:,2), lh_lim_coloc(3:4));
            disp("User-chosen contrast limits applied for analysis in COLOCALIZATION add-on.");
        end
        
        if ~contrast_visual_flag
            disp_im_coloc1 = imadjust(data12CH_ctr(:,:,1), lh_lim_coloc_user(1,1:2));
            disp_im_coloc2 = imadjust(data12CH_ctr(:,:,2), lh_lim_coloc_user(2,1:2));
            
            figure; imshow(disp_im_coloc1);
            title("Colocalization first channel, user display settings");
            figure; imshow(disp_im_coloc2);
            title("Colocalization second channel, user display settings");
            disp("Contrast settings chosen by user will be used for display (Colocalization add-on), regardless of processing settings.");
        else
            disp("Contrast settings used for processing will be used for display (Colozalization add-on).");
        end
            figure; imshow(data12CH(:,:,1));
            title("Colocalization first channel, processing settings");
            figure; imshow(data12CH(:,:,2));
            title("Colocalization second channel, processing settings");
    end
    if FA
            if contrast_flag
                data1 = imadjust(rescale(double(data1), 0, 1), lh_lim_tal);
                disp("User-chosen contrast limits applied for analysis in FA add-on.");
            else
                data1 = imadjust(rescale(double(data1), 0, 1));
                disp("Automatic contrast limits applied for analysis in FA add-on.");
            end
            
            if ~contrast_visual_flag
                disp_im_fa = imadjust(rescale(double(data1), 0, 1), lh_lim_tal_user);

                figure; imshow(disp_im_fa);
                title("Focal Adhesions single channel, user display settings");
                disp("Contrast settings chosen by user will be used for display (Focal Adhesions add-on), regardless of processing settings.");
            else
                disp("Contrast settings used for processing will be used for display (Focal Adhesions add-on).");
            end
                figure; imshow(data1);
                title("Focal Adhesions single channel, user display settings, processing settings");
    end
catch
    disp("ERROR: Contrast adjustment failed. Please check provided image data and contrast limits vectors.");
end

end