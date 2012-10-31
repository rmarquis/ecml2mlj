function p = vFunction( t, epsilon )
%v: Computes the additive correction of a single-sided truncated Gaussian
%with unit variance
denom = normcdfO ( t - epsilon );

if denom < 2.222758749e-162
    p = -t + epsilon;
else
    p = normpdfO ( t - epsilon ) / denom;
end

end

