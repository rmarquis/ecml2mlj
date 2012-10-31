% plot team offence skills
figure; 
subplot(1, 2, 1);
noTeam = size(teamSkillsPoisson, 1);
teamSkillMean = zeros(noTeam, 1);
for idxTeam = 1:noTeam
    teamSkillMean(idxTeam) = teamSkillsPoisson{idxTeam, 1}.Mu;
end
bar(1:noTeam, teamSkillMean);
title('Poisson-offence');
axis tight;

subplot(1, 2, 2);
teamSkillMean = zeros(noTeam, 1);
for idxTeam = 1:noTeam
    teamSkillMean(idxTeam) = teamSkillsPoisson{idxTeam, 2}.Mu;
end
bar(1:noTeam, teamSkillMean)
title('Poisson-defense');
axis tight;
