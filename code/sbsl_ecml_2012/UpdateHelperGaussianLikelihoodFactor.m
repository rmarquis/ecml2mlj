function [MessageBag, varBag] = UpdateHelperGaussianLikelihoodFactor(msg1Idx, msg2Idx, MessageBag, var1Idx, var2Idx, varBag, prec, idx)
% UpdateHelper for GuassianLikelihoodFactor
    
    if idx == 0
        msg1    = MessageBag{msg1Idx};
        msg2    = MessageBag{msg2Idx};
        mar1    = varBag{ var1Idx };
        mar2    = varBag{ var2Idx };
        a       = prec / (prec + mar2.Precision - msg2.Precision);
           
        tempPrecisionMean = a * (mar2.PrecisionMean - msg2.PrecisionMean);
        tempPrecision     = a * (mar2.Precision - msg2.Precision);
        tempMu            = tempPrecisionMean / tempPrecision;
        tempSigma         = sqrt ( 1 / tempPrecision );
        newMsg  = Gaussian ( tempMu, tempSigma );
          
        oldMarginalWithoutMsg = mar1 / msg1;
        newMarginal = oldMarginalWithoutMsg * newMsg;
        MessageBag{msg1Idx} = newMsg;
        varBag{ var1Idx } = newMarginal;
    elseif idx == 1
        msg1    = MessageBag{msg1Idx};
        msg2    = MessageBag{msg2Idx};
        mar1    = varBag{ var1Idx };
        mar2    = varBag{ var2Idx };
        a       = prec / (prec + mar1.Precision - msg1.Precision);
            
        tempPrecisionMean = a * (mar1.PrecisionMean - msg1.PrecisionMean);
        tempPrecision     = a * (mar1.Precision - msg1.Precision);
        tempMu            = tempPrecisionMean / tempPrecision;
        tempSigma         = sqrt ( 1/tempPrecision );
        newMsg  = Gaussian ( tempMu, tempSigma );
        oldMarginalWithoutMsg = mar2 / msg2;
        newMarginal = oldMarginalWithoutMsg * newMsg;
        MessageBag{msg2Idx} = newMsg;
        varBag{ var2Idx } = newMarginal;
    end
end