% revise history
% on 15 April 2011: remove Logistic regression for prediction by replacing
% the results of predicting function to 1/2 

% calculate error functions


function [resultFinal resultFinalWLD skillPercentageYear scoreAccuracyPercentageYear predictedWinResult] = computeThreeMeasure_AllScoreDifference_Halo(matchOutcome, trainingPercentage, testPercentage)
skillYear = cell(1, 5);

% Initialize other parameters
initialMu = 25;
initialSigma = initialMu/3;
beta = initialSigma/2;
beta1 = beta;
beta2 = beta;

mm =min(min(matchOutcome(:, 3:4)));
if mm < 0
    matchOutcome(:, 3:4) = matchOutcome(:, 3:4) + abs(mm);
end
%%%%%
numberOfMatchTotal = size(matchOutcome, 1);
numberOfPredictMatched = floor(numberOfMatchTotal*testPercentage);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numberOfTraining =  floor(numberOfMatchTotal*trainingPercentage);

tempScore = [matchOutcomeTraining(:,3); matchOutcomeTraining(:,4)];
gammaS = var( tempScore ); % score-based Gaussian graphical model
clear tempScore;
gammaSD = var ( matchOutcomeTraining(:,3)-matchOutcomeTraining(:,4) ); % score diff based Gaussian graphical model


epsilon = find( length(matchOutcomeTraining(:,3)-matchOutcomeTraining(:,4)==0) )/length(matchOutcomeTraining(:,4)); % draw margin for trueSkill
%epsilon
matchOutcomeTesting = matchOutcome(end-numberOfPredictMatched +1:end, :); % testing data;
% how many teams
%M = length( unique(matchOutcome(:,1:2)) );
M = max( unique(matchOutcome(:,1:2)) );
% how many matches
N = length(matchOutcomeTraining(:, 1));

% Initialize each team's skills, o_i, d_i, o_j, d_j.

teamSkillsPoisson = cell(M, 2);
teamSkillsTrueSkill = cell(M, 1);
teamSkillsGaussian = cell(M, 2);
teamSkillsGaussianSD = cell(M, 1);
teamSkillsLogisticRegression = zeros(M, 2);

for idxTeam = 1:M
    teamSkillsPoisson{idxTeam, 1} = Gaussian(initialMu, initialSigma);   % Initialize Poisson Offence skill
    teamSkillsPoisson{idxTeam, 2} = Gaussian(initialMu, initialSigma);   % Initialize Poisson Defense skill
    teamSkillsTrueSkill{idxTeam, 1} = Gaussian(initialMu, initialSigma); % Initialize TrueSkill team skill
    teamSkillsGaussian{idxTeam, 1} = Gaussian(initialMu, initialSigma);  % Initialize Gaussian offence skill
    teamSkillsGaussian{idxTeam, 2} = Gaussian(initialMu, initialSigma);  % Initialize Gaussian defence skill
    teamSkillsGaussianSD{idxTeam, 1} = Gaussian(initialMu, initialSigma);% Initialize Gaussian score different model team skill
end

% Setting data: Team 1 ID + Team 2 ID + Team 1 Score + Team 2 Score
data = matchOutcomeTraining; % N: number of the matches

% Update skills according to Poisson model-----------------------------
for idxMatch = 1:N
    teamID_i = data(idxMatch, 1);
    teamID_j = data(idxMatch, 2);
    s_i = data(idxMatch, 3);
    s_j = data(idxMatch, 4);
    [o_i d_j] = updatePoisson( teamSkillsPoisson{teamID_i, 1}, teamSkillsPoisson{teamID_j, 2}, s_i, beta);
    [o_j d_i] = updatePoisson( teamSkillsPoisson{teamID_j, 1}, teamSkillsPoisson{teamID_i, 2}, s_j, beta);
    teamSkillsPoisson{teamID_i, 1} = o_i;
    teamSkillsPoisson{teamID_j, 2} = d_j;
    teamSkillsPoisson{teamID_j, 1} = o_j;
    teamSkillsPoisson{teamID_i, 2} = d_i;
end

