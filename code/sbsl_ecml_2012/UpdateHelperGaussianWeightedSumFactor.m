function [varBag, MessageBag] = UpdateHelperGaussianWeightedSumFactor(w, wS, m1, m2, m3, MessageBag, v1, v2, v3, varBag)
% UpdateHelper for GaussianWeightedSumFactor
    d0 = varBag{v2} / MessageBag{m2};
    d1 = varBag{v3} / MessageBag{m3};
    msg1 = MessageBag{m1};
    mar1 = varBag{v1};
    % Note the index of wS. F#: starting from 0; Matlab: starting from 1.
    denom = wS(1) * d1.Precision + wS(2) * d0.Precision;
    newPrecision = d0.Precision * d1.Precision / denom;
                
    % Note the index of w. F#: starting from 0; Matlab: starting from 1.
    newPrecisionMean = (w(1) * d1.Precision * d0.PrecisionMean + w(2) * d0.Precision * d1.PrecisionMean) / denom;
    newMsg = Gaussian ( newPrecisionMean / newPrecision, sqrt ( 1 / newPrecision ) );
    oldMarginalWithoutMsg = mar1 / msg1;
    newMarginal = oldMarginalWithoutMsg * newMsg;
    % Update the message and marginal
    MessageBag{m1} = newMsg;
    varBag{v1} = newMarginal;
end