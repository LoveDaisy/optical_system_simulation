function p = getPupils(obj)
% INPUT
%   obj:        OpticalSystem object
% OUTPUT
%   p:          2*2 array, [z1, r1; z2, r2], 1 for entrance pupil; 2 for exit pupil
%               z is measured relative to the first surface

d_line = get_fraunhofer_line('d');
p = zeros(2, 2);

[front_sys, back_sys] = obj.splitAtStop();

t1 = front_sys.getTotalThickness();

n0 = front_sys.surfaces(1).glass.getRefractiveIndex(d_line);
front_sys_mat = front_sys.makeGaussianSystemMatrix(d_line, n0);
p(1, 1) = -front_sys_mat(2, 1) ./ front_sys_mat(1, 1);
p(1, 2) = (front_sys_mat(2, 2) - front_sys_mat(1, 2) .* ...
    front_sys_mat(2, 1) ./ front_sys_mat(1, 1)) * front_sys.surfaces(1).ah;

n0 = back_sys.surfaces(1).glass.getRefractiveIndex(d_line);
back_sys_mat = back_sys.makeGaussianSystemMatrix(d_line, n0);
p(2, 1) = -back_sys_mat(2, 1) ./ back_sys_mat(1, 1) - t1;
p(2, 2) = (back_sys_mat(2, 2) - back_sys_mat(1, 2) .* ...
    back_sys_mat(2, 1) ./ back_sys_mat(1, 1)) * front_sys.surfaces(1).ah;
end