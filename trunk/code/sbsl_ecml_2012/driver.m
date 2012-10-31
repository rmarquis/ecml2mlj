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

% how many teams 
m1 = max(matchOutcome(:, 1));
m2 = max(matchOutcome(:, 2));
M = max(m1, m2);

% how many matches
N = length(matchOutcome(:, 1));

% Initialize each team's skills, o_i, d_i, o_j, d_j.

initialMu = 25;
initialSigma = 25/3;
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
data = matchOutcome; % N: number of the matches
beta = 1; % performance variance;

% % Update skills according to Poisson model---------------------------------
% for idxMatch = 1:N
%     teamID_i = data(idxMatch, 1);
%     teamID_j = data(idxMatch, 2);
%     s_i = data(idxMatch, 3); 
%     s_j = data(idxMatch, 4);     
% 
%     [o_i d_j] = updatePoisson( teamSkillsPoisson{teamID_i, 1}, teamSkillsPoisson{teamID_j, 2}, s_i, beta);
%     [o_j d_i] = updatePoisson( teamSkillsPoisson{teamID_j, 1}, teamSkillsPoisson{teamID_i, 2}, s_j, beta);
%     teamSkillsPoisson{teamID_i, 1} = o_i;
%     teamSkillsPoisson{teamID_j, 2} = d_j;
%     teamSkillsPoisson{teamID_j, 1} = o_j;
%     teamSkillsPoisson{teamID_i, 2} = d_i;
% end
% 
% % Update skills according to TrueSkill model-------------------------------
% for idxMatch = 1:N
%     teamID_i = data(idxMatch, 1);
%     teamID_j = data(idxMatch, 2);
%     s_i = data(idxMatch, 3); 
%     s_j = data(idxMatch, 4);     
%     beta = 1;
%     [updatedSkill_I updatedSkill_J] = updateTrueSkill( teamSkillsTrueSkill{teamID_i, 1}, ...
%                                                        teamSkillsTrueSkill{teamID_j, 1}, s_i, s_j, beta);
%     teamSkillsTrueSkill{teamID_i, 1} = updatedSkill_I;
%     teamSkillsTrueSkill{teamID_j, 1} = updatedSkill_J;    
% end
% 
% % Update skills according to simple Gaussian graphical model---------------
% gamma = 3;
% for idxMatch = 1:N
%     teamID_i = data(idxMatch, 1);
%     teamID_j = data(idxMatch, 2);
%     s_i = data(idxMatch, 3); 
%     s_j = data(idxMatch, 4);     
%     beta = 1;
%     [o_i d_j] = updateGaussian( teamSkillsGaussian{teamID_i, 1}, teamSkillsGaussian{teamID_j, 2}, s_i, beta, gamma);
%     [o_j d_i] = updateGaussian( teamSkillsGaussian{teamID_j, 1}, teamSkillsGaussian{teamID_i, 2}, s_j, beta, gamma);
%     teamSkillsGaussian{teamID_i, 1} = o_i;
%     teamSkillsGaussian{teamID_j, 2} = d_j;
%     teamSkillsGaussian{teamID_j, 1} = o_j;
%     teamSkillsGaussian{teamID_i, 2} = d_i;  
% end

% Update skills according to linear regression-----------------------------
% by solving Az = s, 
A = zeros(2*N, 2*M);
s = zeros(2*N, 1);
s(1:2:2*N) = data(:, 3);
s(2:2:2*N) = data(:, 4);
for idxMatch = 1:N
    offenceTeamID = data(idxMatch, 1);
    defenceTeamID = data(idxMatch, 2);
    A( 2*(idxMatch-1)+1, 2*(offenceTeamID-1)+1 ) = 1;  % for s_i,1 --offence
    A( 2*(idxMatch-1)+1, 2*(defenceTeamID-1)+2 ) = -1; % for s_i,1 --defence
    A( 2*(idxMatch-1)+2, 2*(defenceTeamID-1)+1 ) = 1; % for s_i,2 --defence
    A( 2*(idxMatch-1)+2, 2*(offenceTeamID-1)+2 ) = -1;  % for s_i,2 --offence
end
z = A\s;
teamSkillsLinearRegression(:, 1) = z(1:2:end);
teamSkillsLinearRegression(:, 2) = z(2:2:end);


% Update skills according to logistic regression---------------------------
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
out = Logistic([1 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0]*z);





































