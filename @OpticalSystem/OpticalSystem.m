classdef OpticalSystem
    properties
        surfaces OpticalSurface
        ast uint16
    end

    methods
        %%% Constructor
        % The syntax:
        %   sys = OpticalSystem(c_array, t_array, glass_name_array);
        %   sys = OpticalSystem(surface_num);
        function obj = OpticalSystem(varargin)
            if length(varargin) == 1
                surface_num = varargin{1};
                if ~isscalar(surface_num)
                    error('Construct parameter should be a scalar!');
                end
                obj.surfaces = OpticalSurface(surface_num);
            elseif length(varargin) == 3
                c_array = varargin{1};
                t_array = varargin{2};
                glass_name_array = varargin{3};
                OpticalSystem.checkArrayParam(c_array, t_array, glass_name_array);
                surface_num = length(t_array);
                obj.surfaces = OpticalSurface(surface_num);
                for i = 1:surface_num
                    obj.surfaces(i).c = c_array(i);
                    obj.surfaces(i).t = t_array(i);
                    obj.surfaces(i).glass = ZemaxGlass(glass_name_array{i});
                end
            end
            obj.ast = 1;
        end
    end

    methods
        %%% Public methods
        t = getTotalThickness(obj)
        f = getFocalLength(obj, h, lambda)
        l = getBackWorkingLength(obj, h, lambda)
        p = getPupils(obj)
        coef = get3rdAbrrCoeff(obj, field_angle)
        obj = updateApertureHeight(obj, entry_beam_r)

        options = makeOptimOptions(obj, varargin)
        func = getOptimObjectiveFunction(obj, options)
        obj = updateParameters(obj, options, x)
        pts = traceRayInterception(obj, init_rays, varargin)

        % Syntax:
        %   obj.plotLsa()
        %   obj.plotLsa('normalized', true, 'xlim', [-1e-3, 0.2e-3])
        plotLsa(obj, lambda, varargin)

        % Syntax:
        %   obj.plotRayFan(lambda, field_angle)
        %   obj.plotRayFan(lambda, field_angle, 'ylim', [-2e-2, 2e-2])
        plotRayFan(obj, lambda, field_angle, varargin)

        % Syntax:
        %   obj.plotShapeProfiler()
        plotShapeProfiler(obj)
    end

    methods (Access = private)
        %%% Private methods
        sys_mat = makeGaussianSystemMatrix(obj, lambda, varargin)
        sys_data = makeInternalSystemData(obj, lambda)
        l = getGaussianBackWorkingLength(obj, lambda)
        f = getGaussianFocalLength(obj, lambda)
        [front_sys, back_sys] = splitAtStop(obj)
    end

    methods (Static, Access = private)
        %%% Static private methods
        % Check conditions
        checkArrayParam(c_array, t_array, glass_name_array)
        check1D(array)

        % Ray tracing
        rays_store = traceRays(rays, sys_data)
        pts = intersectWithSphere(pts, ray_dir, c)
        pts = intersectWithConic(pts, ray_dir, c, k)
        ray_dir = refractAtSphere(ray, n_rel, c)
        ray_dir = refractAtConic(ray, n_rel, c, k)
    end
end