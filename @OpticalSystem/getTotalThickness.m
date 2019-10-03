function t = getTotalThickness(obj)
% INPUT
%   obj:        OpticalSystem object
% OUTPUT
%   t:          The total thickness

t = 0;
reverse_prop = false;
for i = 1:length(obj.surfaces)-1
    if obj.surfaces(i).glass.is_reflective
        reverse_prop = ~reverse_prop
    end
    curr_t = obj.surfaces(i).t;
    if reverse_prop
        curr_t = -curr_t;
    end
    t = t + curr_t;
end
end