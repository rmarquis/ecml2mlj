% plot team offence skills
figure; 
subplot(2, 2, 1);
noTeam = size(teamSkills, 1);
teamSkillMean = zeros(noTeam, 1);
for idxTeam = 1:noTeam
    teamSkillMean(idxTeam) = teamSkillsPoisson{idxTeam, 1}.Mu + teamSkillsPoisson{idxTeam, 2}.Mu;
end
bar(1:noTeam, teamSkillMean-min(teamSkillMean)+1)
title('Poisson-offence+defence');
axis tight;

subplot(2, 2, 2);
noTeam = size(teamSkills, 1);
teamSkillMean = zeros(noTeam, 1);
for idxTeam = 1:noTeam
    teamSkillMean(idxTeam) = teamSkillsPoisson{idxTeam, 1}.Mu;
end
bar(1:noTeam, teamSkillMean-min(teamSkillMean)+1)
title('Poisson-offence');
axis tight;

subplot(2, 2, 3);
noTeam = size(teamSkills, 1);
teamSkillMean = zeros(noTeam, 1);
for idxTeam = 1:noTeam
    teamSkillMean(idxTeam) = teamSkillsGaussian{idxTeam, 1}.Mu + teamSkillsGaussian{idxTeam, 2}.Mu;
end
bar(1:noTeam, teamSkillMean-min(teamSkillMean)+1)
title('Simple Gaussian: offence + defence');
axis tight;

subplot(2, 2, 4);
noTeam = size(teamSkills, 1);
teamSkillMean = zeros(noTeam, 1);
for idxTeam = 1:noTeam
    teamSkillMean(idxTeam) = teamSkillsGaussian{idxTeam, 1}.Mu;
end
bar(1:noTeam, teamSkillMean-min(teamSkillMean)+1)
title('Simple Gaussian: offence');
axis tight;

%-------------------
figure;

subplot(1, 3, 1);
noTeam = size(teamSkills, 1);
teamSkillMean = zeros(noTeam, 1);
for idxTeam = 1:noTeam
    teamSkillMean(idxTeam) = teamSkillsTrueSkill{idxTeam, 1}.Mu;
end
bar(1:noTeam, teamSkillMean-min(teamSkillMean)+1)
title('TrueSkill');
axis tight;

subplot(1, 3, 2);
noTeam = size(teamSkills, 1);
teamSkillMean = zeros(noTeam, 1);
for idxTeam = 1:noTeam
    teamSkillMean(idxTeam) = sum(teamSkillsLinearRegression(idxTeam,:));
end
bar(1:noTeam, teamSkillMean-min(teamSkillMean)+1)
title('Linear Regression: offence+defence');
axis tight;

subplot(1, 3, 3);
noTeam = size(teamSkills, 1);
teamSkillMean = zeros(noTeam, 1);
for idxTeam = 1:noTeam
    teamSkillMean(idxTeam) = teamSkillsLinearRegression(idxTeam,1);
end
bar(1:noTeam, teamSkillMean-min(teamSkillMean)+1)
title('Linear Regression: offence');
axis tight;