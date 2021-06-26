clear; close all; clc;

d_line = get_fraunhofer_line('d');
Fp_line = get_fraunhofer_line('F''');
F_line = get_fraunhofer_line('F');
e_line = get_fraunhofer_line('e');
Cp_line = get_fraunhofer_line('C''');
C_line = get_fraunhofer_line('C');
r_line = get_fraunhofer_line('r');

%%
% beam_r = 200;
f_number = 5;
full_field_angle = 0.65;
f_des = 2000;
image_curvature = 0;
normalize_size = [f_des, 1e-3*f_des];

alpha = 0.28;
delta = 0.06;
beta = (1 - alpha) / (delta - alpha);
R1 = 2 * f_des * 1.00 / beta;
R2 = alpha * beta / (1 + beta) * R1;
t1 = -(1 - alpha) * R1 / 2;

sys = OpticalSystem([1/R1, 1/R2, ...
    -.008, -.005, .009, .007, .015, .025], ...
    [t1, 470, 8, 2.2, 10, 2.2, 8, 0], ...
    {'AIR+REF', 'AIR+REF', ...
    'BK7', 'AIR', 'BK7', 'AIR', 'BK7', 'AIR'});

sys.ast = 1;
sys.surfaces(1).asph_conic_k = 1 + 2*alpha / (1 - alpha) / beta^2;
sys.surfaces(2).asph_conic_k = (2*beta/(1-alpha) + (1+beta)*(1-beta)^2) / ...
    (1+beta)^3;
% sys = sys.updateApertureHeight(beam_r, full_field_angle);
sys = sys.solveApertureHeight(f_number, full_field_angle);
sys.surfaces(end).t = sys.getBackWorkingLength(0, d_line);

%%
% First optimization
fminsearch_options = optimset('Display', 'iter', 'LargeScale', 'off', ...
    'TolX', 1e-5, 'MaxFunEvals', 1e5, 'MaxIter', 1e5);
fminunc_options = optimoptions('fminunc', 'Algorithm', 'quasi-newton', ...
    'MaxFunctionEvaluation', 1e5, 'Display', 'iter', ...
    'MaxIterations', 1e5);
simulanneal_options = optimoptions('simulannealbnd', 'Display', 'iter', ...
    'MaxFunctionEvaluations', 1e5);
swarm_size = 100;
particle_options = optimoptions('particleswarm', 'Display', 'iter', ...
    'MaxIterations', 1e5, 'SwarmSize', swarm_size, 'ObjectiveLimit', -6.4, ...
    'UseParallel', true);
%%
% First optimization
sys_options = sys.makeOptimOptions('VarC', 3:length(sys.surfaces), ...
    'ChromaticWavelength', [d_line, C_line, F_line], ...
    'NormalizeSize', normalize_size, ...
    'FullField', full_field_angle, ...
    'FieldSample', [0, 0.5, 0.7, 1], ...
    'ImageCurvature', image_curvature, ...
    'ObjFocalLength', [f_des, .005], ...
    'ObjLSA', 50, ...
    'ObjSphChrm', 50, ...
    'ObjRms', [5, 7, 8, 9]*2e-4);
func = sys.getOptimObjectiveFunction(sys_options);

x0 = cat(1, sys.surfaces(3:end).c) * normalize_size(1);
[~, fval0] = func(x0);

x1 = fminunc(func, x0, fminunc_options);
x2 = fminsearch(func, x1, fminsearch_options);
sys = sys.updateParameters(sys_options, x2);

[~, fval2] = func(x2);


% Second optimization
sys_options = sys.makeOptimOptions('VarC', 3:length(sys.surfaces), ...
    'VarT', 2, ...
    'ChromaticWavelength', [d_line, C_line, F_line], ...
    'NormalizeSize', normalize_size, ...
    'FullField', full_field_angle, ...
    'FieldSample', [0, 0.5, 0.7, 1], ...
    'ImageCurvature', image_curvature, ...
    'ObjFocalLength', [f_des, .5], ...
    'ObjLSA', 50, ...
    'ObjSphChrm', 50, ...
    'ObjRms', [5, 7, 8, 9]*2e-4);
func = sys.getOptimObjectiveFunction(sys_options);

x30 = [x2; cat(1, sys.surfaces(2).t) / normalize_size(2)];
[~, fval30] = func(x30);
x30_pop = [x30'; bsxfun(@times, (1 + randn(swarm_size-1, length(x30)) * 0.2), x30')];
particle_options = optimoptions(particle_options, ...
    'InitialSwarmMatrix', x30_pop);

x3 = particleswarm(func, length(x30), [], [], particle_options);
x3 = fminunc(func, x3, fminunc_options);
x4 = fminsearch(func, x3, fminsearch_options);
sys = sys.updateParameters(sys_options, x4);

[~, fval4] = func(x4);
% Optimization finished

sys.surfaces(end).t = sys.getBackWorkingLength(0, d_line);
% sys = sys.updateApertureHeight(beam_r, full_field_angle);
sys = sys.solveApertureHeight(f_number, full_field_angle);

%%
f0 = sys.getFocalLength(0, d_line);
l0 = sys.getBackWorkingLength(0, d_line);

curr_image_curve = -0.2e-3;
sys.surfaces(end).t = l0 + 0.0;

figure(1); clf;
sys.plotLsa([d_line, C_line, F_line]);

figure(2); clf;
sys.plotShapeProfile([0, 1]*full_field_angle);

figure(3); clf;
sys.plotRayFan([d_line, C_line, F_line], ...
    [0, 0.5, 0.7, 1]*full_field_angle, curr_image_curve);

figure(4); clf;
sys.plotFieldCurvature(full_field_angle, [d_line, C_line, F_line]);

figure(5); clf;
sys.plotDistortion(full_field_angle, [d_line, C_line, F_line]);

figure(6); clf;
sys.plotSpotDiagram([C_line, d_line, e_line, F_line], ...
    [0, 0.5, 0.7, 1]*full_field_angle, ...
    'ImageCurv', curr_image_curve, ...
    'WidthLength', 200e-3);

