function plotShapeProfiler(obj)
% INPUT
%   obj:        OpticalSystem object

line_color = [0.337, 0.404, 0.624];
line_width = 1.5;
n_min = 1.35;
n_max = 2.35;
surface_num = length(obj.surfaces);

hold on;

ind = 1;
total_z = 0;
reverse_prop = false;
while ind <= surface_num
    glass_last_ind = ind;
    curr_h = obj.surfaces(glass_last_ind).ah;
    while ~strcmpi(obj.surfaces(glass_last_ind).glass.name, 'air')
        glass_last_ind = glass_last_ind + 1;
        curr_h = max(curr_h, obj.surfaces(glass_last_ind).ah);
    end

    tmp_y = linspace(-curr_h, curr_h, 100);

    % Fill the color
    curr_reverse_prop = reverse_prop;
    curr_z = total_z;
    for i = ind:glass_last_ind-1
        tmp_x1 = obj.surfaces(i).c * tmp_y.^2 ./ ...
            (1 + sqrt(1 - obj.surfaces(i).c^2 * tmp_y.^2)) + curr_z;
        tmp_x2 = obj.surfaces(i+1).c * tmp_y.^2 ./ ...
            (1 + sqrt(1 - obj.surfaces(i+1).c^2 * tmp_y.^2)) + curr_z + obj.surfaces(i).t;
        a = min(max((obj.surfaces(i).glass.nd - n_min) / (n_max - n_min), 0), 1);
        fill_color = [1, 1, 1] * (1 - a) + line_color * a;
        patch([tmp_x1, tmp_x2], [tmp_y, wrev(tmp_y)], fill_color, 'EdgeColor', 'none');
        if obj.surfaces(i).glass.is_reflective
            curr_reverse_prop = ~curr_reverse_prop;
        end
        curr_z = curr_z + obj.surfaces(i).t * (1 - 2 * curr_reverse_prop);
    end

    % Draw the surface
    curr_reverse_prop = reverse_prop;
    curr_z = total_z;
    for i = ind:glass_last_ind
        tmp_x = obj.surfaces(i).c * tmp_y.^2 ./ ...
            (1 + sqrt(1 - obj.surfaces(i).c^2 * tmp_y.^2)) + curr_z;
        plot(tmp_x, tmp_y, 'Color', line_color, 'LineWidth', line_width);
        if obj.surfaces(i).glass.is_reflective
            curr_reverse_prop = ~curr_reverse_prop;
        end
        curr_z = curr_z + obj.surfaces(i).t * (1 - 2 * curr_reverse_prop);
    end

    if obj.surfaces(ind).glass.is_reflective
        reverse_prop = ~reverse_prop;
    end

    % Draw the lens edge
    tmp_x1 = obj.surfaces(ind).c * curr_h^2 / ...
        (1 + sqrt(1 - obj.surfaces(ind).c^2 * curr_h^2)) + total_z;
    tmp_x2 = obj.surfaces(glass_last_ind).c * curr_h^2 / ...
        (1 + sqrt(1 - obj.surfaces(glass_last_ind).c^2 * curr_h^2)) + ...
        curr_z - obj.surfaces(glass_last_ind).t * (1 - 2 * reverse_prop);
    plot([tmp_x1, tmp_x2], [1, 1] * curr_h, ...
        'Color', line_color, 'LineWidth', line_width);
    plot([tmp_x1, tmp_x2], -[1, 1] * curr_h, ...
        'Color', line_color, 'LineWidth', line_width);

    total_z = curr_z;
    ind = glass_last_ind + 1;
end

axis equal; axis off;
end