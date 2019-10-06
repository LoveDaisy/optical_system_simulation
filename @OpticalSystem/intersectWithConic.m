function pts = intersectWithConic(pts, ray_dir, c, k)
% INPUT
%   pts:        n*3 array, [x, y, z]
%   ray_dir:    n*3 array, [dx, dy, dz]
%   c:          scalar, 1/R
% OUTPUT
%   pts:        n*3 array, [x, y, z]

% The conic shape formula is:
%       z = c * y^2 / (1 + sqrt(1 - (1 - k) * c^2 * y^2))
% k = 0 for sphere, k = 1 for paraboloid

if size(pts, 2) ~= 3 || size(ray_dir, 2) ~= 3 || ...
        length(size(pts)) ~= length(size(ray_dir)) || ...
        any(size(pts) ~= size(ray_dir)) || ...
        ~isscalar(c) || ~isscalar(k)
    error('input parameter invalid!');
end

ray_dir = bsxfun(@times, ray_dir, 1./sum(ray_dir.^2, 2));

a = pts.^2 * [1; 1; 1-k] * c - 2 * pts(:, 3);
b = (sum(pts .* ray_dir, 2) - ray_dir(:, 3) .* pts(:, 3) * k) * c - ray_dir(:, 3);

delta = a .* c .* (ray_dir(:, 3).^2 * k - 1) + b.^2;
t = a ./ (sqrt(max(delta, 0)) - b);

pts = pts + bsxfun(@times, t, ray_dir);

y2 = sum(pts(:, 1:2).^2, 2);
off_surf_ind = abs(y2 * c ./ (1 + sqrt(1 - (1 - k) * c^2 .* y2)) - pts(:, 3)) > 1e-5;
pts(off_surf_ind, :) = nan;
end