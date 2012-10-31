function [resultFinal resultFinalWLD skillPercentageYear scoreAccuracyPercentageYear predictedWinResult] = evaluate_model(modelname, matchOutcome, trainingPercentage, testPercentage, flagHalo)

%% Initialization model parameters
initialMu = 25;
initialSigma = initialMu/3;
beta = initialSigma/2;
beta1 = beta;
beta2 = beta;

mm =min(min(matchOutcome(:, 3:4)));
if mm < 0
    matchOutcome(:, 3:4) = matchOutcome(:, 3:4) + abs(mm);
end

numberOfMatchTotal = size(matchOutcome, 1);
numberOfPredictMatched = floor(numberOfMatchTotal*testPercentage);

%% splitting training and testing
numberOfTraining =  floor(numberOfMatchTotal*trainingPercentage);
if flagHalo == 0
    matchOutcomeTraining = matchOutcome(1:numberOfTraining, :); % training data;
else
    %%% revised to randomly choose certain number of training matches. 
    indexMatchForTraining = randperm(numberOfMatchTotal - numberOfPredictMatched);
    matchOutcomeTraining = matchOutcome( indexMatchForTraining(1:numberOfTraining), :); % training data;
    %%% done for randomly choosing training matches. 
end

epsilon = find( length(matchOutcomeTraining(:,3)-matchOutcomeTraining(:,4)==0) )/length(matchOutcomeTraining(:,4)); % draw margin for trueSkill
%epsilon
matchOutcomeTesting = matchOutcome(end-numberOfPredictMatched +1:end, :); % testing data;
% how many teams
%M = length( unique(matchOutcome(:,1:2)) );
M = max( unique(matchOutcome(:,1:2)) );
% how many matches
N = length(matchOutcomeTraining(:, 1));

% Initialize each team's skills, o_i, d_i, o_j, d_j.

teamSkills = cell(M, 2); 

for idxTeam = 1:M
    teamSkills{idxTeam, 1} = Gaussian(initialMu, initialSigma);   % Initialize Offence skill
    teamSkills{idxTeam, 2} = Gaussian(initialMu, initialSigma);   % Initialize Defense skill
end

% Setting data: Team 1 ID + Team 2 ID + Team 1 Score + Team 2 Score
data = matchOutcomeTraining; % N: number of the matches

% Update skills according to Poisson model with Slice Sampling
for idxMatch = 1:N
    teamID_i = data(idxMatch, 1);
    teamID_j = data(idxMatch, 2);
    s_i = data(idxMatch, 3);
    s_j = data(idxMatch, 4);
    % switch depending on model here
    switch(modelname)
        case 'PoissonSlice'
            [o_i d_j] = updatePoisson( teamSkills{teamID_i, 1}, teamSkills{teamID_j, 2}, s_i, beta, 1); % the 5th parameter indicating slicesampling
            [o_j d_i] = updatePoisson( teamSkills{teamID_j, 1}, teamSkills{teamID_i, 2}, s_j, beta, 1);
            return; 
        case 'PoissonVB' 
            [o_i d_j] = updatePoisson( teamSkills{teamID_i, 1}, teamSkills{teamID_j, 2}, s_i, beta, 0); % the 5th parameter indicating slicesampling
            [o_j d_i] = updatePoisson( teamSkills{teamID_j, 1}, teamSkills{teamID_i, 2}, s_j, beta, 0);
        case ''
        case
        case
    end
    teamSkills{teamID_i, 1} = o_i;
    teamSkills{teamID_j, 2} = d_j;
    teamSkills{teamID_j, 1} = o_j;
    teamSkills{teamID_i, 2} = d_i;
end

%**************Testing***************************
% compute the prob of Team I wins
numMatch = size(matchOutcomeTesting, 1);
informationGain  = zeros( numMatch, 1 );
% the accuracy of score predictions;
% revised on 15 August 2011 for using MAE
predictedScore = zeros( numMatch, 2);

wldStatistics = zeros(2, 1);
numWin = 0;
numLose = 0;
scores = zeros(numMatch, 1); 
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
     
    %% model specific operations
    % Winning probability
    lambdaISlice = exp( (teamSkills{teamID_i, 1}.Mu - teamSkills{teamID_j, 2}.Mu) );
    lambdaJSlice = exp( (teamSkills{teamID_j, 1}.Mu - teamSkills{teamID_i, 2}.Mu) );
    % s = s_i - s_j is a Skellam distribution if $s_i$ ($s_j$) is a
    % Poission
    % with lambdaI (lambdaJ).
    pPoissonSlice = computePoissonWinProbLowerBound(lambdaISlice, lambdaJSlice);
    if isnan(pPoissonSlice)
        fprint('Poisson failed!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    end
    dif = matchOutcomeTesting(idxTestData, 3)-matchOutcomeTesting(idxTestData, 4); % score difference -- groundtruth!
    % Socre prediction
    predictedScore(idxTestData, :) = [abs(lambdaISlice-matchOutcomeTesting(idxTestData, 3)) abs(lambdaJSlice-matchOutcomeTesting(idxTestData, 4))];
    
    % Information gain
    if matchOutcomeTesting(idxTestData, 3) > matchOutcomeTesting(idxTestData, 4)      % Team I wins
        informationGain(idxTestData) = 1+log2( pPoissonSlice );        
        
        numWin = numWin + 1;
        if pPoissonSlice > (0.5-epsilon)          % 1 -- draw; 2 -- I wins; 3 -- I loses
            wldStatistics(1, 2) = wldStatistics(1, 2)+1;
        end
    elseif matchOutcomeTesting(idxTestData, 3) == matchOutcomeTesting(idxTestData, 4) % draws
        informationGain(idxTestData) = 1+1/2*log2( pPoissonSlice*(1-pPoissonSlice)   );    
    else                                                                              % Team J wins
        informationGain(idxTestData) = 1+log2( 1 - pPoissonSlice );
        
        numLose = numLose + 1;
        % update the number of lose predicted correctly by each model
        if  (1- pPoissonSlice) > 0.5 
            wldStatistics(1, 2) = wldStatistics(1, 2)+1;
        end        
    end
    % for plotting roc
    scores(idxTestData) = pPoissonSlice;
    classes(idxTestData) = matchOutcomeTesting(idxTestData, 3) > matchOutcomeTesting(idxTestData, 4);
    
end

% roc curve
[auc auh acc0 accm thrm thrs acc sens spec hull] = rocplot_rg(scores, classes, 0);
predictedWinResult = auc;

mmmm = mean(informationGain);
ssss = std(informationGain)./sqrt(numberOfPredictMatched);
informationGain.mean = [mmmm; ssss];
resultFinalWLD = [numWin numMatch wldStatistics(1,1);numLose numMatch wldStatistics(2,1)];
skillYear=teamSkills;
skillPercentageYear = skillYear;

% need to remove bad matches: teams not seen in the training datasets;
predictedScore(flag==0,:) = [];
denomMAESlice = sqrt(length(predictedScore(:)));  % twice the number of matches: predict mean absolute error

scoreAccuracyPercentageYear = [mean(predictedScore(:)); std(predictedScore(:))/denomMAESlice];                           
end