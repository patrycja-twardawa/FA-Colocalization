function [labeled_im, bndrs, obj_del, temp, mean_inten, max_inten, min_inten, mean_inten_all, t_centr, ...
    num_objects] = ...
        talLabelConnect(temp, B3, labeled_im, bndrs, data0, obj_del, mean_inten, max_inten, min_inten, ...
        mean_inten_all, num_objects, varargin)

try
    t_centr = [temp.Centroid(:,2), temp.Centroid(:,1)];
    break_flag = 0;
    
    if isempty(obj_del)
        disp("Choose manually labeled objects to be merged. Press any key to close the window.");
        figure(201);
        imshow(B3);
        title('Adjusted cell image');

        g = figure(202);
        loop_count = 1;
        set(g, 'WindowKeyPressFcn', {@KeyPressed, g}); %listen to loop break {@KeyPressed, h}
        l = 1;
        
        while loop_count
            rgb = label2rgb(labeled_im, 'jet', [.5 .5 .5]);
            imshow(rgb); hold on;
            plotetqts(t_centr, size(t_centr,1)); hold on;
            title('Choose labels to be merged');
            roi = images.roi.AssistedFreehand('Color', 'y', 'MarkerSize', 3, ...
                'LineWidth', 3); 
            draw(roi);
            obj_del = unique(labeled_im(createMask(roi)), 'sorted');

            if (obj_del(1) == 0)
                obj_del = obj_del(2:end);
            end

            if numel(obj_del) > 1
                [labeled_im, bndrs, temp, mean_inten, max_inten, min_inten, mean_inten_all, num_objects] = ...
                    shiftlabels(labeled_im, bndrs, obj_del, data0, []); %usuwanie nadmiarowych obiektów, przesunięcie etykiet

                t_centr = [temp.Centroid(:,2), temp.Centroid(:,1)];

                figure(202);
                rgb = label2rgb(labeled_im, 'jet', [.5 .5 .5]);
                imshow(rgb); hold on;
                plotetqts(t_centr, size(t_centr,1)); hold on;
                title('Label image after merging');

                break_flag = 1;
                disp("Labels merged successfully.");           
            else
                disp("(W14) FOCAL ADHESIONS ADD-ON | WARNING: Only one object selected. Label merging not performed, try again.");
            end
        end
    else
         [labeled_im, bndrs, temp, mean_inten, max_inten, min_inten, mean_inten_all, num_objects] = ...
                shiftlabels(labeled_im, bndrs, obj_del, data0, 'delete'); %usuwanie nadmiarowych obiektów, przesunięcie etykiet
        
            t_centr = [temp.Centroid(:,2), temp.Centroid(:,1)];

            figure(202);
            rgb = label2rgb(labeled_im, 'jet', [.5 .5 .5]);
            imshow(rgb); hold on;
            plotetqts(t_centr, size(t_centr,1)); hold on;
            title('Label image after classification');

            disp("Disqualified objects excluded successfully.");
    end    
catch
    if break_flag
        disp("Label merging finished.");
    else
        disp("(W15) FOCAL ADHESIONS ADD-ON | WARNING: Labeled objects not merged. Previous labels valid. Check data or proceed.");
        return;
    end
end

end