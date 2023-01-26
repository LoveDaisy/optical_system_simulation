function n = getRefractiveIndex(obj, lambda)
% INPUT
%   obj:        ZemaxGlass object
%   lambda:     n-vector, wavelength, nm
% OUTPUT
%   n:          n-vector, refractive index
if obj.disp_formula_type <= 0
    n = ones(size(lambda)) * obj.nd;
    return;
end

lambda = lambda / 1e3;  % from nm to um
switch obj.disp_formula_type
    case 1
        n = schottSeries(obj.disp_formula_coef, lambda);
    case 2
        n = sellmeier1(obj.disp_formula_coef, lambda);
    case 3
        n = herzberger(obj.disp_formula_coef, lambda);
    case 4
        n = sellmeier2(obj.disp_formula_coef, lambda);
    case 5
        n = conrady(obj.disp_formula_coef, lambda);
    case 6
        n = sellmeier3(obj.disp_formula_coef, lambda);
    otherwise
        error('Dispersion formula type invalid!');
end
end


function n = schottSeries(coef, lambda)
% Schott series function
%   n^2 = c(1) + c(2) w^2 + c(3) w^-2 + c(4) w^-4 + c(5) w^-6 + c(6) w^-8

w2 = lambda.^2;
n = coef(1) + coef(2) * w2 + coef(3) ./ w2 + coef(4) ./ w2.^2 + ...
    coef(5) ./ w2.^3 + coef(6) ./ w2.^4;
n = sqrt(n);
end


function n = sellmeier1(coef, lambda)
% Sellmeier formula type 1
%               c(1) w^2       c(3) w^2       c(5) w^2
%   n^2 - 1 = ------------ + ------------ + ------------
%              w^2 - c(2)     w^2 - c(4)     w^2 - c(6)

w2 = lambda.^2;
n = 1;
for i = 1:3
    n = n + coef(i*2-1) * w2 ./ (w2 - coef(i*2));
end
n = sqrt(n);
end


function n = herzberger(coef, lambda)
% Herzberger formula
%                  c(2)              c(3)
%   n = c(1) + ------------- + ----------------- + c(4) w^2 + c(5) w^4 + c(6) w^6
%               w^2 - 0.028     (w^2 - 0.028)^2

w2 = lambda.^2;
l = 1 ./ (w2 - 0.028);
n = coef(1) + coef(2) .* l + coef(3) .* l.^2 + coef(4) .* w2 + ...
    coef(5) .* w2.^2 + coef(6) .* w2.^3;
end


function n = sellmeier2(coef, lambda)
% Sellmeier formula type 2
%                      c(2) w^2         c(4) w^2
%   n^2 - 1 = c(1) + -------------- + --------------
%                     w^2 - c(3)^2     w^2 - c(5)^2

w2 = lambda.^2;
n = 1 + coef(1);
for i = 1:2
    n = n + coef(i*2) * w2 ./ (w2 - coef(i*2+1)^2);
end
n = sqrt(n);
end


function n = conrady(coef, lambda)
% Conrady formula
%   n = c(1) + c(2) / w + c(3) / w^3.5

n = coef(1) + coef(2) ./ lambda + coef(3) ./ lambda.^3.5;
end


function n = sellmeier3(coef, lambda)
% Sellmeier formula type 1
%               c(1) w^2       c(3) w^2       c(5) w^2       c(7) w^2
%   n^2 - 1 = ------------ + ------------ + ------------ + ------------
%              w^2 - c(2)     w^2 - c(4)     w^2 - c(6)     w^2 - c(8)

w2 = lambda.^2;
n = 1;
for i = 1:4
    n = n + coef(i*2-1) * w2 ./ (w2 - coef(i*2));
end
n = sqrt(n);
end
