function [binaryImage, binaryImage2, temp_binaryImage, add_map, temp_add_map, B6col, B6col_nucl, data12CH_ctr, ...
    sum_map, sum_map_nucl, RGB_coloc, RGB_coloc_nucl, h, h_nucl, data_subtracted, data_subtracted_nucl, ...
    data12CH_nucl, G_col] = ...
        imrescaler(binaryImage, binaryImage2, temp_binaryImage, add_map, temp_add_map, B6col, B6col_nucl, ...
    data12CH_ctr, sum_map, sum_map_nucl, RGB_coloc, RGB_coloc_nucl, h, h_nucl, data_subtracted, ...
    data_subtracted_nucl, dataC, data12CH, data12CH_nucl, G_col, FA, colocalization)

    try

        resc_FA = 0;
        resc_coloc = 0;

        if FA
            im_size = size(dataC);
            if any(im_size < 2048) && any(im_size >= 512)
                resc_FA = 1;
            elseif any(im_size < 512)
                disp("ERROR (FA add-on): Resolution of input file too low (lower dimension must be at least 512 px). Please change data for the higher resolution image");
            end
        end
            
        if colocalization
            im_size_coloc = size(data12CH);
            if any(im_size_coloc(1:2) < 2048) && any(im_size_coloc(1:2) >= 512)
                resc_coloc = 1;
            elseif any(im_size_coloc(1:2) < 512)
                disp("ERROR (Colocalization add-on): Resolution of input file too low (lower dimension must be at least 512 px). Please change data for the higher resolution image");
            end
        end

        if FA && resc_FA
            % BINARY MAPS: FA
            binaryImage = zeros(im_size); %stage 0 binary map of all structures in ROI
            binaryImage2 = zeros(im_size); %stage 0 binary map of all structures in cell nucleus ROI
            temp_binaryImage = zeros(im_size); %stage 0 binary map, copy of binaryImage for UNDO / REDO operations
            add_map = zeros(im_size); %binary map representing the places added by user
            temp_add_map = zeros(im_size); %copy of add_map for UNDO / REDO operations

            disp("WARNING (FA add-on): Resolution of the input image is lower than recommended 2048x2048 px, but within acceptable limit. Image rescaled, memory allocation changed.");

            disp("FA add-on: new maps from previous steps prepared based on corrected scaling.");
        end

        if colocalization && resc_coloc
            % BINARY MAPS: colocalization
            B6col = zeros(im_size_coloc(1:2), 'logical'); %stage 3 binary map after applying user ROI to segmentation image
            B6col_nucl = zeros(im_size_coloc(1:2), 'logical'); %stage 3 binary map after applying user ROI for cell nucleus to segmentation image

            % IMAGES: colocalization
            %dataC2CH = zeros(im_size_coloc, 'double'); %original image data for the 1st and 2nd chosen image channels
            data12CH_ctr = zeros(im_size_coloc, 'double'); %image data before contrast adjustment for the 1st and 2nd chosen image channels
            data12CH = zeros(im_size_coloc, 'double'); %image data after processing for the 1st and 2nd chosen image channels
            data12CH_nucl = zeros(im_size_coloc, 'double'); %image of CELL NUCLEUS ROI after processing for the 1st and 2nd chosen image channels
            G_col = zeros(im_size_coloc, 'double'); %image after filtering

            sum_map = zeros(im_size_coloc(1:2), 'double'); %sum colocalisation map
            sum_map_nucl = zeros(im_size_coloc(1:2), 'double'); %sum colocalisation map of cell nucleus
            RGB_coloc = zeros(im_size_coloc(1:2), 'double'); %RGB colocalisation map
            RGB_coloc_nucl = zeros(im_size_coloc(1:2), 'double'); %RGB colocalisation map of cell nucleus
            h = zeros(im_size_coloc(1:2), 'double'); %hue colocalisation map
            h_nucl = zeros(im_size_coloc(1:2), 'double'); %hue colocalisation map of cell nucleus
            data_subtracted = zeros(im_size_coloc(1:2), 'double'); %subtraction colocalisation map
            data_subtracted_nucl = zeros(im_size_coloc(1:2), 'double'); %subtraction colocalisation map of cell nucleus

            disp("WARNING (Colocalization add-on): Resolution of the input image is lower than recommended 2048x2048 px, but within acceptable limit. Image rescaled, memory allocation changed.");

            data12CH_ctr = data12CH;
            sum_map = cat(3, data12CH(:,:,1), data12CH(:,:,2), zeros(size (data12CH(:,:,1)) ));

            disp("Colocalization add-on: new maps from previous steps prepared based on corrected scaling.");
        end

    catch
        disp("ERROR: Maps cannot be rescaled. Please check / change input data. Please do not proceed otherwise, while correct scaling is mandatory.");
    end

end