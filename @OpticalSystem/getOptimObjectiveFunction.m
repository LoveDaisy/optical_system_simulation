function func = getOptimObjectiveFunction(obj, options)
% INPUT
%   obj:        OpticalSystem object
%   options:    OpticalSystemOptimOptins object
% OUTPUT
%   func:       a function used for optimizaiton

func = @(x)objFunc(obj, options, x);
end


function [f, f_all] = objFunc(obj, options, x)
var_c_length = length(options.var_c);
for i = 1:var_c_length
    obj.surfaces(options.var_c(i)).c = x(i);
end
var_t_length = length(options.var_t);
for i = 1:var_t_length
    obj.surfaces(options.var_t(i)).t = x(i + var_c_length);
end
var_conic_length = length(options.var_conic);
for i = 1:var_conic_length
    obj.surfaces(options.var_conic(i)).asph_conic_k = x(i + var_c_length + var_t_length);
end

thickness_violation_err = sum(abs(min(x(var_c_length+1:end), 0))) * 1e6;

% Back working length
main_l_err = getWorkingLengthError(obj, options);

% Focal length
main_f_err = getFocalLengthError(obj, options);

% 3rd order aberration coefficient
abrr3_err = get3rdAbrrError(obj, options);

% Longitude spherical aberration
main_lsa_err = getLsaError(obj, options);

% Sine aberration
main_osc_err = getSineError(obj, options);

% Spherical chromatic aberration
chm_lsa_err = getSphChrm(obj, options);

% Ray fan
ray_fan_err = getRayFanError(obj, options);

% Spot RMS
rms_err = getRmsError(obj, options);

f_all = [thickness_violation_err; main_f_err; main_l_err; abrr3_err; main_lsa_err; ...
    chm_lsa_err; main_osc_err; ray_fan_err; rms_err];
f = log10(sum(f_all) + 1e-12);
end


% -----------------------------------------------------------------------------
% Back working length
function main_l_err = getWorkingLengthError(obj, options)
main_sys_l = obj.getGaussianBackWorkingLength(options.main_wl);

if ~isempty(options.obj_bwl)
    main_l = options.obj_bwl(1);
    main_l_w = options.obj_bwl(2);
    main_l_err = ((main_sys_l - main_l) / f0)^2 * main_l_w;
else
    main_l_err = 0;
end
end


% -----------------------------------------------------------------------------
% Focal length
function main_f_err = getFocalLengthError(obj, options)
f0 = obj.getFocalLength(0, options.main_wl);

if ~isempty(options.obj_f)
    main_f = options.obj_f(1);
    main_f_w = options.obj_f(2);
    main_f_err = ((f0 - main_f) / f0)^2 * main_f_w;
else
    main_f_err = 0;
end
end


% -----------------------------------------------------------------------------
% 3rd order aberration coefficient
function abrr3_err = get3rdAbrrError(obj, options)
coef = obj.get3rdAbrrCoeff(options.field_full);

if ~isempty(options.obj_abrr3)
    abrr3_target = options.obj_abrr3(:, 1);
    abrr3_w = options.obj_abrr3(:, 2);
    abrr3_err = dot((coef(:) - abrr3_target(:)).^2, abrr3_w);
else
    abrr3_err = 0;
end
end


% -----------------------------------------------------------------------------
% Longitude spherical aberration
function main_lsa_err = getLsaError(obj, options)
pupil = obj.getPupils();
main_sys_l = obj.getGaussianBackWorkingLength(options.main_wl);
f0 = obj.getFocalLength(0, options.main_wl);

if ~isempty(options.obj_lsa)
    main_lsa_h = options.pupil_sample_t * pupil(1, 2);
    main_lsa_w = options.obj_lsa;
    main_lsa = (obj.getBackWorkingLength(main_lsa_h, options.main_wl) - main_sys_l) / f0;
    main_lsa_err = dot(main_lsa.^2, main_lsa_w);
else
    main_lsa_err = 0;
end
end


% -----------------------------------------------------------------------------
% Sine aberration
function main_osc_err = getSineError(obj, options)
pupil = obj.getPupils();
main_sys_l = obj.getGaussianBackWorkingLength(options.main_wl);
f0 = obj.getFocalLength(0, options.main_wl);

if ~isempty(options.obj_osc) && ~isempty(options.obj_lsa)
    main_osc_h = options.pupil_sample_t * pupil(1, 2);
    main_osc_w = options.obj_osc;
    main_osc_df = obj.getFocalLength(main_osc_h, options.main_wl) - f0;
    main_lsa = (obj.getBackWorkingLength(main_osc_h, options.main_wl) - main_sys_l) / f0;
    main_osc = (main_osc_df - main_lsa) / f0;
    main_osc_err = dot(main_osc.^2, main_osc_w);
else
    main_osc_err = 0;
end
end


% -----------------------------------------------------------------------------
% Spherical chromatic aberration
function chm_lsa_err = getSphChrm(obj, options)
pupil = obj.getPupils();
f0 = obj.getFocalLength(0, options.main_wl);

if ~isempty(options.obj_sph_chrm)
    chm_lsa_h = options.pupil_sample_t * pupil(1, 2);
    chm_lsa_w = options.obj_sph_chrm;
    chm_lsa = obj.getBackWorkingLength(chm_lsa_h, options.chm_wl);
    chm_lsa_err = dot(var(chm_lsa, 0, 2)/f0^2, chm_lsa_w);
