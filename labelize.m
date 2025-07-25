function [bndrs, labeled_image, dmode_l_im, num_objects] = labelize(Iout)

    [bndrs, labeled_image] = bwboundaries(Iout, 'noholes');
    num_objects = max(max(labeled_image));
    l_im = label2rgb(labeled_image);
    dmode_l_im = l_im;
    dmode_l_im(dmode_l_im == 255) = 0; %lub 255!

end