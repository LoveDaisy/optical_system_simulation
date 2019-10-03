function sys_mat = makeGaussianSystemMatrix(obj, lambda, varargin)
% INPUT
%   obj:        OpticalSystem object
%   lambda:     n-length wavelength
%   n0(opt):    n-length n0
% OUTPUT
%   sys_mat:    2x2xn gaussian system matrix

OpticalSystem.check1D(lambda);
if ~isempty(varargin) && ...
        (length(varargin) ~= 1 || length(varargin{1}) ~= length(lambda))
    error('n0 should be the same length of lambda');
end

surface_num = length(obj.surfaces);
wl_num = length(lambda);
sys_mat = zeros(2, 2, wl_num);

for k = 1:wl_num
    sys_mat(:, :, k) = eye(2);
end

reverse_prop = false;

if isempty(varargin)
    prev_n = ones(wl_num, 1);
else
    prev_n = varargin{1}(:);
end
for i = 1:surface_num
    if obj.surfaces(i).glass.is_reflective
        reverse_prop = ~reverse_prop;
    end

    curr_t = obj.surfaces(i).t;
    if reverse_prop
        curr_t = -curr_t;
    end

    if i < surface_num
        t_mat = [1, 0; curr_t, 1];
    else
        t_mat = eye(2);
    end
    for k = 1:wl_num
        curr_wl = lambda(k);
        curr_n = obj.surfaces(i).glass.getRefractiveIndex(curr_wl);
        if reverse_prop
            curr_n = -curr_n;
        end
        rel_n = prev_n(k) / curr_n;
        r_mat = [rel_n, (rel_n - 1) * obj.surfaces(i).c; 0, 1];
        prev_n(k) = curr_n;

        sys_mat(:,:,k) = t_mat * r_mat * sys_mat(:,:,k);
    end
end
end