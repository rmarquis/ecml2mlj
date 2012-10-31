% plot results with Poisson-SliceSampling for AFL and UK-Halo

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AFL
load result_AFL_allModelsWithSampling; 

[nr, nc] = size(resultFinal_AFL); 
for i = 1:nr
    for j = 1:nc
        resultFinal_AFL{i, j}(: ,2) = resultFinal_AFL_PoissonSampling{i, j};         
    end
end

numberOfYear = 11;
tit = 'AFL';
%%%%%%%%%%%%%%%%%%%%%%%%%%%Average information gain
xInd = 0.1:0.1:0.8;
numTrainingPatch = length(xInd); 
[y, error] = summarizeInformationGain(resultFinal_AFL, numTrainingPatch, numberOfYear);
axisLim = [xInd(1)-0.02 xInd(end)+0.02 -0.7 0.2];
fileName = 'InforGain_AFL';

plotInformationGain(xInd, y, error, axisLim, tit, fileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%Predict accuracy
[nr, nc] = size(resultFinalPredictWin_AFL);
for i = 1:nr
    for j = 1:nc
        resultFinalPredictWin_AFL{i, j}(:, 2) = resultFinalPredictWin_AFL_PoissonSampling{i, j};
    end
end
[y, error]=summarizeWinPredictionAccuracy(resultFinalPredictWin_AFL);
axisLim = [xInd(1)-0.02 xInd(end)+0.02 0.55 0.8];
fileName = 'WLAccuracy_AFL';
flagBrireScore = 0; 
plotWLAccuracy(xInd, y, error, axisLim, tit, fileName);
%%%%%%%%%%%%%%%%%%%%%%%%%%Score Accuracy
[nr, nc] = size(scoreAccuracyPercentageYear); 
for i = 1:nr
    for j = 1:nc
        scoreAccuracyPercentageYear{i, j}(:, 3) = scoreAccuracyPercentageYear_PoissonSampling{i, j};
        % swap second and third method to make sure Poisson-VB is ahead of
        % Guassian-OD
        temp = scoreAccuracyPercentageYear{i, j}(:, 2); 
        scoreAccuracyPercentageYear{i, j}(:, 2) = scoreAccuracyPercentageYear{i, j}(:, 3);
        scoreAccuracyPercentageYear{i, j}(:, 3) = temp;        
    end
end
% add the averageScorePredictor
averageScorePredictorRes = load( 'scoreAccuracyPercentageYear_AFL_withAverageScorePredictor.mat' );
for i = 1:nr
    for j = 1:nc
        scoreAccuracyPercentageYear{i, j}(:, end+1) = averageScorePredictorRes.scoreAccuracyPercentageYear{i, j}(:, 5);
    end
end


xMean = [];
y = [];
error = [];
for idxTraining = 1:numTrainingPatch
    for idxYear = 1:numberOfYear
        xMean = [xMean; scoreAccuracyPercentageYear{idxTraining, idxYear}(1,:)];
    end
    y = [y; mean(xMean)];
    error = [error; std(xMean)/sqrt(numberOfYear)];
    xMean = [];
end
axisLim = [xInd(1)-0.02 xInd(end)+0.02 20 100];
fileName = 'ScoreError_AFL';

plotScoreError(xInd, y, error, axisLim, tit, fileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%Brier Score
load resultFinal_BrierScore_AFL.mat
[y, error]=summarizeWinPredictionAccuracy(resultFinal_BrierScore_AFL);
axisLim = [xInd(1)-0.02 xInd(end)+0.02 0.15 0.4];
fileName = 'WLAccuracy_AFL';
y(:, 2) = [];
error(:, 2) = [];
plotWLAccuracy_BrierScore(xInd, y, error, axisLim, tit, fileName);

% %%%%%%%%%%%%%%%%%%%%%%%%Skill training results
% load resultPercentageYear_AFL
% resultFinal = skillPercentageYear;
% [y, error] = summarizeSkillEstimation(resultFinal, numTrainingPatch, numberOfYear);
% fileName = 'Skills_AFL';
% axisLim = [0.08 0.92 0 100];
% plotSkillEstimation(xInd, y, error, axisLim, tit, fileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Halo
load resultFinal_Halo
resultFinal = resultFinal_Halo;
xInd = 0.1:0.1:0.8;
numTrainingPatch = length(xInd); 
withLogistic = 0;
numberOfYear = 30;
%%%%%%%%%%%%%%%%%%%%%%%%%%%Average information gain
xInd = 0.1:0.1:0.8;
numTrainingPatch = length(xInd); 
[y, error] = summarizeInformationGain(resultFinal, numTrainingPatch, numberOfYear);
axisLim = [xInd(1)-0.02 xInd(end)+0.02 -0.1 0.05];
tit = 'Halo';
fileName = 'InforGain_Halo';
plotInformationGain(xInd, y, error, axisLim, tit, fileName, withLogistic);

%%%%%%%%%%%%%%%%%%%%%%%%%%%Predict accuracy
load resultFinalPredictWin_Halo;
resultFinal = resultFinalPredictWin_Halo;
tit = 'Halo';
fileName = 'WLAccuracy_Halo';
[y, error]=summarizeWinPredictionAccuracy(resultFinal);
axisLim = [xInd(1)-0.02 xInd(end)+0.02 0.55 0.65];
plotWLAccuracy(xInd, y, error, axisLim, tit, fileName, withLogistic);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Score Accuracy
load scoreAccuracyPercentage_Halo; 
resultFinal = scoreAccuracyPercentage;
fileName = 'ScoreError_Halo';
xMean = [];
y = [];
error = [];
for idxTraining = 1:numTrainingPatch
    for idxYear = 1:numberOfYear
        xMean = [xMean; resultFinal{idxTraining, idxYear}(1,:)];
    end
    y = [y; mean(xMean)];
    error = [error; std(xMean)/sqrt(numberOfYear)];
    xMean = [];
end
axisLim = [xInd(1)-0.02 xInd(end)+0.02 0 20];
plotScoreError(xInd, y, error, axisLim, tit, fileName);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  UK-PL
withLogistic = 0;
load resultFinal_UK
numberOfYear = 14;
resultFinal = resultFinal_UK;
xInd = 0.1:0.1:0.8;
numTrainingPatch = length(xInd); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Average information gain
[y, error] = summarizeInformationGain(resultFinal, numTrainingPatch, numberOfYear);
axisLim = [xInd(1)-0.02 xInd(end)+0.02 -3 0.3];
tit = 'UK-PL';
fileName = 'InforGain_UK';
plotInformationGain(xInd, y, error, axisLim, tit, fileName, withLogistic);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Predict accuracy
load resultFinalPredictWin_UK;
resultFinal = resultFinalPredictWin_UK;
[y, error]=summarizeWinPredictionAccuracy(resultFinal);
axisLim = [xInd(1)-0.02 xInd(end)+0.02 0.5 0.7];
fileName = 'WLAccuracy_UK';
plotWLAccuracy(xInd, y, error, axisLim, tit, fileName, withLogistic);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Score Accuracy
load scoreAccuracyPercentageYear_UK;
resultFinal = scoreAccuracyPercentageYear;
xMean = [];
xStd = [];
y = [];
error = [];
for idxTraining = 1:numTrainingPatch
    for idxYear = 1:numberOfYear
        xMean = [xMean; resultFinal{idxTraining, idxYear}(1,:)];
    end
    y = [y; mean(xMean)];
    error = [error; std(xMean)/sqrt(numberOfYear)];
    xMean = [];
end
axisLim = [xInd(1)-0.02 xInd(end)+0.02 0.5 2.5];
fileName = 'ScoreError_UK';
plotScoreError(xInd, y, error, axisLim, tit, fileName);
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%Brier Score
load resultFinal_BrierScore_UK.mat
[y, error]=summarizeWinPredictionAccuracy(resultFinal_BrierScore_UK);
axisLim = [xInd(1)-0.02 xInd(end)+0.02 0.25 0.55];
fileName = 'WLAccuracy_UK';
flagBrireScore = 1;
y(:, 2) = [];
error(:, 2) = [];
plotWLAccuracy_BrierScore(xInd, y, error, axisLim, tit, fileName);

% %%%%%%%%%%%%%%%%%%%%%%%%Skill training results
% load skillPercentageYear_UK.mat
% resultFinal = skillPercentageYear;
% [y, error] = summarizeSkillEstimation(resultFinal, numTrainingPatch, numberOfYear);
% fileName = 'Skills_AFL';
% axisLim = [0.13 0.97 0 100];
% plotSkillEstimation(xInd, y, error, axisLim, tit, fileName);
