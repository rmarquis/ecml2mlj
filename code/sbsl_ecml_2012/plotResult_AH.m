%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AFL
[nr, nc] = size(resultFinal_AFL); 
res_all = cell(nr, nc);
for i = 1:nr
    for j = 1:nc
        res_all{i, j} = [resultFinal_AFL{i, j} resultFinal_AFL_AH{i, j}];
    end
end

numberOfYear = 11;
resultFinal = res_all;
tit = 'AFL';
%%%%%%%%%%%%%%%%%%%%%%%%%%%Average information gain
xInd = 0.1:0.1:0.8;
numTrainingPatch = length(xInd); 
[y, error] = summarizeInformationGain(resultFinal, numTrainingPatch, numberOfYear);
axisLim = [xInd(1)-0.02 xInd(end)+0.02 -0.9 0.2];
fileName = 'InforGain_AFL';
plotInformationGain(xInd, y, error, axisLim, tit, fileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%Predict accuracy
res_all = cell(nr, nc); 
for i = 1:nr
    for j = 1:nc
        res_all{i, j} = [resultFinalPredictWin_AFL{i, j} resultFinalPredictWin_AFL_AH{i, j}];
    end
end
[y, error]=summarizeWinPredictionAccuracy(res_all);
axisLim = [xInd(1)-0.02 xInd(end)+0.02 0.55 0.8];
fileName = 'WLAccuracy_AFL';
plotWLAccuracy(xInd, y, error, axisLim, tit, fileName);
%%%%%%%%%%%%%%%%%%%%%%%%%%Score Accuracy
res_all = cell(nr, nc); 
for i = 1:nr
    for j = 1:nc
        res_all{i, j} = [scoreAccuracyPercentageYear{i, j} scoreAccuracyPercentageYear_AH{i, j}];
    end
end
resultFinal = res_all;
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
axisLim = [xInd(1)-0.02 xInd(end)+0.02 20 100];
fileName = 'ScoreError_AFL';
plotScoreError(xInd, y, error, axisLim, tit, fileName);

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% old script for plotting Halo (i.e., no cross validation)
% load resultFinal_Halo
% resultFinal = resultFinal_Halo;
% xInd = 0.1:0.1:0.9;
% numTrainingPatch = length(xInd); 
% withLogistic = 0;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%Average information gain
% y = [];
% error = [];
% for idxTraining = 1:numTrainingPatch
%     y = [y; resultFinal{idxTraining}(1,:)];
%     error = [error; resultFinal{idxTraining}(2,:)];
% end
% axisLim = [xInd(1)-0.02 xInd(end)+0.02 -0.15 0.05];
% tit = 'Halo';
% fileName = 'InforGain_Halo';
% plotInformationGain(xInd, y, error, axisLim, tit, fileName, withLogistic);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%Predict accuracy
% load resultFinalPredictWin_Halo;
% resultFinal = resultFinalPredictWin_Halo;
% y = zeros(numTrainingPatch, 5);
% for i = 1:numTrainingPatch
%     y(i, :) = resultFinal{i, 1};
% end
% error = zeros(size(y));
% %%%
% axisLim = [xInd(1)-0.02 xInd(end)+0.02 0.5 0.66];
% tit = 'Halo';
% fileName = 'WLAccuracy_Halo';
% plotWLAccuracy(xInd, y, error, axisLim, tit, fileName, withLogistic);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%Score Accuracy
% load scoreAccuracyPercentage_Halo; 
% resultFinal = scoreAccuracyPercentage;
% y = [];
% error = [];
% for idxTraining = 1:numTrainingPatch
%     y = [y; resultFinal{idxTraining}(1,:)];
%     error = [error; resultFinal{idxTraining}(2,:)];
% end
% axisLim = [xInd(1)-0.02 xInd(end)+0.02 3 17];
% fileName = 'ScoreError_Halo';
% plotScoreError(xInd, y, error, axisLim, tit, fileName);

% %%%%%%%%%%%%%%%%%%%%%%%%Skill training results
% load skillPercentage_Halo
% resultFinal = skillPercentage;
% y = [];
% error = [];
% for idxTraining = 1:numTrainingPatch
%         tempPoissonCell = resultFinal{idxTraining}{1};
%         tempGaussianCell = resultFinal{idxTraining}{3};
%         tempGaussianSDCell = resultFinal{idxTraining}{4};
%         tempPoisson = [];
%         tempGaussian = [];
%         tempGaussianSD = [];
%         nTeam = size(tempPoissonCell, 1);
%         for idxTeam = 1:nTeam
%             tempPoisson = [tempPoisson tempPoissonCell{idxTeam, 1}.Mu + tempPoissonCell{idxTeam, 2}.Mu];
%             tempGaussian = [tempGaussian  tempGaussianCell{idxTeam, 1}.Mu + tempGaussianCell{idxTeam, 2}.Mu];
%             tempGaussianSD = [tempGaussianSD  tempGaussianSDCell{idxTeam, 1}.Mu];
%         end        
%         y = [y; [mean(tempPoisson) mean(tempGaussian) mean(tempGaussianSD)]];
%         error = [error; [std(tempPoisson)/sqrt(nTeam) std(tempGaussian)/sqrt(nTeam) std(tempGaussianSD)/sqrt(nTeam)]];
% end
% fileName = 'Skills_AFL';
% axisLim = [0.13 0.97 0 100];
% plotSkillEstimation(xInd, y, error, axisLim, tit, fileName);

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
% %%%%%%%%%%%%%%%%%%%%%%%%Skill training results
% load skillPercentageYear_UK.mat
% resultFinal = skillPercentageYear;
% [y, error] = summarizeSkillEstimation(resultFinal, numTrainingPatch, numberOfYear);
% fileName = 'Skills_AFL';
% axisLim = [0.13 0.97 0 100];
% plotSkillEstimation(xInd, y, error, axisLim, tit, fileName);
