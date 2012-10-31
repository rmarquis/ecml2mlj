function res = vFun(t, l)
    nom = normpdf(t-l, 0, 1);
    denom = normcdf(t-l, 0, 1);
    res = nom/denom;
end