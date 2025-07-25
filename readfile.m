function [save_default_name, info, read_flag, filepath, dataC] = readfile(ch)

try
    [filename, filepath] = uigetfile({'*.tiff; *.tif'}, 'Choose image file.'); 
    filename = string(filename);
    filepath = string(filepath);
    save_default_name = erase(strcat('Results-', filename, '-', strrep(datestr(datetime('now')), ...
    ':', '-')), [" ", "_"]); 
    info = imfinfo(strcat(filepath, filename)); 
    data1 = imread(strcat(filepath, filename), 'Tiff', 'Info', info); 
    if (size(data1,3) == 3)
        dataC = data1(:,:,ch);
    else
        dataC = data1;
    end
    read_flag = 1;
    disp("File read successfully.");
catch
    save_default_name = [];
    info = [];
    read_flag = 0;
    filepath = [];
    dataC = [];
    disp("ERROR: File read error. Check root file and try again.");
end

end