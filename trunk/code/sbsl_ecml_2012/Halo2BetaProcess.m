% Halo 2 Beta data processing
fileName = '.\dataset\Halo2Beta\HeadToHead_forECML.csv';
[team score ]= textread(fileName, '%f%d', 'delimiter', ',');
sortedTeam = sort(team);
sortedTeam = unique(sortedTeam);

teamID_realID = zeros( length(sortedTeam), 2 );
teamID_realID(:, 1) = 1:length(sortedTeam);
teamID_realID(:, 2) = sortedTeam;

team1 = team(1:2:end);
team2 = team(2:2:end);
score1 = score(1:2:end);
score2 = score(2:2:end);
matchOutcome = [team1 team2 score1 score2];
finalMatchOutcome = matchOutcome;
numMatch = length(team1);

% map teamID to the hashtable
for idxMatch = 1:numMatch
    pos1 = find( teamID_realID(:, 2) == matchOutcome(idxMatch, 1));
    team1ID = teamID_realID(pos1, 1);
    finalMatchOutcome(idxMatch, 1) = team1ID;
    pos2 = find( teamID_realID(:, 2) == matchOutcome(idxMatch, 2));
    team2ID = teamID_realID(pos2, 1);
    finalMatchOutcome(idxMatch, 2) = team2ID;
end
matchOutcome = finalMatchOutcome;
clear finalMatchOutcome;
%save matchOutcomeHalo matchOutcome;

% test how many teams in Halo 2 Beta
% teamAssociated = zeros(length(team), 2);
% teamAssociated(:, 1) = team;
% for i=1:length(team)
%     teamID = find(sortedTeam == team(i));
%     teamAssociated(i, 2) = teamID;
% end
