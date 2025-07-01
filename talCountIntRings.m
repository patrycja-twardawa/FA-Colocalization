function [int_rings_tab, varargout] = talCountIntRings(binaryImage, data0, int_rings_tab, ...
    ring_diameter, ring_flag_mod, varargin)

try
    if ~isempty(ring_diameter)
        bin_temp = binaryImage;

        if any(any(bin_temp))

            int_rings = struct('MeanInten', [], 'MinInten', [], 'MaxInten', [], 'Area', [], ...
                'BorderDistance', [], 'MeanIntenNorm', [], 'ObjectsOverlapping', []);
            temp_dist = 0;
            ring_flag = 1;  
            ir_maps = [];
            iter = 1;

            if ring_flag_mod %get the basic values
                while ring_flag

                    temp_dist = temp_dist + ring_diameter;

                    ir_map = xor(bin_temp, imerode(bin_temp, strel('disk', ring_diameter)));
                    int_rings.MeanInten = [int_rings.MeanInten; mean(mean(data0(ir_map)))];
                    int_rings.MinInten = [int_rings.MinInten; min(min(data0(ir_map)))];
                    int_rings.MaxInten = [int_rings.MaxInten; max(max(data0(ir_map)))];
                    int_rings.Area = [int_rings.Area; numel(find(ir_map))];
                    int_rings.BorderDistance = [int_rings.BorderDistance; temp_dist];

                    ir_maps(:,:,iter) = ir_map;
                    iter = iter + 1;

                    bin_temp = and(bin_temp, imerode(bin_temp, strel('disk', ring_diameter)));

                    if ~any(any(bin_temp))
                        ring_flag = 0;
                    end

                end

                int_rings.MeanIntenNorm = int_rings.MeanInten ./ double(max(int_rings.MeanInten));
                int_rings.ObjectsOverlapping = zeros(size(int_rings.Area));

                int_rings_tab = struct2table(int_rings, "AsArray", false); 
                varargout{1} = ir_maps;
                disp("Intensities have been assessed successfully for the 'ring areas'.");
            else %correct for label number in rings after labelling 
                try
                    io_overlap = [];
                    labeled_im = varargin{1};
                    Iout_ncirc = varargin{2};

                    while ring_flag

                        ir_map = xor(bin_temp, imerode(bin_temp, strel('disk', ring_diameter)));                   
                        t_map = and(ir_map, Iout_ncirc);
                        t_objects = unique(labeled_im(t_map), 'sorted');

                        if (~isempty(t_objects) && t_objects(1) == 0)
                            t_objects(1) = [];
                        end

                        io_overlap = [io_overlap; numel(t_objects)];
                        bin_temp = and(bin_temp, imerode(bin_temp, strel('disk', ring_diameter)));

                        if ~any(any(bin_temp))
                            ring_flag = 0;
                        end

                    end %while 

                    int_rings_tab.ObjectsOverlapping = io_overlap;
                    disp("Data for number of objects in rings of given diameter added successfully to the table.");

                catch
                    disp("(E15) FOCAL ADHESIONS ADD-ON | ERROR: Objects in chosen rings of given diameter cannot be counted. Check data and try again.");
                end                     
            end %if mod       
        else
            disp("(E16) FOCAL ADHESIONS ADD-ON | ERROR: There is no object to erode from. Check data and assign ROI again.");
        end
    else
        disp("(E17) FOCAL ADHESIONS ADD-ON | ERROR: Ring diameter not provided. Please check your data and try again.");
    end
catch
    disp("(E18) FOCAL ADHESIONS ADD-ON | ERROR: Failure during processing of ring areas. Check data and assign ROI again.");
end

end