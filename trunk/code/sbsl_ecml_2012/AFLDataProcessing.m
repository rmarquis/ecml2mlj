% AFL data analysis: 1. delete file head; 2. read and process each row
dirName = '.\dataset\AFLData\AFL\';
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
            if length(tline)<1 % skip empty line
                continue;
            end
            if tline(1) < '0' || tline(1) > '9' % skip summary of team
                continue;
            end
            counter = counter + 1;
            disp(tline)
            % delete ( and )             
            posLeft = find(tline == '(');
            posRight = find(tline == ')');
            posSharp = find(tline =='#');
            posDoubleLeft = find(tline == '"');
            needDeletePos = [posLeft posRight posSharp posDoubleLeft(1):posDoubleLeft(2)];
            tline(needDeletePos) = [];
            
            % extract team1 team2 score1 score2
            [junk, team1, team2, time, junk, junk, score1, junk, junk, score2] = strread(tline, '%s%s%s%s%d%d%d%d%d%d', 'delimiter', ' ');
            matchOutcome{counter, 1} = team1;
            matchOutcome{counter, 2} = team2;      
            matchOutcome{counter, 3} = score1;
            matchOutcome{counter, 4} = score2;
        else
            break;
        end
    end
    fclose(fid);
end

% define team here
numTeam = 16;
TeamName = {'Adelaide', 'Brisbane', 'Carlton', 'Collingwood', 'Essendon', 'Fremantle', 'Geelong', 'Hawthorn', ...
            'Melbourne', 'Kangaroos', 'P_Adelaide', 'Richmond', 'St_Kilda', 'Sydney', 'W_Coast', 'W_Bulldogs'};
[numMatch, junk ] = size(matchOutcome);
matchOutcomeAFL = zeros(numMatch, junk);
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
    matchOutcomeAFL(idxMatch, 1) = team1ID;
    matchOutcomeAFL(idxMatch, 2) = team2ID;
    matchOutcomeAFL(idxMatch, 3) = matchOutcome{idxMatch, 3};
    matchOutcomeAFL(idxMatch, 4) = matchOutcome{idxMatch, 4};
end
save matchOutcomeAFL matchOutcomeAFL;
