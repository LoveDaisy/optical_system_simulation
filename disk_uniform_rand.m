function xy = disk_uniform_rand(center, r, num)
% This function generates points uniformly distributed in a disk.
% INPUT
%  center:      2-vec
%  r:           scalar
%  num:         scalar
% OUTPUT
%  xy:          num*2

tmp_r = sqrt(rand(num, 1)) * r;
tmp_q = rand(num, 1) * 2 * pi;
xy = [tmp_r .* cos(tmp_q) + center(1), tmp_r .* sin(tmp_q) + center(2)];
end