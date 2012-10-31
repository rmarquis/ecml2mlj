%organized data;
numTrainingPatch = 9;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AFL
load resultFinal_AFL
numberOfYear = 11;
resultFinal = resultFinal_AFL;
tit = 'AFL';
%%%%%%%%%%%%%%%%%%%%%%%%%%%Average information gain
[y, error] = summarizeInformationGain(resultFinal, numTrainingPatch, numberOfYear);
xInd = 0.1:0.1:0.9;
axisLim = [0.08 0.92 -0.15 0.1];
fileName = 'InforGain_AFL';
plotInformationGain(xInd, y, error, axisLim, tit, fileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%Predict accuracy
load resultFinalWLD_AFL;
resultFinal = resultFinalWLD_AFL;
[y, error]=summarizeWLAccuracy(resultFinal, numTrainingPatch, numberOfYear);
axisLim = [0.08 0.92 0.1 0.7];
fileName = 'WLAccuracy_AFL';
plotWLAccuracy(xInd, y, error, axisLim, tit, fileName);
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
end
axisLim = [0.08 0.92 0.25 1.05];
fileName = 'ScoreError_AFL';
plotScoreError(xInd, y, error, axisLim, tit, fileName);

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
axisLim = [0.17 1.01 -2 0.3];
tit = 'Halo';
fileName = 'InforGain_Halo';
plotInformationGain(xInd, y, error, axisLim, tit, fileName);
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
axisLim = [0.17 1.01 0.1 1.02];
tit = 'Halo';
fileName = 'WLAccuracy_Halo';
plotWLAccuracy(xInd, y, error, axisLim, tit, fileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Score Accuracy
load scoreAccuracyPercentage_Halo; 
resultFinal = scoreAccuracyPercentage;
y = [];
error = [];
for idxTraining = 1:9
    y = [y; resultFinal{idxTraining}(1,:)];
    error = [error; resultFinal{idxTraining}(2,:)];
end
axisLim = [0.17 1.01 0 4.8];
fileName = 'ScoreError_Halo';
plotScoreError(xInd, y, error, axisLim, tit, fileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  UK-PL
load resultFinal_UK
numberOfYear = 14;
resultFinal = resultFinal_UK;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Average information gain
[y, error] = summarizeInformationGain(resultFinal, numTrainingPatch, numberOfYear);
xInd = 0.15:0.1:0.95;
axisLim = [0.13 0.97 -9 0.2];
tit = 'UK-PL';
fileName = 'InforGain_UK';
plotInformationGain(xInd, y, error, axisLim, tit, fileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Predict accuracy
load resultFinalWLD_UK;
resultFinal = resultFinalWLD_UK;
[y, error]=summarizeWLAccuracy(resultFinal, numTrainingPatch, numberOfYear);
axisLim = [0.13 0.97 0 0.7];
fileName = 'WLAccuracy_UK';
plotWLAccuracy(xInd, y, error, axisLim, tit, fileName);

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
end
axisLim = [0.13 0.97 0.4 1.55];
fileName = 'ScoreError_UK';
plotScoreError(xInd, y, error, axisLim, tit, fileName);

