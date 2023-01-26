% This script will build up a air spaced doublet lens for astronomy purpose.
% We choose two glasses as N-BK7 and F2 from Schott.

clear; close all; clc;

% Prepare spectral lines
d_line = get_fraunhofer_line('d');
F_line = get_fraunhofer_line('F');
e_line = get_fraunhofer_line('e');
C_line = get_fraunhofer_line('C');
r_line = get_fraunhofer_line('r');
g_line = get_fraunhofer_line('g');

f_number = 10;                  % F number
field_angle = 0.65;             % Half angle
f_des = 2000;                   % Focal length
image_curvature = -1/1000;      % Curvature of best image surface

%%
% Surface parameters, curvature of surfaces, thickness of surfaces.
c_array = [9.3730e-4, -1.2959e-3, -1.2959e-3, -2.4094e-4];
t_array = [18, 0.3, 10, 2000];
sys = OpticalSystem(c_array, t_array, {'N-BK7', 'AIR', 'F2', 'AIR'});

% Set first surface as aperture stop
sys.ast = 1;

% Solve all surface height according to F-number and field angle.
sys = sys.solveApertureHeight(f_number, field_angle);

% Set the last thickness to Gaussian backworking length (backworking lenght of height 0 ray).
l0 = sys.getBackWorkingLength(0, d_line);
sys.surfaces(end).t = l0;

%%
% Optimize the system.
% The optimization stage has two phases:
%   1. Optimize against primary aberrations.
%   2. Optimize against some final metrics, like RMS.
% `sys1` is the system after phase 1 and `sys` is the system after all two phases.
% See optimize_simple_system for detail.
[sys, ~, sys1] = optimize_simple_system(sys, f_des, field_angle, f_number, image_curvature);

% Check the final system focal length and backworking length.
f0 = sys.getFocalLength(0, d_line);
l0 = sys.getBackWorkingLength(0, d_line);

%% Show some charts
% Show charts of sys1, the systam after optimization phase 1.
if exist('sys1', 'var')

    % Combine shape profile and LSA (longitudinal spherical aberration) chart together.
    figure(1); clf;
    set(gcf, 'Position', [300, 320, 600, 450]);
    axes('Position', [-0.05, 0.1, 0.4, 0.82]);
    sys.plotShapeProfile('ShowRays', false);
    axes('Position', [0.38, 0.1, 0.57, 0.82]);
    sys.plotLsa({'d', 'C', 'F', 'e', 'g', 'r'}, 'xlim', [-6, 6], 'ShowLegend', true);
    
    figure(3); clf;
    sys1.plotRayFan([d_line, C_line, F_line, e_line, g_line, r_line], ...
        [0, 0.5, 1] * field_angle, image_curvature);
    
    figure(5); clf;
    sys1.plotSpotDiagram([C_line, d_line, e_line, F_line], field_angle * [0, 0.3, 0.5, 1.0], ...
        'ImageCurv', image_curvature, 'WidthLength', 600e-3);
end

% Manual fine-tuning backworking length and curvature of image surface, to see changes of aberrations.
sys.surfaces(end).t = l0 + 0.15;
image_curvature = -1/1000;

% Show charts of sys, the final system.
shape_lsa_fig = figure(2); clf;
set(gcf, 'Position', [400, 350, 600, 450]);
axes('Position', [-0.05, 0.1, 0.4, 0.82]);
sys.plotShapeProfile('ShowRays', false);
axes('Position', [0.38, 0.1, 0.57, 0.82]);
sys.plotLsa({'d', 'C', 'F', 'e', 'g', 'r'}, 'xlim', [-6, 6], 'ShowLegend', true);

figure(4); clf;
sys.plotRayFan([d_line, C_line, F_line, e_line, g_line, r_line], ...
    [0, 0.5, 1] * field_angle, image_curvature);

spt_fig = figure(6); clf;
sys.plotSpotDiagram([C_line, d_line, e_line, F_line], field_angle * [0, 0.3, 0.5, 1.0], ...
    'ImageCurv', image_curvature, 'WidthLength', 600e-3);

