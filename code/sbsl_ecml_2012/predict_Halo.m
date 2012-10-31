% Halo 2;
% updated on 5 September 2011 to rerun the experiments for getting error
% bars using 30 randomly drawn training samples. 
load matchOutcomeHalo;  
[numMatch junk] = size(matchOutcome); 

testPercentage = 0.1;
trainingPercentageVar       = 0.1:0.1:0.8;
numberOfYear = 30;
resultFinal_Halo            = cell(length(trainingPercentageVar), numberOfYear);
resultFinalWLD_Halo         = cell(length(trainingPercentageVar), numberOfYear);
skillPercentage             = cell(length(trainingPercentageVar), numberOfYear);
scoreAccuracyPercentage     = cell(length(trainingPercentageVar), numberOfYear);
resultFinalPredictWin_Halo  = cell(length(trainingPercentageVar), numberOfYear);
idxTraining = 0;
for trainingPercentage = trainingPercentageVar
    % decide which dataset to take
    idxTraining = idxTraining+1;
    tic
    for idxYear = 1:30
        fprintf('training Percentage = %d; idxYear = %d \n', idxTraining, idxYear);
        % choose how many data points for testing
        % compute appropriate parameters
        [tempInfoGain tempWLD tempSkill tempScoreAccuracy temppredictedWinResult] = computeThreeMeasure_AllScoreDifference(matchOutcome, trainingPercentage, testPercentage, 1);
        resultFinal_Halo{idxTraining, idxYear} = tempInfoGain;
        resultFinalWLD_Halo{idxTraining, idxYear} = tempWLD;
        skillPercentage{idxTraining, idxYear} = tempSkill;
        scoreAccuracyPercentage{idxTraining, idxYear} = tempScoreAccuracy;
        resultFinalPredictWin_Halo{idxTraining, idxYear} = temppredictedWinResult;
    end
end
save resultFinal_Halo.mat resultFinal_Halo
save resultFinalWLD_Halo.mat resultFinalWLD_Halo
save skillPercentage_Halo.mat skillPercentage
save scoreAccuracyPercentage_Halo.mat scoreAccuracyPercentage
save resultFinalPredictWin_Halo.mat resultFinalPredictWin_Halo;