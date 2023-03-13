classdef OpticalGlass
    properties (GetAccess = public, SetAccess = private)
        nd double
        vd double
    end

    properties
        is_reflective logical
    end

    properties (Dependent)
        name char
    end

    properties (Access = private)
        name_str char
        disp_formula_coef double  % length of 10
        disp_formula_type int16   % Can be these values:
                                  % 0 = none / air
                                  % 1 = Schott basic formula
                                  % 2 = Sellmeier1
                                  % 3 = Herzberger
                                  % 4 = Sellmeier2
                                  % 5 = Conrady
    end

    methods
        %%% Constructor
        % Syntax
        %   glass = OpticalGlass('BK7');
        %   glass = OpticalGlass(nd);
        %   glass = OpticalGlass([nd, vd]);
        %   glass = OpticalGlass(nd, vd);
        function obj = OpticalGlass(varargin)
            obj.nd = 1;
            obj.vd = inf;
            obj.disp_formula_coef = zeros(1, 10);
            obj.disp_formula_type = 0;
            obj.name_str = 'AIR';
            obj.is_reflective = false;

            if isempty(varargin)
                return;
            end

            if length(varargin) == 1 && ischar(varargin{1})
                glass_name = varargin{1};
                c = strsplit(glass_name, '+');
                if length(c) > 2
                    error('glass name invalid!');
                elseif length(c) == 2 && strcmpi(c{2}, 'ref')
                    obj.is_reflective = true;
                    glass_name = c{1};
                elseif length(c) ~= 1
                    error('glass name invalid!');
                end

                [param, formula_type] = OpticalGlass.findGlass(glass_name);
                if formula_type >= 0
                    obj.nd = param(1);
                    obj.vd = param(2);
                    obj.disp_formula_coef = param(3:end);
                    obj.disp_formula_type = formula_type;
                    obj.name_str = upper(glass_name);
                else
                    error('glass name invalid!');
                end
            elseif length(varargin) == 1 && isscalar(varargin{1})
                obj.nd = varargin{1};
                obj.name_str = 'CUSTOM';
            elseif length(varargin) == 1 && isnumeric(varargin{1})
                param = varargin{1};
                OpticalSystem.check1D(param);
                if length(param) ~= 2
                    error('Syntax: OpticalGlass([nd, vd])');
                end
                obj.nd = param(1);
                obj.vd = param(2);
                obj.name_str = 'CUSTOM';
            elseif length(varargin) == 2 && isscalar(varargin{1}) && isscalar(varargin{2})
                obj.nd = varargin{1};
                obj.vd = varargin{2};
                obj.name_str = 'CUSTOM';
            end
        end
    end

    methods
        %%% Getters and setters
        function obj = set.name(obj, glass_name)
            glass_name = upper(glass_name);
            if isempty(glass_name)
                obj.disp_formula_coef = zeros(1, 8);
                obj.disp_formula_type = 0;
                obj.name_str = 'AIR';
            else
                [param, formula_type] = OpticalGlass.findGlass(glass_name);
                if formula_type >= 0
                    obj.nd = param(1);
                    obj.vd = param(2);
                    obj.disp_formula_coef = param(3:end);
                    obj.disp_formula_type = formula_type;
                    obj.name_str = glass_name;
                else
                    error('glass name invalid!');
                end
            end
        end

        function n = get.name(obj)
            n = obj.name_str;
        end
    end

    methods
        n = getRefractiveIndex(obj, lambda)
        P = getPartialDispersion(obj, lambda1, lambda2)
    end

    methods (Static, Access = private)
        [pram, formula_type] = findGlass(glass_name)
    end
end