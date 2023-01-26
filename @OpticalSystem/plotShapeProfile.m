function plotShapeProfile(obj, varargin)
% SYNTAX
%   sys.plotShapeProfile(fields)
%   sys.plotShapeProfile(Name, Value, ...)
%       Name - Value can be following pairs
%       'fields':  n-length vector
%       'showrays': {true} | false

[fields, show_rays] = parseArgs(varargin{:});
if ~isempty(fields)
    OpticalSystem.check1D(fields);
end

line_color = [0.337, 0.404, 0.624];
ray_color = [1, 0.267, 0];
line_width = 1.5;
n_min = 1.35;
n_max = 2.35;
surface_num = length(obj.surfaces);
field_num = length(fields);

pupil = obj.getPupils();
ray_num = 7;
d_line = get_fraunhofer_line('d');

hold on;

% Plot surfaces
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
        if obj.surfaces(i).glass.is_reflective
            curr_reverse_prop = ~curr_reverse_prop;
        end
        tmp_x1 = obj.surfaces(i).getShapeProfile(tmp_y) + curr_z;
        tmp_x2 = obj.surfaces(i+1).getShapeProfile(tmp_y) + curr_z + ...
            obj.surfaces(i).t * (1 - 2 * curr_reverse_prop);
        a = min(max((obj.surfaces(i).glass.nd - n_min) / (n_max - n_min), 0), 1);
        fill_color = [1, 1, 1] * (1 - a) + line_color * a;
        patch([tmp_x1, tmp_x2], [tmp_y, wrev(tmp_y)], fill_color, 'EdgeColor', 'none');
        curr_z = curr_z + obj.surfaces(i).t * (1 - 2 * curr_reverse_prop);
    end

    % Draw the surface
    curr_reverse_prop = reverse_prop;
    curr_z = total_z;
    for i = ind:glass_last_ind
        if obj.surfaces(i).glass.is_reflective
            curr_reverse_prop = ~curr_reverse_prop;
        end
        tmp_x = obj.surfaces(i).getShapeProfile(tmp_y) + curr_z;
        plot(tmp_x, tmp_y, 'Color', line_color, 'LineWidth', line_width);
        curr_z = curr_z + obj.surfaces(i).t * (1 - 2 * curr_reverse_prop);
    end

    if obj.surfaces(ind).glass.is_reflective
        reverse_prop = ~reverse_prop;
    end

    % Draw the lens edge
    tmp_x1 = obj.surfaces(ind).getShapeProfile(curr_h) + total_z;
    tmp_x2 = obj.surfaces(glass_last_ind).getShapeProfile(curr_h) + ...
        curr_z - obj.surfaces(glass_last_ind).t * (1 - 2 * reverse_prop);
    plot([tmp_x1, tmp_x2], [1, 1] * curr_h, ...
        'Color', line_color, 'LineWidth', line_width);
    plot([tmp_x1, tmp_x2], -[1, 1] * curr_h, ...
        'Color', line_color, 'LineWidth', line_width);

    total_z = curr_z;
    ind = glass_last_ind + 1;
end


% Plot rays
if show_rays
    sys_data = obj.makeInternalSystemData(d_line);
    sys_data = cat(1, sys_data, zeros(1, size(sys_data, 2), size(sys_data, 3)));
    sys_data(end, 3, :) = 1;
    init_ray_dist = abs(obj.getFocalLength(0, d_line)) * 0.05;
    for fi = 1:field_num
        rays = [zeros(ray_num, 1), linspace(-pupil(1, 2), pupil(1, 2), ray_num)', ...
            ones(ray_num, 1) * pupil(1, 1), ...
            zeros(ray_num, 1), sind(fields(fi)) * ones(ray_num, 1), ...
            cosd(fields(fi)) * ones(ray_num, 1)];
        rays_store = OpticalSystem.traceRays(rays, sys_data);
        z = squeeze(rays_store(:, 3, :));
        y = squeeze(rays_store(:, 2, :));
        valid_ray_ind = all(bsxfun(@le, abs(y(:, 1:end-1)), sys_data(1:end-1, 4)'), 2);
        z = z(valid_ray_ind, :);
        y = y(valid_ray_ind, :);
        tmp_z = [-rays(valid_ray_ind,6)*init_ray_dist + z(:,1), z];
        tmp_y = [-rays(valid_ray_ind,5)*init_ray_dist + y(:,1), y];
        plot(tmp_z', tmp_y', 'Color', ray_color);
    end
end

axis equal; axis tight; axis off;
end


function [fields, show_rays] = parseArgs(varargin)
if nargin == 1
    fields = varargin{1};
    show_rays = true;
elseif nargin > 1 && mod(nargin, 2) == 0
    show_rays = true;
    fields = 0;
    for i = 1:2:nargin
        name = varargin{i};
        value = varargin{i+1};
        if strcmpi(name, 'fields')
            fields = value;
        elseif strcmpi(name, 'showrays')
            show_rays = value;
        else
            warning('Invalid name: %s. Ignore the value.', name);
        end
    end
else
    error('Invalid input arguments!');
end
end