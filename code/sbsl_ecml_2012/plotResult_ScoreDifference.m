%organized data;
numTrainingPatch = 9;
withLogistic = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AFL
load resultFinal_AFL
numberOfYear = 11;
resultFinal = resultFinal_AFL;
tit = 'AFL';
%%%%%%%%%%%%%%%%%%%%%%%%%%%Average information gain
[y, error] = summarizeInformationGain(resultFinal, numTrainingPatch, numberOfYear);
xInd = 0.1:0.1:0.9;
axisLim = [0.08 0.92 -0.9 0.2];
fileName = 'InforGain_AFL';
plotInformationGain(xInd, y, error, axisLim, tit, fileName, withLogistic);

%%%%%%%%%%%%%%%%%%%%%%%%%%Predict accuracy
load resultFinalWLD_AFL;
resultFinal = resultFinalWLD_AFL;
[y, error]=summarizeWLAccuracy(resultFinal, numTrainingPatch, numberOfYear);
axisLim = [0.08 0.92 0.45 0.71];
fileName = 'WLAccuracy_AFL';
plotWLAccuracy(xInd, y, error, axisLim, tit, fileName, withLogistic);
%%%%%%%%%%%%%%%%%%%%%%%%%%Score Accuracy
load scoreAccuracyPercentageYear_AFL; 
resultFinal = scoreAccuracyPercentageYear;
xMean = [];
y = [];
error = [];
for idxTraining = 1:9
    for idxYear = 1:numberOfYear
        xMean = [xMean; resultFinal{idxTraining, idxYear}(1,:)];
    end
    y = [y; mean(xMean)];
    error = [error; std(xMean)/sqrt(numberOfYear)];
    xMean = [];
end
axisLim = [0.08 0.92 0.85 2.5];
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%Average information gain
y = [];
error = [];
for idxTraining = 1:9
    y = [y; resultFinal{idxTraining}(1,:)];
    error = [error; resultFinal{idxTraining}(2,:)];
end
xInd = 0.19:0.1:0.99;
axisLim = [0.17 1.01 -0.05 0.275];
tit = 'Halo';
fileName = 'InforGain_Halo';
plotInformationGain(xInd, y, error, axisLim, tit, fileName, withLogistic);
%%%%%%%%%%%%%%%%%%%%%%%%%%%Predict accuracy
load resultFinalWLD_Halo;
resultFinal = resultFinalWLD_Halo;
y = [];
error = [];
for idxTraining = 1:9
    temp = (resultFinal{idxTraining}(1,:)+resultFinal{idxTraining}(2,:))/(resultFinal{idxTraining}(1, 1)+resultFinal{idxTraining}(2, 1));
    temp(:,1:2) = [];
    y = [y; temp];
    error = [error; zeros(1,5)];
end
%%%
axisLim = [0.17 1.01 0.45 3];
tit = 'Halo';
fileName = 'WLAccuracy_Halo';
plotWLAccuracy(xInd, y, error, axisLim, tit, fileName, withLogistic);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Score Accuracy
load scoreAccuracyPercentage_Halo; 
resultFinal = scoreAccuracyPercentage;
y = [];
error = [];
for idxTraining = 1:9
    y = [y; resultFinal{idxTraining}(1,:)];
    error = [error; resultFinal{idxTraining}(2,:)];
end
axisLim = [0.17 1.01 0.75 1.2];
fileName = 'ScoreError_Halo';
plotScoreError(xInd, y, error, axisLim, tit, fileName);

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
load resultFinal_UK
numberOfYear = 14;
resultFinal = resultFinal_UK;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Average information gain
[y, error] = summarizeInformationGain(resultFinal, numTrainingPatch, numberOfYear);
xInd = 0.15:0.1:0.95;
axisLim = [0.13 0.97 -3.5 0.2];
tit = 'UK-PL';
fileName = 'InforGain_UK';
plotInformationGain(xInd, y, error, axisLim, tit, fileName, withLogistic);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Predict accuracy
load resultFinalWLD_UK;
resultFinal = resultFinalWLD_UK;
[y, error]=summarizeWLAccuracy(resultFinal, numTrainingPatch, numberOfYear);
axisLim = [0.13 0.97 0.45 0.7];
fileName = 'WLAccuracy_UK';
plotWLAccuracy(xInd, y, error, axisLim, tit, fileName, withLogistic);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Score Accuracy
load scoreAccuracyPercentageYear_UK; 
resultFinal = scoreAccuracyPercentageYear;
xMean = [];
xStd = [];
y = [];
error = [];
for idxTraining = 1:9
    for idxYear = 1:numberOfYear
        xMean = [xMean; resultFinal{idxTraining, idxYear}(1,:)];
    end
    y = [y; mean(xMean)];
    error = [error; std(xMean)/sqrt(numberOfYear)];
    xMean = [];
end
axisLim = [0.13 0.97 0.75 2.75];
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
