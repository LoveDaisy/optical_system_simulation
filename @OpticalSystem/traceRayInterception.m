function pts = traceRayInterception(obj, init_rays, varargin)
% INPUT
%   obj:        OpticalSystem object
%   init_rays:  n*6, rays, [x, y, z, dx, dy, dz]
% OPTIONAL INPUT
%   lambda:     m-vector, wavelength
%   ci:         scalar, curvature of image sphere
%   obstruct:   {true}|false
% OUTPUT
%   pts:        n*2*m array

if size(init_rays, 2) ~= 6
    error('Rays must be like [x, y, z, dx, dy, dz]');
end
[lambda, ci, obstruct] = parse_args(varargin);

wl_num = length(lambda);
ray_num = size(init_rays, 1);
surface_num = length(obj.surfaces);

reverse_prop = false;
for i = 1:surface_num
    if obj.surfaces(i).glass.is_reflective
        reverse_prop = ~reverse_prop;
    end
end
z0 = obj.surfaces(end).t * (1 - 2 * reverse_prop) + obj.getTotalThickness();

pts = zeros(ray_num, 2, wl_num);
for i = 1:wl_num
    sys_data = obj.makeInternalSystemData(lambda(i));
    rays_store = OpticalSystem.traceRays(init_rays, sys_data);

    if obstruct
        rays_store = remove_obstructed_rays(obj, init_rays, rays_store);
    end
    rays_store = remove_eclipsed_rays(obj, rays_store);

    tmp_rays = rays_store(:, :, end);
    tmp_rays(:, 3) = tmp_rays(:, 3) - z0;
    tmp_pts = OpticalSystem.intersectWithConic(tmp_rays(:, 1:3), tmp_rays(:, 4:6), ci, 0);

    if abs(ci) > 1e-4
        pts(:, 1, i) = asin(tmp_pts(:, 1) * abs(ci)) / abs(ci);
        pts(:, 2, i) = asin(tmp_pts(:, 2) * abs(ci)) / abs(ci);
    else
        pts(:, :, i) = tmp_pts(:, 1:2);
    end
end
end


function [lambda, ci, obstruct] = parse_args(args)
lambda = util.get_fraunhofer_line('d');
ci = 0;
obstruct = true;

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

if length(args) >= 3
    if ~islogical(args{3})
        error('obstruct should be a locical!');
    end
    obstruct = args{3};
end
end


function [obs_ind, obs_z] = get_obstruct_info(obj)
surface_num = length(obj.surfaces);
obs_ind = false(surface_num, 1);
obs_z = nan(surface_num, 1);

curr_z = 0;
reverse_prop = false;
for i = 1:surface_num
    if reverse_prop && obj.surfaces(i).glass.is_reflective
        obs_ind(i) = true;
        obs_z(i) = curr_z;
    end
    if obj.surfaces(i).glass.is_reflective
        reverse_prop = ~reverse_prop;
    end
    if reverse_prop
        curr_z = curr_z - obj.surfaces(i).t;
    else
        curr_z = curr_z + obj.surfaces(i).t;
    end
end
obs_ind = find(obs_ind);
obs_z = obs_z(obs_ind);
end


function rays_store = remove_obstructed_rays(obj, init_rays, rays_store)
[obs_ind, obs_z] = get_obstruct_info(obj);

for l = 1:size(rays_store, 4)
    last_z = -inf;
    curr_z = 0;
    reverse_prop = false;
    prev_rays = init_rays;
    for i = 1:size(rays_store, 3)
        if obj.surfaces(i).glass.is_reflective
            reverse_prop = ~reverse_prop;
        end
        for k = 1:length(obs_z)
            if last_z < obs_z(k) && obs_z(k) < curr_z && i ~= obs_ind(k)
                obs_pts = bsxfun(@times, (obs_z(k) - prev_rays(:, 3)) ./ prev_rays(:, 6), ...
                    prev_rays(:, 4:6)) + prev_rays(:, 1:3);
                tmp_ind = sqrt(sum(obs_pts(:, 1:2).^2, 2)) < obj.surfaces(obs_ind(k)).ah;
                rays_store(tmp_ind, :, i, l) = nan;
            end
        end
        prev_rays = rays_store(:, :, i, l);
        last_z = curr_z;
        if reverse_prop
            curr_z = curr_z - obj.surfaces(i).t;
        else
            curr_z = curr_z + obj.surfaces(i).t;
        end
    end
    rays_store(isnan(sum(sum(rays_store, 3), 2)), :, :, l) = nan;
end
end


function rays_store = remove_eclipsed_rays(obj, rays_store)
for i = 1:size(rays_store, 3)
    invalid_ind = abs(rays_store(:, 2, i, :)) > obj.surfaces(i).ah;
    rays_store(invalid_ind) = nan;
end
end