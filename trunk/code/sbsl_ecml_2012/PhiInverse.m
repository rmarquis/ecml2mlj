function t = PhiInverse ( p )
%PhiInverse: Computes the inverse of the cummulative Gaussian density (qunatile function) at a specified point of interest

% PhiInverse: A different function from Matlab's norminv. 

sqrt2 = 1.4142135623730951;
t     = (-sqrt2 * erfcinvO (2.0 * p));

end

