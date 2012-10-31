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
score = zeros(11, 3); % over 11 years. first (second, third) column Poisson (Logistic, Gaussian)
c = 0;
gamma = 4.7;
initialMu = 1.4;
numberTest = 18;
for idxYear = 1:11
    %**************Training***************************
    rowFinder = 185*(idxYear-1)+1:185*idxYear;
    matchOutcomeYear = matchOutcome(rowFinder, :);
    matchOutcomeTraining = matchOutcomeYear(1:end-numberTest, :); % training data;
    matchOutcomeTesting = matchOutcomeYear(end-numberTest+1:end, :); % testing data;
    % how many teams 
    m1 = max(matchOutcomeTraining(:, 1));
    m2 = max(matchOutcomeTraining(:, 2));
    M = max(m1, m2);

    % how many matches
    N = length(matchOutcomeTraining(:, 1));

    % Initialize each team's skills, o_i, d_i, o_j, d_j.
    initialSigma = initialMu/3;
    teamSkillsPoisson = cell(M, 2);

    for idxTeam = 1:M
        teamSkillsPoisson{idxTeam, 1} = Gaussian(initialMu, initialSigma);  % Initialize Poisson Offence skill
        teamSkillsPoisson{idxTeam, 2} = Gaussian(initialMu, initialSigma);  % Initialize Poisson Defense skill         
    end

    % Setting data: Team 1 ID + Team 2 ID + Team 1 Score + Team 2 Score
    data = matchOutcomeTraining; % N: number of the matches
    %beta = 1; % performance variance;

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
    plot_Poisson
    %**************Testing***************************
    % compute the prob of Team I wins
    numMatch = size(matchOutcomeTesting, 1);
    scorePoisson  = zeros( numMatch, 1 );
    scoreGaussian = zeros( numMatch, 1);
    scoreLogistic = zeros( numMatch, 1 );
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
        for tempCounter = 1:1:1000 % approximation to calculate the winProb. Lower bound
            pPoisson = pPoisson + ...
                exp(-(lambdaI+lambdaJ))*(lambdaI/lambdaJ)^(tempCounter/2)*besseli(tempCounter, 2*sqrt(lambdaI*lambdaJ));
        end
        temp = [temp; pPoisson];
        % compute the score of win probability
        if matchOutcomeTesting(idxTestData, 3) > matchOutcomeTesting(idxTestData, 4)      % Team I wins
            scorePoisson(idxTestData) = 1+log2( pPoisson );
        elseif matchOutcomeTesting(idxTestData, 3) == matchOutcomeTesting(idxTestData, 4) % draws
            scorePoisson(idxTestData) = 1+1/2*log2( pPoisson*(1-pPoisson)   );
        else                                                                              % Team J wins
            scorePoisson(idxTestData) = 1+log2( 1 - pPoisson );
        end        
    end
    score(idxYear, 1) = sum(scorePoisson);
end
mean(score)
std(score)./sqrt(11)



































