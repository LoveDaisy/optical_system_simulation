function plotRayFan(obj, lambda, field_angle, varargin)
% INPUT
%   obj:            OpticalSystem object
%   lambda:         n-vector, wavelength
%   field_angle:    m-vector, field angle, in degree
% OPTIONAL INPUT
%   image_curvature:    scalar

OpticalSystem.check1D(lambda);
OpticalSystem.check1D(field_angle);

if length(varargin) >= 1 && isscalar(varargin{1})
    image_curvature = varargin{1};
else
    image_curvature = 0;
end

line_colors = spec_to_rgb([lambda(:), ones(length(lambda), 1)], 'maxy', 1.2);

wl_num = length(lambda);
angle_num = length(field_angle);

z0 = obj.surfaces(end).t + obj.getTotalThickness();
pupils = obj.getPupils();
pr = pupils(1, 2);
sys_data = obj.makeInternalSystemData(lambda);

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
    tangential_pts(:, :, :, i) = bsxfun(@minus, tangential_pts(:, :, :, i), ...
        tangential_pts(1, :, :, i));
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
    sagittal_pts(:, :, :, i) = bsxfun(@minus, sagittal_pts(:, :, :, i), ...
        sagittal_pts(1, :, :, i));
end

d_min = min(min(reshape(tangential_pts(:, 2, :, :), [], 1)), ...
    min(reshape(sagittal_pts(:, 1, :, :), [], 1)));
d_max = max(max(reshape(tangential_pts(:, 2, :, :), [], 1)), ...
    max(reshape(sagittal_pts(:, 1, :, :), [], 1)));


margins = [0.07, 0.07, 0.1, 0.1];   % top, right, bottom, left
spacings = [0.06, 0.06];  % horizontal, vertical
subplot_w = (1 - spacings(1) - margins(2) - margins(4)) / 3;
subplot_h = (1 - spacings(2)*(angle_num - 1) - margins(1) - margins(3)) / angle_num;

axes_store = cell(angle_num, 2);
% Tangential
for i = 1:angle_num
%     subplot(angle_num, 2, i*2-1);
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
    set(gca, 'xlim', [-1.05, 1.05], 'ylim', [d_min, d_max]*1.3);
    axes_store{i, 1} = gca;
end

% Sagittal
for i = 1:angle_num
%     subplot(angle_num, 2, i*2);
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
    set(gca, 'xlim', [0, 1.05], 'ylim', [d_min, d_max]*1.3);
    axes_store{i, 2} = gca;
end

end