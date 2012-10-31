%%%%%%%%%%%%%%%%%%%%%%%%Skill training results  --AFL
load resultPercentageYear_AFL
resultFinal = skillPercentageYear;

interestedCell = resultFinal{9, 6};
numTeam = size(interestedCell{1}, 1);
skillTable = zeros(numTeam, 10);
for i = 1:numTeam
    skillTable(i,1) = interestedCell{1}{i, 1}.Mu; % Poisson Offence Mean
    skillTable(i,2) = interestedCell{1}{i, 2}.Mu; % Poisson Defence Mean
    skillTable(i,3) = interestedCell{3}{i, 1}.Mu; % Gaussian-S Offence Mean
    skillTable(i,4) = interestedCell{3}{i, 2}.Mu; % Gaussian-S Defence Mean
    skillTable(i,5) = interestedCell{4}{i, 1}.Mu; % Gaussian-SD Mean
    
    skillTable(i,6) = interestedCell{1}{i, 1}.Sigma; % Poisson Offence Mean
    skillTable(i,7) = interestedCell{1}{i, 2}.Sigma; % Poisson Defence Mean
    skillTable(i,8) = interestedCell{3}{i, 1}.Sigma; % Gaussian-S Offence Mean
    skillTable(i,9) = interestedCell{3}{i, 2}.Sigma; % Gaussian-S Defence Mean
    skillTable(i,10) = interestedCell{4}{i, 1}.Sigma; % Gaussian-SD Mean
end
xInd = 1:numTeam;
x= [xInd' xInd' xInd' xInd' xInd'];
y= skillTable(:, 1:5);
error = skillTable(:, 6:10);
axisLim = [0.8 16.2 10 35];
tit = 'AFL';
fileName = 'skillEstimation_AFL';
plotSkillEsitmation(x, y, error, axisLim, tit, fileName);

%%%%%%%%%%%%%%%%%%%%%%%%Skill training results  --UK
load skillPercentageYear_UK
resultFinal = skillPercentageYear;

interestedCell = resultFinal{9, 1};
numTeam = size(interestedCell{1}, 1);
skillTable = zeros(numTeam, 10);
for i = 1:numTeam
    skillTable(i,1) = interestedCell{1}{i, 1}.Mu; % Poisson Offence Mean
    skillTable(i,2) = interestedCell{1}{i, 2}.Mu; % Poisson Defence Mean
    skillTable(i,3) = interestedCell{3}{i, 1}.Mu; % Gaussian-S Offence Mean
    skillTable(i,4) = interestedCell{3}{i, 2}.Mu; % Gaussian-S Defence Mean
    skillTable(i,5) = interestedCell{4}{i, 1}.Mu; % Gaussian-SD Mean
    
    skillTable(i,6) = interestedCell{1}{i, 1}.Sigma; % Poisson Offence Mean
    skillTable(i,7) = interestedCell{1}{i, 2}.Sigma; % Poisson Defence Mean
    skillTable(i,8) = interestedCell{3}{i, 1}.Sigma; % Gaussian-S Offence Mean
    skillTable(i,9) = interestedCell{3}{i, 2}.Sigma; % Gaussian-S Defence Mean
    skillTable(i,10) = interestedCell{4}{i, 1}.Sigma; % Gaussian-SD Mean
end
xInd = 1:numTeam;
x= [xInd' xInd' xInd' xInd' xInd'];
y= skillTable(:, 1:5);
error = skillTable(:, 6:10);
axisLim = [0.8 40.2 15 35];
tit = 'UK-PL';
fileName = 'skillEstimation_UK';
plotSkillEsitmation(x, y, error, axisLim, tit, fileName);