function pPoisson = computePoissonWinProbLowerBound(lambdaI, lambdaJ)

pPoisson = 0; 
for tempCounter = 1:74 % approximation to calculate the winProb. Lower bound
        pPoisson = pPoisson + ...
            exp(-(lambdaI+lambdaJ))*(lambdaI/lambdaJ)^(tempCounter/2)*besseli(tempCounter, 2*sqrt(lambdaI*lambdaJ));
end

end