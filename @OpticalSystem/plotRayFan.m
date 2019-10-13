function plotRayFan(obj, lambda, field_angle, varargin)
% INPUT
%   obj:            OpticalSystem object
%   lambda:         n-vector, wavelength
%   field_angle:    m-vector, field angle, in degree
% OPTIONAL INPUT
%   image_curvature:    scalar
%   'YLim':             2-vector

OpticalSystem.check1D(lambda);
OpticalSystem.check1D(field_angle);

if length(varargin) >= 1 && isscalar(varargin{1})
    image_curvature = varargin{1};
else
    image_curvature = 0;
end
if length(varargin) >= 3 && ischar(varargin{2}) && strcmpi(varargin{2}, 'ylim')
    OpticalSystem.check1D(varargin{3});
    if isnumeric(varargin{3}) && length(varargin{3}) >= 2
        ylim = varargin{3};
    else
        error('YLim should be 2-length vector [y_min, y_max]!');
    end
else
    ylim = [];
end

line_colors = spec_to_rgb([lambda(:), ones(length(lambda), 1)], 'maxy', 1.2);

wl_num = length(lambda);
angle_num = length(field_angle);

pupils = obj.getPupils();
pr = pupils(1, 2);

d_line = get_fraunhofer_line('d');
airy_disk_r = 1.22 * d_line * 1e-9 / (2 * pr * 1e-3) * ...
    obj.getFocalLength(0, d_line);

fan_ray_num = 50;

% Tangential input rays
ty = linspace(-pr, pr, fan_ray_num - 1);
ty = [0; ty(:)];
tangential_pts = zeros(fan_ray_num, 2, wl_num, angle_num);
for i = 1:angle_num
    ray_pts = [zeros(fan_ray_num, 1), ty, zeros(fan_ray_num, 1)];
    ray_dir = [zeros(fan_ray_num, 1), ...
        sind(field_angle(i)) * ones(fan_ray_num, 1), ...
        cosd(field_angle(i)) * ones(fan_ray_num, 1)];
    tangential_pts(:, :, :, i) = obj.traceRayInterception([ray_pts, ray_dir], lambda, image_curvature);
    pts0 = obj.traceRayInterception([ray_pts(1,:), ray_dir(1,:)], lambda, ...
        image_curvature, false);
    tangential_pts(:, :, :, i) = bsxfun(@minus, tangential_pts(:, :, :, i), pts0);
end

% Sagittal input rays
sx = linspace(0, pr, fan_ray_num);
sx = sx(:);
sagittal_pts = zeros(fan_ray_num, 2, wl_num, angle_num);
for i = 1:angle_num
    ray_pts = [sx, zeros(fan_ray_num, 2)];
    ray_dir = [zeros(fan_ray_num, 1), ...
        sind(field_angle(i)) * ones(fan_ray_num, 1), ...
        cosd(field_angle(i)) * ones(fan_ray_num, 1)];
    sagittal_pts(:, :, :, i) = obj.traceRayInterception([ray_pts, ray_dir], lambda, image_curvature);
    pts0 = obj.traceRayInterception([ray_pts(1,:), ray_dir(1,:)], lambda, ...
        image_curvature, false);
    sagittal_pts(:, :, :, i) = bsxfun(@minus, sagittal_pts(:, :, :, i), pts0);
end

d_min = min(min(reshape(tangential_pts(:, 2, :, :), [], 1)), ...
    min(reshape(sagittal_pts(:, 1, :, :), [], 1)));
d_max = max(max(reshape(tangential_pts(:, 2, :, :), [], 1)), ...
    max(reshape(sagittal_pts(:, 1, :, :), [], 1)));
if isempty(ylim)
    ylim = [min(d_min, -airy_disk_r), max(d_max, airy_disk_r)];
end


margins = [0.07, 0.08, 0.13, 0.15];   % top, right, bottom, left
spacings = [0.04, 0.075];  % horizontal, vertical
subplot_w = (1 - spacings(1) - margins(2) - margins(4)) / 3;
subplot_h = (1 - spacings(2)*(angle_num - 1) - margins(1) - margins(3)) / angle_num;

% Axis title
subplot('Position', [0, 0, margins(4), 1]);
text(0.35, 0.5, 'Lateral aberration (mm)', 'FontSize', 14, 'Rotation', 90, ...
    'HorizontalAlignment', 'center');
axis off;

subplot('Position', [margins(4), 1 - margins(1), subplot_w * 2, margins(1)]);
text(0.5, 0.5, '$$\Delta y$$', 'FontSize', 14, 'Rotation', 0, ...
    'HorizontalAlignment', 'center', 'Interpreter', 'latex');
axis off;

subplot('Position', [margins(4) + subplot_w * 2 + spacings(1), 1 - margins(1), subplot_w, margins(1)]);
text(0.5, 0.5, '$$\Delta x$$', 'FontSize', 14, 'Rotation', 0, ...
    'HorizontalAlignment', 'center', 'Interpreter', 'latex');
axis off;

% Tangential
for i = 1:angle_num
    subplot('Position', [margins(4), ...
        margins(3) + (subplot_h + spacings(2)) * (angle_num - i), ...
        subplot_w*2, subplot_h]);

    hold on;
    plot([-1, 1], [1, 1] * airy_disk_r, 'k:', 'linewidth', 0.5);
    plot([-1, 1], -[1, 1] * airy_disk_r, 'k:', 'linewidth', 0.5);
    for k = 1:wl_num
        plot(ty(2:end) / pr, tangential_pts(2:end, 2, k, i), ...
            'linewidth', 1.5, ...
            'color', line_colors(k, :));
    end
    box on;
    set(gca, 'xlim', [-1.05, 1.05], 'ylim', ylim*1.3, 'FontSize', 12, 'TickLength', [0.012, 0.005]);
    if i == angle_num
        xlabel('Relative entrance pupil', 'FontSize', 14);
    end
    ylabel(sprintf('$$%.2f^\\circ$$', field_angle(i)), 'FontSize', 14, ...
        'Interpreter', 'latex');
end

% Sagittal
for i = 1:angle_num
    subplot('Position', [margins(4) + spacings(1) + subplot_w*2, ...
        margins(3) + (subplot_h + spacings(2)) * (angle_num - i), ...
        subplot_w, subplot_h]);

    hold on;
    plot([0, 1], [1, 1] * airy_disk_r, 'k:', 'linewidth', 0.5);
    plot([0, 1], -[1, 1] * airy_disk_r, 'k:', 'linewidth', 0.5);
    for k = 1:wl_num
        plot(sx(2:end) / pr, sagittal_pts(2:end, 1, k, i), ...
            'linewidth', 1.5, ...
            'color', line_colors(k, :));
    end
    box on;
    set(gca, 'xlim', [0, 1.05], 'ylim', ylim*1.3, 'YAxisLocation', 'right', 'FontSize', 12, ...
        'TickLength', [0.012, 0.005]*2);
    if i == angle_num
        xlabel('Relative entrance pupil', 'FontSize', 14);
    end
end

end