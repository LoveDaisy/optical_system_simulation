clear; close all; clc;

d_line = get_fraunhofer_line('d');
F_line = get_fraunhofer_line('F');
e_line = get_fraunhofer_line('e');
Cp_line = get_fraunhofer_line('C''');
C_line = get_fraunhofer_line('C');
r_line = get_fraunhofer_line('r');
wl_store = [d_line, C_line, F_line];
line_colors = spec_to_rgb([wl_store(:), ones(length(wl_store), 1)], 'maxy', 1.2);

beam_r = 50;
field_angle = 3;

optical_sys = OpticalSystem([0.000989602, -0.00347687, -0.00136675], ...
    [8, 5, 0], ...
    {'BK7', 'F2', 'AIR'});
optical_sys.ast = 1;
optical_sys = optical_sys.updateApertureHeight(beam_r);

l0 = optical_sys.getBackWorkingLength(0, d_line);
optical_sys.surfaces(end).t = abs(l0);

f0 = optical_sys.getFocalLength(0, d_line);
p = optical_sys.getPupils();
coef = optical_sys.get3rdAbrrCoeff([0, 1]*field_angle);

%%
figure(1); clf;
optical_sys.plotLsa(wl_store);

figure(2); clf;
optical_sys.plotRayFan(wl_store, [0, 0.5, 1]*field_angle);