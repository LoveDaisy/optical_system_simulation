function [sys_mat, t_mat_store, r_mat_store] = makeGaussianSystemMatrix(obj, lambda, varargin)
% SYNTAX
%   [sys_mat, t_mat, r_mat] = sys.makeGaussianSystemMatrix(lambda)
%   [sys_mat, t_mat, r_mat] = sys.makeGaussianSystemMatrix(lambda, n0)
% where
%   lambda:     n-length wavelength
%   n0:         n-length n0
%   sys_mat:    2x2xn gaussian system matrix
%   t_mat:      2x2xm translation matrix. m is surface number. The translation matrix of last
%               surface is eye(2). When in reflection cases, the translation distance will be
%               negative.
%   r_mat:      2x2xmxn refraction matrix. n is wavelength number. When in reflection cases, the
%               refractive index will be negative.

% Parse input arguments
parser = inputParser;
parser.FunctionName = 'makeGaussianSystemMatrix';
parser.addRequired('lambda', @(x) isnumeric(x) && isreal(x) && isvector(x));
parser.addOptional('n0', ones(size(lambda)), ...
    @(x) isnumeric(x) && isreal(x) && isvector(x) && length(x) == length(lambda));
parser.parse(lambda, varargin{:});

surface_num = length(obj.surfaces);
wl_num = length(lambda);
sys_mat = zeros(2, 2, wl_num);
t_mat_store = zeros(2, 2, surface_num);
r_mat_store = zeros(2, 2, surface_num, wl_num);

for k = 1:wl_num
    sys_mat(:, :, k) = eye(2);
end

reverse_prop = false;

prev_n = parser.Results.n0;
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
    t_mat_store(:, :, i) = t_mat;

    for k = 1:wl_num
        curr_wl = lambda(k);
        curr_n = obj.surfaces(i).glass.getRefractiveIndex(curr_wl);
        if reverse_prop
            curr_n = -curr_n;
        end
        rel_n = prev_n(k) / curr_n;
        r_mat = [rel_n, (rel_n - 1) * obj.surfaces(i).c; 0, 1];
        r_mat_store(:, :, i, k) = r_mat;
        prev_n(k) = curr_n;

        sys_mat(:,:,k) = t_mat * r_mat * sys_mat(:,:,k);
    end
end
end