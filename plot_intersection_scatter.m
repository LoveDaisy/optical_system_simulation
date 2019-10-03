function heat_map = plot_intersection_scatter(xy, size_config)
% Plot heat map of intersections alone ray axis
% INPUT
%  xy:          n*2, points
%  size_config: [side_pixels, side_real_length, center_x, center_y]

pixel_length = size_config(1);
real_length = size_config(2);
center = size_config(3:4);

dx = real_length / (pixel_length - 1);
xy_ind = round((bsxfun(@minus, xy, center) + real_length/2) / dx) + 1;
xy_ind = xy_ind(sum(xy_ind > 0 & xy_ind < pixel_length, 2) == 2, :);

heat_map = accumarray(xy_ind, 1, pixel_length*[1,1])' / size(xy, 1);
end