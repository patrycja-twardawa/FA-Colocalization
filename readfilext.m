function [name2CH, info2CH, read_flag2CH, filepath2CH, dataC2CH, data12CH, sum_map, ...
    save_default_name, info, read_flag, filepath, dataC, data1, px_size, px_flag, ring_diameter] = ...
        readfilext(ch_coloc, read_image_flag, ch_tal, ring_diameter_um, name2CH, info2CH, ...
        read_flag2CH, filepath2CH, dataC2CH, data12CH, sum_map, save_default_name, info, ...
        read_flag, filepath, dataC, data1, px_size, px_flag, ring_diameter, FA, colocalization)
    
close all;
rgb_nam_tab = ["R", "G", "B"];
if colocalization
    try
        disp("Reading image channels for COLOCALIZATION add-on...");
        disp(strcat("Choose ", rgb_nam_tab(ch_coloc(1)), " channel file.")); 
        [name2CH(1), info2CH{1}, read_flag2CH(1), filepath2CH(1), dataC2CH(:,:,1)] = readfile(ch_coloc(1)); %1st channel read
        disp(strcat("Choose ", rgb_nam_tab(ch_coloc(2)), " channel file.")); 
        [name2CH(2), info2CH{2}, read_flag2CH(2), filepath2CH(2), dataC2CH(:,:,2)] = readfile(ch_coloc(2)); %2nd channel read

        data12CH(:,:,1) = rescale(im2double(dataC2CH(:,:,1)), 0, 1); 
        data12CH(:,:,2) = rescale(im2double(dataC2CH(:,:,2)), 0, 1); 
        
        sum_map = cat(3, data12CH(:,:,1), data12CH(:,:,2), zeros(size (data12CH(:,:,1)) ));
        disp("Image data read successfully for COLOCALIZATION add-on.");
    catch
        disp("(E1) COLOCALIZATION ADD-ON | ERROR: File read error for COLOCALIZATION add-on. Check the format and size of files (TIFF).");
    end
end
if FA
    try
        if read_image_flag
            disp("Reading image channels for FA add-on...");
            if colocalization && any(ch_coloc == ch_tal)
                doubled_ch = ch_coloc(ch_coloc == ch_tal);
                save_default_name = strcat(name2CH(doubled_ch), "-FA");
                info = info2CH{doubled_ch};
                filepath = filepath2CH(doubled_ch);
                dataC = dataC2CH(:,:,doubled_ch);
                read_flag = 1;
                disp(strcat("Channel ", num2str(doubled_ch), " (", rgb_nam_tab(doubled_ch), ...
                    ") data has been copied from COLOCALIZATION add-on."));
            else
                [save_default_name, info, read_flag, filepath, dataC] = readfile(ch_tal); 
            end
                
                [px_size, px_flag, ring_diameter] = talReadPxSize(info, px_size, px_flag, ...
                    ring_diameter_um, ring_diameter); 
                disp("Image data read successfully for FA add-on.");
        end
    catch
        disp("(E2) FOCAL ADHESIONS ADD-ON | ERROR: File read error for FA add-on. Check the format and size of files (TIFF).");
    end
end

end