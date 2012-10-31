function [ varBag, MessageBag ]= UpdateHelperGreaterThanOrWithinFactorsStrength(MessageBag, varIdx, varBag, rank, flagSampling)

% the 5th parameter is used to decide if switch to sampling for learning
% posterior: 1, yes; 0, no

oldMarginal = varBag{varIdx};             
if nargin < 5
    % Iterative and find the fixed point of varBag{varIdx}.
    numIter = 10;
    K = zeros(numIter, 1);
    K(1) = abs( randn(1,1) );
    for i = 2:numIter
        numerator = oldMarginal.Mean + rank * oldMarginal.Variance - 1 - K(i-1) + ...
                    sqrt( (K(i-1)- oldMarginal.Mean - rank*oldMarginal.Variance -1)^2 + 2*oldMarginal.Variance  );
        denumerator = 2*oldMarginal.Variance;
        K(i) = log(numerator / denumerator);
    end
%     if K(end-1)~= K(end)
%         disp('Not covergence when estimating K');
%     end
%     
%     % test the iteration of K
%     figure
%     plot(1:numIter, K)
    newMean = oldMarginal.Mean + oldMarginal.Variance * ( rank - exp(K(end)) );
    newVariance = oldMarginal.Variance / ( 1+oldMarginal.Variance*exp(K(end)) );
    
else
    muPrior = oldMarginal.Mean; 
    sigmaPrior = sqrt(oldMarginal.Variance);
    [newMean, newSigma] = slicesampling(rank, muPrior, sigmaPrior); 
    newVariance = newSigma^2; 
end
newMarginal = Gaussian( newMean, sqrt(newVariance) );
varBag{varIdx} = newMarginal;

end