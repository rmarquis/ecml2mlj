function y = erfcO( x )
%erfcO: Computes the complementary error function. This function is defined
%by 2/sqrt(pi) * integral from x to infinity of exp(-t^2) dt

% erfcO: A different function from Matlab's erfc. Here 'O' is used to
% differentiate these two functions

if x == inf
    y = 0;
elseif x == -inf
    y = 2;
else
    z = abs(x);
    t = 1 / (1 + 0.5 * z);
    tempY = t * exp (-z * z - 1.26551223 + t * (1.00002368 + t * (0.37409196 + t * (0.09678418 + t * (-0.18628806 + t * (0.27886807 + t * (-1.13520398 + t * (1.48851587 + t * (-0.82215223 + t * 0.17087277))))))))) ;
    if x >= 0 
        y = tempY;
    else
        y = 2 - tempY;
    end
end

end

