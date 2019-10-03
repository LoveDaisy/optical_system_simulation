function f = getGaussianFocalLength(obj, lambda)
% INPUT
%   obj:        OpticalSystem object
%   lambda:     n-length vector
% OUTPUT
%   f:          n-length vector, the gaussian focal length

OpticalSystem.check1D(lambda);

sys_mat = obj.makeGaussianSystemMatrix(lambda);
wl_num = size(sys_mat, 3);
f = zeros(size(lambda));
for i = 1:wl_num
    f(i) = -1 / sys_mat(1, 2, i);
end
end