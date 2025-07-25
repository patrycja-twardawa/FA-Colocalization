function plotetqts(centr_table, num_objects, varargin) %wors, cols

if ~isempty(varargin)
    f_size = 30;
    f_colour = '\color{black}';
else
    f_size = 8;
    f_colour = '\color{white}';
end

    for i = 1 : num_objects
        text(centr_table(i,2), centr_table(i,1), sprintf('%s', strcat(f_colour, '\bf', num2str(i))), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', f_size); %najpierw kolumny, potem rzędy: t(1) - kol., t(2) - rzęd.
    end
    hold on;

end