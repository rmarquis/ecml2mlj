function [h_i, o_i, d_j] = updatePoisson_homeFieldAdvantage( offenceHAGaussian, offenceGaussian, defenceGaussian, score, beta, flagSliceSampling)

% Created by Shengbo Guo
% Date: 28 October 2012
% Email: Shengbo.Guo@gmail.com

%%%%%%%%%%%%%%%%%%%%%%%% ( beta, tau, initial, drawProb, skills, draws)

% NPlayerTrueSkillUpdateTeam: Runs a full foward-backward factor graph analysis
% on a chess outcome dataset with a fixed draw margin
skills = cell(1, 3);
skills{1} = offenceGaussian;
skills{2} = defenceGaussian;
skills{3} = offenceHAGaussian; 

noPlayers = 2;
numberOfMessages = 4*noPlayers + 2 + 2;
MessageBag = cell(1, numberOfMessages);
initGaussian = Gaussian( 0, inf );
for i = 1:numberOfMessages
    MessageBag{i} = initGaussian;
end
% Compute the internal parameters
betaSquared = beta * beta;
% tauSquared  = tau * tau;
% epsilon = -sqrt( 2 * betaSquared ) * PhiInverse (  (1 - drawProb) / 2 );

% Allocate the dictionary of all relevant variables
numberOfVariables = 2 * noPlayers + 1 + 1;
varBag = cell(1, numberOfVariables);
for i = 1:numberOfVariables
    varBag{i} = Gaussian( 0, inf ) ;
end

% The list of player skills
playerSkills = 1:noPlayers;
playerHA = 2*noPlayers + 2; 
% idx of message associated with the HA variable
idxMessageHADown = 4*noPlayers + 2 + 1; 
idxMessageHAUp   = 4*noPlayers + 2 + 2;

% The list of player performances
playerPerformances = noPlayers+1 : 2*noPlayers;

% The list of team performances
% teamPerformances = 2*noPlayers+1 : 2*noPlayers+2;

% The list of team performance differences
teamPerformanceDifferences = 2*noPlayers + 1;


% At first, send the skill priors of all players to the player variable
% nodes
for i = 1:noPlayers
    newMsg = Gaussian ( skills{playerSkills(i)}.Mu, sqrt (skills{playerSkills(i)}.Variance) );
    oldMarginal = varBag{ playerSkills(i) };
    oldMsg      = MessageBag{ playerSkills(i) };
    tempPrecisionMean = oldMarginal.PrecisionMean + newMsg.PrecisionMean - oldMsg.PrecisionMean;
    tempPrecision     = oldMarginal.Precision + newMsg.Precision - oldMsg.Precision;
    tempMu            = tempPrecisionMean / tempPrecision;
    tempSigma         = sqrt( 1 / tempPrecision );
    newMarginal = Gaussian ( tempMu, tempSigma );
    varBag{ playerSkills(i) } = newMarginal;
    MessageBag {playerSkills(i)} = newMsg;
end

% Fill the HA variable
newMsg = Gaussian ( skills{3}.Mu, sqrt (skills{3}.Variance) );
oldMarginal = varBag{ playerHA };
oldMsg      = MessageBag{ idxMessageHADown };
tempPrecisionMean = oldMarginal.PrecisionMean + newMsg.PrecisionMean - oldMsg.PrecisionMean;
tempPrecision     = oldMarginal.Precision + newMsg.Precision - oldMsg.Precision;
tempMu            = tempPrecisionMean / tempPrecision;
tempSigma         = sqrt( 1 / tempPrecision );
newMarginal = Gaussian ( tempMu, tempSigma );
varBag{ playerHA } = newMarginal;
MessageBag { idxMessageHADown } = newMsg;

%  Fill the performances
for i = 1:noPlayers
    prec    = 1 / betaSquared;
    msg1Idx = playerPerformances(i) + noPlayers;
    msg2Idx = playerSkills(i) + noPlayers;
    var1Idx = playerPerformances(i);
    var2Idx = playerSkills(i);
    [MessageBag, varBag] = UpdateHelperGaussianLikelihoodFactor(msg1Idx, msg2Idx, MessageBag, var1Idx, var2Idx, varBag, prec, 0);
end

