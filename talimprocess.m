function [B1, B3, B5, B6, B6_nucl, G, J, I_adapt, param_flag] = talimprocess(data1, se, denoise_flag, filt_flag, ...
    rb_flag, rb_method, rb_thresh, gauss_sd, binarization_met, segm_threshold, binaryImage, binaryImage2)

try
    disp("Image processing for TALIN add-on started...");
    
    [B1, B3] = imdenoise(data1, se, denoise_flag); %denoising
    B3 = talbgsubtraction(data1, rb_flag, rb_method, rb_thresh, se); %background subtraction
    
    if filt_flag
        G = imgaussfilt(double(B3), gauss_sd); %Gaussian filtering %B4 = G >= 0.2;
        disp("Image filtered (Gaussian filtering).");
    elseif ~filt_flag
        G = imbilatfilt(B3,0.1); %Bilateral filtering with 0.1 degree of smoothing
        disp("Image filtered (bilateral filtering with constant degree of smoothing).");
    elseif (filt_flag == 2)
        patch = imcrop(B3,[170, 35, 50 50]); %fragment of bgrnd (POPRAW ŻEBY ZAWSZE WYBIERAŁO TŁO)
        patchVar = std2(patch)^2;
        DoS = 2*patchVar;
        G = imbilatfilt(B3, DoS); %choose degree of smoothing larger than noise variance
        disp("Image filtered (bilateral filtering with degree of smoothing larher than noise variance).");
    else
        G = sgolayfilt(B3, 1, 5); %window frame smaller - smaller blur in Y direction (dir can be chosen), lesser order - more "coherence"
        disp("Image filtered (Savitzky-Golay filtering).");
    end
    J = fibermetric(G, 'StructureSensitivity', 0.015, ...
        'ObjectPolarity', 'bright'); %enhancement of fibers (can apply width if necessary), filtr Hessian
    disp("Fibers enhanced (Hessian based Frangi Vesselness filtering).");
    disp("Processing finished."); 
    
    I_adapt = talsegment(J, binarization_met, segm_threshold); %segmentation, despeckling
    B5 = imfill(I_adapt, 'holes'); %filling holes
    disp("Objects designated.");
 
    B6 = B5;
    B6(~binaryImage) = 0;

    B6_nucl = B5;
    B6_nucl(~binaryImage2) = 0;
    disp("Objects outside CELL ROI cleared.");
    
    param_flag = 1; %able to proceed further to labelling
    disp("Segmentation finished."); 
    
    figure(101); 
    subplot(1,2,1); imshow(B6); title('TALIN ADD-ON | Chosen ROI: cell');
    subplot(1,2,2); imshow(B6_nucl); title('TALIN ADD-ON | Chosen ROI: cell nucleus');
catch
    param_flag = 0; %proceeding disabled
    disp("ERROR | TALIN ADD-ON: Error during image processing and segmentation. Objects have not been designated. Please check data."); 
end

end