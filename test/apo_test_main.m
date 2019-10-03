clear; close all; clc;

d_line = get_fraunhofer_line('d');
F_line = get_fraunhofer_line('F');
Fp_line = get_fraunhofer_line('F''');
e_line = get_fraunhofer_line('e');
Cp_line = get_fraunhofer_line('C''');
C_line = get_fraunhofer_line('C');
r_line = get_fraunhofer_line('r');
wl_store = [d_line, C_line, F_line];
line_colors = spec_to_rgb([wl_store(:), ones(length(wl_store), 1)], 'maxy', 1.2);

beam_r = 65;
full_field_angle = 0.5;
f_des = 1000;
image_curvature = 0;

apo_sys = OpticalSystem(1./[2380, -262.2, -239.8, 2580, 444, -926], ...
    [12, 22.9, 7, 1, 11, 0], ...
    {'FPL53', 'AIR', 'BSL7', 'AIR', 'FPL53', 'AIR'});
apo_sys.ast = 1;
apo_sys = apo_sys.updateApertureHeight(beam_r);

%%
options = optimset('Display', 'iter', 'LargeScale', 'off', ...
    'TolX', 1e-6, 'MaxFunEvals', 1e5, 'MaxIter', 1e5);

% First optimization
lens_sys_options = apo_sys.makeOptimOptions('VarC', 1:6, ...
    'ChromaticWavelength', [d_line, C_line, F_line], ...
    'FullField', full_field_angle, ...
    'ObjFocalLength', [f_des, 1e-2], ...
    'Obj3rdAbrr', [0, 5; 0, 5; 0, 3; 0, 1; 0, 0; 0, 5; 0, 0], ...
    'ObjSphChrm', 50);
func = apo_sys.getOptimObjectiveFunction(lens_sys_options);

x1 = fminunc(func, cat(1, apo_sys.surfaces(:).c), options);
x2 = fminsearch(func, x1, options);
apo_sys = apo_sys.updateParameters(lens_sys_options, x2);

% Second optimization
lens_sys_options = apo_sys.makeOptimOptions('VarC', 1:6, ...
    'ChromaticWavelength', [d_line, C_line, F_line], ...
    'FullField', full_field_angle, ...
    'ImageCurvature', image_curvature, ...
    'ObjFocalLength', [f_des, 10], ...
    'ObjLSA', 20, ...
    'ObjOSC', 0.02, ...
    'Obj3rdAbrr', [0, 0; 0, 0.08; 0, 0.1; 0, 0; 0, 0; 0, 0; 0, 0], ...
    'ObjRayFan', [5, 7, 20], 3e-3*[0,0,0,0,1,1], 3e-3*[0,0,0,0,0,1], ...
    'ObjRms', [5, 7, 20], ...
    'ObjSphChrm', 10);
func = apo_sys.getOptimObjectiveFunction(lens_sys_options);

x3 = fminunc(func, x2, options);
x4 = fminsearch(func, x3, options);
apo_sys = apo_sys.updateParameters(lens_sys_options, x4);

% % Third optimization
% lens_sys_options = apo_sys.makeOptimOptions('VarC', 1:4, ...
%     'ChromaticWavelength', [d_line, 650, 600, 500, 450], ...
%     'FullField', full_field_angle, ...
%     'ObjFocalLength', [f_des, 10], ...
%     'ObjLSA', 10, ...
%     'ObjRayFan', [1, 0.5, 0.2], [.3, .3, .8, 1, 1, 1.5]*1.5, 1.5, ...
%     'ObjSphChrm', 50);
% func = apo_sys.getOptimObjectiveFunction(lens_sys_options);
%
% x5 = fminunc(func, x4, options);
% x6 = fminsearch(func, x5, options);
% apo_sys = apo_sys.updateParameters(lens_sys_options, x6);

%% Optimization end
l0 = apo_sys.getBackWorkingLength(0, d_line);
f0 = apo_sys.getFocalLength(0, d_line);
pupil = apo_sys.getPupils();
apo_sys.surfaces(end).t = l0 + 0;

figure(1); clf;
apo_sys.plotLsa([d_line, 450:50:650]);

figure(2); clf;
apo_sys.plotRayFan([d_line, 450:50:650], [0, 0.5, 1]*full_field_angle, ...
    image_curvature);

%%
% Ray tracing
ray_num = 500000;
curr_field = full_field_angle;    % degree
init_pts = [disk_uniform_rand([0, 0], pupil(1, 2), ray_num), pupil(1, 1)*ones(ray_num, 1)];
init_dir = [zeros(ray_num, 1), ones(ray_num, 1) * sind(curr_field), ...
    ones(ray_num, 1) * cosd(curr_field)];
pts = apo_sys.traceRayInterception([init_pts, init_dir], wl_store, image_curvature);

%%
size_config = [900, 100e-3, 0, f0 * tand(curr_field)];
heat_map = plot_intersection_scatter(pts(:,:,2), size_config);

airy_disk_r = 1.22 * d_line*1e-9 / (2*beam_r*1e-3) * f0 * ...
    size_config(1) / size_config(2);
pix_num = [64, 36, 24, 12];
pix_size = 24./(sqrt(pix_num/1.5)*1e3);
size_bar_len = pix_size * size_config(1) / size_config(2);

figure(3); clf;
imshow(heat_map * 5e3);
axis xy;
hold on;
plot(cosd(0:360)*airy_disk_r+size_config(1)/2+1, ...
    sind(0:360)*airy_disk_r+size_config(1)/2+1, 'r', 'linewidth', 1);
notation_color = [1,1,1]*0.9;
text(0.05*size_config(1), 0.20*size_config(1), 'Pixel size:', ...
    'color', notation_color, ...
    'fontsize', 12);
notation_color = [1,1,1]*0.75;
line_height = 27;
for i = 1:length(size_bar_len)
    text(0.05*size_config(1), 0.19*size_config(1)+1-i*line_height, ...
        sprintf('%.1fum (%dMP)', pix_size(i)*1e3, pix_num(i)), ...
        'color', notation_color, ...
        'fontsize', 11);
    plot(floor(0.22*size_config(1))+[1, size_bar_len(i)], ...
        floor(0.19*size_config(1))+[1, 1]-i*line_height, 'color', [1,1,1]*0.7, ...
        'linewidth', 1.5);
end