function f = getGaussianFocalLength(obj, lambda)
% SYNTAX
%   f = sys.getGaussianFocalLength(lambda)
% where
%   lambda:     n-length vector, wavelength
%   f:          n-length vector, gaussian focal length

parser = inputParser;
parser.FunctionName = 'getGaussianFocalLength';
parser.addRequired('lambda', @(x) isnumeric(x) && isreal(x) && isvector(x));
parser.parse(lambda);

sys_mat = obj.makeGaussianSystemMatrix(lambda);
f = squeeze(-1 ./ sys_mat(1, 2, :));
end