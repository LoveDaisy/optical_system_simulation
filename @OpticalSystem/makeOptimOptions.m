function options = makeOptimOptions(obj, varargin)
% INPUT
%   obj:        OpticalSystem object
% OPTIONAL INPUT
%   'VarC':             n1-length uint16, surface index
%   'VarT':             n2-length uint16, surface index
%   'VarConic':         n3-length uint16, surface index
%
%   'MainWavelength':   1 double, wavelength used in monochromatic aberration,
%                       default is d-line
%   'ChromaticWavelength':
%                       double array, wavelength(s) used in chromatic aberrations,
%                       default is C-line and F-line
%   'PupilSampleT':     1-D vector, default is [0, 0.3, 0.5, 0.707, 0.85, 1]
%   'PupilSampleS':     1-D vector, default is [0.3, 0.5, 0.707, 0.85, 1]
%   'FieldSample':      1-D vector, default is [0, 0.5, 1]
%   'FullField':        scalar, default is 0.
%   'ImageCurvature':   scalar, default is 0.
%
%   'ObjBackWorkingLength':
%                       2-vector, objective back working length, [l, weight]
%   'ObjFocalLength':   2-vector, objective focal length, [f, weight]
%   'Obj3rdAbrr':       7*2 double, 3rd aberration coefficient, [target, weight]
%   'ObjLSA':           scalar, or same length vector to 'PupilSampleT', the weights for LSA at
%                       different relative height.
%   'ObjOSC':           scalar, or same length vector to 'PupilSampleT', the weights for OSC at
%                       different relative height.
%   'ObjSphChrm':       scalar, or same length vector to 'PupilSampleT', the weights for spherical
%                       chromatic aberration at different relative height
%   'ObjRayFan':        Three parameters.
%                       First is for field. A scalar or the same length as 'FieldSample'.
%                       Second is for tangential pupile sample. A scalar or the same length as 'PupilSampleT'
%                       Third is for sagittal pupile sample. A scalar or the same length as 'PupilSampleS'
%   'ObjRms':           Tow parameters.
%                       First is for field. A scalar or the same length as 'FieldSample'.
%                       Second is whether fit to a image sphere.
% OUTPUT
%   options:    OpticalSystemOptimOption object

options = OpticalSystemOptimOption();
surface_num = length(obj.surfaces);

% Default values
options.main_wl = get_fraunhofer_line('d');
options.chm_wl = zeros(2, 1);
options.chm_wl(1) = get_fraunhofer_line('C');
options.chm_wl(2) = get_fraunhofer_line('F');
options.pupil_sample_t = [0, 0.3, 0.5, 0.707, 0.85, 1];
options.pupil_sample_s = [0, 0.3, 0.5, 0.707, 0.85, 1];
options.field_sample = [0, 0.5, 1];
options.field_full = 0;
options.image_curv = 0;

