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
        % Basic properties
        t = getTotalThickness(obj)
        f = getFocalLength(obj, h, lambda)
        l = getBackWorkingLength(obj, h, lambda)
        p = getPupils(obj)

        % Abrration evaluation
        coef = get3rdAbrrCoeff(obj, field_angle)

        % System solving
        obj = updateApertureHeight(obj, entry_beam_r, full_field_angle)
        obj = solveApertureHeight(obj, f_number, full_field_angle)

        % Optimization
        options = makeOptimOptions(obj, varargin)
        func = getOptimObjectiveFunction(obj, options)
        obj = updateParameters(obj, options, x)

        % Ray tracing
        pts = traceRayInterception(obj, init_rays, varargin)

        % Plot functions
        plotLsa(obj, lambda, varargin)
        plotRayFan(obj, lambda, field_angle, varargin)
        plotFieldCurvature(obj, full_angle, varargin)
        plotDistortion(obj, full_angle, varargin)
        img = plotSpotDiagram(obj, lambda, field_angle, varargin)
        plotShapeProfile(obj, varargin)
    end

    methods (Access = private)
        %%% Private methods
        [sys_mat, t_mat, r_mat] = makeGaussianSystemMatrix(obj, lambda, varargin)
        sys_data = makeInternalSystemData(obj, lambda)
        l = getGaussianBackWorkingLength(obj, lambda)
        f = getGaussianFocalLength(obj, lambda)
        [front_sys, back_sys] = splitAt(obj, surf_ind)
    end

    methods (Static, Access = private)
        %%% Static private methods
        % Check conditions
        checkArrayParam(c_array, t_array, glass_name_array)
        check1D(array)

        % Ray tracing
        rays_store = traceRays(rays, sys_data)
        pts = intersectWithConic(pts, ray_dir, c, k)
        ray_dir = refractAtConic(ray, n_rel, c, k)
    end
end