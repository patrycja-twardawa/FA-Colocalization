function [distances, temp] = talRatioGoI(num_objects, bndrs, temp, data0)

try
    temp.Ratio = [temp.MajorAxisLength(:) ./ temp.MinorAxisLength(:)];

    for i = 1 : num_objects  % GoI i dyskryminacja ze względu na kolistość, rozmiar, średnią intensywność

        distances = sqrt((temp.WeightedCentroid(i,1) - bndrs{i}(:,2)).^2 + ... %cols
            (temp.WeightedCentroid(i,2) - bndrs{i}(:,1)).^2); %rows
        [minDistance, indexOfMin] = min(distances);
        temp.Gradient(i) = ( double(data0( round(temp.WeightedCentroid(i,2)), ... %rows
        round(temp.WeightedCentroid(i,1)) )) - double(data0(indexOfMin)) ) / minDistance; %cols

    end
catch
    distances = [];
    disp("(E21) FOCAL ADHESIONS ADD-ON | ERORR: Ratio property of objects was not reassigned properly. Check data and try again.");
end

end