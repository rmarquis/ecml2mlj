function [o_i d_j] = updatePoisson( offenceGaussian, defenceGaussian, score )
    
    %%%%%%%%%%%%%%%%%%%%%%%% ( beta, tau, initial, drawProb, skills, draws)
    
    % NPlayerTrueSkillUpdateTeam: Runs a full foward-backward factor graph analysis
    % on a chess outcome dataset with a fixed draw margin
    skills = cell(1, 2);
    skills{1} = offenceGaussian;
    skills{2} = defenceGaussian;
    
    noTeams = 2;   
    noPlayers = 2;
    numberOfMessages = 4*noPlayers + 2;
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
    numberOfVariables = 2 * noPlayers + 1;
    varBag = cell(1, numberOfVariables);
    for i = 1:numberOfVariables
        varBag{i} = Gaussian( 0, inf ) ;
    end

    % The list of player skills
    playerSkills = 1:noPlayers;

    % The list of player performances
    playerPerformances = noPlayers+1 : 2*noPlayers;
    
    % The list of team performances
    % teamPerformances = 2*noPlayers+1 : 2*noPlayers+2;

    % The list of team performance differences
    teamPerformanceDifferences = 2*noPlayers + 1;

    % At first, send the skill priors of all players to the player variable
    % nodes
    for i = 1:noPlayers
        newMsg = Gaussian ( skills( playerSkills(i) ).Mu, sqrt (skills( playerSkills(i) ).Variance + tauSquared) );
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
    %  Fill the performances
    for i = 1:noPlayers
        prec    = 1 / betaSquared;
        msg1Idx = playerPerformances(i) + noPlayers;   
        msg2Idx = playerSkills(i) + noPlayers;
        var1Idx = playerPerformances(i);
        var2Idx = playerSkills(i);
        [MessageBag, varBag] = UpdateHelperGaussianLikelihoodFactor(msg1Idx, msg2Idx, MessageBag, var1Idx, var2Idx, varBag, prec, 0);
    end
    % Calculate the team performances
%     wTeamPerformances = ones(noPlayers/2, 1);
%     wTeamPerformancesSquared = wTeamPerformances.^2;
%     messageIdxCell = [3*noPlayers+1 : 3*noPlayers+noPlayers/2; 3*noPlayers+noPlayers/2+1 : 4*noPlayers];
%     varIdxCell = [noPlayers + 1 : noPlayers + noPlayers/2; noPlayers + noPlayers/2 + 1 : 2*noPlayers];
%     for i = 1 : 2
%         messageIdx1 = 4*noPlayers + i;
%         messageIdxs = messageIdxCell(i, :); 
%         v1 = 2 * noPlayers + i;
%         varIdxs     =  varIdxCell(i, :);
%         [varBag, MessageBag] = UpdateHelperGaussianWeightedSumFactorTeamPerformance(wTeamPerformances, wTeamPerformancesSquared, ...
%                                                                                             messageIdx1, messageIdxs, MessageBag, ...
%                                                                                             v1, varIdxs, varBag, noPlayers);
%     end    
    % The inner loop schedule
    w  = [1; -1];
    a1 = w(1);
    a2 = w(2);
    weight0 = [a1; a2];
    weight1 = [-a2/a1; 1/a1];
    weight2 = [-a1/a2; 1/a2];
    weight0Squared = weight0.^2;
    weight1Squared = weight1.^2;
    weight2Squared = weight2.^2;   
    m1 = 4 * noPlayers + 1;
    m2 = 4 * noPlayers - 2;
    m3 = m2 + 1;
    if noTeams == 2
       % Send the team performance difference
       v1 = 2 * noPlayers + 1;
       v2 = v1 - 2;
       v3 = v1 - 1;
       [varBag, MessageBag] = UpdateHelperGaussianWeightedSumFactor(weight0, weight0Squared, m1, m2, m3, MessageBag, ...
                                                                                              v1, v2, v3, varBag);
       % Send Poisson factor
       % TODO: replace the greater than factor with Poisson factor
       [varBag, MessageBag] = UpdateHelperGreaterThanOrWithinFactorsStrength(numberOfMessages, MessageBag, numberOfVariables, varBag, score);
    else
        disp('Cannot handle more than two teams');
    end
    
    v1 = teamPerformanceDifferences(1);
    v2 = playerPerformances(1);
    v3 = v2 + 1;
    % Send message from teamPerformanceDifferences variables to
    % teamPerformance1 variable;
    [varBag, MessageBag] = UpdateHelperGaussianWeightedSumFactor(weight1, weight1Squared, m2, m1, m3, MessageBag, ...
                                                                                             v2, v1, v3, varBag);                                                                   
                                                                                         
    % Send message from teamPerformanceDifferences variables to
    % teamPerformance2 variable;
    [varBag, MessageBag] = UpdateHelperGaussianWeightedSumFactor(weight2, weight2Squared, m3, m2, m1, MessageBag, ...
                                                                                             v3, v2, v1, varBag);
                                                                                         
%     % Send message from Team Performance Differences variables to
%     % players' performances variables.
%     wTeamPerformances = zeros(noPlayers/2, 1)-1;
%     wTeamPerformances(end) = 1;
%     wTeamPerformancesSquared = wTeamPerformances.^2;
%     for i = 1:2
%         v1 = 2*noPlayers + i;
%         m1 = 4*noPlayers + i;
%         varIdxs = varIdxCell(i, :);
%         messageIdxs = messageIdxCell(i, :);
%         for j = 1:noPlayers/2
%             messageTemp = messageIdxs;
%             messageTemp(j) = [];
%             messageIdxRest = [messageTemp m1];
%             varTemp     = varIdxs;
%             varTemp(j)     = [];
%             varIdxRest     = [varTemp v1];
%             [varBag, MessageBag] = UpdateHelperGaussianWeightedSumFactorTeamPerformance(wTeamPerformances, wTeamPerformancesSquared, ...
%                                                                                                 messageIdxs(j), messageIdxRest, MessageBag, ...
%                                                                                                 varIdxs(j), varIdxRest, varBag, noPlayers);
%         end
%     end
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
    for i = 1:noPlayers 
        if  isnan( varBag{i}.PrecisionMean ) || isnan( varBag{i}.Precision )
            disp('Nan Mu Sigma, check NPlayerTrueSkillUpdateTeam')
            break;
        end
    end
    o_i = varBag{1};
    d_j = varBag{2};
end