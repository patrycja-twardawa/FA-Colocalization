function [px_size, px_flag, temp, int_rings_tab] = talPxTransfer(temp, int_rings_tab, px_size, px_flag)

try
    if ((px_flag == 1) && ~isempty(px_size))
        temp.Area = (px_size(1) * px_size(2)) * temp.Area;
        temp.Centroid(:,1) = temp.Centroid(:,1) * px_size(1);
        temp.Centroid(:,2) = temp.Centroid(:,2) * px_size(2);
        temp.MajorAxisLength = temp.MajorAxisLength * px_size(1); %sprawdzić czy kwadratowy! Lub pitagorasem z BoundingBox
        temp.MinorAxisLength = temp.MinorAxisLength * px_size(1); %sprawdzić czy kwadratowy!
        temp.Perimeter = temp.Perimeter * px_size(1); %sprawdzić czy kwadratowy!
        temp.WeightedCentroid(:,1) = temp.WeightedCentroid(:,1) * px_size(1);
        temp.WeightedCentroid(:,2) = temp.WeightedCentroid(:,2) * px_size(2);

        int_rings_tab.Area = (px_size(1) * px_size(2)) * int_rings_tab.Area;
        int_rings_tab.BorderDistance = px_size(1) * int_rings_tab.BorderDistance;

        px_flag = 0;
        disp("Distances in px have been successfully transferred to real distances.");
    else
        disp("(W16) FOCAL ADHESIONS ADD-ON | WARNING: This operation cannot be called if you have already performed one transfer to real size units.");
    end
    
catch
    disp("(E22) FOCAL ADHESIONS ADD-ON | ERROR: Transfer from distances in pixels to real size failed. Check data and try again.");
end