function obj = updateParameters(obj, options, x)
% INPUT
%   obj:        OpticalSystem object
%   options:    OpticalSystemOptimOption object

for i = 1:length(options.var_c)
    obj.surfaces(options.var_c(i)).c = x(i) / options.norm_size(1);
end
for i = 1:length(options.var_t)
    obj.surfaces(options.var_t(i)).t = x(i+length(options.var_c)) * options.norm_size(2);
end
for i = 1:length(options.var_conic)
    obj.surfaces(options.var_conic(i)).asph_conic_k = x(i+length(options.var_c)+length(options.var_t));
end
end