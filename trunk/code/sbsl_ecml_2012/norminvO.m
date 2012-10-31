function t = norminvO ( p )
%norminvO: Computes the inverse of the cummulative Gaussian density (qunatile function) at a specified point of interest

% norminvO: A different function from Matlab's norminv. Here 'O' is used to
% differentiate these two functions

sqrt2 = 1.4142135623730951;
t     = (-sqrt2 * erfcinvO (2.0 * p));

end

