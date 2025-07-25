function [Iout_ncirc, Iout_circ, labeled_im, labeled_im_circ, bndrs, temp, obj_del, num_objects, mean_inten, ...
    max_inten, min_inten, mean_inten_all, t_centr, varargout] = ...
        talclassify(labeled_image, B3, Iout, num_objects, temp, data0, mean_inten, max_inten, ...
        min_inten, mean_inten_all, circ_param, obj_area_thresh_circ_itsty, itsty_lvl, bndrs, ...
        obj_area_thresh_itsty, obj_area_thresh, add_map, manualcorr_flag)

try
    labeled_im_circ = labeled_image; 
    labeled_im = labeled_image;
    Iout_circ = Iout; 
    Iout_ncirc = Iout;
    obj_del = [];
    
    for i = 1 : num_objects  % Dyskryminacja ze względu na kolistość, rozmiar, średnią intensywność

        if ( ((temp.Circularity(i) >= circ_param) && (temp.Area(i) < obj_area_thresh_circ_itsty) && ...
                ( mean_inten(i) < (itsty_lvl * max(mean_inten)) )) || ... 
            ((temp.Area(i) < obj_area_thresh_itsty) && ( mean_inten(i) < ((itsty_lvl-0.1) * max(mean_inten)) )) || ...
            ((temp.Area(i) < (obj_area_thresh)) && (temp.MajorAxisLength(i)/temp.MinorAxisLength(i) < 2)) || ...
            (temp.Area(i) < (obj_area_thresh - 20)) || (temp.MeanIntensity(i) < (max(mean_inten) * 0.05)) )

            l_map = Iout;
            l_map(labeled_image ~= i) = 0;
            if ( ~isempty(add_map) && ~manualcorr_flag && any(any( and(add_map, l_map) )) ) % manualcorr_flag set to 0 induces classification override and includes all objects added by user
                    temp.ManualOverride(i) = 1;
            else
                labeled_im(labeled_image == i) = 0;
                obj_del = [obj_del; i]; 
            end
            
        else 
            labeled_im_circ(labeled_image == i) = 0;
        end

    end

    Iout_circ(labeled_im_circ == 0) = 0;
    Iout_ncirc(labeled_im == 0) = 0;
    varargout{1} = Iout_ncirc; %Iout_ncirc_temp, kopia zapasowa
    
    if ~isempty(obj_del)
        [labeled_im, bndrs, obj_del, temp, mean_inten, max_inten, min_inten, mean_inten_all, t_centr, ...
        num_objects] = talLabelConnect(temp, B3, labeled_im, bndrs, data0, obj_del, mean_inten, max_inten, ...
        min_inten, mean_inten_all, num_objects, []);
    else
        t_centr = [temp.Centroid(:,2), temp.Centroid(:,1)];
        disp("(W12) FOCAL ADHESIONS ADD-ON | WARNING: Classification finished. No object has been rejected based on provided criteria.");
    end

    % Iout_ncirc = imerode(Iout_ncirc, strel('sphere', 2));
    % Iout_circ = imerode(Iout_circ, strel('sphere', 2));

    disp("FOCAL ADHESIONS ADD-ON | Classification and labelling finished.");
catch
    Iout_ncirc = [];
    Iout_circ = [];
    labeled_im = [];
    labeled_im_circ = [];
    max_inten = [];
    min_inten = [];
    mean_inten_all = [];
    t_centr = [];
    varargout{1} = [];
    
    disp("(E20) FOCAL ADHESIONS ADD-ON | ERROR: Labelling failed. Object selection failed. Check data and try again.");
end

end