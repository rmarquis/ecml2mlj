function [resultFinal resultFinalWLD skillPercentageYear scoreAccuracyPercentageYear predictedWinResult] = computeThreeMeasure_AllScoreDifference_AH(matchOutcome, trainingPercentage, testPercentage, matchAHIndicator, flagHalo)

% revise history
% created on 28 October 2012: modeling HA for all models except Poisson-Sampling since it is slow to finish;

% calculate error functions

skillYear = cell(1, 2);
% Initialize other parameters
initialMu = 25;
initialSigma = initialMu/3;

HAMuPoisson = 0.001;           % prior mean for Homefield advantage
HASigmaPoisson = HAMuPoisson/3;   % prior standard deviation for Homefield advantage

HAMuGaussianOD = 0.001;
HASigmaGaussianOD = HAMuGaussianOD/3;

beta = initialSigma/2;
beta1 = beta;
beta2 = beta;
beta3 = beta; % beta3 is the standard deviation of the home field advantage variable. 

mm =min(min(matchOutcome(:, 3:4)));
if mm < 0
    matchOutcome(:, 3:4) = matchOutcome(:, 3:4) + abs(mm);
end
%%%%%
numberOfMatchTotal = size(matchOutcome, 1);
numberOfPredictMatched = floor(numberOfMatchTotal*testPercentage);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numberOfTraining =  floor(numberOfMatchTotal*trainingPercentage);

if flagHalo == 0
    matchOutcomeTraining = matchOutcome(1:numberOfTraining, :); % training data;
    matchOutcomeTesting = matchOutcome(end-numberOfPredictMatched +1:end, :); % testing data;
else
    %%% revised to randomly choose certain number of training matches. 
    indexMatchForTraining = randperm(numberOfMatchTotal - numberOfPredictMatched);
    matchOutcomeTraining = matchOutcome( indexMatchForTraining(1:numberOfTraining), :); % training data;
    matchOutcomeTesting = matchOutcome(  indexMatchForTraining(end-numberOfPredictMatched +1:end), :); % testing data;    
end

matchOutcomeTrainingAHIndicator = matchAHIndicator(1:numberOfTraining, :);
matchOutcomeTestAHIndicator = matchAHIndicator(end-numberOfPredictMatched +1:end, :);


tempScore = [matchOutcomeTraining(:,3); matchOutcomeTraining(:,4)];
gammaS = var( tempScore ); % score-based Gaussian graphical model
clear tempScore;
gammaSD = var ( matchOutcomeTraining(:,3)-matchOutcomeTraining(:,4) ); % score diff based Gaussian graphical model

epsilon = find( length(matchOutcomeTraining(:,3)-matchOutcomeTraining(:,4)==0) )/length(matchOutcomeTraining(:,4)); % draw margin for trueSkill
%epsilon

% how many teams
%M = length( unique(matchOutcome(:,1:2)) );
M = max( unique(matchOutcome(:,1:2)) );
% how many matches
N = length(matchOutcomeTraining(:, 1));

% Initialize each team's skills, o_i, d_i, o_j, d_j.

teamSkillsPoisson = cell(M, 3);
teamSkillsGaussian = cell(M, 2);

for idxTeam = 1:M
    teamSkillsPoisson{idxTeam, 1} = Gaussian(initialMu, initialSigma);   % Initialize Poisson Offence skill
    teamSkillsPoisson{idxTeam, 2} = Gaussian(initialMu, initialSigma);   % Initialize Poisson Defense skill
    teamSkillsPoisson{idxTeam, 3} = Gaussian(HAMuPoisson, HASigmaPoisson);   % Initialize Team homefield advantage
    
    teamSkillsGaussian{idxTeam, 1} = Gaussian(initialMu, initialSigma);  % Initialize Gaussian offence skill
    teamSkillsGaussian{idxTeam, 2} = Gaussian(initialMu, initialSigma);  % Initialize Gaussian defence skill
    teamSkillsGaussian{idxTeam, 3} = Gaussian(HAMuGaussianOD, HASigmaGaussianOD);   % Initialize Team homefield advantage
end

% Setting data: Team 1 ID + Team 2 ID + Team 1 Score + Team 2 Score
data = matchOutcomeTraining; % N: number of the matches

