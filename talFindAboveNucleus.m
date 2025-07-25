function [labeled_im_nucleus, labeled_im_cytoplasm, temp] = talFindAboveNucleus(labeled_im, ...
    num_objects, binaryImage2, temp)

try   
    labeled_im_nucleus = labeled_im;
    labeled_im_cytoplasm = labeled_im;
    
    for i = 1 : num_objects
        
        % MAPY DLA J. KOM. I POZOSTAŁEJ CZĘŚCI KOMÓRKI
        if (isempty(find((labeled_im == i) & binaryImage2)))
            labeled_im_nucleus(labeled_im == i) = 0;
            temp.AboveNucleus(i) = 0;
        else
            labeled_im_cytoplasm(labeled_im == i) = 0;
            temp.AboveNucleus(i) = 1;
        end
    end
    
    disp("Object status & label maps based on localization relative to nucleus have been found successfully.");
catch
    disp("(W13) FOCAL ADHESIONS ADD-ON | WARNING: Object status & label maps based on localization relative to nucleus were not prepared.");
end

end