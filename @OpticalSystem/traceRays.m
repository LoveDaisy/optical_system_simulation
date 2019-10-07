function rays_store = traceRays(rays, sys_data)
% INPUT
%   rays:       n*6, [x, y, z, dx, dy, dz]
%   sys_data:   m*k*l, the system data of OpticalSystem object. m is surface number,
%               k is dimension of data of a surface, l is the wavelength number.
%               The data of a surface is like:
%               [c, t, n, H_max, is_AST, conic_k, asph_type, asph_coefs]
% OUTPUT
%   rays_store: n*6*m*l, rays at each surface

if size(rays, 2) ~= 6
    error('size(rays, 2) must be 6! [x, y, z, dx, dy, dz]');
end
if length(size(sys_data)) ~= 2 && length(size(sys_data)) ~= 3
    error('sys_data must be 2D or 3D array!');
end

surface_num = size(sys_data, 1);
wl_num = size(sys_data, 3);
ray_num = size(rays, 1);

rays_store = zeros(ray_num, 6, surface_num, wl_num);

for k = 1:wl_num
    ray_pts = rays(:, 1:3);
    ray_dir = rays(:, 4:6);

    prev_n = 1;
    dz = 0;
    for i = 1:surface_num
        curr_c = sys_data(i, 1, k);
        curr_t = sys_data(i, 2, k);
        curr_n = sys_data(i, 3, k);
        curr_conic = sys_data(i, 6, k);

        ray_pts = OpticalSystem.intersectWithConic(ray_pts, ray_dir, curr_c, curr_conic);
        ray_dir = OpticalSystem.refractAtConic([ray_pts, ray_dir], ...
            prev_n / curr_n, curr_c, curr_conic);
        prev_n = curr_n;

        rays_store(:, 1:3, i, k) = ray_pts;
        rays_store(:, 3, i, k) = rays_store(:, 3, i, k) + dz;
        rays_store(:, 4:6, i, k) = ray_dir;

        if i < surface_num
            ray_pts(:, 3) = ray_pts(:, 3) - curr_t;
            dz = dz + curr_t;
        end
    end
end
end