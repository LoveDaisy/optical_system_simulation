function obj = solveApertureHeight(obj, f_number, full_field_angle)
% SYNTAX
%   sys.solveApertureHeight(f_number, full_field_angle)

% Parse input arguments
parser = inputParser;
parser.FunctionName = 'solveApertureHeight';
parser.addRequired('FNumber', @(x) isscalar(x));
parser.addRequired('Field', @(x) isscalar(x));
parser.parse(f_number, full_field_angle);

% === Determine height of aperture stop in Gaussian solution ===
d_line = get_fraunhofer_line('d');

% Trace a Gaussian ray of [0, y]
ray_state = traceGaussianRay(obj, [0, 1], d_line);
aperture_stop_height = (1 / f_number / 2) / -ray_state(3, end) * ray_state(2, obj.ast);

% === Back trace from aperture stop ===
[front_sys, ~] = obj.splitAt(obj.ast);
upper_ray_state = traceGaussianRay(front_sys, [0, aperture_stop_height], d_line);
lower_ray_state = traceGaussianRay(front_sys, [0, -aperture_stop_height], d_line);
center_ray_state = traceGaussianRay(front_sys, [-1, 0], d_line);

entry_center_ray = tand(full_field_angle) / center_ray_state(3, end) * ...
    center_ray_state(3:4, end);

upper_u = -(entry_center_ray(1) - upper_ray_state(3, end)) / center_ray_state(3, end);
ray_state = traceGaussianRay(front_sys, [upper_u, aperture_stop_height], d_line);
entry_upper_ray = ray_state(3:4, end);
lower_u = -(entry_center_ray(1) - lower_ray_state(3, end)) / center_ray_state(3, end);
ray_state = traceGaussianRay(front_sys, [lower_u, -aperture_stop_height], d_line);
entry_lower_ray = ray_state(3:4, end);

upper_ray_state = traceGaussianRay(obj, entry_upper_ray, d_line);
lower_ray_state = traceGaussianRay(obj, entry_lower_ray, d_line);
surface_num = length(obj.surfaces);
for i = 1:surface_num
    obj.surfaces(i).ah = max(abs([upper_ray_state(4, i), lower_ray_state(4, i)]));
end
end


function gaussian_ray_state = traceGaussianRay(sys, init_ray, lambda)
surface_num = length(sys.surfaces);
[~, t_mat, r_mat] = sys.makeGaussianSystemMatrix(lambda);
gaussian_ray_state = zeros(4, surface_num);
gaussian_ray_state(1:2, 1) = init_ray;
for i = 1:surface_num
    gaussian_ray_state(3:4, i) = r_mat(:, :, i) * gaussian_ray_state(1:2, i);
    if i < surface_num
        gaussian_ray_state(1:2, i + 1) = t_mat(:, :, i) * gaussian_ray_state(3:4, i);
    end
end
end