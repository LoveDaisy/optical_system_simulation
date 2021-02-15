function [front_sys, back_sys] = splitAt(obj, surf_ind)
% INPUT
%   obj:        OpticalSystem object
%   surf_ind:   surface index (start from 1)
% OUTPUT
%   front_sys:    front sub-system
%   back_sys:     back sub-system

front_surface = obj.surfaces(surf_ind:-1:1);
back_surface = obj.surfaces(surf_ind:end);

for i = 1:length(front_surface)-1
    front_surface(i).t = front_surface(i+1).t;
    front_surface(i).glass = front_surface(i+1).glass;
end
front_surface(end).t = 0;
front_surface(end).glass = ZemaxGlass('AIR');
front_surface(1).glass.is_reflective = true;
front_surface(1).c = 0;
front_surface(1).asph_coef = [];
front_surface(1).asph_conic_k = 0;
front_sys = obj;
front_sys.surfaces = front_surface;
front_sys.ast = 1;

back_surface(1).c = 0;
back_surface(1).asph_coef = [];
back_surface(1).asph_conic_k = 0;
back_sys = obj;
back_sys.surfaces = back_surface;
back_sys.ast = 1;
end