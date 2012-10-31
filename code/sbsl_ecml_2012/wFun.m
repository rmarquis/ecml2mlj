function res = wFun(t, l)
    first = vFun(t, l);
    res = first*(first+t-l);
end