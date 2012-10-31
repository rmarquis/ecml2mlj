function [ varBag, MessageBag]= UpdateHelperGreaterThanOrWithinFactors(draw, msgIdx, MessageBag, varIdx, varBag, epsilon)
% UpdateHelper for UpdateHelperGreaterThanOrWithinFactors
    if draw == 'N'
        oldMarginal = varBag{varIdx};
        oldMsg      = MessageBag{msgIdx};
        msgFromVar  = oldMarginal / oldMsg;
        c           = msgFromVar.Precision;
        d           = msgFromVar.PrecisionMean;
        sqrtC       = sqrt( c );
        dOnSqrtC    = d / sqrtC;
        epsTimesSqrtC  = epsilon * sqrtC;
        d           = msgFromVar.PrecisionMean;
        denom       = 1.0 - wFunction( dOnSqrtC, epsTimesSqrtC );
        newPrecision   = c / denom;
        newPrecisionMean   = (d + sqrtC * vFunction( dOnSqrtC, epsTimesSqrtC) ) / denom;
        newMarginal = Gaussian (newPrecisionMean / newPrecision, sqrt (1 / newPrecision) );
        newMsg      = oldMsg * newMarginal / oldMarginal;
        %Update the message and marginal
        MessageBag{msgIdx} = newMsg;
        varBag{varIdx}     = newMarginal;
        %Return the difference in the new marginal
%         delta       = newMarginal - oldMarginal;
    else
        oldMarginal = varBag{varIdx};
        oldMsg      = MessageBag{msgIdx};
        msgFromVar  = oldMarginal / oldMsg;
        c           = msgFromVar.Precision;
        d           = msgFromVar.PrecisionMean;
        sqrtC       = sqrt( c );
        dOnSqrtC    = d / sqrtC;
        epsTimesSqrtC   = epsilon * sqrtC;
        denom       = 1.0 - w0Function( dOnSqrtC, epsTimesSqrtC );
        newPrecision    = c / denom;
        newPrecisionMean   = ( d + sqrtC * v0Function( dOnSqrtC, epsTimesSqrtC ) ) / denom;
        newMarginal = Gaussian ( newPrecisionMean / newPrecision, sqrt ( 1 / newPrecision ) );
        newMsg      = oldMsg * newMarginal / oldMarginal;
        % Update the message and marginal
        MessageBag{msgIdx} = newMsg;
        varBag{varIdx}     = newMarginal;
        % Return the difference in the new marginal
%         delta       = newMarginal - oldMarginal;
    end
end