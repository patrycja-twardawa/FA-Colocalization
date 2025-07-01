function [B6, B6_nucl, param_flag, B6col, B6col_nucl, G_tal, G_col] = ...
    tcimprocess(data1, data12CH, ch_coloc, se, denoise_flag, filt_flag, rb_flag, rb_method, ...
    rb_thresh, gauss_sd, binarization_met, segm_threshold, binaryImage, binaryImage2, B6, B6_nucl, ...
    B6col, B6col_nucl, FA, coloc, param_flag)

try
    if ((~coloc && FA) || (~FA && coloc) || (FA && coloc))         
        if FA              
            disp("Image processing for FOCAL ADHESIONS add-on started...");
            G_tal = tcpartprocess(data1, se, denoise_flag, filt_flag, rb_flag, rb_method, rb_thresh, gauss_sd);
            J = fibermetric(G_tal, 'StructureSensitivity', 0.015, ...
                'ObjectPolarity', 'bright'); %enhancement of fibers (can apply width if necessary), filtr Hessian
            disp("Fibers enhanced (Hessian based Frangi Vesselness filtering).");
            disp("Processing finished for FOCAL ADHESIONS add-on."); 
            I_adapt = talsegment(J, binarization_met, segm_threshold, 1); %segmentation, despeckling
            clear J;
            B5 = imfill(I_adapt, 'holes'); %filling holes
            clear I_adapt;
            disp("Objects designated for FA add-on.");

            B6 = B5;
            B6(~binaryImage) = 0;

            B6_nucl = B5;
            clear B5;
            B6_nucl(~binaryImage2) = 0;
            disp("Objects outside CELL ROI cleared (FA add-on).");

            param_flag = 1; %able to proceed further to labelling (only FA add-on)

            figure(101); 
            subplot(1,2,1); imshow(B6); title("FOCAL ADHESIONS add-on | Chosen ROI: cell");
            subplot(1,2,2); imshow(B6_nucl); title("FOCAL ADHESIONS add-on | Chosen ROI: cell nucleus");

            disp("Segmentation finished for FOCAL ADHESIONS add-on."); 
        else
            B6 = [];
            B6_nucl = [];
            G_tal = [];
        end

        if coloc
            disp("Image processing for COLOCALIZATION add-on started...");
            sum_map = data12CH(:,:,ch_coloc(1)) + data12CH(:,:,ch_coloc(2));
            G_col = tcpartprocess(sum_map, se, denoise_flag, filt_flag, rb_flag, rb_method, rb_thresh, gauss_sd);
            disp(strcat( "Processing finished for COLOCALIZATION add-on, channel ", num2str(ch_coloc(1)) )); 
            I_adapt = talsegment(G_col, binarization_met, segm_threshold, 2.5); %segmentation, despeckling
            B5 = imfill(I_adapt, 'holes'); %filling holes
            clear I_adapt;
            disp( strcat( "Structures designated for COLOCALIZATION add-on, channel ", num2str(ch_coloc(1)), "." ));

            B6col = B5;
            B6col(~binaryImage) = 0;

            B6col_nucl = B5;
            clear B5;
            B6col_nucl(~binaryImage2) = 0;
            disp(strcat( "Structures outside CELL ROI cleared (COLOCALIZATION add-on), channel ", ...
                num2str(ch_coloc(1)), "." ));

            figure(102); 
            subplot(1,2,1); imshow(B6col); title("COLOCALIZATION add-on | Chosen ROI: cell");
            subplot(1,2,2); imshow(B6col_nucl); title("COLOCALIZATION add-on | Chosen ROI: cell nucleus");

            disp("Segmentation finished for COLOCALIZATION add-on."); 
        else
            B6col = [];
            B6col_nucl = [];
            G_col = [];
        end     

        disp("Processing finished.");

    else
        disp("(E5) ERROR: No add-on selected. Choose either FA, COLOCALIZATION, or both. Check USER INPUT variables.");
    end
catch
    param_flag = 0; %proceeding disabled
    disp("(E12) ERROR: Error during image processing and segmentation. Objects have not been designated. Please check data."); 
end

end