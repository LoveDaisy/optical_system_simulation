function checkArrayParam(c_array, t_array, glass_name_array)
type_check = isnumeric(c_array) && isnumeric(t_array) && ...
    iscell(glass_name_array);
if ~type_check
    error(['c_array and t_array should be numeric; '
        'glass_name_array should be cell array']);
end

OpticalSystem.check1D(c_array);
OpticalSystem.check1D(t_array);
OpticalSystem.check1D(glass_name_array);

size_check = length(c_array) == length(t_array) && ...
    length(c_array) == length(glass_name_array);
if ~size_check
    error('All input array should be 1D vector!');
end
end