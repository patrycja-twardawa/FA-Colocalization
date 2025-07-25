function [px_size, px_flag, ring_diameter] = talReadPxSize(info, px_size, px_flag, ring_diameter_um, ring_diameter)

try
    if isempty(px_size)
        px_flag = 1; %allow for pixel recounting
    
    if ~isempty(info(1).YResolution) && isnumeric(1/info(1).YResolution) && (1/info(1).YResolution > 0)
        px_size = [1/info(1).YResolution, 1/info(1).XResolution];
        disp("Pixel size has been read from image metadata.");
    elseif ~isempty(info(1).YResolution) && isnumeric(1/info(1).YResolution) && (1/info(1).YResolution >= 1)    
        xt = input("WARNING: Unexpected pixel size. Check file for metadata corruption. Add size of pixel in um: ");
        px_size = [xt, xt];
        disp("Assumption about square pixel shape accepted.");
    else
        xt = input("WARNING: No data about pixel size in root files. Add size of pixel in um: ");
        px_size = [xt, xt];
        disp("Assumption about square pixel shape accepted.");
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
        xt = input("WARNING: Pixel size read from root file failed. Add size of pixel in um: ");
        px_size = [xt, xt];
        disp("Assumption about square pixel shape accepted.");
        
        if ~isempty(px_size)
            ring_diameter = round(1 / px_size(1));
        else
            ring_diameter = [];
            disp("ERROR: Ring diameter could not be obtained. Please check image metadata / provide information about pixel size in real units. You must repeat image read.");
        end
end 

end