% The inner loop schedule: x = y1+y2-y3 (HA+offenceI-defenceJ)
w  = [1; 1; -1];
a1 = w(1);
a2 = w(2);
a3 = w(3);
weight_x = [a1; a2; a3];
weight_y1 = [-a2/a1; -a3/a1; 1/a1];
weight_y2 = [-a1/a2; -a3/a2; 1/a2];
weight_y3 = [-a1/a3; -a2/a3; 1/a3];

idx_performdiff_msg = 4 * noPlayers + 1;
idx_offenceI_msg = idx_performdiff_msg - 2;
idx_offenceJ_msg = idx_performdiff_msg - 1;

idx_performdiff_var = 2 * noPlayers + 1;
idx_offenceI_var = idx_performdiff_var - 2;
idx_offenceJ_var = idx_performdiff_var - 1;

% Send the team performance difference
[varBag, MessageBag] = UpdateHelperGaussianWeightedSumFactor_HA(weight_x, idx_performdiff_msg, idxMessageHAUp, idx_offenceI_msg, idx_offenceJ_msg, MessageBag, ...
    idx_performdiff_var, playerHA, idx_offenceI_var, idx_offenceJ_var, varBag);
% Send Poisson factor
if flagSliceSampling == 0
    [varBag, MessageBag] = UpdateHelperGreaterThanOrWithinFactorsStrength(MessageBag, numberOfVariables, varBag, score);
else
    [varBag, MessageBag] = UpdateHelperGreaterThanOrWithinFactorsStrength(MessageBag, numberOfVariables, varBag, score, flagSliceSampling);
end

% Send message from teamPerformanceDifferences variables to
% teamPerformance 1 & 2 variable & HA;
% update HA
[varBag, MessageBag] = UpdateHelperGaussianWeightedSumFactor_HA(weight_y1, idxMessageHAUp, idx_offenceI_msg, idx_offenceJ_msg, idx_performdiff_msg, MessageBag, ...
                                                                           playerHA, idx_offenceI_var, idx_offenceJ_var, idx_performdiff_var, varBag); 
% update teamPerformance1
[varBag, MessageBag] = UpdateHelperGaussianWeightedSumFactor_HA(weight_y2, idx_offenceI_msg, idxMessageHAUp, idx_offenceJ_msg, idx_performdiff_msg, MessageBag, ...
                                                                           idx_offenceI_var, playerHA, idx_offenceJ_var, idx_performdiff_var, verBag);
% update teamPerformance2
[varBag, MessageBag] = UpdateHelperGaussianWeightedSumFactor_HA(weight_y3, idx_offenceJ_msg, idxMessageHAUp, idx_offenceI_msg, idx_performdiff_msg, MessageBag, ...
                                                                           idx_offenceJ_var, playerHA, idx_offenceI_var, idx_performdiff_var, verBag);

% At last, send the skill performances of all players to the player skills variable
for i = 1:noPlayers
    prec    = 1 / betaSquared;
    msg1Idx = playerPerformances(i) + noPlayers;
    msg2Idx = playerSkills(i) + noPlayers;
    var1Idx = playerPerformances(i);
    var2Idx = playerSkills(i);
    [MessageBag, varBag] = UpdateHelperGaussianLikelihoodFactor(msg1Idx, msg2Idx, MessageBag, ...
        var1Idx, var2Idx, varBag, prec, 1);
end

% check if there is 'NaN'
for i = 1:noPlayers
    if  isnan( varBag{i}.PrecisionMean ) || isnan( varBag{i}.Precision )
        disp('Nan Mu Sigma, check NPlayerTrueSkillUpdateTeam')
        break;
    end
end

% now return o_i, d_j, h_i
o_i = varBag{1};
d_j = varBag{2};
% And also compute the postrior on HA
msg1_HA = varBag{ playerHA };
msg2_HA = MessageBag{ idxMessageHAUp };
precisionMean = msg1_HA.PrecisionMean + msg2_HA.PrecisionMean;
precision     = msg1_HA.Precision     + msg2_HA.Precision;
mu = precisionMean / precision;       % Mean of the Gaussian
variance = 1 / precision;             % Variance of the Gaussian
standardDeviation = sqrt (variance);  % Standard deviation of the Gaussian
sigma = standardDeviation;            % Standard deviation of the Gaussian
h_i = Gaussian(mu, sigma);

end