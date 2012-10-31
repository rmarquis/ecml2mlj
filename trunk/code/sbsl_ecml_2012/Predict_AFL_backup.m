% Task 1: training on 22*8, testing on the final 9. Performance evaluated
% using log2(p)

% decide which dataset to take
dataSelection = 1;
if dataSelection == 1
    %AFL: 
    load matchOutcomeAFL;
    matchOutcome = matchOutcomeAFL;
elseif dataSelection == 2
    load matchOutcomeHalo;
    matchOutcome = matchOutcomeHalo;
elseif dataSelection == 3
    load matchOutcomeUK;
    matchOutcome = matchOutcomeUK;
end

% normalize match outcome scores
%matchOutcome(:, 3:4) = log(matchOutcome(:, 3:4));

beta = 1;
score = zeros(11, 4); % over 11 years. first (second, third) column Poisson (Logistic, Gaussian)
c = 0;
gamma = 27.5591;
a = [];
numberOfYear = 11;
for initialMu = 10:20:150
for idxYear = 1:numberOfYear
    %**************Training***************************
    rowFinder = 185*(idxYear-1)+1:185*idxYear;
    matchOutcomeYear = matchOutcome(rowFinder, :);
    matchOutcomeTraining = matchOutcomeYear(1:end-9, :); % training data;
    matchOutcomeTesting = matchOutcomeYear(end-9+1:end, :); % testing data;
    % how many teams 
    m1 = max(matchOutcomeTraining(:, 1));
    m2 = max(matchOutcomeTraining(:, 2));
    M = max(m1, m2);

    % how many matches
    N = length(matchOutcomeTraining(:, 1));

    % Initialize each team's skills, o_i, d_i, o_j, d_j.

    %initialMu = 0.1;
    initialSigma = initialMu/3;
    teamSkillsPoisson = cell(M, 2);
    teamSkillsTrueSkill = cell(M, 1);
    teamSkillsGaussian = cell(M, 2);
    teamSkillsLinearRegression = zeros(M, 2);
    teamSkillsLogisticRegression = zeros(M, 2);

    for idxTeam = 1:M
        teamSkillsPoisson{idxTeam, 1} = Gaussian(initialMu, initialSigma);  % Initialize Poisson Offence skill
        teamSkillsPoisson{idxTeam, 2} = Gaussian(initialMu, initialSigma);  % Initialize Poisson Defense skill 
        teamSkillsTrueSkill{idxTeam, 1} = Gaussian(initialMu, initialSigma);% Initialize TrueSkill team skill
        teamSkillsGaussian{idxTeam, 1} = Gaussian(initialMu, initialSigma); % Initialize Gaussian offence skill
        teamSkillsGaussian{idxTeam, 2} = Gaussian(initialMu, initialSigma); % Initialize Gaussian defence skill
    end

    % Setting data: Team 1 ID + Team 2 ID + Team 1 Score + Team 2 Score
    data = matchOutcomeTraining; % N: number of the matches
    beta = 1; % performance variance;

    % Update skills according to Poisson model-----------------------------
    for idxMatch = 1:N
        teamID_i = data(idxMatch, 1);
        teamID_j = data(idxMatch, 2);
        s_i = data(idxMatch, 3); 
        s_j = data(idxMatch, 4);     

        [o_i d_j] = updatePoisson( teamSkillsPoisson{teamID_i, 1}, teamSkillsPoisson{teamID_j, 2}, s_i, beta);
        [o_j d_i] = updatePoisson( teamSkillsPoisson{teamID_j, 1}, teamSkillsPoisson{teamID_i, 2}, s_j, beta);
        teamSkillsPoisson{teamID_i, 1} = o_i;
        teamSkillsPoisson{teamID_j, 2} = d_j;
        teamSkillsPoisson{teamID_j, 1} = o_j;
        teamSkillsPoisson{teamID_i, 2} = d_i;
    end

    % Update skills according to TrueSkill
    for idxMatch = 1:N
        teamID_i = data(idxMatch, 1);
        teamID_j = data(idxMatch, 2);
        s_i = data(idxMatch, 3); 
        s_j = data(idxMatch, 4);     
        [o_i d_j] = updateTrueSkill( teamSkillsTrueSkill{teamID_i, 1}, teamSkillsTrueSkill{teamID_j, 1}, s_i, s_j, beta);        
        teamSkillsTrueSkill{teamID_i, 1} = o_i;
        teamSkillsTrueSkill{teamID_j, 2} = d_j;        
    end
    
    % Update skills according to Simple Gaussian model-----------------------------

    for idxMatch = 1:N
        teamID_i = data(idxMatch, 1);
        teamID_j = data(idxMatch, 2);
        s_i = data(idxMatch, 3); 
        s_j = data(idxMatch, 4);   
        [o_i d_j] = updateGaussian( teamSkillsGaussian{teamID_i, 1}, teamSkillsGaussian{teamID_j, 2}, s_i, beta, gamma);
        [o_j d_i] = updateGaussian( teamSkillsGaussian{teamID_j, 1}, teamSkillsGaussian{teamID_i, 2}, s_j, beta, gamma);
        teamSkillsGaussian{teamID_i, 1} = o_i;
        teamSkillsGaussian{teamID_j, 2} = d_j;
        teamSkillsGaussian{teamID_j, 1} = o_j;
        teamSkillsGaussian{teamID_i, 2} = d_i;
    end
    
    % Update skills according to logistic regression-----------------------
    % N: Number of Match
    % M: number of team
    A = zeros(N, M);
    s = zeros(N, 1);
    flag = ones(N, 1);
    for idxMatch = 1:N
        offenceTeamID = data(idxMatch, 1);
        defenceTeamID = data(idxMatch, 2);
        A( idxMatch, offenceTeamID ) = 1;  % for offence
        A( idxMatch, defenceTeamID ) = 1; % for defence
        if data(idxMatch, 1) == data(idxMatch, 2)
            flag(idxMatch) = 0; % draw
        elseif data(idxMatch, 1) > data(idxMatch, 2)
            s(idxMatch) = 1; % teamI wins
        else
            s(idxMatch) = 0; % teamI loses
        end       
    end

    % Remove draw matches
    pos = find(flag == 0);
    A(pos,:) = [];
    s(pos) = [];

    [z, dev ]= glmfit(A, [s ones(length(s), 1)], 'binomial', 'link', 'logit');        
