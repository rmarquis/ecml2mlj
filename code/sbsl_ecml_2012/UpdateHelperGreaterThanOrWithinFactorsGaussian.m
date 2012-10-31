function [ varBag, MessageBag]= UpdateHelperGreaterThanOrWithinFactorsGaussian(msgIdx, MessageBag, varIdx, varBag, epsilon)

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
end