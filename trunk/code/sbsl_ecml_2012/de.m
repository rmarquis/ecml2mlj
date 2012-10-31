a = zeros(1, 42);
for i = 1:42
    a(i) = teamSkillsPoisson{i,1}.Mu+teamSkillsPoisson{i,2}.Mu;
    teamSkillsPoisson{i,1}.Sigma
end
figure;
plot(a);
[pos valuePoisson] = sort(a);

a = zeros(1, 42);
for i = 1:42
    a(i) = teamSkillsTrueSkill{i,1}.Mu;
    teamSkillsTrueSkill{i,1}.Sigma
end
figure;
plot(a);
[pos valueTrueSkill] = sort(a);

a = zeros(1, 42);
for i = 1:42
    a(i) = teamSkillsGaussian{i,1}.Mu + teamSkillsGaussian{i,2}.Mu;
    teamSkillsGaussian{i,1}.Sigma
end
figure;
plot(a);
[pos valueGaussian] = sort(a);

a = zeros(1, 42);
for i = 1:42
    a(i) = teamSkillsGaussianSD{i,1}.Mu;
    teamSkillsGaussianSD{i,1}.Sigma
end
figure;
plot(a);
[pos valueGaussianSD] = sort(a);

rank = [valuePoisson' valueTrueSkill' valueGaussian' valueGaussianSD']