% decide which dataset to take -- UK PK
dataSelection = 3;
testPercentage = 0.2;

% choose how many data points for testing        
if dataSelection == 1
    % load approprate data
    load matchOutcomeAFL;
    matchOutcome = matchOutcomeAFL;
    numberOfMatchEachYear = 185;
    numberOfYear = 11;
elseif dataSelection == 2
    load matchOutcomeHalo;
elseif dataSelection == 3
    load matchOutcomeUK;
    matchOutcome = matchOutcomeUK;
    numberOfMatchEachYear = 380;
    numberOfYear = 14;
end
trainingPercentageVar       = 0.1:0.1:0.8;
resultFinal_UK              = cell( length(trainingPercentageVar), numberOfYear);
resultFinalWLD_UK           = cell( length(trainingPercentageVar), numberOfYear);
skillPercentageYear         = cell( length(trainingPercentageVar), numberOfYear);
scoreAccuracyPercentageYear = cell( length(trainingPercentageVar), numberOfYear);
resultFinalPredictWin_UK = cell( length(trainingPercentageVar), numberOfYear);

idxTraining = 0;
for trainingPercentage = trainingPercentageVar
    % decide which dataset to take
    idxTraining = idxTraining+1;
    skillYear = cell(1, 5);
    for idxYear = 1:numberOfYear;
        tempMatchOutcome = matchOutcome;
        rowFinder = numberOfMatchEachYear*(idxYear-1)+1:numberOfMatchEachYear*idxYear;
        matchOutcomeYear = matchOutcome(rowFinder, :);
        matchOutcome = matchOutcomeYear;
        % compute appropriate parameters
        [tempInfoGain tempWLD tempSkill tempScoreAccuracy temppredictedWinResult] = computeThreeMeasure_AllScoreDifference(matchOutcome, trainingPercentage, testPercentage, 0);  % the last parameter 0 indicating the data set is not Halo
        resultFinal_UK{idxTraining, idxYear} = tempInfoGain;
        resultFinalWLD_UK{idxTraining, idxYear} = tempWLD;
        skillPercentageYear{idxTraining, idxYear} = tempSkill;
        scoreAccuracyPercentageYear{idxTraining, idxYear} = tempScoreAccuracy;
        resultFinalPredictWin_UK{idxTraining, idxYear} = temppredictedWinResult;
        matchOutcome = tempMatchOutcome;
    end
end
save resultFinal_UK.mat resultFinal_UK
save resultFinalWLD_UK.mat resultFinalWLD_UK
save skillPercentageYear_UK.mat skillPercentageYear;
save scoreAccuracyPercentageYear_UK.mat scoreAccuracyPercentageYear;
save resultFinalPredictWin_UK.mat resultFinalPredictWin_UK;