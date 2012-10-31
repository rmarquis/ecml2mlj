function [y, error]=summarizeWinPredictionAccuracy(resultFinal)
    numTrainingBatch = size(resultFinal, 1);
    numYear          = size(resultFinal, 2);
    nModel = length(resultFinal{1, 1});
    y = zeros(numTrainingBatch, nModel); 
    error = zeros(numTrainingBatch, nModel); 
    for i = 1:numTrainingBatch
        temp = [];
        for j = 1:numYear
            temp = [temp; resultFinal{i, j}];
        end
        y(i, :) = mean(temp);
        error(i, :) = std(temp)/sqrt(numYear);
    end
end

%    temp = (resultFinal{idxTraining}(1,:)+resultFinal{idxTraining}(2,:))/(resultFinal{idxTraining}(1, 1)+resultFinal{idxTraining}(2, 1));
