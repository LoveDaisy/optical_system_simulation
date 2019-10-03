function plotShapeProfiler(obj)
% INPUT
%   obj:        OpticalSystem object

line_color = [0.337, 0.404, 0.624];
line_width = 1.5;
surface_num = length(obj.surfaces);

hold on;

ind = 1;
total_z = 0;
while ind <= surface_num
    glass_last_ind = ind;
    curr_h = obj.surfaces(glass_last_ind).ah;
    while ~strcmpi(obj.surfaces(glass_last_ind).glass.name, 'air')
        glass_last_ind = glass_last_ind + 1;
        curr_h = max(curr_h, obj.surfaces(glass_last_ind).ah);
    end

    tmp_y = linspace(-curr_h, curr_h, 100);

    % Fill the color
    curr_z = total_z;
    for i = ind:glass_last_ind-1
        tmp_x1 = obj.surfaces(i).c * tmp_y.^2 ./ ...
            (1 + sqrt(1 - obj.surfaces(i).c^2 * tmp_y.^2)) + curr_z;
        tmp_x2 = obj.surfaces(i+1).c * tmp_y.^2 ./ ...
            (1 + sqrt(1 - obj.surfaces(i+1).c^2 * tmp_y.^2)) + curr_z + obj.surfaces(i).t;
        a = min(max((obj.surfaces(i).glass.nd - 1.35) / 1.0, 0), 1);
        fill_color = [1, 1, 1] * (1 - a) + line_color * a;
        patch([tmp_x1, tmp_x2], [tmp_y, wrev(tmp_y)], fill_color, 'EdgeColor', 'none');
        curr_z = curr_z + obj.surfaces(i).t;
    end

    % Draw the surface
    curr_z = total_z;
    for i = ind:glass_last_ind
        tmp_x = obj.surfaces(i).c * tmp_y.^2 ./ ...
            (1 + sqrt(1 - obj.surfaces(i).c^2 * tmp_y.^2)) + curr_z;
        plot(tmp_x, tmp_y, 'Color', line_color, 'LineWidth', line_width);
        curr_z = curr_z + obj.surfaces(i).t;
    end

    % Draw the lens edge
    tmp_x1 = obj.surfaces(ind).c * curr_h^2 / ...
        (1 + sqrt(1 - obj.surfaces(ind).c^2 * curr_h^2)) + total_z;
    tmp_x2 = obj.surfaces(glass_last_ind).c * curr_h^2 / ...
        (1 + sqrt(1 - obj.surfaces(glass_last_ind).c^2 * curr_h^2)) + ...
        curr_z - obj.surfaces(glass_last_ind).t;
    plot([tmp_x1, tmp_x2], [1, 1] * curr_h, ...
        'Color', line_color, 'LineWidth', line_width);
    plot([tmp_x1, tmp_x2], -[1, 1] * curr_h, ...
        'Color', line_color, 'LineWidth', line_width);

    total_z = curr_z;
    ind = glass_last_ind + 1;
end

axis equal; axis off;
end