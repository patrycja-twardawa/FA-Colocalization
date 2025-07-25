function I_adapt = talsegment(B3, binarization_met, segm_threshold, T_threshold)

try
    disp("Segmentation started... Please wait.");
    
    B3 = rescale(im2double(B3), 0, 1); %normalize
    
    if ~binarization_met %segmentation
        I_adapt = imbinarize(B3, 'adaptive', 'sensitivity', 0.0001); %local thresholding, low sensitivity (less pixels as foreground)
    elseif binarization_met == 1
        I_adapt = imbinarize(B3, segm_threshold); %global thresholding
    elseif binarization_met == 2
        I_adapt = imbinarize(B3, 'adaptive'); %local thresholding, automated sensitivity
    else
        T = graythresh(B3); %global thresholding, automated Otsu thresholds
        I_adapt = imbinarize(B3, T);
        if (T_threshold ~= 1)
            T_gain = 1 / mean(mean(B3(I_adapt)));
            I_adapt = imbinarize(B3, T*T_gain);
        end
    end

    se = strel('sphere', 2);
    I_adapt = imopen(I_adapt, se); %clearing 1-px wide noise
    
    disp("Segmentation finished.");
catch
    disp("(E11) ERROR: Segmentation failed. Check workspace data and try again after repeating former steps.");
end
    
end