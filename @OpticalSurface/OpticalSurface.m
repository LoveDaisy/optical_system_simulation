classdef OpticalSurface
    properties
        c double             % curvature
        t double             % thickness
        glass ZemaxGlass     % ZemaxGlass object
        ah double            % aperture height
        asph_type char       % asphere polynomial type (qcon or qbsf)
        asph_coef double     % asphere polynomial coefficients
        asph_conic_k double  % conic k, k = 0 for sphere, k = 1 for paraboloid
                             % z = c * y^2 / (1 + sqrt(1 - (1 - k) * c^2 * y^2))
    end

    methods
        % Construct syntax:
        %  OpticalSurface(c, t, glass)
        %  OpticalSurface()
        %  OpticalSurface(num)
        function s = OpticalSurface(varargin)
            s.glass = '';
            s.ah = 0;
            s.asph_type = 'qcon';
            s.asph_coef = [];
            s.asph_conic_k = 0;
            if nargin == 0
                s.c = 0;
                s.t = 0;
            elseif nargin == 1
                num = varargin{1};
                s(num) = s;
                for i = 1:num
                    s(i) = OpticalSurface();
                end
            elseif nargin == 3
                s.c = varargin{1};
                s.t = varargin{2};
                s.glass = ZemaxGlass(varargin{3});
            else
                error('Constructor parameter invalid!');
            end
        end
    end
end