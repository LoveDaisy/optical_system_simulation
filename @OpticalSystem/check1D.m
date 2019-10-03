function check1D(array)
if length(size(array)) ~= 2 || min(size(array)) ~= 1
    error('parameter should be 1D vector!');
end
end