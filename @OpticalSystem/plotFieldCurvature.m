function plotFieldCurvature(obj, full_angle, varargin)
% INPUT
%   obj:        OpticalSystem object
%   full_angle: full field angle
% OPTIONAL INPUT
%   lambda:     1-D vector, wavelength
%   ref_c:      scalar

d_line = get_fraunhofer_line('d');
lambda = d_line;
ref_c = 0;

if length(varargin) >= 1
    lambda = varargin{1};
    OpticalSystem.check1D(lambda);
end
if length(varargin) >= 2
    if ~isscalar(varargin{2})
        error('ref_c must be a scalar!');
    end
    ref_c = varargin{2};
end
wl_num = length(lambda);
line_colors = spec_to_rgb([lambda(:), ones(wl_num, 1)], 'y', 1.5, 'Mixed', false);
line_width = 2;
notation_height = 0.92;

pupil = obj.getPupils();
sys_data = obj.makeInternalSystemData(lambda);

field_samples = 100;
fields = linspace(0, full_angle, 100);

main_rays = [zeros(field_samples, 2),  pupil(1, 1) * ones(field_samples, 1), ...
    zeros(field_samples, 1), sind(fields(:)), cosd(fields(:))];

% Tangential
t_rays = main_rays;
t_rays(:, 2) = t_rays(:, 2) + 1e-3 * pupil(1, 2);

% Sagittal
s_rays = main_rays;
s_rays(:, 1) = s_rays(:, 1) + 1e-3 * pupil(1, 2);

rays_store = OpticalSystem.traceRays([main_rays; t_rays; s_rays], sys_data);
total_z = obj.getTotalThickness();
l0 = obj.getBackWorkingLength(0, d_line);
f0 = obj.getFocalLength(0, d_line);

hold on;
plot([0, 0], [0, full_angle], 'k:', 'LineWidth', 1);
if abs(ref_c) > 1e-5
    plot((1 - cosd(atand(tand(fields) * f0 * ref_c))) / ref_c, fields, ...
        'k', 'LineWidth', 1);
end
notation_dx = nan;
for i = 1:wl_num
    curr_main_rays = rays_store(1:field_samples, :, end, i);
    curr_t_rays = rays_store((1:field_samples)+field_samples, :, end, i);
    curr_s_rays = rays_store((1:field_samples)+2*field_samples, :, end, i);

    dp = curr_main_rays(:, 1:3) - curr_t_rays(:, 1:3);
    d1 = curr_main_rays(:, 4:6);
    d2 = curr_t_rays(:, 4:6);
    t_focus = bsxfun(@times, (sum(d2 .* d2, 2) .* sum(dp .* d1, 2) - ...
        sum(d1 .* d2, 2) .* sum(dp .* d2, 2)) ./ ...
        (sum(d1 .* d2, 2).^2 - sum(d1 .* d1, 2) .* sum(d2 .* d2, 2)), d1) + curr_main_rays(:, 1:3);
    plot(t_focus(:, 3) - (total_z + l0), fields, 'LineWidth', line_width, 'Color', line_colors(i, :));

    dp = curr_main_rays(:, 1:3) - curr_s_rays(:, 1:3);
    d1 = curr_main_rays(:, 4:6);
    d2 = curr_s_rays(:, 4:6);
    s_focus = bsxfun(@times, (sum(d2 .* d2, 2) .* sum(dp .* d1, 2) - ...
        sum(d1 .* d2, 2) .* sum(dp .* d2, 2)) ./ ...
        (sum(d1 .* d2, 2).^2 - sum(d1 .* d1, 2) .* sum(d2 .* d2, 2)), d1) + curr_main_rays(:, 1:3);
    plot(s_focus(:, 3) - (total_z + l0), fields, '--', 'LineWidth', line_width, 'Color', line_colors(i, :));

    if isnan(notation_dx)
        notation_dx = (max([t_focus(:, 3) - (total_z + l0); s_focus(:, 3) - (total_z + l0)]) - ...
            min([t_focus(:, 3) - (total_z + l0); s_focus(:, 3) - (total_z + l0)])) * 0.07;
    end
    text(t_focus(floor(field_samples * notation_height), 3) - (total_z + l0) + notation_dx, ...
        notation_height * full_angle, ...
        'T', 'Color', line_colors(i, :), 'FontSize', 12);
    text(s_focus(floor(field_samples * notation_height), 3) - (total_z + l0) + notation_dx, ...
        notation_height * full_angle, ...
        'S', 'Color', line_colors(i, :), 'FontSize', 12);
end

box on;
set(gca, 'FontSize', 12, 'YLim', [0, full_angle]);
xlabel('Focus shift (mm)', 'FontSize', 14);
ylabel('Field angle (degree)', 'FontSize', 14);
title('Field curvature plot', 'FontSize', 16);
end