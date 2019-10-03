function l = getGaussianBackWorkingLength(obj, lambda)
% INPUT
%   obj:        OpticalSystem object
%   lambda:     n-length vector
% OUTPUT
%   l:          n-length vector, the gaussian rear working length

OpticalSystem.check1D(lambda);

sys_mat = obj.makeGaussianSystemMatrix(lambda);
wl_num = size(sys_mat, 3);
l = zeros(size(lambda));
for i = 1:wl_num
    l(i) = -sys_mat(2, 2, i) / sys_mat(1, 2, i);
end
end