var_ind = 1;
while var_ind <= length(varargin)
    if ~ischar(varargin{var_ind})
        error('options parameter invalid!');
    end
    var_name = varargin{var_ind};
    var_ind = var_ind + 1;
    var_val = varargin{var_ind};
    var_ind = var_ind + 1;

    if strcmpi(var_name, 'varc')
        OpticalSystem.check1D(var_val);
        if ~isnumeric(var_val) || any(var_val < 1) || any(var_val > surface_num)
            error('parameter invalid!');
        end
        options.var_c = var_val;
    elseif strcmpi(var_name, 'vart')
        OpticalSystem.check1D(var_val);
        if ~isnumeric(var_val) || any(var_val < 1) || any(var_val > surface_num)
            error('parameter invalid!');
        end
        options.var_t = var_val;
    elseif strcmpi(var_name, 'varconic')
        OpticalSystem.check1D(var_val);
        if ~isnumeric(var_val) || any(var_val < 1) || any(var_val > surface_num)
            error('parameter invalid!');
        end
        options.var_conic = var_val;
    elseif strcmpi(var_name, 'mainwavelength')
        if ~isscalar(var_val)
            error('main wavelength should be a double!');
        end
        options.main_wl = var_val;
    elseif strcmpi(var_name, 'chromaticwavelength')
        if ~isnumeric(var_val)
            error('chromatic wavelength shold be double (array)!');
        end
        OpticalSystem.check1D(var_val);
        options.chm_wl = var_val;
    elseif strcmpi(var_name, 'pupilsamples')
        if ~isnumeric(var_val)
            error('PupilSampleS should be a 1-D array!');
        end
        OpticalSystem.check1D(var_val);
        options.pupil_sample_s = var_val;
    elseif strcmpi(var_name, 'pupilsamplet')
        if ~isnumeric(var_val)
            error('PupilSampleT should be a 1-D array!');
        end
        OpticalSystem.check1D(var_val);
        options.pupil_sample_s = var_val;
    elseif strcmpi(var_name, 'fieldsample')
        if ~isnumeric(var_val)
            error('FieldSample should be a 1-D array!');
        end
        OpticalSystem.check1D(var_val);
        options.field_sample = var_val;
    elseif strcmpi(var_name, 'fullfield')
        if ~isscalar(var_val)
            error('FullField should be a scalar');
        end
        options.field_full = var_val;
    elseif strcmpi(var_name, 'imagecurvature')
        if ~isscalar(var_val)
            error('ImageCurvature should be a scalar!');
        end
        options.image_curv = var_val;
    elseif strcmpi(var_name, 'objbackworkinglength')
        OpticalSystem.check1D(var_val);
        if ~isnumeric(var_val) || length(var_val) ~= 2
            error('ObjBackWrokingLength value should be 2-vector double!');
        end
        options.obj_bwl = var_val;
    elseif strcmpi(var_name, 'objfocallength')
        OpticalSystem.check1D(var_val);
        if ~isnumeric(var_val) || length(var_val) ~= 2
            error('ObjFocalLength value should be 2-vector double!');
        end
        options.obj_f = var_val;
    elseif strcmpi(var_name, 'obj3rdabrr')
        if ~isnumeric(var_val) || size(var_val, 1) ~= 7 || size(var_val, 2) ~= 2
            error('Obj3rdAbrr should be 7*2 array!');
        end
        options.obj_abrr3 = var_val;
    elseif strcmpi(var_name, 'objlsa')
        if ~isnumeric(var_val)
            error('ObjLSA value should be scalar or 1-D vector!');
        end
        OpticalSystem.check1D(var_val);
        if length(var_val) ~= length(options.pupil_sample_t) && ~isscalar(var_val)
            error('ObjLSA value showld be scalar, or the same length with PupilSampleT!');
        end
        if isscalar(var_val)
            options.obj_lsa = var_val * ones(size(options.pupil_sample_t));
        else
            options.obj_lsa = var_val;
        end
    elseif strcmpi(var_name, 'objosc')
        if ~isnumeric(var_val)
            error('ObjOSC value should be scalar or 1-D vector!');
        end
        OpticalSystem.check1D(var_val);
        if length(var_val) ~= length(options.pupil_sample_t) && ~isscalar(var_val)
            error('ObjOSC value showld be scalar, or the same length with PupilSampleT!');
        end
        if isscalar(var_val)
            options.obj_osc = var_val * ones(size(options.pupil_sample_t));
        else
            options.obj_osc = var_val;
        end
    elseif strcmpi(var_name, 'objsphchrm')
        if ~isnumeric(var_val)
            error('ObjSphChrm value should be scalar or 1-D vector!');
        end
        OpticalSystem.check1D(var_val);
        if length(var_val) ~= length(options.pupil_sample_t) && ~isscalar(var_val)
            error('ObjSphChrm value showld be scalar, or the same length with PupilSampleT!');
        end
        if isscalar(var_val)
            options.obj_sph_chrm = var_val * ones(size(options.pupil_sample_t));
        else
            options.obj_sph_chrm = var_val;
        end
    elseif strcmpi(var_name, 'objrayfan')
        if var_ind + 1 > length(varargin)
            error('Invalid parameter! Not enough value for ObjRayFan!');
        end
        if ~isnumeric(var_val) || ~isnumeric(varargin{var_ind}) || ~isnumeric(varargin{var_ind+1})
            error('Invalid parameter for ObjRayFan!');
        end
        var_val1 = var_val;
        var_val2 = varargin{var_ind};
        var_val3 = varargin{var_ind+1};
        var_ind = var_ind + 2;

        OpticalSystem.check1D(var_val1);
        OpticalSystem.check1D(var_val2);
        OpticalSystem.check1D(var_val3);

        if ~isscalar(var_val1) && length(var_val1) ~= length(options.field_sample)
            error('1st param of ObjRayFan should be a scalar or the same length of FieldSample!');
        end
        if ~isscalar(var_val2) && length(var_val2) ~= length(options.pupil_sample_t)
            error('2nd param of ObjRayFan should be a scalar or the same length of PupilSampleT!');
        end
        if ~isscalar(var_val3) && length(var_val3) ~= length(options.pupil_sample_s)
            error('3rd param of ObjRayFan should be a scalar or the same length of PupilSampleS!');
        end

        if isscalar(var_val1)
            options.obj_rf_field = var_val1 * ones(size(options.field_sample));
        else
            options.obj_rf_field = var_val1;
        end

        if isscalar(var_val2)
            options.obj_rf_t = var_val2 * ones(size(options.pupil_sample_t));
        else
            options.obj_rf_t = var_val2;
        end

        if isscalar(var_val3)
            options.obj_rf_s = var_val3 * ones(size(options.pupil_sample_s));
        else
            options.obj_rf_s = var_val3;
        end
    elseif strcmpi(var_name, 'objrms')
        if ~isnumeric(var_val)
            error('Invalid parameter for ObjRms!');
        end
        OpticalSystem.check1D(var_val);

        if ~isscalar(var_val) && length(var_val) ~= length(options.field_sample)
            error('1st param of ObjRms should be a scalar or the same length of FieldSample!');
        end
        if isscalar(var_val)
            options.obj_rms_field = var_val * ones(size(options.field_sample));
        else
            options.obj_rms_field = var_val;
        end
        options.obj_rms_k = 7;
    else
        error('Parameter cannot recognize!');
    end
end
end