% Update skills according to TrueSkill
for idxMatch = 1:N
    teamID_i = data(idxMatch, 1);
    teamID_j = data(idxMatch, 2);
    s_i = data(idxMatch, 3);
    s_j = data(idxMatch, 4);
    [o_i d_j] = updateTrueSkill( teamSkillsTrueSkill{teamID_i, 1}, teamSkillsTrueSkill{teamID_j, 1}, s_i, s_j, beta, epsilon);
    teamSkillsTrueSkill{teamID_i, 1} = o_i;
    teamSkillsTrueSkill{teamID_j, 1} = d_j;
end
% Update skills according to Simple Gaussian model-----------------------------

for idxMatch = 1:N
    teamID_i = data(idxMatch, 1);
    teamID_j = data(idxMatch, 2);
    s_i = data(idxMatch, 3);
    s_j = data(idxMatch, 4);
    [o_i d_j] = updateGaussian( teamSkillsGaussian{teamID_i, 1}, teamSkillsGaussian{teamID_j, 2}, s_i, beta, gammaS);
    [o_j d_i] = updateGaussian( teamSkillsGaussian{teamID_j, 1}, teamSkillsGaussian{teamID_i, 2}, s_j, beta, gammaS);
    teamSkillsGaussian{teamID_i, 1} = o_i;
    teamSkillsGaussian{teamID_j, 2} = d_j;
    teamSkillsGaussian{teamID_j, 1} = o_j;
    teamSkillsGaussian{teamID_i, 2} = d_i;
end

% Update skills according to socre difference Gaussian model --Added on
% 6 October 2010

for idxMatch = 1:N
    teamID_i = data(idxMatch, 1);
    teamID_j = data(idxMatch, 2);
    s_i = data(idxMatch, 3);
    s_j = data(idxMatch, 4);
    s = s_i - s_j;
    newPrecisionSi = 1/teamSkillsGaussianSD{teamID_i, 1}.Variance + 1/(beta1^2 + beta2^2 + gammaSD^2 + teamSkillsGaussianSD{teamID_j, 1}.Variance);
    newPrecisionAdjustedMeanSi = teamSkillsGaussianSD{teamID_i, 1}.Mu/teamSkillsGaussianSD{teamID_i, 1}.Variance + ...
        (s+teamSkillsGaussianSD{teamID_j, 1}.Mu)/(beta1^2 + beta2^2 + gammaSD^2 + teamSkillsGaussianSD{teamID_j, 1}.Variance);
    newPrecisionSj = 1/teamSkillsGaussianSD{teamID_j, 1}.Variance + 1/(beta1^2 + beta2^2 + gammaSD^2 + teamSkillsGaussianSD{teamID_i, 1}.Variance);
    newPrecisionAdjustedMeanSj = teamSkillsGaussianSD{teamID_j, 1}.Mu/teamSkillsGaussianSD{teamID_j, 1}.Variance + ...
        (teamSkillsGaussianSD{teamID_i, 1}.Mu-s)/(beta1^2 + beta2^2 + gammaSD^2 + teamSkillsGaussianSD{teamID_j, 1}.Variance);
    teamSkillsGaussianSD{teamID_i, 1} = Gaussian( newPrecisionAdjustedMeanSi/newPrecisionSi, sqrt(1/newPrecisionSi) );
    teamSkillsGaussianSD{teamID_j, 1} = Gaussian( newPrecisionAdjustedMeanSj/newPrecisionSj, sqrt(1/newPrecisionSj) );
end

%**************Testing***************************
% compute the prob of Team I wins
numMatch = size(matchOutcomeTesting, 1);
scorePoisson  = zeros( numMatch, 1 );
scoreGaussian = zeros( numMatch, 1);
scoreLogistic = zeros( numMatch, 1 );
scoreTrueSkill = zeros( numMatch, 1);
scoreGaussianSD = zeros (numMatch, 1);
% the accuracy of score predictions;
% revised on 15 August 2011 for using MAE
predictedScorePoisson = zeros( numMatch, 2);
predictedScoreGaussian = zeros( numMatch, 2);
predictedScoreGaussianSD = zeros( numMatch, 1);

