function ray_dir = refractAtConic(ray, n_rel, c, k)
% INPUT
%   ray:        n*6 array, [x, y, z, dx, dy, dz], [x, y, z] shoul be on shpere
%   n_rel:      scalar, n0/n1
%   c:          scalar, 1/R
%   k:          scalar, conic coefficient

if size(ray, 2) ~= 6 || ~isscalar(c) || ~isscalar(n_rel)
    error('input parameter invalid!');
end
y2 = sum(ray(:, 1:2).^2, 2);
off_surf_ind = abs(y2 * c ./ (1 + sqrt(1 - (1 - k) * c^2 .* y2)) - ray(:, 3)) > 1e-5;

ray(:, 4:6) = bsxfun(@times, ray(:, 4:6), ...
    1./sum(ray(:, 4:6).^2, 2));

norm_dir = [ray(:, 1:2) * c, ray(:, 3) * c * (1 - k) - 1];
norm_dir = bsxfun(@times, norm_dir, 1 ./ sqrt(sum(norm_dir.^2, 2)));

angle_c = sum(norm_dir .* ray(:, 4:6), 2);
a = 1 / n_rel^2 - 1 + angle_c.^2;

invalid_ind = a < 0 | isnan(a);

a = sqrt(max(a, 0));
ray_dir = bsxfun(@times, -angle_c + sign(angle_c * n_rel) .* a, norm_dir) + ...
    ray(:, 4:6);
ray_dir = bsxfun(@times, ray_dir, ...
    1 ./ sqrt(sum(ray_dir.^2, 2)));

ray_dir(invalid_ind | off_surf_ind, :) = nan;
end