function [bndrs, labeled_image, dmode_l_im, num_objects, temp, ...
    mean_inten_all, mean_inten, min_inten, max_inten] = countparamsext(data_im, Iout, param_flag)  

try
    if param_flag
        [bndrs, labeled_image, dmode_l_im, num_objects] = labelize(Iout); %wyznaczenie etykiet
        temp = regionprops('table', labeled_image, data_im, 'Area', 'Centroid', 'Circularity', ...
            'Perimeter', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'WeightedCentroid', ...
            'MeanIntensity', 'MinIntensity', 'MaxIntensity'); %obliczenie parametrów 
        [mean_inten_all, mean_inten, min_inten, max_inten] = ...
            countintsty(data_im, Iout, num_objects, labeled_image); %Iout2!! Bez małych artefaktów przyklejonych do komórek
        disp('Labelling finished.');
        
        existcol_flagtab = strcmp('ManualOverride', temp.Properties.VariableNames);
        if ~any(existcol_flagtab)
            temp.ManualOverride = zeros(num_objects, 1);
        end
    else
        disp("(W11) FOCAL ADHESIONS ADD-ON | WARNING: Processing flag turned OFF.");
    end
catch
    disp("(E19) FOCAL ADHESIONS ADD-ON | ERROR: Labelling failed. Check data and try again.");
end

end