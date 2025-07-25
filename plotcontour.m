function plotcontour(bndrs)

    for i = 1 : length(bndrs)
      boundary = bndrs{i};
      plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2); %kontury
    end

end