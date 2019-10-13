function obj = updateApertureHeight(obj, entry_beam_r, full_field_angle)
% INPUT
%   obj:                OpticalSystem object
%   entry_beam_r:       scalar
%   full_field_angle:   scalar
% OUTPUT
%   obj:            OpticalSystem object

d_line = get_fraunhofer_line('d');
sys_data = obj.makeInternalSystemData(d_line);
surface_num = size(sys_data, 1);

rays = [0, entry_beam_r, 0, 0, 0, 1;
    0, entry_beam_r, 0, 0, sind(full_field_angle), cosd(full_field_angle);
    0, -entry_beam_r, 0, 0, sind(full_field_angle), cosd(full_field_angle)];
rays_store = OpticalSystem.traceRays(rays, sys_data);
for i = 1:surface_num
    obj.surfaces(i).ah = max(abs(rays_store(:, 2, i, 1)));
end
end