function obj = updateApertureHeight(obj, entry_beam_r)
% INPUT
%   obj:            OpticalSystem object
%   entry_beam_r:   scalar
% OUTPUT
%   obj:            OpticalSystem object

d_line = get_fraunhofer_line('d');
sys_data = obj.makeInternalSystemData(d_line);
rays = [0, entry_beam_r, 0, 0, 0, 1];
surface_num = size(sys_data, 1);

rays_store = OpticalSystem.traceRays(rays, sys_data);

for i = 1:surface_num
    obj.surfaces(i).ah = rays_store(1, 2, i, 1);
end
end