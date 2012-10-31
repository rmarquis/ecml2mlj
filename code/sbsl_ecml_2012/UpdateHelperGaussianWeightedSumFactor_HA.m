function [varBag, MessageBag] = UpdateHelperGaussianWeightedSumFactor_HA(w, m1, idxMessageHAUp, m2, m3, MessageBag, v1, playerHA, v2, v3, varBag)

% m1: index for d= p_hai + p_oi - p_dj, i.e., the message corresponds to performance difference
% m2: index for p_oi
% m3: index for p_dj
% idxMessageHAUP: the message corresponds to the homefield advantage% variable
% playerHA: index for p_hai

wS = w.^2;
% UpdateHelper for GaussianWeightedSumFactor
d0 = varBag{v2} / MessageBag{m2};
d1 = varBag{v3} / MessageBag{m3};
d2 = varBag{playerHA} / MessageBag{idxMessageHAUp};

msg1 = MessageBag{m1};
mar1 = varBag{v1};
% updating equation according to Table 1 in TrueSkill paper
newPrecision = ( wS(1)/d2.Precision + wS(2)/d0.Precision + wS(3)/d1.Precision )^-1;
newPrecisionMean = newPrecision * (w(1)*d2.PrecisionMean/d2.Precision +  w(2)*d0.PrecisionMean/d0.Precision + w(3)*d1.PrecisionMean/d1.Precision);

newMsg = Gaussian ( newPrecisionMean / newPrecision, sqrt ( 1 / newPrecision ) );
oldMarginalWithoutMsg = mar1 / msg1;
newMarginal = oldMarginalWithoutMsg * newMsg;
% Update the message and marginal
MessageBag{m1} = newMsg;
varBag{v1} = newMarginal;
end