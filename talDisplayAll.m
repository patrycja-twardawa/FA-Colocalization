function talDisplayAll(data1, ch, Iout_circ, Iout_ncirc, bndrs, temp, labeled_im, int_rings_tab, ...
    ring_diameter, px_size, t_centr, labeled_im_nucleus, labeled_im_cytoplasm, filepath, save_default_name)

try  
    close all;

    fig1 = figure(1); imshow(data1);
    title(strcat("Image after contrast adjustment, CH: ", num2str(ch)));
    saveas(fig1, strcat(filepath, save_default_name, '-ContrastAdjusted.tif'));
    savefig(fig1, strcat(filepath, save_default_name, '-ContrastAdjusted.fig'));

    fig2 = figure(2); imshow(Iout_circ);
    title("Binary map of circular objects");
    saveas(fig2, strcat(filepath, save_default_name, '-CircularObjectsMap.tif'));
    savefig(fig2, strcat(filepath, save_default_name, '-CircularObjectsMap.fig'));

    fig3 = figure(3); imshow(Iout_ncirc);
    title("Binary map of fibrilar objects");
    saveas(fig3, strcat(filepath, save_default_name, '-FibrilarObjectsMap.tif'));
    savefig(fig3, strcat(filepath, save_default_name, '-FibrilarObjectsMap.fig'));
    
    fig4 = figure(4); imshow(data1); hold on; 
    plotcontour(bndrs); hold on; 
    plotetqts(t_centr, size(t_centr,1)); 
    title("Label contours of segmented objects");
    saveas(fig4, strcat(filepath, save_default_name, '-LabelContours.tif'));
    savefig(fig4, strcat(filepath, save_default_name, '-LabelContours.fig'));

    I_over = uint16(labeled_im); 
    I_over(I_over > 0) = 65535;
    data_overlay = cat(3, I_over, im2uint16(data1), I_over); 
    fig5 = figure(5); imshow(data_overlay); hold on; 
    title("Overlay of image channel (adjusted) and found structures");
    saveas(fig5, strcat(filepath, save_default_name, '-OverlayImage.tif'));
    savefig(fig5, strcat(filepath, save_default_name, '-OverlayImage.fig'));

    rgb = label2rgb(labeled_im, 'hsv', [.5 .5 .5]);
    fig6 = figure(6); imshow(rgb); hold on;
    plotetqts(t_centr, size(t_centr,1));
    title("Labels - colours"); 
    saveas(fig6, strcat(filepath, save_default_name, '-LabelsColoredMap.tif'));
    savefig(fig6, strcat(filepath, save_default_name, '-LabelsColoredMap.fig'));

    rgb1 = rgb(:,:,1,1);
    rgb1(~Iout_ncirc) = 0;
    rgb2 = rgb(:,:,2,1);
    rgb2(~Iout_ncirc) = 0;
    rgb3 = rgb(:,:,3,1);
    rgb3(~Iout_ncirc) = 0;
    rgbm = cat(3, rgb1, rgb2, rgb3);
    fig7 = figure(7); imshow(rgbm); hold on;
    title("Label map - colours"); 
    saveas(fig7, strcat(filepath, save_default_name, '-LabelsColoredMapNoEtqts.tif'));
    savefig(fig7, strcat(filepath, save_default_name, '-LabelsColoredMapNoEtqts.fig'));

    u_ln = unique(labeled_im_nucleus);
    if u_ln(1) == 0
        u_ln = u_ln(2:end);
    end

    u_lc = unique(labeled_im_cytoplasm);
    if u_lc(1) == 0
        u_lc = u_lc(2:end);
    end

    rgb_nucleus = label2rgb(labeled_im_nucleus, 'jet', [.5 .5 .5]);
    fig8 = figure(8); imshow(rgb_nucleus); hold on;
    plotetqts(t_centr(u_ln, :), numel(u_ln));
    title("Labels - colours, areas over cell nucleus"); 
    saveas(fig8, strcat(filepath, save_default_name, '-LabelsColoredNucleusMap.tif'));
    savefig(fig8, strcat(filepath, save_default_name, '-LabelsColoredNucleusMap.fig'));

    rgb_cytoplasm = label2rgb(labeled_im_cytoplasm, 'jet', [.5 .5 .5]);
    fig9 = figure(9); imshow(rgb_cytoplasm); hold on;
    plotetqts(t_centr(u_lc, :), numel(u_lc));
    title("Labels - colours, area of cytoplasm"); 
    saveas(fig9, strcat(filepath, save_default_name, '-LabelsColoredCytoplasm.tif'));
    savefig(fig9, strcat(filepath, save_default_name, '-LabelsColoredCytoplasm.fig'));
    
    fig10 = figure(10); stem(int_rings_tab.BorderDistance, int_rings_tab.MeanIntenNorm, 'r');
    xlabel("Distance from cell border [um]", 'FontSize', 10); % strcat("Distance from cell border [um]"), (band radius: ", num2str(ring_diameter * px_size(1)), " px)"), 'FontSize', 10);
    xlim([0, max(int_rings_tab.BorderDistance) + 0.1 * max(int_rings_tab.BorderDistance)]);
    ylabel('Normalized mean intensity [0-1]', 'FontSize', 10);
    ylim([0, 1.2]);
    title('Distance from cell edge and intensity dependency');
    grid on;
    saveas(fig10, strcat(filepath, save_default_name, '-RingsChart.tif'));
    savefig(fig10, strcat(filepath, save_default_name, '-RingsChart.fig'));
        
    fig11 = figure(11); stem(int_rings_tab.BorderDistance, int_rings_tab.ObjectsOverlapping, 'b');
    xlabel("Distance from cell border [um]", 'FontSize', 10); % strcat("Distance from cell border [um]"), (band radius: ", num2str(ring_diameter * px_size(1)), " px)"), 'FontSize', 10);
    xlim([0, max(int_rings_tab.BorderDistance) + 0.1 * max(int_rings_tab.BorderDistance)]);
    ylabel('Number of overlapping objects', 'FontSize', 10);
    ylim([0, max(int_rings_tab.ObjectsOverlapping) + 5]);
    title('Relation between number of objects and distance from cell edge');
    grid on;
    saveas(fig11, strcat(filepath, save_default_name, '-RingsChartObjects.tif'));
    savefig(fig11, strcat(filepath, save_default_name, '-RingsChartObjects.fig'));
    
    disp("Results have been displayed.");  
catch
    disp("(E23) FOCAL ADHESIONS ADD-ON | ERROR: Results cannot be fully displayed. Check data.");
end

end