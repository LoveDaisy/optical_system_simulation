function P = getPartialDispersion(obj, lambda1, lambda2)
% INPUT
%   obj:        ZemaxGlass object
%   lambda1:    n-vector, wavelength, nm
%   lambda2:    n-vector, wavelength, nm
% OUTPUT
%   P:          n-vector, partial dispersion

C_line = util.get_fraunhofer_line('C');
F_line = util.get_fraunhofer_line('F');

P = (getRefractiveIndex(obj, lambda1) - getRefractiveIndex(obj, lambda2)) ./ ...
    (getRefractiveIndex(obj, F_line) - getRefractiveIndex(obj, C_line));
end