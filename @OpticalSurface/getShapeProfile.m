function z = getShapeProfile(obj, y)
% INPUT
%   obj:        OpticalSurface object
%   y:          y coordinate
% OUTPUT
%   z:          z coordinate

z = obj.c * y.^2 ./ (1 + sqrt(1 - (1 - obj.asph_conic_k) * obj.c^2 * y.^2));
end