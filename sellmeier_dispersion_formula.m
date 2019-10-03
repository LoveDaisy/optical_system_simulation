function n =  sellmeier_dispersion_formula(coef, lambda)
% INPUT
%  coef:        n*8
%  lambda:      m
% OUTPUT
%  n:           n*m
lambda = reshape(lambda / 1000, 1, []);
n = 1;
for i = 1:floor(size(coef,2)/2)
    n = n + coef(:, i * 2 - 1) * lambda.^2 ./ bsxfun(@minus, lambda.^2, coef(:, i * 2));
end
n = sqrt(n);
end