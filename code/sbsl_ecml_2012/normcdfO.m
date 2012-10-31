function p = normcdfO ( t )
%normcdfO: Computes the cummulative Gaussian distribution at a specified
%point of interest

% normcdfO: A different function from Matlab's normcdf. Here 'O' is used to
% differentiate these two functions

sqrt2 = 1.4142135623730951;
p = (erfcO (-t / sqrt2)) / 2.0;

end

