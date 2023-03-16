function p = findIntersectionPoint(obj, ray_in)
% This function find the intersection point of a ray with the optical surface.
% SYNTAX:
%   p = obj.findIntersectionPoint(ray_in)
% INPUT:
%   obj:        an OpticalSurface object
%   ray_in:     n*6 array, each row is a ray, [x, y, z, dx, dy, dz].
% OUTPUT:
%   p:          n*3 array, each row is the intersection point of the ray with the surface, [x, y, z].

p = ray_in(:, 1:3);
d = ray_in(:, 4:6);

% Step 0. Translate p to the local origin plane (z=0)
% Compute the coordinates of the intersection point of the ray with the local origin plane.
p(:, 1:2) = [(d(:, 3) .* p(:, 1) - d(:, 1) .* p(:, 3)) ./ d(:, 3), ...
    (d(:, 3) .* p(:, 2) - d(:, 2) .* p(:, 3)) ./ d(:, 3)];
p(:, 3) = 0;

% Step 1. Calculate the intersection point of the ray with the surface.
% The surface is a conic section with the equation:
%   z = c * (x^2 + y^2) / (1 + sqrt(1 - (1 + k) * (x^2 + y^2) * c^2))
k = obj.asph_conic_k;
c = obj.c;

% Suppose the intersection point is (x, y, z), and the ray is (x0, y0, z0) + t * (dx, dy, dz).
% Then we have:
%   z = c * (x^2 + y^2) / (1 + sqrt(1 - (1 + k) * (x^2 + y^2) * c^2))   ... (1)
%   x = x0 + dx * t                                                     ... (2)
%   y = y0 + dy * t                                                     ... (3)
%   z = z0 + dz * t                                                     ... (4)
% We have 4 equations and 4 variables, so we can solve for x, y, z, and t.
% Note that we have already translate the ray to the local origin plane, so z0 = 0.

% First we solve for t.
a = sum(p .* d, 2);
b = (1 + k * d(:, 3).^2);
r02 = sum(p.^2, 2);
delta_4 = c^2 * a.^2 + d(:, 3).^2 - 2 * c * a .* d(:, 3) - c^2 * b .* r02;
t = -a ./ b + (-c * a.^2 + 2 * a * d(:, 3) + c * b .* r02) ./ ...
    b ./ (d(:, 3) + sqrt(delta_4));

% Then we solve for x, y, and z.
p = p + t .* d;
end