classdef OpticalSystemOptimOption
    properties (Access = ?OpticalSystem)
        var_c uint16        % surface index
        var_t uint16        % surface index
        var_conic uint16    % surface index

        main_wl double      % scalar, wavelength for monochromatic aberration
        chm_wl double       % m-vector, wavelength used in chromatic-related
        pupil_sample_t double   % n1-vector, entrance pupil sample position for tangential
        pupil_sample_s double   % n2-vector, entrance pupil sample position for sagittal
        field_sample double     % n3-vector, field sample position
        field_full double   % scalar
        image_curv double   % scalar, image curvature

        obj_bwl double      % 2-vector, back working length, [l, weight]
        obj_f double        % 2-vector, focal length, [f, weight]

        obj_abrr3 double    % 7*2, 3rd order aberration coefficient, [target, weight]
                            % [S, C, A, P, D, AC, LC]

        % Following are weights for different target
        obj_lsa double      % n1-vector, the same length of pupil_sample_t
        obj_osc double      % n1-vector, the same length of pupil_sample_t, OSC = (df - dl) / f
        obj_sph_chrm double % n1-vector, the same length of pupil_sample_t,
                            % spherical chromatic, it is the variance of LSA of different wavelength
        obj_rf_field double % n3-vector, the same length of field_sample,
                            % the weights for ray fan at different field
        obj_rf_t double     % n1-vector, the same length of pupil_sample_t
        obj_rf_s double     % n2-vector, the same length of pupil_sample_s
        obj_rms_field double    % n3-vector, the same length of field_sample
        obj_rms_k double    % scalar, the rings of disk samples
    end
end