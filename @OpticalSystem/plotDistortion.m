function plotDistortion(obj, full_angle, varargin)
% INPUT
%   obj:        OpticalSystem object
%   full_angle: full field angle
% OPTIONAL INPUT
%   lambda:     1-D vector, wavelength

d_line = util.get_fraunhofer_line('d');
lambda = d_line;

if length(varargin) >= 1
    lambda = varargin{1};
    OpticalSystem.check1D(lambda);
end
wl_num = length(lambda);
surface_num = length(obj.surfaces);
line_colors = spec_to_rgb([lambda(:), ones(wl_num, 1)], 'y', 1.5, 'Mixed', false);
line_width = 2;

pupil = obj.getPupils();

field_samples = 100;
fields = linspace(0, full_angle, 100)';

main_rays = [zeros(field_samples, 2),  pupil(1, 1) * ones(field_samples, 1), ...
    zeros(field_samples, 1), sind(fields(:)), cosd(fields(:))];

pts = obj.traceRayInterception(main_rays, lambda, 0, false);
f0 = obj.getFocalLength(0, d_line);

reverse_prop = false;
for i = 1:surface_num
    if obj.surfaces(i).glass.is_reflective
        reverse_prop = ~reverse_prop;
    end
end
p0 = f0 * (1 - 2 * reverse_prop) * tand(fields);
d = bsxfun(@times, bsxfun(@minus, squeeze(pts(:, 2, :)), p0), ...
    1 ./ p0) * 100;
xlim = [min(min(d(:)), -0.1), max(max(d(:)), 0.1)];

hold on;
plot([0, 0], [0, full_angle], 'k:', 'LineWidth', 1);
for i = 1:wl_num
    plot(d(:, i), fields, ...
        'Color', line_colors(i, :), 'LineWidth', line_width);
end

box on;
set(gca, 'FontSize', 12, 'YLim', [0, full_angle], 'XLim', xlim);
xlabel('Distortion (%)', 'FontSize', 14);
ylabel('Field angle (degree)', 'FontSize', 14);
title('Distortion plot', 'FontSize', 16);
end