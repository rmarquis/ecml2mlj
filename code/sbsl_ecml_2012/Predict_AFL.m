% Task 1: training on 22*8, testing on the final 9. Performance evaluated
% using log2(p)

testPercentage = 0.2;
dataSelection = 1;
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
flagHalo = 0; 
trainingPercentageVar = 0.1:0.1:0.8;
resultFinal_AFL = cell( length(trainingPercentageVar), numberOfYear);
resultFinalWLD_AFL = cell( length(trainingPercentageVar), numberOfYear);
skillPercentageYear = cell( length(trainingPercentageVar), numberOfYear);
scoreAccuracyPercentageYear = cell( length(trainingPercentageVar), numberOfYear);
resultFinalPredictWin_AFL = cell( length(trainingPercentageVar), numberOfYear);
idxTraining = 0;
for trainingPercentage = trainingPercentageVar
    fprintf(fid, 'trainingPercentage %f\n', trainingPercentage);
    idxTraining = idxTraining+1;    
    for idxYear = 1:numberOfYear;
        fprintf(fid, 'idx year: %d\n', numberOfYear - idxYear);
        rowFinder = numberOfMatchEachYear*(idxYear-1)+1:numberOfMatchEachYear*idxYear;
        tempMatchOutcome = matchOutcome;
        matchOutcomeYear = matchOutcome(rowFinder, :);
        matchOutcome = matchOutcomeYear;
        % compute appropriate parameters
        [tempInfoGain tempWLD tempSkill tempScoreAccuracy temppredictedWinResult] = computeThreeMeasure_AllScoreDifference_PoissonSampling(matchOutcome, trainingPercentage, testPercentage, flagHalo); % the last parameter 0 indicating the data set is not Halo
        resultFinal_AFL{idxTraining, idxYear} = tempInfoGain;
        resultFinalWLD_AFL{idxTraining, idxYear} = tempWLD;
        skillPercentageYear{idxTraining, idxYear} = tempSkill;
        scoreAccuracyPercentageYear{idxTraining, idxYear} = tempScoreAccuracy;
        resultFinalPredictWin_AFL{idxTraining, idxYear} = temppredictedWinResult;
        matchOutcome = tempMatchOutcome;
    end
end
save resultFinal_AFL.mat resultFinal_AFL;
save resultFinalWLD_AFL.mat resultFinalWLD_AFL;
save resultPercentageYear_AFL.mat skillPercentageYear;
save scoreAccuracyPercentageYear_AFL.mat scoreAccuracyPercentageYear;
save resultPredictWin_AFL.mat resultFinalPredictWin_AFL;