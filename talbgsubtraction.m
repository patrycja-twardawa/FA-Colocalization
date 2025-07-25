function data1 = talbgsubtraction(data0, rb_flag, rb_method, rb_thresh, se)

try
    if ~rb_flag
        data1 = data0;
        disp("Background subtraction is OFF.");
    else
        disp("Background subtraction started... Please wait.");
        
        if ~rb_method
            data1 = rollingballradius(data0, rb_thresh, 1);
        else
            data_temp = imopen(data0, se);
            data1 = data0 - data_temp;
        end
        
        disp("Background subtracted.");
    end
catch
    disp("(W8) WARNING: Background subtraction failed. You can proceed further with unsubtracted background.");
end

end