function plotSpotDiagram(obj, lambda, field_angle, varargin)
% INPUT
%   obj:            OpticalSystem object
%   lambda:         n1-vector, wavelength
%   field_angle:    n2-vector, field angle
% OPTIONAL INPUT
%   'Margins':      4-vector, [top, right, bottom, left], the ratio of width or height
%   'WidthPixel':   scalar
%   'WidthLength':  scalar
%   'RowHeight':    scalar, the ratio of row height vs. image width
%   'RayNum':       scalar
%   'MaxIllum':     scalar
%   'Airy':         'On' or 'Off'
%   'ImageCurv':    scalar

OpticalSystem.check1D(lambda);
OpticalSystem.check1D(field_angle);

options = parse_input(varargin);

% Get some basic parameters
wl_num = length(lambda);
field_num = length(field_angle);

d_line = get_fraunhofer_line('d');
pupil = obj.getPupils();
f0 = obj.getFocalLength(0, d_line);

width_pixel = options.width_pixel;
hor_spacing = width_pixel * (1 - options.margins(2) - options.margins(4)) / (wl_num - 1);
ver_spacing = width_pixel * options.row_height_ratio;
height_pixel = floor(ver_spacing * (field_num - 1) / (1 - options.margins(1) - options.margins(3)));

% Get the spot diagram
spot_diagram = get_spec_heat_map(obj, lambda, field_angle, options);

% Compute some size
airy_disk_r = 1.22 * d_line * 1e-9 / (2 * pupil(1, 2) * 1e-3) * f0 * ...
    options.width_pixel / options.width_length;
pix_num = [24, 12, 8];
pix_size = 24 ./ (sqrt(pix_num / 1.5) * 1e3);
size_bar_len = pix_size * options.width_pixel / options.width_length;

% Show spot diagram
imshow(spot_diagram);
axis xy;
hold on;

% Plot airy circle
notation_color = [1, 1, 1] * 0.8;
for fi = 1:field_num
    for wi = 1:wl_num
        x0 = options.margins(4) * width_pixel + hor_spacing * (wi - 1);
        y0 = options.margins(3) * height_pixel + ver_spacing * (fi - 1);
        plot(cosd(0:360) * airy_disk_r + x0, sind(0:360) * airy_disk_r + y0, ...
            'Color', notation_color, ...
            'LineWidth', 1);
    end
end

% Plot field label
for fi = 1:field_num
    y0 = options.margins(3) * height_pixel + ver_spacing * (fi - 1);
    text(0.04 * width_pixel, y0, ...
        sprintf(' %.2f deg.\n(%.2f field)', field_angle(fi), field_angle(fi) / max(field_angle)), ...
        'Color', notation_color, ...
        'FontSize', 12);
end

% Plot pixel size bar
notation_color = [1,1,1] * 0.9;
text(0.04 * width_pixel, 0.12 * height_pixel, 'Pixel size:', ...
    'Color', notation_color, ...
    'FontSize', 12);
notation_color = [1,1,1] * 0.75;
line_height = 27;
for i = 1:length(size_bar_len)
    text(0.04 * width_pixel, 0.115 * height_pixel + 1 - i * line_height, ...
        sprintf('%.1fum (%dMP)', pix_size(i) * 1e3, pix_num(i)), ...
        'Color', notation_color, ...
        'FontSize', 11);
    plot(floor(0.22 * width_pixel) + [1, size_bar_len(i)], ...
        floor(0.115 * height_pixel) + [1, 1] - i * line_height, 'Color', notation_color, ...
        'LineWidth', 1.5);
end
end


function options = parse_input(varargin)
if ~isempty(varargin)
    varargin = varargin{1};
end
options.margins = [0.18, 0.12, 0.25, 0.25];      % top, right, bottom, left
options.width_pixel = 1000;
options.width_length = 300e-3;
options.row_height_ratio = 0.28;
options.ray_num = 50000;
options.spectrum_max_y = 3.5;
options.show_airy = true;
options.image_curv = 0;             % Image curvature

