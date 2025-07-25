function [mean_inten_all, mean_inten, min_inten, max_inten] = countintsty(data_im, ...
    Iout, num_objects, labeled_image)

    mean_inten_all = round(mean(data_im(Iout ~= 0)))

    mean_inten = [];
    for i = 1 : num_objects
%         [tempx, tempy] = find(labeled_image == i); %< 256 liczba kom.!
%         mean_inten(i) = round(mean(mean(data_im(tempx, tempy)))); %ŹLE!        
        mean_inten(i) = round(mean(mean(data_im(labeled_image == i))));
        min_inten(i) = min(min(data_im(labeled_image == i)));
        max_inten(i) = max(max(data_im(labeled_image == i)));
    end

end