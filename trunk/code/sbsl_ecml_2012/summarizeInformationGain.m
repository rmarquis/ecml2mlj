function [y, error] = summarizeInformationGain(resultFinal, numTrainingPatch, numberOfYear)
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
end