wldStatistics = zeros(2, 5);
numWin = 0;
numLose = 0;
flagZero = ones(1, numMatch);
flagZeroTeamI = ones(1, numMatch);
flagZeroTeamJ = ones(1, numMatch);
scores = zeros(numMatch, 5); 
classes = zeros(numMatch, 1);
countTrainTest = 0;
flag = ones(1, numMatch);
for idxTestData = 1:numMatch
    % winProb of Team I predicting by Poisson
    teamID_i = matchOutcomeTesting(idxTestData, 1);
    teamID_j = matchOutcomeTesting(idxTestData, 2);
    
    % check if the groups in a testing match have been seen in the training
    % dataset
    if ~ismember( teamID_i, unique(matchOutcomeTraining(:, 1:2)) )  || ~ismember( teamID_j, unique(matchOutcomeTraining(:, 1:2)) )
        countTrainTest = countTrainTest + 1;
        flag(idxTestData) = zeros;
    end
    lambdaI = exp( (teamSkillsPoisson{teamID_i, 1}.Mu - teamSkillsPoisson{teamID_j, 2}.Mu) );
    lambdaJ = exp( (teamSkillsPoisson{teamID_j, 1}.Mu - teamSkillsPoisson{teamID_i, 2}.Mu) );
    % s = s_i - s_j is a Skellam distribution if $s_i$ ($s_j$) is a
    % Poission
    % with lambdaI (lambdaJ).
    pPoisson = 0;
    for tempCounter = 1:74 % approximation to calculate the winProb. Lower bound
        pPoisson = pPoisson + ...
            exp(-(lambdaI+lambdaJ))*(lambdaI/lambdaJ)^(tempCounter/2)*besseli(tempCounter, 2*sqrt(lambdaI*lambdaJ));
    end
    if isnan(pPoisson)
        fprint('Poisson failed!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    end
    dif = matchOutcomeTesting(idxTestData, 3)-matchOutcomeTesting(idxTestData, 4); % score difference -- groundtruth!
    % predictedScorePoisson(idxTestData) = abs( (lambdaI - lambdaJ)- dif);
    predictedScorePoisson(idxTestData, :) = [abs(lambdaI-matchOutcomeTesting(idxTestData, 3)) abs(lambdaJ-matchOutcomeTesting(idxTestData, 4))];
    
    % winProb of Team I predicted by TrueSkill
    tempMu = teamSkillsTrueSkill{teamID_i, 1}.Mu - teamSkillsTrueSkill{teamID_j, 1}.Mu;
    tempVariance = teamSkillsTrueSkill{teamID_i, 1}.Variance + teamSkillsTrueSkill{teamID_j, 1}.Variance + 2*beta^2;
    pTrueSkill = 1 - normcdf(0, tempMu, sqrt(tempVariance));
    
    % winProb of Team I predicted by Gaussian
    mu1 = (teamSkillsGaussian{teamID_i, 1}.Mu - teamSkillsGaussian{teamID_j, 2}.Mu);
    mu2 = (teamSkillsGaussian{teamID_j, 1}.Mu - teamSkillsGaussian{teamID_i, 2}.Mu);
    variance1 = teamSkillsGaussian{teamID_i, 1}.Variance + teamSkillsGaussian{teamID_j, 2}.Variance + beta1^2 + beta2^2;
    variance2 = teamSkillsGaussian{teamID_j, 1}.Variance + teamSkillsGaussian{teamID_i, 2}.Variance + beta1^2 + beta2^2;
    sigma = sqrt(variance1 + variance2);
    pGaussian = 1 - normcdf(0, mu1-mu2, sigma);
    % predictedScoreGaussian(idxTestData) = abs((mu1 - mu2) - dif);
    predictedScoreGaussian(idxTestData, :) = [abs(mu1-matchOutcomeTesting(idxTestData, 3)) abs(mu2-matchOutcomeTesting(idxTestData, 4))];
    
    % winProb of Team I predicted by Gaussian Score Difference --
    % -- 6 October 2010
    mu = teamSkillsGaussianSD{teamID_i, 1}.Mu - teamSkillsGaussianSD{teamID_j, 1}.Mu;
    sigma = sqrt(beta1^2 + beta2^2 + teamSkillsGaussianSD{teamID_i, 1}.Variance + teamSkillsGaussianSD{teamID_j, 1}.Variance);
    pGaussianSD = 1 - normcdf(0, mu, sigma);
  
    predictedScoreGaussianSD(idxTestData) = abs( mu - dif );
    if dif ==0
        flagZero(idxTestData) = 0;
    end
    
    % winProb of Team I predicted by Logistic
%     rowData = zeros(1, M);
%     rowData( matchOutcomeTesting( idxTestData, 1) ) = 1;
%     rowData( matchOutcomeTesting( idxTestData, 2) ) = -1;
%     tempResLogistic = [1 rowData]*wSoftmax;
%     [junk winLoseDraw] = max(tempResLogistic);   
    pLogistic = 1/2; % 1/(1+exp(-tempResLogistic(2)));
    
    % compute the score of win probability
    if matchOutcomeTesting(idxTestData, 3) > matchOutcomeTesting(idxTestData, 4)      % Team I wins
        scorePoisson(idxTestData) = 1+log2( pPoisson );
        scoreLogistic(idxTestData)= 1+log2( pLogistic );
        scoreGaussian(idxTestData)= 1+log2( pGaussian );
        scoreTrueSkill(idxTestData)= 1+log2( pTrueSkill );
        scoreGaussianSD(idxTestData) = 1+log2( pGaussianSD);
        
        numWin = numWin + 1;
        if pPoisson > (0.5-epsilon) %(teamSkillsPoisson{teamID_i, 1}.Mu + teamSkillsPoisson{teamID_i, 2}.Mu) > (teamSkillsPoisson{teamID_j, 1}.Mu + teamSkillsPoisson{teamID_j, 2}.Mu)
            wldStatistics(1, 1) = wldStatistics(1, 1)+1;
        end        
        %if winLoseDraw == 2          % 1 -- draw; 2 -- I wins; 3 -- I loses
            wldStatistics(1, 2) = wldStatistics(1, 2)+1;
        %end
        if  pGaussian > (0.5-epsilon) % (teamSkillsGaussian{teamID_i, 1}.Mu + teamSkillsGaussian{teamID_i, 2}.Mu) > (teamSkillsGaussian{teamID_j, 1}.Mu + teamSkillsGaussian{teamID_j, 2}.Mu)
            wldStatistics(1, 3) = wldStatistics(1, 3)+1;
        end
        if pTrueSkill > (0.5-epsilon) % teamSkillsTrueSkill{teamID_i, 1}.Mu > teamSkillsTrueSkill{teamID_j, 1}.Mu
            wldStatistics(1, 4) = wldStatistics(1, 4)+1;
        end
        if pGaussianSD > (0.5-epsilon) % teamSkillsGaussianSD{teamID_i, 1}.Mu > teamSkillsGaussianSD{teamID_j, 1}.Mu
            wldStatistics(1, 5) = wldStatistics(1, 5)+1;
        end
    elseif matchOutcomeTesting(idxTestData, 3) == matchOutcomeTesting(idxTestData, 4) % draws
        scorePoisson(idxTestData) = 1+1/2*log2( pPoisson*(1-pPoisson)   );
        scoreLogistic(idxTestData)= 1+1/2*log2( pLogistic*(1-pLogistic) );
        scoreGaussian(idxTestData)= 1+1/2*log2( pGaussian*(1-pGaussian) );
        scoreTrueSkill(idxTestData)= 1+1/2*log2( pTrueSkill*(1-pTrueSkill) );
        scoreGaussianSD(idxTestData) = 1+1/2*log2(pGaussianSD*(1-pGaussianSD));
    else                                                                              % Team J wins
        scorePoisson(idxTestData) = 1+log2( 1 - pPoisson );
        scoreLogistic(idxTestData)= 1+log2( 1 - pLogistic);
        scoreGaussian(idxTestData) = 1+log2(1 - pGaussian);
        scoreTrueSkill(idxTestData) = 1+log2(1 - pTrueSkill);
        scoreGaussianSD(idxTestData) = 1+log2(1 - pGaussianSD);
        
        numLose = numLose + 1;
        % update the number of lose predicted correctly by each model
        if  (1- pPoisson) > 0.5 % (teamSkillsPoisson{teamID_i, 1}.Mu + teamSkillsPoisson{teamID_i, 2}.Mu) < (teamSkillsPoisson{teamID_j, 1}.Mu + teamSkillsPoisson{teamID_j, 2}.Mu)
            wldStatistics(2, 1) = wldStatistics(2, 1)+1;
        end
        %if winLoseDraw == 3       % 1 -- draw; 2 -- I wins; 3 -- I loses
            wldStatistics(2, 2) = wldStatistics(2, 2)+1;
        %end
        if  (1-pGaussian) > 0.5 % (teamSkillsGaussian{teamID_i, 1}.Mu + teamSkillsGaussian{teamID_i, 2}.Mu) < (teamSkillsGaussian{teamID_j, 1}.Mu + teamSkillsGaussian{teamID_j, 2}.Mu)
            wldStatistics(2, 3) = wldStatistics(2, 3)+1;
        end
        if  (1- pTrueSkill) > 0.5 % teamSkillsTrueSkill{teamID_i, 1}.Mu < teamSkillsTrueSkill{teamID_j, 1}.Mu
            wldStatistics(2, 4) = wldStatistics(2, 4)+1;
        end
        if (1-pGaussianSD) > 0.5 % teamSkillsGaussianSD{teamID_i, 1}.Mu < teamSkillsGaussianSD{teamID_j, 1}.Mu
            wldStatistics(2, 5) = wldStatistics(2, 5)+1;
        end
    end
    % for plotting roc
    scores(idxTestData, :) = [pPoisson, pLogistic, pGaussian, pTrueSkill, pGaussianSD];
    classes(idxTestData, :) = matchOutcomeTesting(idxTestData, 3) > matchOutcomeTesting(idxTestData, 4);
    
end

% roc curve
predictedWinResult = zeros(1, 5);
[auc auh acc0 accm thrm thrs acc sens spec hull] = rocplot_rg(scores(:, 1), classes, 0);
predictedWinResult(1, 1) = auc;
[auc auh acc0 accm thrm thrs acc sens spec hull] = rocplot_rg(scores(:, 2), classes, 0);
predictedWinResult(1, 2) = auc;
[auc auh acc0 accm thrm thrs acc sens spec hull] = rocplot_rg(scores(:, 3), classes, 0);
predictedWinResult(1, 3) = auc;
[auc auh acc0 accm thrm thrs acc sens spec hull] = rocplot_rg(scores(:, 4), classes, 0);
predictedWinResult(1, 4) = auc;
[auc auh acc0 accm thrm thrs acc sens spec hull] = rocplot_rg(scores(:, 5), classes, 0);
predictedWinResult(1, 5) = auc;

score = [scorePoisson scoreLogistic scoreGaussian scoreTrueSkill scoreGaussianSD];
mmmm = mean(score);
ssss = std(score)./sqrt(numberOfPredictMatched);
resultFinal = [mmmm; ssss];
resultFinalWLD = [numWin numMatch wldStatistics(1,:);numLose numMatch wldStatistics(2,:)];
skillYear{1}=teamSkillsPoisson;
skillYear{2}=teamSkillsLogisticRegression;
skillYear{3}=teamSkillsGaussian;
skillYear{4}=teamSkillsTrueSkill;
skillYear{5}=teamSkillsGaussianSD;
skillPercentageYear = skillYear;

% need to remove bad matches: teams not seen in the training datasets;
predictedScorePoisson(flag==0,:) = [];
predictedScoreGaussian(flag==0,:) = [];
predictedScoreGaussianSD(flag==0, :) = [];
denomMAE = sqrt(length(predictedScorePoisson(:)));  % twice the number of matches: predict mean absolute error
denom = sqrt(length(predictedScoreGaussianSD));

scoreAccuracyPercentageYear = [mean(predictedScorePoisson(:)) mean(predictedScoreGaussian(:)) mean(predictedScoreGaussianSD); ...
                                std(predictedScorePoisson(:))/denomMAE std(predictedScoreGaussian(:))/denomMAE, std(predictedScoreGaussianSD)/denom ];
                           
%fprintf('number wrong testing matches = %d \n', countTrainTest);
end