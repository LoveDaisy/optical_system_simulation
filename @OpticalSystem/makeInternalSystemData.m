function sys_data = makeInternalSystemData(obj, lambda)
% INPUT
%   obj:        OpticalSystem object
%   lambda:     n-length vector
% OUTPUT
%   sys_data:   m*k*n matrix, m is surface number, k is data number for
%               each surface, n is wavelength number.
%               The data of a surface is like:
%               [c, t, n, H_max, is_AST, conic_k, asph_type, asph_coefs]

OpticalSystem.check1D(lambda);

wl_num = length(lambda);
surface_num = length(obj.surfaces);
data_dim = 15;  % 8 aspherical coefficients

reverse_prop = false;
sys_data = zeros(surface_num, data_dim, wl_num);
for i = 1:surface_num
    if obj.surfaces(i).glass.is_reflective
        reverse_prop = ~reverse_prop;
    end
    sys_data(i, 1, :) = obj.surfaces(i).c;
    sys_data(i, 2, :) = obj.surfaces(i).t;
    sys_data(i, 3, :) = obj.surfaces(i).glass.getRefractiveIndex(lambda);
    sys_data(i, 4, :) = obj.surfaces(i).ah;
    sys_data(i, 5, :) = (obj.ast == i);
    sys_data(i, 6, :) = obj.surfaces(i).asph_conic_k;
    if reverse_prop
        sys_data(i, 2, :) = -sys_data(i, 2, :);
        sys_data(i, 3, :) = -sys_data(i, 3, :);
    end
    % TODO: complete other properties
end
end