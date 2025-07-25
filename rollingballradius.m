function [data1] = rollingballradius(data0, radius, method)
 
SE = strel('sphere', radius);
if (method == 1)
    data_temp = imopen(data0, SE); 
    data1 = data0 - data_temp;
else
    data_temp = imclose(data0, SE);
    data1 = data0 - (255-data_temp);
end

end