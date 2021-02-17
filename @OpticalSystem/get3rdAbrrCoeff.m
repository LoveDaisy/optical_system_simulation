function coef = get3rdAbrrCoeff(obj, field_angle, varargin)
% INPUT
%   obj:            OpticalSystem object
%   field_angle:    n-length vector, field angle
% OPTIONAL INPUT
%   'Wavelength':   3-vector, the first one will be used for monochrome aberration.
%                   The default value is [d_line, C_line, F_line]
% OUTPUT
%   coef:       7*n array. primary aberration coefficients. [S, C, A, P, D, AC, LC]
%               1. Spherical
%               2. Coma
%               3. Astigmatism
%               4. Pitzval curvature
%               5. Distortion
%               6. Axial color
%               7. Lateral color

OpticalSystem.check1D(field_angle);

lambda = parse_args(varargin);

surface_num = length(obj.surfaces);
field_num = length(field_angle);

pupils = obj.getPupils();

init_rays = [0, field_angle(:)' * pi / 180; pupils(1, 2), pupils(1, 1) * ones(1, field_num)];
invariant = init_rays(1, 1) * init_rays(2, 2:end) - ...
    init_rays(1, 2:end) * init_rays(2, 1);

coef = zeros(7, field_num);

reverse_prop = false;
prev_n = ones(size(lambda));

% Entrance pupil
curr_t = -pupils(1, 1);
t_mat = [1, 0; curr_t, 1];

rays = t_mat * init_rays;
for i = 1:surface_num
    if obj.surfaces(i).glass.is_reflective
        reverse_prop = ~reverse_prop;
    end

    incident_angles = rays(1, :) + obj.surfaces(i).c * rays(2, :);
    curr_t = obj.surfaces(i).t;
    if reverse_prop
        curr_t = -curr_t;
    end

    t_mat = [1, 0; curr_t, 1];

    curr_n = obj.surfaces(i).glass.getRefractiveIndex(lambda);
    if reverse_prop
        curr_n = -curr_n;
    end
    rel_n = prev_n ./ curr_n;
    r_mat = [rel_n(1), (rel_n(1) - 1) * obj.surfaces(i).c; 0, 1];
    
    after_rays = r_mat * rays;

    % The formula of W is from <Modern geometric optics>,
    % but there is a different formula from the Chinese textbook.
    W = rays(2, :) .* prev_n(1) .* (rel_n(1) - 1) .* ...
        (incident_angles + after_rays(1, :));
    C = rays(2, 1) .* prev_n(1) .* ((prev_n(2) - prev_n(3)) / prev_n(1) - (curr_n(2) - curr_n(3)) / curr_n(1));
    coef(1, :) = coef(1, :) + W(1) .* incident_angles(1).^2;        % Spherical
    coef(2, :) = coef(2, :) + W(1) .* incident_angles(1) .* ...
        incident_angles(2:end);       % Coma
    coef(3, :) = coef(3, :) + W(1) .* incident_angles(2:end).^2;        % Astigmatism
    coef(4, :) = coef(4, :) + (rel_n(1) - 1) / prev_n(1) * obj.surfaces(i).c;   % Pitzval
    coef(5, :) = coef(5, :) + W(2:end) .* incident_angles(1) .* ...
        incident_angles(2:end) + ...
        (rays(1, 2:end).^2 - after_rays(1, 2:end).^2) .* invariant;
    coef(6, :) = coef(6, :) + C * incident_angles(1);
    coef(7, :) = coef(7, :) + C * incident_angles(2:end);

    prev_n = curr_n;
    rays = t_mat * after_rays;
end
end


function lambda = parse_args(args)
% Helper function. Parses the optional arguments

d_line = get_fraunhofer_line('d');
C_line = get_fraunhofer_line('C');
F_line = get_fraunhofer_line('F');

lambda = [d_line, C_line, F_line];

ind = 1;
while ind <= length(args)
    arg_name = args{ind};
    ind = ind + 1;
    if ind > length(args)
        error('args length invalid!')
    end
    arg_val = args{ind};
    ind = ind + 1;

    if strcmpi(arg_name, 'wavelength')
        OpticalSystem.check1D(arg_val);
        if length(arg_val) ~= 3
            error('Wavelength should be 3-length!');
        end
        lambda = arg_val;
    else
        error('invalid parameter name!');
    end
end
end
