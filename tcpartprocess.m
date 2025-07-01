function G = tcpartprocess(data1, se, denoise_flag, filt_flag, rb_flag, rb_method, rb_thresh, gauss_sd)

    B1 = imdenoise(data1, se, denoise_flag); %denoising
    B3 = talbgsubtraction(B1, rb_flag, rb_method, rb_thresh, se); %background subtraction
    
    if filt_flag
        G = imgaussfilt(double(B3), gauss_sd); %Gaussian filtering %B4 = G >= 0.2;
        disp("Image filtered (Gaussian filtering).");
    elseif ~filt_flag
        G = imbilatfilt(B3, 0.1); %Bilateral filtering with 0.1 degree of smoothing
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
    
end