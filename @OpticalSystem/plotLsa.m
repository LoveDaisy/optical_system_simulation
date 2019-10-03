function plotLsa(obj, lambda, varargin)
% INPUT
%   lambda:     m-vector, wavelength. lambda(1) will used as default wavelength

line_colors = spec_to_rgb([lambda(:), ones(length(lambda), 1)], 'maxy', 1.5);

p = obj.getPupils();
hm = p(1, 2);

h = linspace(0, 1, 100) * hm;
lsa = obj.getBackWorkingLength(h, lambda);
l0 = obj.getBackWorkingLength(0, lambda(1));

hold on;
plot([0, 0], [0, 1], 'k:');
for i = 1:length(lambda)
    plot((lsa(:, i) - l0), h/hm, 'linewidth', 2, ...
        'color', line_colors(i, :));
end
set(gca, 'ylim', [0, 1]);
box on;
end