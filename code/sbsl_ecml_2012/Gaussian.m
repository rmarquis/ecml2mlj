classdef Gaussian
    %GAUSSIAN: A Gaussian Distribution based on float numbers in
    %exponential parameterisation
    
    properties
        PrecisionMean;                       % Precision times the mean of the Gaussian
        Precision;                           % Precision of the Gaussian
        Mu;                                  % Mean of the Gaussian: Mu = PrecisionMean / Precision;
        Mean;                                % Mean of the Gaussian: Mean = Mu;
        Variance;                            % Variance of the Gaussian: Variance = 1.0 / Precision;
        StandardDeviation;                   % Standard deviation of the Gaussian: StandardDeviation = sqrt ( Variance);
        Sigma;                               % Standard deviation of the Gaussian
    end
    
    methods
        function obj = Gaussian(mu, sigma)                % Create a Gaussian in (mean, standard-deviation) coordinates
            if nargin > 0 
                obj.PrecisionMean = mu / sigma^2;
                obj.Precision     = 1 / sigma^2;
                obj.Mu = mu;  % Mean of the Gaussian: Mu = PrecisionMean / Precision;
                obj.Mean = mu;                           % Mean of the Gaussian: Mean = Mu;
                obj.Variance = sigma^2;            % Variance of the Gaussian: Variance = 1.0 / Precision;
                obj.StandardDeviation = sigma; % Standard deviation of the Gaussian
                obj.Sigma = sigma;           % Standard deviation of the Gaussian
            end
        end
        function obj = mtimes(obj1, obj2)                 % Multiplies two Gaussians: Overloading operator (*) 
            precisionMean = obj1.PrecisionMean + obj2.PrecisionMean;
            precision     = obj1.Precision     + obj2.Precision;
            mu = precisionMean / precision;       % Mean of the Gaussian
            variance = 1 / precision;             % Variance of the Gaussian
            standardDeviation = sqrt (variance);  % Standard deviation of the Gaussian
            sigma = standardDeviation;            % Standard deviation of the Gaussian
            obj = Gaussian(mu, sigma);
        end
        function obj = mrdivide(obj1, obj2)               % Divide two Gaussians: Overloading operator (/)
            precisionMean = obj1.PrecisionMean - obj2.PrecisionMean;
            temp = obj1.Precision - obj2.Precision;
%             if temp < 0 
%                 disp('Warning: Negative Variance by Dividing Two Gaussian!');
%             end
            precision = temp;                         % May cause Precision < 0
            mu = precisionMean / precision;   % Mean of the Gaussian
            variance = 1 / precision;           % Variance of the Gaussian
            standardDeviation = sqrt ( variance );  % Standard deviation of the Gaussian
            sigma = standardDeviation;            % Standard deviation of the Gaussian
            obj = Gaussian(mu, sigma);
            if obj1.PrecisionMean == 0 && obj.Precision == 0 && obj2.PrecisionMean == 0 && obj2.Precision == 0
                obj.PrecisionMean = 0; 
            end
        end 
        function ADifference = AbsoluteDifference(obj1, obj2)     % Compute the absolute difference between two Gaussians for checking convergence
            tempMeanDiff      = abs(obj1.PrecisionMean - obj2.PrecisionMean);
            tempPrecisionDiff = sqrt( abs( obj1.Precision - obj2.Precision ) );
            ADifference = max  (tempMeanDiff, tempPrecisionDiff );
        end        
        function ADifferenceFloat = minus ( obj1, obj2 )    % Compute the absolute difference between two Gaussians
            ADifferenceFloat = AbsoluteDifference( obj1, obj2 );
        end            
        function LPN = LogProductNormalisation (obj1, obj2)  % Computes the log-normalization factor when two normalised Gaussians gets multiplied
            if obj1.Precision == 0
                LPN = 0;
            elseif obj2.Precision == 0 
                LPN = 0;
            else
                varSum = obj1.Variance + obj2.Variance;
                muDiff = obj1.Mean     - obj2.Mean;
                LPN    = -0.91893853320467267 - log(varSum)/2.0 - muDiff*muDiff/(2.0 * varSum);
            end
        end
        function LRN = LogRatioNormalisation (obj1, obj2) % Computes the log-normalization factor when two normalised Gaussians gets divided
            if obj1.Precision == 0
                LRN = 0;
            elseif obj2.Precision == 0
                LRN = 0;
            else
                v2 = obj2.Variance;
                varDiff = v2 - obj1.Variance;
                muDiff = obj1.Mean - obj2.Mean;
                if varDiff == 0
                    LRN = 0;
                else
                    LRN = log(v2) + 0.91893853320467267 - log(varDiff)/2.0 + muDiff*muDiff/(2.0 * varDiff);
                end
            end
        end
    end
    
end