%     
%     
    %**************Testing***************************
    % compute the prob of Team I wins
    numMatch = size(matchOutcomeTesting, 1);
    scorePoisson  = zeros( numMatch, 1 );
    scoreGaussian = zeros( numMatch, 1);
    scoreLogistic = zeros( numMatch, 1 );
    scoreTrueSkill = zeros( numMatch, 1);
    temp = [];
    for idxTestData = 1:numMatch
        % winProb of Team I predicting by Poisson
        teamID_i = matchOutcomeTesting(idxTestData, 1);
        teamID_j = matchOutcomeTesting(idxTestData, 2);
        lambdaI = exp( (teamSkillsPoisson{teamID_i, 1}.Mu - teamSkillsPoisson{teamID_j, 2}.Mu) + ...
                    c*sqrt( teamSkillsPoisson{teamID_i, 1}.Variance +  teamSkillsPoisson{teamID_j, 2}.Variance+beta^2) );
        lambdaJ = exp( (teamSkillsPoisson{teamID_j, 1}.Mu - teamSkillsPoisson{teamID_i, 2}.Mu) + ...
                    c*sqrt( teamSkillsPoisson{teamID_j, 1}.Variance +  teamSkillsPoisson{teamID_i, 2}.Variance+beta^2) );
        % s = s_i - s_j is a Skellam distribution if $s_i$ ($s_j$) is a Poission
        % with lambdaI (lambdaJ).        
        pPoisson = 0;
        for tempCounter = 1:500 % approximation to calculate the winProb. Lower bound
            pPoisson = pPoisson + ...
                exp(-(lambdaI+lambdaJ))*(lambdaI/lambdaJ)^(tempCounter/2)*besseli(tempCounter, 2*sqrt(lambdaI*lambdaJ));
        end
        
        % winProb of Team I predicted by TrueSkill
        tempMu = teamSkillsTrueSkill{teamID_i, 1}.Mu - teamSkillsTrueSkill{teamID_j, 1}.Mu;
        tempVariance = teamSkillsTrueSkill{teamID_i, 1}.Variance + teamSkillsTrueSkill{teamID_j, 1}.Variance + 2*beta^2;
        pTrueSkill = 1 - normcdf(0, tempMu, sqrt(tempVariance));
        
        % winProb of Team I predicting by Gaussian
        mu1 = (teamSkillsGaussian{teamID_i, 1}.Mu - teamSkillsGaussian{teamID_j, 2}.Mu) + ...
                    c*sqrt( teamSkillsGaussian{teamID_i, 1}.Variance +  teamSkillsGaussian{teamID_j, 2}.Variance+beta^2);
        mu2 = (teamSkillsGaussian{teamID_j, 1}.Mu - teamSkillsGaussian{teamID_i, 2}.Mu) + ...
                    c*sqrt( teamSkillsGaussian{teamID_j, 1}.Variance +  teamSkillsGaussian{teamID_i, 2}.Variance+beta^2);
        pGaussian = 1 - normcdf(0, mu1-mu2, sqrt(2*gamma^2));
        
        % winProb of Team I predicting by Logistic
        rowData = zeros(1, M+1);
        rowData(1) = 1;
        rowData( matchOutcomeTesting( idxTestData, 1) ) = 1; 
        rowData( matchOutcomeTesting( idxTestData, 2) ) = 1; 
        pLogistic= Logistic(rowData*z); 
        
        % compute the score of win probability
        if matchOutcomeTesting(idxTestData, 3) > matchOutcomeTesting(idxTestData, 4)      % Team I wins
            scorePoisson(idxTestData) = 1+log2( pPoisson );
            scoreLogistic(idxTestData)= 1+log2( pLogistic );
            scoreGaussian(idxTestData)= 1+log2( pGaussian );
            scoreTrueSkill(idxTestData)= 1+log2( pTrueSkill );
        elseif matchOutcomeTesting(idxTestData, 3) == matchOutcomeTesting(idxTestData, 4) % draws
            scorePoisson(idxTestData) = 1+1/2*log2( pPoisson*(1-pPoisson)   );
            scoreLogistic(idxTestData)= 1+1/2*log2( pLogistic*(1-pLogistic) );
            scoreGaussian(idxTestData)= 1+1/2*log2( pGaussian*(1-pGaussian) );
            scoreTrueSkill(idxTestData)= 1+1/2*log2( pTrueSkill*(1-pTrueSkill) );
        else                                                                              % Team J wins
            scorePoisson(idxTestData) = 1+log2( 1 - pPoisson );
            scoreLogistic(idxTestData)= 1+log2( 1 - pLogistic);
            scoreGaussian(idxTestData) = 1+log2(1 - pGaussian);
            scoreTrueSkill(idxTestData) = 1+log2(1 - pTrueSkill);
        end        
    end    
    score(idxYear, 1) = sum(scorePoisson);
    score(idxYear, 2) = sum(scoreLogistic);
    score(idxYear, 3) = sum(scoreGaussian);
    score(idxYear, 4) = sum(scoreTrueSkill);
end
mmmm = mean(score)
ssss = std(score)./sqrt(numberOfYear);
a = [a; mmmm ssss];
end
