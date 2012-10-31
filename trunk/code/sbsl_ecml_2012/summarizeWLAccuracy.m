function [y, error]=summarizeWLAccuracy(resultFinal, numTrainingPatch, numberOfYear)
    xMean = [];
    y = [];
    error = [];
    for idxTraining = 1:numTrainingPatch
        for idxYear = 1:numberOfYear
            temp = mean ( [ resultFinal{idxTraining, idxYear}(1,:) / resultFinal{idxTraining, idxYear}(1,1)
			    resultFinal{idxTraining, idxYear}(2,:) / resultFinal{idxTraining, idxYear}(2,1)  ] );  
            temp(:,1:2) = [];        
            xMean = [xMean; temp];
        end
        y = [y; mean(xMean)];
        error = [error; std(xMean)/sqrt(numberOfYear)];
        xMean = [];
    end
end

%    temp = (resultFinal{idxTraining}(1,:)+resultFinal{idxTraining}(2,:))/(resultFinal{idxTraining}(1, 1)+resultFinal{idxTraining}(2, 1));
