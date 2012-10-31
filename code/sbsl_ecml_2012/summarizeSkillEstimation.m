function [y, error] = summarizeSkillEstimation(resultFinal, numTrainingPatch, numberOfYear)
xMean = [];
y = [];
error = [];
for idxTraining = 1:numTrainingPatch
    for idxYear = 1:numberOfYear
        tempPoissonCell = resultFinal{idxTraining, idxYear}{1};
        tempGaussianCell = resultFinal{idxTraining, idxYear}{3};
        tempGaussianSDCell = resultFinal{idxTraining, idxYear}{4};
        tempPoisson = 0;
        tempGaussian = 0;
        tempGaussianSD = 0;
        nTeam = size(tempPoissonCell, 1);
        for idxTeam = 1:nTeam
            tempPoisson = tempPoisson + tempPoissonCell{idxTeam, 1}.Mu + tempPoissonCell{idxTeam, 2}.Mu;
            tempGaussian = tempGaussian + tempGaussianCell{idxTeam, 1}.Mu + tempGaussianCell{idxTeam, 2}.Mu;
            tempGaussianSD = tempGaussianSD + tempGaussianSDCell{idxTeam, 1}.Mu;
        end
        xMean = [xMean; [tempPoisson/nTeam tempGaussian/nTeam tempGaussianSD/nTeam]];
    end
    y = [y; mean(xMean)];
    error = [error; std(xMean)/sqrt(numberOfYear)];
end
end