function p = normpdfO ( t )
%normpdfO: Computes the Gaussian density at a specified point of interest

% normpdfO: A different function from Matlab's normpdf. Here 'O' is used to
% differentiate these two functions

invsqrt2pi = 0.398942280401433;
p = invsqrt2pi * exp (- (t * t / 2.0));

end

