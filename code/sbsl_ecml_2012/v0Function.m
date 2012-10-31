function p = v0Function ( t, epsilon )
%v: Computes the additive correction of a double-sided truncated Gaussian
%with unit variance

v = abs(t);

denom = normcdfO( epsilon - v) - normcdfO( -epsilon - v );

if denom < 2.222758749e-162
    if t < 0
        p = -t - epsilon;
    else
        p = -t + epsilon; 
    end
else
    num = normpdfO( -epsilon - v ) - normpdfO ( epsilon - v);
    if t < 0 
        p = -num/denom;
    else
        p = num/denom;
    end
end

end

