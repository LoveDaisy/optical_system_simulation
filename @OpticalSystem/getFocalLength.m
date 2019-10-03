function f = getFocalLength(obj, h, lambda)
% INPUT
%   obj:        OpticalSystem object
%   h:          n-vector, ray entry height
%   lambda:     m-vector, wavelength

OpticalSystem.check1D(h);
OpticalSystem.check1D(lambda);

gaussian_f = getGaussianFocalLength(obj, lambda);
gaussian_f = reshape(gaussian_f, 1, []);
gaussian_index = h(:) < 1e-8;

ray_num = length(h);
wl_num = length(lambda);

f = nan(ray_num, wl_num);
init_rays = [zeros(ray_num, 1), h(:), zeros(ray_num, 3), ones(ray_num, 1)];
init_rays = init_rays(~gaussian_index, :);

if ~isempty(init_rays)
    sys_data = obj.makeInternalSystemData(lambda);
    rays_store = OpticalSystem.traceRays(init_rays, sys_data);

    f(~gaussian_index, :) = bsxfun(@times, reshape(h(~gaussian_index), [], 1), ...
        reshape(-rays_store(:, 6, end, :) ./ ...
        rays_store(:, 5, end, :), [], wl_num));
end

for i = 1:wl_num
    f(gaussian_index, i) = gaussian_f(i);
end
end