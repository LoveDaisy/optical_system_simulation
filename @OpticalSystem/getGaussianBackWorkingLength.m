function l = getGaussianBackWorkingLength(obj, lambda)
% SYNTAX
%   l = sys.getGaussianBackWorkingLength(lambda)
% where
%   lambda:     n-length vector, wavelength
%   l:          n-length vector, the gaussian back working length

parser = inputParser;
parser.FunctionName = 'getGaussianBackWorkingLength';
parser.addRequired('lambda', @(x) isnumeric(x) && isreal(x) && isvector(x));
parser.parse(lambda);

sys_mat = obj.makeGaussianSystemMatrix(lambda);
l = squeeze(-sys_mat(2, 2, :) ./ sys_mat(1, 2, :));
end