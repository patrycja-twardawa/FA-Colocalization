function [labeled_image, bndrs, temp, mean_inten, max_inten, min_inten, mean_inten_all, num_objects] = ...
    shiftlabels(labeled_image, bndrs, obj_del, data0, varargin)

if isempty(varargin{1}) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Object borders
    bndrs_cat = [];
    for k = 1 : numel(obj_del)
        bndrs_cat = [bndrs_cat; bndrs{obj_del(k)}];
    end
    
    bndrs(obj_del(1)) = {bndrs_cat};
    bndrs(obj_del(2:end)) = []; 

%Image labels p. 1
    for i = 2 : numel(obj_del)
        labeled_image(labeled_image == obj_del(i)) = obj_del(1);
    end
    
else %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Object borders
    bndrs(obj_del) = [];

%Image labels p. 1
    for i = 1 : numel(obj_del)
        labeled_image(labeled_image == obj_del(i)) = 0;
    end
    
end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Image labels p. 2
    labels_sorted = unique(labeled_image, 'sorted');
    if (labels_sorted(1) == 0)
        labels_sorted = labels_sorted(2:end);
    end
    
    num_objects = numel(labels_sorted)

    for k = 1 : num_objects
        labeled_image(labeled_image == labels_sorted(k)) = k;
    end
    
%Data
    temp = regionprops('table', labeled_image, data0, 'Area', 'Centroid', 'Circularity', ...
            'Perimeter', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'WeightedCentroid', ...
            'MeanIntensity', 'MinIntensity', 'MaxIntensity'); %obliczenie parametrów 
%Intensities       
    [mean_inten_all, mean_inten, min_inten, max_inten] = ...
            countintsty(data0, labeled_image, num_objects, labeled_image); %Iout2!! Bez małych artefaktów przyklejonych do komórek

end