else
    chm_lsa_err = 0;
end
end


% -----------------------------------------------------------------------------
% Ray fan error
function ray_fan_err = getRayFanError(obj, options)
if isempty(options.obj_rf_field) || isempty(options.obj_rf_t) || isempty(options.obj_rf_s)
    ray_fan_err = 0;
    return
end

pupil = obj.getPupils();
lambda = [options.main_wl; options.chm_wl(:)];
wl_num = length(lambda);
angle_num = length(options.field_sample);
image_curvature = options.image_curv;

obj.surfaces(end).t = obj.getBackWorkingLength(0, options.main_wl);

% Tangential input rays
ty = [options.pupil_sample_t(:); reshape(-options.pupil_sample_t(2:end), [], 1)] * pupil(1, 2);
fan_ray_num = length(ty);
tangential_pts = zeros(fan_ray_num, 2, wl_num, angle_num);
for i = 1:angle_num
    ray_pts = [zeros(fan_ray_num, 1), ty, zeros(fan_ray_num, 1)];
    ray_dir = [zeros(fan_ray_num, 1), ...
        sind(options.field_sample(i) * options.field_full) * ones(fan_ray_num, 1), ...
        cosd(options.field_sample(i) * options.field_full) * ones(fan_ray_num, 1)];
    tangential_pts(:, :, :, i) = obj.traceRayInterception([ray_pts, ray_dir], lambda, image_curvature);
    tangential_pts(:, :, :, i) = bsxfun(@minus, tangential_pts(:, :, :, i), ...
        tangential_pts(1, :, :, i));
end

% Sagittal input rays
sx = options.pupil_sample_s(:) * pupil(1, 2);
fan_ray_num = length(sx);
sagittal_pts = zeros(fan_ray_num, 2, wl_num, angle_num);
for i = 1:angle_num
    ray_pts = [sx, zeros(fan_ray_num, 2)];
    ray_dir = [zeros(fan_ray_num, 1), ...
        sind(options.field_sample(i) * options.field_full) * ones(fan_ray_num, 1), ...
        cosd(options.field_sample(i) * options.field_full) * ones(fan_ray_num, 1)];
    sagittal_pts(:, :, :, i) = obj.traceRayInterception([ray_pts, ray_dir], lambda, image_curvature);
    sagittal_pts(:, :, :, i) = bsxfun(@minus, sagittal_pts(:, :, :, i), ...
        sagittal_pts(1, :, :, i));
end

dy = squeeze(tangential_pts(:, 2, :, :));
dx = squeeze(sagittal_pts(:, 1, :, :));

dy = bsxfun(@times, dy, reshape(options.obj_rf_field, 1, 1, angle_num));
dy = bsxfun(@times, dy, reshape([options.obj_rf_t(:); ...
    reshape(options.obj_rf_t(2:end), [], 1)], [], 1, 1));
dy = dy / pupil(1, 2);      % Normalize

dx = bsxfun(@times, dx, reshape(options.obj_rf_field, 1, 1, angle_num));
dx = bsxfun(@times, dx, reshape(options.obj_rf_s, [], 1, 1));
dx = dx / pupil(1, 2);      % Normalize

ray_fan_err = (sum(reshape(dy(:, 1, :).^2, [], 1)) + ...
    sum(reshape(dx(:, 1, :).^2, [], 1)) * 2) * 10;
ray_fan_err = ray_fan_err + (sum(reshape(var(dy(:, 2:end, :), 0, 2), [], 1)) + ...
    sum(reshape(var(dx(:, 2:end, :), 0, 2), [], 1)) * 2) * 50;
end


% -----------------------------------------------------------------------------
% Spot RMS error
function rms_err = getRmsError(obj, options)
if isempty(options.obj_rms_field) || isempty(options.obj_rms_k)
    rms_err = 0;
    return
end

pupil = obj.getPupils();
lambda = [options.main_wl; options.chm_wl(:)];
angle_num = length(options.field_sample);

obj.surfaces(end).t = obj.getBackWorkingLength(0, options.main_wl);

pts0 = disk_circular_sample([0, 0], pupil(1, 2), options.obj_rms_k);
pts_num = size(pts0, 1);

rms = 0;
sk = 0;
ast = 0;
init_pts = [pts0, zeros(pts_num, 1)];
init_dir = zeros(pts_num, 3);
for i = 1:angle_num
    init_dir(:, 2) = sind(options.field_full * options.field_sample(i));
    init_dir(:, 3) = cosd(options.field_full * options.field_sample(i));
    pts = obj.traceRayInterception([init_pts, init_dir], lambda, options.image_curv);
    pts_center = mean(pts, 1);

    d = bsxfun(@minus, pts, pts_center);

    mean_r2 = squeeze(sum(d.^2) / pts_num);
    curr_sk = reshape(max(abs(skewness(d, 0, 1)), [], 2), 1, []);
    curr_ast = abs(diff(mean_r2, 1, 1));

    rms = rms + sum(mean_r2) * options.obj_rms_field(i);
    sk = sk + curr_sk * options.obj_rms_field(i);
    ast = ast + curr_ast * options.obj_rms_field(i);
end
rms_err = sum(rms(:)) + sum(sk(:)) * 0.5e-5 + sum(ast(:)) * 5;
end
