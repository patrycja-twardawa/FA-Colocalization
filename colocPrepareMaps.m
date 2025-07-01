function [sum_map, sum_map_nucl, add_overlay, add_overlay_nucl, h, h_nucl, ...
    data_subtracted, data_subtracted_nucl] = colocPrepareMaps(data12CH, ch_coloc, ...
    B6col, B6col_nucl, nameR, filepathR, cMap1, cMap2, labels_cbar)

try 
    rgb_nam_tab = ["R", "G", "B"];

    dataCH1 = data12CH(:,:,ch_coloc(1));
    dataCH2 = data12CH(:,:,ch_coloc(2));
    dataCH1_nucl = dataCH1;
    dataCH2_nucl = dataCH2;
    dataCH1(~B6col) = 0;
    dataCH2(~B6col) = 0;
    dataCH1_nucl(~B6col_nucl) = 0;
    dataCH2_nucl(~B6col_nucl) = 0;

    nameR = nameR(1);
    filepathR = filepathR(1);

    disp("COLOCALIZATION add-on maps in preparation.");

    % SUM MAP preparation
    disp("Sum map in preparation...");   
    sum_map = dataCH1 + dataCH2;
    sum_map_nucl = dataCH1_nucl + dataCH2_nucl;
    disp("Sum map prepared.");

    fig1 = figure(1); 
    imshow(B6col); title("COLOCALIZATION add-on | Binary map of cell area");
    saveas(fig1, strcat(filepathR, nameR, '-CellAreaBinaryMap.tif'));
    fig2 = figure(2);  
    imshow(B6col_nucl); title("COLOCALIZATION add-on | Binary map of area over cell nucleus");
    saveas(fig2, strcat(filepathR, nameR, '-NucleusAreaBinaryMap.tif'));

    fig3 = figure(3);
    colocdisp(sum_map, fig3, hot(double(65536)), strcat(rgb_nam_tab(ch_coloc(1)), " & ", ...
        rgb_nam_tab(ch_coloc(2)), " sum"), [0, 1], {'Low sum', 'High sum'}, ...
        strcat(filepathR, nameR, '-SumMap.tif'));
    fig4 = figure(4);
    colocdisp(sum_map_nucl, fig4, hot(double(65536)), strcat(rgb_nam_tab(ch_coloc(1)), " & ", ...
        rgb_nam_tab(ch_coloc(2)), " sum, c. nucl. area"), [0, 1], {'Low sum', 'High sum'}, ...
        strcat(filepathR, nameR, '-SumMap_nucl.tif'));   
    disp("RGB map in preparation...");

    % RGB MAP preparation
    add_overlay = zeros(size(dataCH1,1), size(dataCH1,2), 3);
    add_overlay(:,:,ch_coloc(1)) = dataCH1(:,:);
    add_overlay(:,:,ch_coloc(2)) = dataCH2(:,:);

    add_overlay_nucl = zeros(size(dataCH1,1), size(dataCH1,2), 3);
    add_overlay_nucl(:,:,ch_coloc(1)) = dataCH1_nucl(:,:);
    add_overlay_nucl(:,:,ch_coloc(2)) = dataCH2_nucl(:,:);

    fig5 = figure(5); 
    colocdisp(add_overlay, fig5, cMap1, strcat(rgb_nam_tab(ch_coloc(1)), " & ", ...
        rgb_nam_tab(ch_coloc(2)), " RGB map"), [0, 0.5, 1], labels_cbar, ...
        strcat(filepathR, nameR, '-OverlayRGMap.tif'), 1);    
    fig6 = figure(6); 
    colocdisp(add_overlay_nucl, fig6, cMap1, strcat(rgb_nam_tab(ch_coloc(1)), " & ", ...
        rgb_nam_tab(ch_coloc(2)), " RGB map, c. nucl. area"), [0, 0.5, 1], ...
        labels_cbar, strcat(filepathR, nameR, '-OverlayRGNucleusMap.tif'), 1);
    disp("RGB map prepared.");

    % HSV-HUE MAP preparation
    disp("Hue-based colocalization map in preparation...");
    overlay_val = rgb2hsv(add_overlay);    
    h = overlay_val(:,:,1);
    h = abs(h - max(max(h)));
    h(~B6col) = 0 - max(diff(unique(h, 'first')));
    h = h + max(diff(unique(h, 'first')));

    h_nucl = h;
    h_nucl(~B6col_nucl) = 0 - max(diff(unique(h, 'first')));
    h_nucl = h_nucl + max(diff(unique(h_nucl, 'first')));

    fig7 = figure(7); 
    colocdisp(rescale(h, 0, 1), fig7, cMap2, strcat(rgb_nam_tab(ch_coloc(1)), " & ", ...
        rgb_nam_tab(ch_coloc(2)), " hue-based map"), [0, 0.5, 1], labels_cbar, ...
        strcat(filepathR, nameR, '-HSV-h-Map.tif')); 
    fig8 = figure(8);
    colocdisp(rescale(h_nucl, 0, 1), fig8, cMap2, strcat(rgb_nam_tab(ch_coloc(1)), " & ", ...
        rgb_nam_tab(ch_coloc(2)), " hue-based map, c. nucl. area"), [0, 0.5, 1], labels_cbar, ...
        strcat(filepathR, nameR, '-HSV-h-NucleusMap.tif')); 
    disp("Hue-based colocalization map prepared.");

    disp("Subtraction colocalization map in preparation...");  
    data_subtracted = dataCH1 - dataCH2; %for positive values -> R prevalence, for negative values -> G prevalence
    bck_val = max(diff(unique(data_subtracted, 'first'))); %find suitable difference between picture / background intensity

    data_subtracted_temp = data_subtracted;

    data_subtracted_temp(and(data_subtracted <= 0, B6col)) = ...
        rescale(data_subtracted_temp(and(data_subtracted <= 0, B6col)), bck_val, 0.5);
    data_subtracted_temp(and(data_subtracted >= 0, B6col)) = ...
        rescale(data_subtracted_temp(and(data_subtracted >= 0, B6col)), 0.5, 1);
    data_subtracted_temp(~B6col) = 0;
    data_subtracted = data_subtracted_temp;

    data_subtracted_nucl = data_subtracted_temp;
    data_subtracted_nucl(~B6col_nucl) = 0;

    clear data_subtracted_temp

    fig9 = figure(9);
    colocdisp(data_subtracted, fig9, cMap2, strcat(rgb_nam_tab(ch_coloc(1)), " & ", ...
        rgb_nam_tab(ch_coloc(2)), " subtraction map"), [0, 0.5, 1], labels_cbar, ...
        strcat(filepathR, nameR, '-SubtractionMap.tif')); 
    fig10 = figure(10); 
    colocdisp(data_subtracted_nucl, fig10, cMap2, strcat(rgb_nam_tab(ch_coloc(1)), " & ", ...
        rgb_nam_tab(ch_coloc(2)), " subtraction map, c. nucl. area"), [0, 0.5, 1], labels_cbar, ...
        strcat(filepathR, nameR, '-SubtractionNucleusMap.tif'));    
    disp("Subtraction map prepared.");
catch
    disp("(E13) COLOCALIZATION add-on | ERROR: Map preparation error. Please check before continuation.");
end

end