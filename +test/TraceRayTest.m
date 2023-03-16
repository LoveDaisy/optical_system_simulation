classdef TraceRayTest < matlab.unittest.TestCase
    methods (Test)
        % Test OpticalSystem.traceRays method
        function testTraceRay(testCase)
            sys_data = [1e-2, 20, 1.62, 15, 1, 0;
                0, 0, 1.62, 15, 1, 0];
            ray_in = [0, 5, 0, 0, 0, 1];
            expected_ray_store = cat(3, ...
                [0,5,0.125078222809105,0,-0.0191505862174315,0.999816610707948], ...
                [0,4.61931378316540,20,0,-0.0191505862174315,0.999816610707948]);

            ray_store = OpticalSystem.traceRays(ray_in, sys_data);
            testCase.verifyEqual(size(ray_store), size(expected_ray_store), 'Size mismatch');
            testCase.verifyEqual(ray_store, expected_ray_store, 'AbsTol', 1e-6, 'Ray store error');
        end

        % Test OpticalSystem.intersectWithConic method
        % and OpticalSurface.findIntersectionPoint method
        function testIntersectWithConic(testCase)
            % Paraxial ray
            p = [0, 4, 0];
            d = [0, 0, 1];
            surf = OpticalSurface();

            % Pure spherical surface
            c = 0.05;
            k = 0;
            expected_pts = [0,4,0.404082057734575];
            surf.c = c;
            surf.asph_conic_k = k;

            pts1 = OpticalSystem.intersectWithConic(p, d, c, k);
            testCase.verifyEqual(size(pts1), size(expected_pts), 'Size mismatch');
            testCase.verifyEqual(pts1, expected_pts, 'AbsTol', 1e-10, 'Pure spherical surface error');

            pts2 = surf.findIntersectionPoint([p, d]);
            testCase.verifyEqual(size(pts2), size(expected_pts), 'Size mismatch');
            testCase.verifyEqual(pts2, expected_pts, 'AbsTol', 1e-10, 'Pure spherical surface error');

            % Hyperbolic surface
            k = 1.5;
            expected_pts = [0,4,0.398019753448312];
            surf.asph_conic_k = -k;

            pts1 = OpticalSystem.intersectWithConic(p, d, c, k);
            testCase.verifyEqual(size(pts1), size(expected_pts), 'Size mismatch');
            testCase.verifyEqual(pts1, expected_pts, 'AbsTol', 1e-10, 'Pure spherical surface error');

            pts2 = surf.findIntersectionPoint([p, d]);
            testCase.verifyEqual(size(pts2), size(expected_pts), 'Size mismatch');
            testCase.verifyEqual(pts2, expected_pts, 'AbsTol', 1e-10, 'Pure spherical surface error');

            % Arbitrary ray
            d = [0.1, 0.2, 1];
            d = d / norm(d);

            % Pure spherical surface
            k = 0;
            expected_pts = [0.0421525199705364,4.08430503994107,0.421525199705364];
            surf.asph_conic_k = k;

            pts1 = OpticalSystem.intersectWithConic(p, d, c, k);
            testCase.verifyEqual(size(pts1), size(expected_pts), 'Size mismatch');
            testCase.verifyEqual(pts1, expected_pts, 'AbsTol', 1e-10, 'Pure spherical surface error');

            pts2 = surf.findIntersectionPoint([p, d]);
            testCase.verifyEqual(size(pts2), size(expected_pts), 'Size mismatch');
            testCase.verifyEqual(pts2, expected_pts, 'AbsTol', 1e-10, 'Pure spherical surface error');

            % Hyperbolic surface
            k = 1.5;
            expected_pts = [0.0414651790409366,4.08293035808187,0.414651790409366];
            surf.asph_conic_k = -k;

            pts1 = OpticalSystem.intersectWithConic(p, d, c, k);
            testCase.verifyEqual(size(pts1), size(expected_pts), 'Size mismatch');
            testCase.verifyEqual(pts1, expected_pts, 'AbsTol', 1e-10, 'Pure spherical surface error');

            pts2 = surf.findIntersectionPoint([p, d]);
            testCase.verifyEqual(size(pts2), size(expected_pts), 'Size mismatch');
            testCase.verifyEqual(pts2, expected_pts, 'AbsTol', 1e-10, 'Pure spherical surface error');
        end
    end
end