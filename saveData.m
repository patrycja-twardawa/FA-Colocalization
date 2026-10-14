function saveData(temp, filepath, save_default_name, int_rings_tab)

try
    writetable(temp, strcat(filepath, save_default_name, ".xlsx"), 'Sheet', 'Object data');
    if any(size(int_rings_tab)) > 1
        writetable(int_rings_tab, strcat(filepath, save_default_name, ".xlsx"), 'Sheet', 'Ring data');
    end
    save(strcat(filepath, 'BinaryMaps-', save_default_name)); %do not modify this statement, or the statements above / below

    disp(strcat("Result file has been written to MS Excel file. Filename: ", filepath, save_default_name, ".xlsx"));
catch
    disp("ERROR: Results have not been saved. Please check data.");
    
end

end