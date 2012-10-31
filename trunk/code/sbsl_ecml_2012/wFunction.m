function p = wFunction ( t, epsilon )
%v: Computes the multiplicative correction of a single-sided truncated Gaussian
%with unit variance
denom = normcdfO ( t - epsilon );

if denom < 2.222758749e-162
    if t < 0 
        p = 1;
    else
        p = 0;
    end
else
    vt = vFunction ( t, epsilon);
    p = vt * (vt + t - epsilon);
end

end

