function B1 = imdenoise(data1, se, denoise_flag)

try
    disp("Denoising in operation... Please wait.");

    if ~denoise_flag
        B1 = data1;
        disp("Denoising is OFF.");
    elseif (denoise_flag == 1)
        net = denoisingNetwork('DnCNN');
        B1 = denoiseImage(data1, net); 
        disp("Denoising finished.");
    else
        B1 = imopen(data1, se); 
    end

catch
    disp("(W7) WARNING: Denoising failed. You can proceed further without image modification.");
end

end