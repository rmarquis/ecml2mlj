function [ varBag, MessageBag]= UpdateHelperGreaterThanOrWithinFactorsStrength_ab(MessageBag, varIdx, varBag, rank, a, b)

    oldMarginal = varBag{varIdx};         
    % Iterative and find the fixed point of varBag{varIdx}.
    numIter = 10;
    K = zeros(numIter, 1);
    K(1) = abs( randn(1,1) );
    for i = 2:numIter
        A = ( (K(i-1)/b) - oldMarginal.Mean )/oldMarginal.Variance - rank*b;
        
        numerator = -(b^2*oldMarginal.Variance*A+1) + ...
            sqrt( (b^2*oldMarginal.Variance*A+1)^2-2*a*b^2*oldMarginal.Variance*(2*A-b) );         
        denumerator = 2*a*b^2*oldMarginal.Variance;
        K(i) = log(numerator / denumerator);
    end
%     if K(end-1)~= K(end)
%         disp('Not covergence when estimating K');
%     end
%     
    % test the iteration of K
%     figure
%     plot(1:numIter, K)
    newMean = oldMarginal.Mean + oldMarginal.Variance * ( rank - exp(K(end)) );
    newVariance = oldMarginal.Variance / ( 1+oldMarginal.Variance*exp(K(end)) );
    newMarginal = Gaussian( newMean, sqrt(newVariance) );
    varBag{varIdx} = newMarginal;
end