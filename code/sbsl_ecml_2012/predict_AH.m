function predict_AH(dataSelection)

% dataselection = 1, 2, or 3
% example: demo_predict(1); % predict on AFL for 20% testing data

if dataSelection == 1
    % load approprate data
    load matchOutcomeAFL_AH;
    matchOutcome = matchOutcomeAFL_AH(:, 1:end-2);
    matchAHIndicator = matchOutcomeAFL_AH(:, end-1:end);
    numberOfMatchEachYear = 185;
    numberOfYear = 11;
    testPercentage = 0.2;
    trainingPercentageVar = 0.1:0.1:0.8;
    flagHalo = 0;
    flagAFL = 1; 
elseif dataSelection == 2
    load matchOutcomeHalo;
    testPercentage = 0.1;
    trainingPercentageVar       = 0.1:0.1:0.8;
    numberOfYear = 30;
    flagHalo = 1;
    flagAFL = 0; 
elseif dataSelection == 3
    load matchOutcomeUK;
    matchOutcome = matchOutcomeUK;
    matchAHIndicator = ones( size(matchOutcome, 1), 2);
    matchAHIndicator(:, 2) = zeros( size(matchOutcome, 1), 1 );
    numberOfMatchEachYear = 380;
    numberOfYear = 14;
    testPercentage = 0.2;
    trainingPercentageVar = 0.1:0.1:0.8;
    flagHalo = 0;     
end

%% AFL or UK
if dataSelection == 1 || dataSelection == 3
    resultFinal = cell( length(trainingPercentageVar), numberOfYear);
    resultFinalWLD = cell( length(trainingPercentageVar), numberOfYear);
    skillPercentageYear = cell( length(trainingPercentageVar), numberOfYear);
    scoreAccuracyPercentageYear = cell( length(trainingPercentageVar), numberOfYear);
    resultFinalPredictWin = cell( length(trainingPercentageVar), numberOfYear);
    idxTraining = 0;
    for trainingPercentage = trainingPercentageVar        
        idxTraining = idxTraining+1;        
        for idxYear = 1:numberOfYear;
            fprintf('training Percentage = %d; idxYear = %d \n', idxTraining, idxYear);
            rowFinder = numberOfMatchEachYear*(idxYear-1)+1:numberOfMatchEachYear*idxYear;
            tempMatchOutcome = matchOutcome;
            matchOutcomeYear = matchOutcome(rowFinder, :);
            matchOutcome = matchOutcomeYear;
            
            [tempInfoGain tempWLD tempSkill tempScoreAccuracy temppredictedWinResult] = computeThreeMeasure_AllScoreDifference_AH(matchOutcome, trainingPercentage, testPercentage, matchAHIndicator, flagHalo);
            
            resultFinal{idxTraining, idxYear} = tempInfoGain;
            resultFinalWLD{idxTraining, idxYear} = tempWLD;
            skillPercentageYear{idxTraining, idxYear} = tempSkill;
            scoreAccuracyPercentageYear{idxTraining, idxYear} = tempScoreAccuracy;
            resultFinalPredictWin{idxTraining, idxYear} = temppredictedWinResult;
            matchOutcome = tempMatchOutcome;
        end
    end
    
end

%% Halo
if dataSelection == 2
    resultFinal_Halo            = cell(length(trainingPercentageVar), numberOfYear);
    resultFinalWLD_Halo         = cell(length(trainingPercentageVar), numberOfYear);
    skillPercentage             = cell(length(trainingPercentageVar), numberOfYear);
    scoreAccuracyPercentage     = cell(length(trainingPercentageVar), numberOfYear);
    resultFinalPredictWin_Halo  = cell(length(trainingPercentageVar), numberOfYear);
    idxTraining = 0;
    for trainingPercentage = trainingPercentageVar
        idxTraining = idxTraining+1;
        for idxYear = 1:30
            fprintf('training Percentage = %d; idxYear = %d \n', idxTraining, idxYear);
            [tempInfoGain tempWLD tempSkill tempScoreAccuracy temppredictedWinResult] = computeThreeMeasure_AllScoreDifference_PoissonSampling(matchOutcome, trainingPercentage, testPercentage, flagHalo); % the last parameter 0 indicating the data set is not Halo
            resultFinal_Halo{idxTraining, idxYear} = tempInfoGain;
            resultFinalWLD_Halo{idxTraining, idxYear} = tempWLD;
            skillPercentage{idxTraining, idxYear} = tempSkill;
            scoreAccuracyPercentage{idxTraining, idxYear} = tempScoreAccuracy;
            resultFinalPredictWin_Halo{idxTraining, idxYear} = temppredictedWinResult;
        end
    end
end

%% save results
if dataSelection == 1
    resultFinal_AFL = resultFinal;
    resultFinalWLD_AFL = resultFinalWLD;
    save resultFinal_AFL_AH.mat resultFinal_AFL;
    save resultFinalWLD_AFL_AH.mat resultFinalWLD_AFL;
    
    save resultPercentageYear_AFL_AH.mat skillPercentageYear;
    save scoreAccuracyPercentageYear_AFL_AH.mat scoreAccuracyPercentageYear;
    
    resultFinalPredictWin_AFL = resultFinalPredictWin;
    save resultPredictWin_AFL_AH.mat resultFinalPredictWin_AFL;
elseif dataSelection == 2
    save resultFinal_Halo_AH.mat resultFinal_Halo;
    save resultFinalWLD_Halo_AH.mat resultFinalWLD_Halo;
    save skillPercentage_Halo_AH.mat skillPercentage;
    save scoreAccuracyPercentage_Halo_AH.mat scoreAccuracyPercentage;
    save resultFinalPredictWin_Halo_AH.mat resultFinalPredictWin_Halo;
elseif dataSelection == 3
    resultFinal_UK = resultFinal;
    resultFinalWLD_UK = resultFinalWLD;
    save resultFinal_UK_AH.mat resultFinal_UK
    save resultFinalWLD_UK_AH.mat resultFinalWLD_UK
    
    save skillPercentageYear_UK_AH.mat skillPercentageYear;
    save scoreAccuracyPercentageYear_UK_AH.mat scoreAccuracyPercentageYear;
    
    resultFinalPredictWin_UK = resultFinalPredictWin;
    save resultFinalPredictWin_UK_AH.mat resultFinalPredictWin_UK;
end

end