function [px_size, px_flag, ring_diameter] = talReadPxSize(info, px_size, px_flag, px_size_flag, ...
    ring_diameter_um, ring_diameter)

try
    if isempty(px_size)
        px_flag = 1; %allow for pixel recounting
    
    if (~isempty(info(1).YResolution) && isnumeric(1/info(1).YResolution) && (1/info(1).YResolution > 0) && ...
            ~px_size_flag)
        px_size_temp = double([1/info(1).YResolution, 1/info(1).XResolution]);
        if isnumeric(px_size_temp)
            px_size = px_size_temp;
            disp("Pixel size has been read from image metadata.");
            disp("WARNING: Assumed size unit is um! In case of different unit used in metadata, please overwrite manually.");
        else
            disp("ERROR: Non-numeric value was read. Please overwrite manually. Pixel size not saved.");
        end
    elseif (~isempty(info(1).YResolution) && isnumeric(1/info(1).YResolution) && (1/info(1).YResolution >= 1) ...
            && ~px_size_flag)
        yt = input("WARNING: Unexpected pixel size. Check file for metadata corruption. Add Y-axis size of pixel in um: ");
        xt = input("WARNING: Add X-axis size of pixel in um: ");
        px_size_temp = [yt, xt];
        if isnumeric(px_size_temp)
            px_size = px_size_temp;
            disp("Pixel size data saved correctly.");
            disp("WARNING: Assumed size unit is um! In case of different unit used in metadata, please overwrite manually.");
        else
            disp("ERROR: Non-numeric value provided. Please try again. Pixel size not saved.");
        end
    else
        yt = input("WARNING: No data about pixel size in root files. Add Y-axis size of pixel in um: ");
        xt = input("WARNING: Add X-axis size of pixel in um: ");
        px_size_temp = [yt, xt];
        if isnumeric(px_size_temp)
            px_size = px_size_temp;
            disp("Pixel size data saved correctly.");
            disp("WARNING: Assumed size unit is um! In case of different unit used in metadata, please overwrite manually.");
        else
            disp("ERROR: Non-numeric value provided. Please try again. Pixel size not saved.");
        end
    end
    
    if ~isempty(px_size)
        ring_diameter = round(ring_diameter_um / px_size(1));
        disp("Ring diameter has been estimated in real units.");
    else
        ring_diameter = [];
        disp("ERROR: Ring diameter could not be obtained. Please check image metadata / provide information about pixel size in real units. You must repeat image read.");
    end
    
    else
        if (px_flag == 1)
            disp("WARNING: Information about pixel size has already been provided. You can proceed with distance recounting.");
            
        else
            disp("WARNING: You have already recounted the data to real distance units. Operation cannot be repeated.");
        end
    end
catch
        yt = input("WARNING: Pixel size read from root file failed. Add Y-axis size of pixel in um: ");
        xt = input("WARNING: Add X-axis size of pixel in um: ");
        px_size = [yt, xt];
        disp("Pixel size data saved correctly.");
        
        if ~isempty(px_size)
            ring_diameter = round(1 / px_size(1));
        else
            ring_diameter = [];
            disp("ERROR: Ring diameter could not be obtained. Please check image metadata / provide information about pixel size in real units. You must repeat image read.");
        end
end 

end