clear; close all; clc;

datasheet_filename = {'OHARA_190820', ...
    'cdgm_2017-09', 'schottzemax-20180601'};

for fi = 1:length(datasheet_filename)
    filename = datasheet_filename{fi};
    fid = fopen(sprintf('@ZemaxGlass/%s.agf', filename));
    
    % Count glass numbers
    glass_num = 0;
    
    line_txt = fgetl(fid);
    while ischar(line_txt)
        if length(line_txt) < 3
            line_txt = fgetl(fid);
            continue;
        end
        if strcmp(line_txt(1:3), 'NM ')
            glass_num = glass_num + 1;
        end
        line_txt = fgetl(fid);
    end
    
    glass_name = cell(glass_num, 1);
    glass_prop = zeros(glass_num, 12);  % properties: [nd, vd, coef]
    glass_coef_type = zeros(glass_num, 1, 'int16');
    
    % Read glass properties
    fseek(fid, 0, 'bof');
    glass_ind = 1;
    line_txt = fgetl(fid);
    while ischar(line_txt)
        if length(line_txt) < 3
            line_txt = fgetl(fid);
            continue;
        end
        if strcmp(line_txt(1:3), 'NM ')
            c = strsplit(line_txt(4:end), ' ');
            glass_name{glass_ind} = c{1};
            coef_type = textscan(c{2}, '%d');
            if ~isempty(coef_type)
                glass_coef_type(glass_ind) = int16(coef_type{1});
            end
            nd = textscan(c{4}, '%f');
            if ~isempty(nd)
                glass_prop(glass_ind, 1) = nd{1};
            end
            vd = textscan(c{5}, '%f');
            if ~isempty(vd)
                glass_prop(glass_ind, 2) = vd{1};
            end
        end
        if strcmp(line_txt(1:3), 'CD ')
            c = strsplit(line_txt(4:end), ' ');
            for ci = 1:min(length(c), 10)
                try
                    coef = textscan(c{ci}, '%f');
                    if ~isempty(coef)
                        glass_prop(glass_ind, 2+ci) = coef{1};
                    end
                catch e
                    continue;
                end
            end
            glass_ind = glass_ind + 1;
        end
        line_txt = fgetl(fid);
    end
    
    fclose(fid);
    
    save(sprintf('@ZemaxGlass/%s.mat', filename), ...
        'glass_name', 'glass_prop', 'glass_coef_type');
end