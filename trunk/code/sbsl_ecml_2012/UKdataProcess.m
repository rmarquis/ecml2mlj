% AFL data analysis: 1. delete file head; 2. read and process each row
dirName = '.\dataset\UKPremierLeagure\';
fileFolder = dir(dirName);
numFile = length(fileFolder) - 2; % remove filefolder . and ..
counter = 0;
matchOutcome = [];
for idxFile = 1:numFile
    fileName = fileFolder(idxFile+2).name
    completePath = strcat(dirName, fileName);
    fid = fopen(completePath);
    while 1 
        tline = fgetl(fid);
        if ischar(tline) 
            if tline(1) == 'D' || tline(2) > 'i' % skip row starting with 'Div'
                continue;
            end
            if tline(1) == ',' || tline(2) == ',' % skip line with comma
                continue;
            end
            pos = find(tline == ',');            
            counter = counter + 1;                             
            matchOutcome{counter, 1} = tline(pos(2)+1:pos(3)-1);
            matchOutcome{counter, 2} = tline(pos(3)+1:pos(4)-1);
            matchOutcome{counter, 3} = tline(pos(4)+1:pos(5)-1);
            matchOutcome{counter, 4} = tline(pos(5)+1:pos(6)-1);
        else
            break;
        end
    end
    fclose(fid);
end

% define team here
TeamName = unique(matchOutcome(:, 1));
numTeam = length(TeamName);
[numMatch, junk ] = size(matchOutcome);
matchOutcomeUK = zeros(numMatch, junk);
% replace teamNameString with teamID
for idxMatch = 1:numMatch
    % find team1ID
    for idxTeamName = 1:numTeam
        if strcmp(matchOutcome{idxMatch, 1}, TeamName{idxTeamName})
            team1ID = idxTeamName;
        end
    end
    % find team2ID
    for idxTeamName = 1:numTeam
        if strcmp(matchOutcome{idxMatch, 2}, TeamName{idxTeamName})
            team2ID = idxTeamName;
        end
    end 
    matchOutcomeUK(idxMatch, 1) = team1ID;
    matchOutcomeUK(idxMatch, 2) = team2ID;
    matchOutcomeUK(idxMatch, 3) = str2num(matchOutcome{idxMatch, 3});
    matchOutcomeUK(idxMatch, 4) = str2num(matchOutcome{idxMatch, 4});
end
save matchOutcomeUK matchOutcomeUK;