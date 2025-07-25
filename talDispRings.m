function talDispRings(data1, ir_rings, ring_number, contrast_visual_flag, lh_lim_user)

try
    if (ring_number <= size(ir_rings,3))
    tt = data1;   
    tt(ir_rings(:,:,ring_number) == 1) = 1;
    if ~contrast_visual_flag
        data_overlay_ir = cat(3, im2uint16(tt), imadjust(data1, lh_lim_user), im2uint16(data1));
    else
        data_overlay_ir = cat(3, im2uint16(tt), im2uint16(data1), im2uint16(data1));
    end
    figure(500);
    imshow(data_overlay_ir);
    
    disp("Ring area image has been successfully displayed.");
    else
        disp(strcat("(W9) FOCAL ADHESIONS ADD-ON | WARNING: Ring area number exceeds the number of found ring areas. The maximum ring area number is ", ...
            num2str(size(ir_rings,3)), ". Reload data and try again."));
    end
catch
    disp("(W10) FOCAL ADHESIONS ADD-ON | WARNING: Ring area image cannot be displayed. Check data.");
end

end