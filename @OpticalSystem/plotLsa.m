function plotLsa(obj, lambda, varargin)
% DESCRIPTION
%   This function plots Longitudinal Spherical Aberration (LAS) curves for one or more wavelengths.
% SYNTAX
%   plotLsa(obj, lambda)
%   plotLsa(obj, [lambda1, lambda2, ...])
%   plotLsa(obj, 'line_name')
%   plotLsa(obj, {'line_name1', 'line_name2', ...})
%   plotLsa(..., option_name, option_value, ...)
%   obj.plotLsa(...)
% INPUT
%   lambda:         1: m-vector, wavelength.
%                   2: m-cell of string, wavelength names.
%                   lambda(1) will used as default wavelength.
% OPTION
%   'XLim':         2-vector, x-limits.
%   'ShowLegend':   {false}|true

p = inputParser;
p.addRequired('obj', @(x) isa(obj, 'OpticalSystem'));
p.addRequired('lambda', @(x) ischar(x) || (isnumeric(x) && isscalar(x)) || ...
    (isnumeric(x) && isvector(x)) || (iscell(x) && isvector(x)));
p.addParameter('XLim', [], @(x) isnumeric(x) && isvector(x) && length(x) == 2);
p.addParameter('ShowLegend', false, @(x) islogical(x) && isscalar(x));
p.parse(obj, lambda, varargin{:});

if ischar(lambda)
    lambda = get_fraunhofer_line(lambda);
elseif iscell(lambda)
    lambda = cellfun(@(x) get_fraunhofer_line(x), lambda);
end

pupil = obj.getPupils();
hm = pupil(1, 2);

l0 = obj.getBackWorkingLength(0, lambda(1));

lambda = sort(lambda);
h = linspace(0, 1, 100) * hm;
lsa = obj.getBackWorkingLength(h, lambda);

line_colors = spec_to_rgb([lambda(:), ones(length(lambda), 1)], 'y', 1.5, 'mixed', false);

hold on;
for i = 1:length(lambda)
    plot((lsa(:, i) - l0), h/hm, 'linewidth', 2, ...
        'color', line_colors(i, :));
end
plot([0, 0], [0, 1], 'k:');
if ~isempty(p.Results.XLim)
    set(gca, 'ylim', [0, 1], 'xlim', p.Results.XLim, 'FontSize', 12);
else
    set(gca, 'ylim', [0, 1], 'FontSize', 12);
end
box on;
xlabel('Focus shift (mm)', 'FontSize', 14);
ylabel('Relative entrance pupil', 'FontSize', 14);
t = title('Longitudinal aberration', 'FontSize', 16, ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Units', 'normalized');
t.Position(2) = 1.03;
if p.Results.ShowLegend
    legend(arrayfun(@(x) sprintf('%.2f nm', x), lambda, 'UniformOutput', false), 'Location', 'best');
end
end