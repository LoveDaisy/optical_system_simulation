clear; close all; clc;

d_line = get_fraunhofer_line('d');
F_line = get_fraunhofer_line('F');
e_line = get_fraunhofer_line('e');
Cp_line = get_fraunhofer_line('C''');
C_line = get_fraunhofer_line('C');
r_line = get_fraunhofer_line('r');
wl_store = [d_line, C_line, F_line];
line_colors = spec_to_rgb([wl_store(:), ones(length(wl_store), 1)], 'maxy', 1.2);

%%
beam_r = 100;
full_field_angle = 0.65;
f_des = 2000;
image_curvature = 0;

% lens_sys = OpticalSystem([2.15648e-3, -2.31e-3, -0.1999e-3], ...
%     [8, 4.5, 0], ...
%     {'BK7', 'F2', 'AIR'});

lens_sys = OpticalSystem([2.15648e-3, -2.31e-3, -2.31e-3, -0.1999e-3]*0.5, ...
    [22, 2, 14, 0], ...
    {'BK7', 'AIR', 'F2', 'AIR'});
% lens_sys = OpticalSystem([0.989602e-3, -3.47687e-3, -3.47687e-3, -1.36675e-3], ...
%     [8, 0.12, 4.5, 0], ...
%     {'BK7', 'AIR', 'F2', 'AIR'});

% lens_sys = OpticalSystem([0.00342381, -0.00360092, -0.00360092, 0.000431579]*0.5, ...
%     [22, 2, 14, 0], ...
%     {'FPL53', 'AIR', 'BSL7', 'AIR'});

lens_sys.ast = 1;
lens_sys = lens_sys.updateApertureHeight(beam_r);

options = optimset('Display', 'iter', 'LargeScale', 'off', ...
    'TolX', 1e-5, 'MaxFunEvals', 1e5, 'MaxIter', 1e5);

% First optimization
lens_sys_options = lens_sys.makeOptimOptions('VarC', 1:4, ...
    'ChromaticWavelength', [d_line, C_line, F_line], ...
    'FullField', full_field_angle, ...
    'ObjFocalLength', [f_des, 10], ...
    'Obj3rdAbrr', [0, 10; 0, 20; 0, 0; 0, 0; 0, 0; 0, 10; 0, 0]);
func = lens_sys.getOptimObjectiveFunction(lens_sys_options);

x1 = fminunc(func, cat(1, lens_sys.surfaces(:).c), options);
x2 = fminsearch(func, x1, options);

lens_sys = lens_sys.updateParameters(lens_sys_options, x2);
lens_sys.surfaces(end).t = lens_sys.getBackWorkingLength(0, d_line);

% Second optimization
lens_sys_options = lens_sys.makeOptimOptions('VarC', 1:4, ...
    'ChromaticWavelength', [C_line, F_line], ...
    'FullField', full_field_angle, ...
    'ImageCurvature', image_curvature, ...
    'ObjFocalLength', [f_des, 10], ...
    'ObjLSA', 20*[0,0,0,0,0.8,1], ...
    'ObjRayFan', [5, 7, 20], 5e-2*[0,0,.5,.5,1,1], 2e-2*[0,0,0,0.5,1,1], ...
    'ObjRms', [5, 7, 20], ...
    'ObjSphChrm', 40);
func = lens_sys.getOptimObjectiveFunction(lens_sys_options);

x3 = fminunc(func, x2, options);
x4 = fminsearch(func, x3, options);

lens_sys = lens_sys.updateParameters(lens_sys_options, x4);
% Optimization ends

l0 = lens_sys.getBackWorkingLength(0, d_line);
f0 = lens_sys.getFocalLength(0, d_line);
coef = lens_sys.get3rdAbrrCoeff(full_field_angle);

%%
lens_sys.surfaces(end).t = l0 + -0.2;
lens_edge_color = [0.33725490196078434, 0.403921568627451, 0.6235294117647059];

figure(1); clf;
lens_sys.plotLsa([wl_store, 450:50:650]);

figure(2); clf;
lens_sys.plotRayFan(d_line, [0, 0.5, 1]*full_field_angle);

figure(3); clf;
lens_sys.plotShapeProfiler();

%%
% Ray tracing
ray_num = 500000;
curr_field = full_field_angle * 1;
init_pts = [disk_uniform_rand([0, 0], beam_r, ray_num), zeros(ray_num, 1)];
init_dir = [zeros(ray_num, 1), ones(ray_num, 1) * sind(curr_field), ...
    ones(ray_num, 1) * cosd(curr_field)];
pts = lens_sys.traceRayInterception([init_pts, init_dir], wl_store, image_curvature);

%%
size_config = [900, 100e-3, 0, f0 * tand(curr_field)];
heat_map = plot_intersection_scatter(pts(:,:,1), size_config);

airy_disk_r = 1.22 * d_line*1e-9 / (2*beam_r*1e-3) * f0 * ...
    size_config(1) / size_config(2);
pix_num = [64, 36, 24, 12];
pix_size = 24./(sqrt(pix_num/1.5)*1e3);
size_bar_len = pix_size * size_config(1) / size_config(2);

figure(4); clf;
imshow(heat_map * 1e4);
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