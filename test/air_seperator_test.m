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
beam_r = 50;
full_field_angle = 0.5;
f_des = 1000;
image_curvature = 0;

% lens_sys = OpticalSystem([1.6218e-3, -2.7796e-3, -0.69151e-3], ...
%     [8, 4.5, 0], ...
%     {'BK7', 'F2', 'AIR'});

lens_sys = OpticalSystem([1.6218e-3, -2.7796e-3, -2.7449e-3, -0.69151e-3], ...
    [8, 0, 4.5, 0], ...
    {'BK7', 'AIR', 'F2', 'AIR'});

lens_sys.ast = 1;
lens_sys = lens_sys.updateApertureHeight(beam_r);
lens_sys.surfaces(end).t = lens_sys.getBackWorkingLength(0, d_line);

l0 = lens_sys.getBackWorkingLength(0, d_line);
f0 = lens_sys.getFocalLength(0, d_line);
coef = lens_sys.get3rdAbrrCoeff(full_field_angle);


%%
lens_sys.surfaces(end).t = l0 + 0.1;
lens_edge_color = [0.33725490196078434, 0.403921568627451, 0.6235294117647059];

figure(1); clf;
lens_sys.plotLsa([wl_store, 450:50:650]);

figure(2); clf;
lens_sys.plotRayFan(wl_store, [0, 0.5, 1]*full_field_angle);

figure(3); clf;
hold on;
dt = 0;
for i = 1:length(lens_sys.surfaces)
    tmp_y = linspace(-beam_r, beam_r, 100);
    tmp_x = tmp_y.^2 * lens_sys.surfaces(i).c ./ ...
        (1 + sqrt(1 - (tmp_y * lens_sys.surfaces(i).c).^2)) + dt;
    plot(tmp_x, tmp_y, 'linewidth', 2, 'color', lens_edge_color);
    dt = dt + lens_sys.surfaces(i).t;
end

dt = 0;
for i = 1:length(lens_sys.surfaces)-1
    if strcmpi(lens_sys.surfaces(i).glass.name, 'air')
        dt = dt + lens_sys.surfaces(i).t;
        continue;
    end
    tmp_y = [-beam_r, beam_r];
    tmp_x1 = tmp_y.^2 * lens_sys.surfaces(i).c ./ ...
        (1 + sqrt(1 - (tmp_y * lens_sys.surfaces(i).c).^2)) + dt;
    tmp_x2 = tmp_y.^2 * lens_sys.surfaces(i+1).c ./ ...
        (1 + sqrt(1 - (tmp_y * lens_sys.surfaces(i+1).c).^2)) + ...
        dt + lens_sys.surfaces(i).t;
    plot([tmp_x1(1), tmp_x2(1)], tmp_y(1)*[1,1], ...
        'linewidth', 2, 'color', lens_edge_color);
    plot([tmp_x1(2), tmp_x2(2)], tmp_y(2)*[1,1], ...
        'linewidth', 2, 'color', lens_edge_color);
    dt = dt + lens_sys.surfaces(i).t;
end
axis equal; axis off;

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