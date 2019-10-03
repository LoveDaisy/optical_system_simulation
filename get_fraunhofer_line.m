function lambda = get_fraunhofer_line(name)
% INPUT
%  name:    Fraunhofer line name
% OUTPUT
%  lambda:  wavelength

data = {'h', 404.7; 'g', 435.8; 'F''', 480.0; 'F', 486.1; 'e', 546.1; 'd', 587.6;
    'D', 589.3; 'C''', 643.8; 'C', 656.3; 'r', 706.5};
for i = 1:size(data, 1)
    if strcmpi(name, data{i, 1})
        lambda = data{i, 2};
        return;
    end
end
error('Line name is not supported!');
end