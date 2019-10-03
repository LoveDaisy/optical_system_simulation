function l = getBackWorkingLength(obj, h, lambda)
% INPUT
%   obj:        OpticalSystem object
%   h:          n-length vector, entry aperture height
%   lambda:     m-length vector, wavelength
% OUTPUT
%   l:          n*m matrix, rear working length (w.r.t h and lambda)

OpticalSystem.check1D(h);
OpticalSystem.check1D(lambda);

gaussian_wl = getGaussianBackWorkingLength(obj, lambda);
gaussian_wl = reshape(gaussian_wl, 1, []);
gaussian_index = h(:) < 1e-8;

ray_num = length(h);
wl_num = length(lambda);

init_ray_pts = [zeros(ray_num, 1), h(:), zeros(ray_num, 1)];
init_ray_dir = [zeros(ray_num, 2), ones(ray_num, 1)];

sys_data = obj.makeInternalSystemData(lambda);
total_z = obj.getTotalThickness();
rays_store = OpticalSystem.traceRays([init_ray_pts, init_ray_dir], sys_data);

l = reshape(rays_store(:, 3, end, :) - total_z - rays_store(:, 2, end, :) .* ...
        rays_store(:, 6, end, :) ./ rays_store(:, 5, end, :), ray_num, wl_num);

for i = 1:length(gaussian_wl)
    l(gaussian_index, i) = gaussian_wl(i);
end
end