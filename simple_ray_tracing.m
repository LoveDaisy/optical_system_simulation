function [xy, path_pts] = simple_ray_tracing(sys, entry_ray, df)
% INPUT
%  sys:         n*3, n surfaces, [c, t, n]
%  entry_ray:   num*6, num rays, [x, y, z, dx, dy, dz]
%  df:          m*1 or 1*m, defocus distance
%
% OUTPUT
%  xy:          num*2*m, ray points on defocus planes
%  path_pts:    num*2*n, ray points on each surface

ray_num = size(entry_ray, 1);
pts = entry_ray(:, 1:3);
ray_d = entry_ray(:, 4:6);
face_num = size(sys, 1);

sys = [0, 0, 1; sys];

path_pts = zeros(size(pts, 1), 3, face_num + 1);

delta_z = 0;
for i = 1:face_num
    pts = sphere_intersection(pts, ray_d, sys(i+1, 1));
    ray_d = sphere_refraction([pts, ray_d], sys(i+1, 1), sys(i, 3) / sys(i+1, 3));
    dt = (sys(i+1, 2) - pts(:, 3)) ./ ray_d(:, 3);

    path_pts(:, :, i) = pts;
    path_pts(:, 3, i) = path_pts(:, 3, i) + delta_z;
    delta_z = delta_z + sys(i+1, 2);

    pts = pts + bsxfun(@times, dt, ray_d);
    pts(:, 3) = 0;
end
path_pts(:, :, end) = pts;
path_pts(:, 3, end) = path_pts(:, 3, end) + delta_z;

xy = zeros(ray_num, 2, length(df));
for i = 1:length(df)
    dt = df(i) ./ ray_d(:, 3);
    tmp_pts = pts + bsxfun(@times, dt, ray_d);
    xy(:, :, i) = tmp_pts(:, 1:2);
end
end


function pts = sphere_intersection(pts, ray_dir, c)
a = sum([pts(:, 1:2) * c, -ones(size(pts, 1), 1)] .* ray_dir, 2);
r2 = sum(pts(:, 1:2).^2, 2);
t = -c * r2 ./ (a - sqrt(a.^2 - c^2 * r2));
pts = pts + bsxfun(@times, t, ray_dir);
end


function ray_dir = sphere_refraction(ray, c, n_rel)
% INPUT
%  ray:         [x, y, z, dx, dy, dz]
%  n_rel:       n1/n0

norm_dir = [ray(:, 1:2) * c, ray(:, 3) * c - 1];
norm_dir = bsxfun(@times, norm_dir, 1./sqrt(sum(norm_dir.^2, 2)));

angle_c = sum(norm_dir .* ray(:, 4:6), 2);
a = 1/n_rel^2 - 1 + angle_c.^2;
invalid_ind = a < 0 | isnan(a);
a = sqrt(max(a, 0));
ray_dir = bsxfun(@times, -angle_c + sign(angle_c) .* a, norm_dir) + ray(:, 4:6);
ray_dir = bsxfun(@times, ray_dir, 1./sqrt(sum(ray_dir.^2, 2)));
ray_dir(invalid_ind, :) = nan;
end