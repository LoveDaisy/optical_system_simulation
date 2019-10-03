function obj = updateParameters(obj, options, x)
% INPUT
%   obj:        OpticalSystem object
%   options:    OpticalSystemOptimOption object

for i = 1:length(options.var_c)
    obj.surfaces(options.var_c(i)).c = x(i);
end
for i = 1:length(options.var_t)
    obj.surfaces(options.var_t(i)).t = x(i+length(options.var_c));
end
end