% Update skills according to Poisson model-----------------------------
% fprintf('update Poisson model: \n');
for idxMatch = 1:N
%    fprintf('%d\n', idxMatch); 
    teamID_i = data(idxMatch, 1);
    teamID_j = data(idxMatch, 2);
    s_i = data(idxMatch, 3);
    s_j = data(idxMatch, 4);

    if matchOutcomeTrainingAHIndicator(idxMatch, 1) == 1 % check if i HA
        [h_i, o_i, d_j] = updateModel_homeFieldAdvantage( 'Poisson', teamSkillsPoisson{teamID_i, 3}, teamSkillsPoisson{teamID_i, 1}, teamSkillsPoisson{teamID_j, 2}, s_i, beta, gammaS, 0);
        teamSkillsPoisson{teamID_i, 3} = h_i;
    else
        [o_i, d_j] = updatePoisson( teamSkillsPoisson{teamID_i, 1}, teamSkillsPoisson{teamID_j, 2}, s_i, beta, 0);
    end
    teamSkillsPoisson{teamID_i, 1} = o_i;
    teamSkillsPoisson{teamID_j, 2} = d_j;
    
    if matchOutcomeTrainingAHIndicator(idxMatch, 2) == 1 % check if j HA
        [h_j, o_j, d_i] = updateModel_homeFieldAdvantage( 'Poisson', teamSkillsPoisson{teamID_j, 3}, teamSkillsPoisson{teamID_j, 1}, teamSkillsPoisson{teamID_i, 2}, s_j, beta, gammaS, 0);
        teamSkillsPoisson{teamID_j, 3} = h_j;
    else
        [o_j, d_i] = updatePoisson( teamSkillsPoisson{teamID_j, 1}, teamSkillsPoisson{teamID_i, 2}, s_j, beta, 0);
    end
    teamSkillsPoisson{teamID_j, 1} = o_j;
    teamSkillsPoisson{teamID_i, 2} = d_i;

end


% Update skills according to Gaussian-OD model-----------------------------
%fprintf('update Gaussian model: \n');
for idxMatch = 1:N
    % fprintf('%d\n', idxMatch); 
    teamID_i = data(idxMatch, 1);
    teamID_j = data(idxMatch, 2);
    s_i = data(idxMatch, 3);
    s_j = data(idxMatch, 4);
    if matchOutcomeTrainingAHIndicator(idxMatch, 1) == 1 % check if i HA
        [h_i, o_i, d_j] = updateModel_homeFieldAdvantage( 'GaussianOD', teamSkillsGaussian{teamID_i, 3}, teamSkillsGaussian{teamID_i, 1}, teamSkillsGaussian{teamID_j, 2}, s_i, beta, gammaS, 0);
        teamSkillsGaussian{teamID_i, 3} = h_i;
    else        
        [o_i, d_j] = updateGaussian(teamSkillsGaussian{teamID_i, 1}, teamSkillsGaussian{teamID_j, 2}, s_i, beta, gammaS);
    end
    teamSkillsGaussian{teamID_i, 1} = o_i;
    teamSkillsGaussian{teamID_j, 2} = d_j;
    
    if matchOutcomeTrainingAHIndicator(idxMatch, 2) == 1 % check if i HA
        [h_j, o_j, d_i] = updateModel_homeFieldAdvantage( 'GaussianOD', teamSkillsGaussian{teamID_j, 3}, teamSkillsGaussian{teamID_j, 1}, teamSkillsGaussian{teamID_i, 2}, s_j, beta, gammaS, 0);
        teamSkillsGaussian{teamID_j, 3} = h_j;
    else        
        [o_j, d_i] = updateGaussian(teamSkillsGaussian{teamID_i, 1}, teamSkillsGaussian{teamID_j, 2}, s_j, beta, gammaS);
    end    
    teamSkillsGaussian{teamID_j, 1} = o_j;
    teamSkillsGaussian{teamID_i, 2} = d_i;
    
end

%**************Testing***************************
% compute the prob of Team I wins
numMatch = size(matchOutcomeTesting, 1);
scorePoisson  = zeros( numMatch, 1 );
scoreGaussian = zeros( numMatch, 1);
% the accuracy of score predictions;
% revised on 15 August 2011 for using MAE
predictedScorePoisson = zeros( numMatch, 2);
predictedScoreGaussian = zeros( numMatch, 2);

