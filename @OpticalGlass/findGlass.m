function [param, formula_type] = findGlass(glass_name)
% INPUT
%   glass_name:     char, glass name
% OUTPUT
%   param:          12-vector, [nd, vd, coef]
%   formula_type:   int16, dispersion formula type

databases = {'schottzemax-20180601.mat', 'OHARA_190820.mat', 'cdgm_2017-09'};

if isempty(glass_name) || strcmpi(glass_name, 'air')
    param = [1, inf, zeros(1, 10)];
    formula_type = int16(0);
    return;
end

for di = 1:length(databases)
    C = load(databases{di});

    glass_num = length(C.glass_name);
    for i = 1:glass_num
        curr_name = C.glass_name{i};
        if strcmpi(glass_name, curr_name)
            formula_type = C.glass_coef_type(i);
            param = C.glass_prop(i, :);
            return;
        end
    end
    for i = 1:glass_num
        curr_name = C.glass_name{i};
        if length(curr_name) >= 3 && curr_name(2) == '-' && ...
                strcmpi(curr_name(3:end), glass_name)
            formula_type = C.glass_coef_type(i);
            param = C.glass_prop(i, :);
            return;
        end
    end
end
error('glass name invalid!');
end