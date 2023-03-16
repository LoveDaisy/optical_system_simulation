function rays_out = reactToRays(obj, rays_in)
% This function computes the result of a ray passing through a surface.
% SYNTAX
%   rays_out = obj.reactToRays(rays_in)
% INPUT
%   obj:        OpticalSurface object.
%   rays_in:    n*6 array. [x, y, z, dx, dy, dz], where (x, y, z) is the start point of the ray,
%               and (dx, dy, dz) is the direction vector.
% OUTPUT
%   rays_out:   n*6 array. [x, y, z, dx, dy, dz]

% First we find the intersection points of the rays with the surface.
p = obj.findIntersectionPoint(rays_in);
end