wldStatistics = zeros(2, 2);
numWin = 0;
numLose = 0;
flagZero = ones(1, numMatch);
scores = zeros(numMatch, 2); 
classes = zeros(numMatch, 1);
countTrainTest = 0;
flag = ones(1, numMatch);
for idxTestData = 1:numMatch    
    %% winProb of Team I predicting by Poisson with VB
    teamID_i = matchOutcomeTesting(idxTestData, 1);
    teamID_j = matchOutcomeTesting(idxTestData, 2);
    
    % check if the groups in a testing match have been seen in the training
    % dataset
    if ~ismember( teamID_i, unique(matchOutcomeTraining(:, 1:2)) )  || ~ismember( teamID_j, unique(matchOutcomeTraining(:, 1:2)) )
        countTrainTest = countTrainTest + 1;
        flag(idxTestData) = zeros;
    end
    lambdaI = exp( (teamSkillsPoisson{teamID_i, 1}.Mu + matchOutcomeTestAHIndicator(idxTestData,1)*teamSkillsPoisson{teamID_i, 3}.Mu - teamSkillsPoisson{teamID_j, 2}.Mu) );
    lambdaJ = exp( (teamSkillsPoisson{teamID_j, 1}.Mu + matchOutcomeTestAHIndicator(idxTestData,2)*teamSkillsPoisson{teamID_j, 3}.Mu - teamSkillsPoisson{teamID_i, 2}.Mu) );

    % s = s_i - s_j is a Skellam distribution if $s_i$ ($s_j$) is a
    % Poission
    % with lambdaI (lambdaJ).
    pPoisson = computePoissonWinProbLowerBound(lambdaI, lambdaJ);
    if isnan(pPoisson)
        fprintf('Poisson failed!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    end
    dif = matchOutcomeTesting(idxTestData, 3)-matchOutcomeTesting(idxTestData, 4); % score difference -- groundtruth!
    % predictedScorePoisson(idxTestData) = abs( (lambdaI - lambdaJ)- dif);
    predictedScorePoisson(idxTestData, :) = [abs(lambdaI-matchOutcomeTesting(idxTestData, 3)) abs(lambdaJ-matchOutcomeTesting(idxTestData, 4))];
    
    %% winProb of Team I predicted by Gaussian    
    mu1 = (teamSkillsGaussian{teamID_i, 1}.Mu + matchOutcomeTestAHIndicator(idxTestData,1) * teamSkillsGaussian{teamID_i, 3}.Mu - teamSkillsGaussian{teamID_j, 2}.Mu);
    mu2 = (teamSkillsGaussian{teamID_j, 1}.Mu + matchOutcomeTestAHIndicator(idxTestData,2) * teamSkillsGaussian{teamID_j, 3}.Mu - teamSkillsGaussian{teamID_i, 2}.Mu);
    variance1 = teamSkillsGaussian{teamID_i, 1}.Variance + matchOutcomeTestAHIndicator(idxTestData,1) * teamSkillsGaussian{teamID_i, 3}.Variance + teamSkillsGaussian{teamID_j, 2}.Variance + beta1^2 + beta2^2;
    variance2 = teamSkillsGaussian{teamID_j, 1}.Variance + matchOutcomeTestAHIndicator(idxTestData,2) * teamSkillsGaussian{teamID_j, 3}.Variance + teamSkillsGaussian{teamID_i, 2}.Variance + beta1^2 + beta2^2;
    sigma = sqrt(variance1 + variance2);
    pGaussian = 1 - normcdf(0, mu1-mu2, sigma);
    % predictedScoreGaussian(idxTestData) = abs((mu1 - mu2) - dif);
    predictedScoreGaussian(idxTestData, :) = [abs(mu1-matchOutcomeTesting(idxTestData, 3)) abs(mu2-matchOutcomeTesting(idxTestData, 4))];
    
    if dif ==0
        flagZero(idxTestData) = 0;
    end
    
    % compute the score of win probability
    if matchOutcomeTesting(idxTestData, 3) > matchOutcomeTesting(idxTestData, 4)      % Team I wins
        scorePoisson(idxTestData) = 1+log2( pPoisson );
        scoreGaussian(idxTestData)= 1+log2( pGaussian );
       
        numWin = numWin + 1;
        if pPoisson > (0.5-epsilon) %(teamSkillsPoisson{teamID_i, 1}.Mu + teamSkillsPoisson{teamID_i, 2}.Mu) > (teamSkillsPoisson{teamID_j, 1}.Mu + teamSkillsPoisson{teamID_j, 2}.Mu)
            wldStatistics(1, 1) = wldStatistics(1, 1)+1;
        end        
        if  pGaussian > (0.5-epsilon) % (teamSkillsGaussian{teamID_i, 1}.Mu + teamSkillsGaussian{teamID_i, 2}.Mu) > (teamSkillsGaussian{teamID_j, 1}.Mu + teamSkillsGaussian{teamID_j, 2}.Mu)
            wldStatistics(1, 2) = wldStatistics(1, 2)+1;
        end
    elseif matchOutcomeTesting(idxTestData, 3) == matchOutcomeTesting(idxTestData, 4) % draws
        scorePoisson(idxTestData) = 1+1/2*log2( pPoisson*(1-pPoisson)   );
        scoreGaussian(idxTestData)= 1+1/2*log2( pGaussian*(1-pGaussian) );
    else                                                                              % Team J wins
        scorePoisson(idxTestData) = 1+log2( 1 - pPoisson );
        scoreGaussian(idxTestData) = 1+log2(1 - pGaussian);
        
        numLose = numLose + 1;
        % update the number of lose predicted correctly by each model
        if  (1- pPoisson) > 0.5 % (teamSkillsPoisson{teamID_i, 1}.Mu + teamSkillsPoisson{teamID_i, 2}.Mu) < (teamSkillsPoisson{teamID_j, 1}.Mu + teamSkillsPoisson{teamID_j, 2}.Mu)
            wldStatistics(2, 1) = wldStatistics(2, 1)+1;
        end
        if  (1-pGaussian) > 0.5 % (teamSkillsGaussian{teamID_i, 1}.Mu + teamSkillsGaussian{teamID_i, 2}.Mu) < (teamSkillsGaussian{teamID_j, 1}.Mu + teamSkillsGaussian{teamID_j, 2}.Mu)
            wldStatistics(2, 2) = wldStatistics(2, 2)+1;
        end
    end
    % for plotting roc
    scores(idxTestData, :) = [pPoisson, pGaussian];
    classes(idxTestData, :) = matchOutcomeTesting(idxTestData, 3) > matchOutcomeTesting(idxTestData, 4);
    
end

% roc curve
predictedWinResult = zeros(1, 2);
[auc auh acc0 accm thrm thrs acc sens spec hull] = rocplot_rg(scores(:, 1), classes, 0);
predictedWinResult(1, 1) = auc;
[auc auh acc0 accm thrm thrs acc sens spec hull] = rocplot_rg(scores(:, 2), classes, 0);
predictedWinResult(1, 2) = auc;
score = [scorePoisson scoreGaussian];
mmmm = mean(score);
ssss = std(score)./sqrt(numberOfPredictMatched);
resultFinal = [mmmm; ssss];
resultFinalWLD = [numWin numMatch wldStatistics(1,:);numLose numMatch wldStatistics(2,:)];
skillYear{1}=teamSkillsPoisson;
skillYear{2}=teamSkillsGaussian;
skillPercentageYear = skillYear;

% need to remove bad matches: teams not seen in the training datasets;
predictedScorePoisson(flag==0,:) = [];
predictedScoreGaussian(flag==0,:) = [];
denomMAE      = sqrt(length(predictedScorePoisson(:)));  % twice the number of matches: predict mean absolute error

scoreAccuracyPercentageYear = [mean(predictedScorePoisson(:))          mean(predictedScoreGaussian(:)); ...
                                std(predictedScorePoisson(:))/denomMAE std(predictedScoreGaussian(:))/denomMAE];                           

fprintf('Poisson-AH AUC: %f, Gaussian-AH AUC: %f\n', predictedWinResult(1, 1), predictedWinResult(1, 2));
fprintf('Poisson-AH Score: %f+/-%f \n', mean(predictedScorePoisson(:)), std(predictedScorePoisson(:))/denomMAE);
fprintf('Gaussian-AH Score: %f+/-%f \n', mean(predictedScoreGaussian(:)), std(predictedScoreGaussian(:))/denomMAE);
fprintf('Poisson-AH IG: %f+/-%f \n', mmmm(1), ssss(1));
fprintf('Gaussian-AH IG: %f+/-%f \n', mmmm(2), ssss(2));
end