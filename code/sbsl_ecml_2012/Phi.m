function p = Phi ( t )
%Phi: Computes the cummulative Gaussian distribution at a specified
%point of interest

% Phi: A different function from Matlab's normcdf. 

sqrt2 = 1.4142135623730951;
p = (erfcO (-t / sqrt2)) / 2.0;

end

