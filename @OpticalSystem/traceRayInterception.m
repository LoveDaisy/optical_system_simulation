function pts = traceRayInterception(obj, init_rays, varargin)
% INPUT
%   obj:        OpticalSystem object
%   init_rays:  n*6, rays, [x, y, z, dx, dy, dz]
% OPTIONAL INPUT
%   lambda:     m-vector, wavelength
%   ci:         scalar, curvature of image sphere
% OUTPUT
%   pts:        n*2*m array

if size(init_rays, 2) ~= 6
    error('Rays must be like [x, y, z, dx, dy, dz]');
end
[lambda, ci] = parse_args(varargin);

wl_num = length(lambda);
ray_num = size(init_rays, 1);

z0 = obj.surfaces(end).t + obj.getTotalThickness();

pts = zeros(ray_num, 2, wl_num);
for i = 1:wl_num
    sys_data = obj.makeInternalSystemData(lambda(i));
    rays_store = OpticalSystem.traceRays(init_rays, sys_data);

    tmp_rays = rays_store(:, :, end);
    tmp_rays(:, 3) = tmp_rays(:, 3) - z0;
    tmp_pts = OpticalSystem.intersectWithConic(tmp_rays(:, 1:3), tmp_rays(:, 4:6), ci, 0);

    if abs(ci) > 1e-4
        pts(:, 1, i) = asin(tmp_pts(:, 1) * abs(ci)) / abs(ci);
        pts(:, 2, i) = asin(tmp_pts(:, 2) * abs(ci)) / abs(ci);
    else
        pts(:, :, i) = tmp_pts(:, 1:2);
    end

    % t = (z0 - rays_store(:, 3, end)) ./ rays_store(:, 6, end);
    % pts(:, :, i) = rays_store(:, 1:2, end) + ...
    %     bsxfun(@times, rays_store(:, 4:5, end), t);
end
end


function [lambda, ci] = parse_args(args)
lambda = get_fraunhofer_line('d');
ci = 0;

if length(args) >= 1
    OpticalSystem.check1D(args{1});
    lambda = args{1};
end

if length(args) >= 2
    if ~isscalar(args{2})
        error('ci should be a scalar!');
    end
    ci = args{2};
end
end