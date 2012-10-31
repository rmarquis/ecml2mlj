function p = w0Function ( t, epsilon )
%v: Computes the multiplicative correction of a double-sided truncated Gaussian
%with unit variance

v = abs(t);
denom = normcdfO ( epsilon - v ) - normcdfO ( -epsilon - v );

%if denom < 2.222758749e-162
if denom < 2.222758749e-10
    p = 1;
else
    vt = v0Function(v, epsilon);
    p = vt*vt + ( (epsilon-v) * normpdfO (epsilon-v) - (-epsilon-v) * normpdfO (-epsilon-v) )/denom;
end

end