ind = 1;
while ind <= length(varargin)
    var_name = varargin{ind};
    ind = ind + 1;
    if ind > length(varargin)
        break;
    end
    if ~ischar(var_name)
        error('Invalid name-value parameter!');
    end

    var_val = varargin{ind};
    ind = ind + 1;
    if strcmpi(var_name, 'margins')
        OpticalSystem.check1D();
        if length(var_val) ~= 4
            error('Margins should be 4-length vector of [top, right, bottom, left]!');
        end
        options.margins = min(max(var_val, 0), 1);
    elseif strcmpi(var_name, 'widthpixel')
        if ~isscalar(var_val)
            error('WidthPixel should be a scalar!');
        end
        options.width_pixel = floor(max(var_val, 1));
    elseif strcmpi(var_name, 'widthlength')
        if ~isscalar(var_val)
            error('WidthLength should be a scalar!');
        end
        options.width_length = max(var_val, 0);
    elseif strcmpi(var_name, 'rowheight')
        if ~isscalar(var_val)
            error('RowHeight should be a scalar!');
        end
        options.row_height_ratio = max(var_val, 0.2);
    elseif strcmpi(var_name, 'raynum')
        if ~isscalar(var_val)
            error('RayNum should be a scalar!');
        end
        options.ray_num = floor(max(var_val, 1));
    elseif strcmpi(var_name, 'maxillum')
        if ~isscalar(var_val)
            error('MaxIllum should be a scalar!');
        end
        options.spectrum_max_y = var_val;
    elseif strcmpi(var_name, 'airy')
        if ~ischar(var_val)
            error('Airy should be On|Off!');
        end
        if strcmpi(var_val, 'on')
            options.show_airy = true;
        elseif strcmpi(var_val, 'off')
            options.show_airy = false;
        else
            error('Airy should be On|Off!');
        end
    elseif strcmpi(var_name, 'imagecurv')
        if ~isscalar(var_val)
            error('ImageCurv should be a scalar!');
        end
        options.image_curv = var_val;
    end
end
end


function heat_map = get_spec_heat_map(obj, lambda, field_angle, options)
wl_num = length(lambda);
field_num = length(field_angle);

d_line = get_fraunhofer_line('d');
pupil = obj.getPupils();
f0 = obj.getFocalLength(0, d_line);

width_pixel = options.width_pixel;
hor_spacing = width_pixel * (1 - options.margins(2) - options.margins(4)) / (wl_num - 1);
ver_spacing = width_pixel * options.row_height_ratio;
height_pixel = floor(ver_spacing * (field_num - 1) / (1 - options.margins(1) - options.margins(3)));

spec_heat_map = zeros(height_pixel, width_pixel, wl_num);

init_pts = [disk_uniform_rand([0, 0], pupil(1, 2), options.ray_num), zeros(options.ray_num, 1)];
for fi = 1:field_num
    curr_field = field_angle(fi);
    init_dir = [zeros(options.ray_num, 1), ones(options.ray_num, 1) * sind(curr_field), ...
        ones(options.ray_num, 1) * cosd(curr_field)];
    pts = obj.traceRayInterception([init_pts, init_dir], ...
        lambda, options.image_curv);

    y0 = mean(reshape(pts(:,2,:), [], 1));

    field_heat_map = zeros(size(spec_heat_map));
    size_config = [options.width_pixel, options.width_length, 0, y0];
    for wi = 1:wl_num
        curr_heat_map = plot_intersection_scatter(pts(:,:,wi), size_config);

        back_left = floor(options.margins(4) * width_pixel + hor_spacing * (wi - 1) - size_config(1) / 2);
        tmp_left = max(1 - back_left, 1);
        tmp_right = min(width_pixel - back_left + 1, size_config(1));
        back_left = max(back_left, 1);
        back_right = min(back_left + (tmp_right - tmp_left), width_pixel);

        back_top = floor(options.margins(3) * height_pixel + ver_spacing * (fi - 1) - size_config(1) / 2);
        tmp_top = max(1 - back_top, 1);
        tmp_bottom = min(height_pixel - back_top + 1, size_config(1));
        back_top = max(back_top, 1);
        back_bottom = min(back_top + (tmp_bottom - tmp_top), height_pixel);

        field_heat_map(back_top:back_bottom, back_left:back_right, wi) = ...
            field_heat_map(back_top:back_bottom, back_left:back_right, wi) + ...
            curr_heat_map(tmp_top:tmp_bottom, tmp_left:tmp_right);
    end
    field_heat_map = field_heat_map / max(field_heat_map(:));
    spec_heat_map = spec_heat_map + field_heat_map;
end

wl_xyz = spec_to_ciexyz([lambda(:), ones(wl_num, 1)]);
heat_map = 0;
for wi = 1:wl_num
    curr_rgb = spec_to_rgb([lambda(wi) * ones(height_pixel * width_pixel, 1), ...
        reshape(spec_heat_map(:, :, wi), [], 1)], ...
        'MaxY', options.spectrum_max_y * wl_xyz(wi, 2));
    heat_map = heat_map + reshape(curr_rgb, [height_pixel, width_pixel, 3]);
end
end