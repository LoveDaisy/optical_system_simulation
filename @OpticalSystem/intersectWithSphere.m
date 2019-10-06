function pts = intersectWithSphere(pts, ray_dir, c)
% INPUT
%   pts:        n*3 array, [x, y, z]
%   ray_dir:    n*3 array, [dx, dy, dz]
%   c:          scalar, 1/R
% OUTPUT
%   pts:        n*3 array, [x, y, z]

if size(pts, 2) ~= 3 || size(ray_dir, 2) ~= 3 || ...
        length(size(pts)) ~= length(size(ray_dir)) || ...
        any(size(pts) ~= size(ray_dir)) || ...
        ~isscalar(c)
    error('input parameter invalid!');
end

ray_dir = bsxfun(@times, ray_dir, 1./sum(ray_dir.^2, 2));

p = [pts(:, 1:2) * c, pts(:, 3) * c - 1];
a = sum(p .* ray_dir(:, :), 2);
b = sum(pts.^2, 2) * c - 2 * pts(:, 3);

delta = a.^2 - sum(p.^2, 2) + 1;
t = -b ./ (a - sqrt(max(delta, 0)));
pts = pts + bsxfun(@times, t, ray_dir);

off_surf_ind = abs(sum(bsxfun(@minus, pts * c, [0, 0, 1]).^2, 2) - 1) > 1e-5;
pts(off_surf_ind, :) = nan;
end