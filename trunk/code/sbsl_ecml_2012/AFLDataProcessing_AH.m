% created on 29/10/2012 by Shengbo GUO
% extract home and away team as well, and store in the last two columns in
% the matchOutcomeAFL_AH

% AFL data analysis: 1. delete file head; 2. read and process each row
dirName = '.\dataset\AFLData\AFL\';
fileFolder = dir(dirName);
numFile = length(fileFolder) - 2; % remove filefolder . and ..
counter = 0;
matchOutcome = [];
matchFlagHA = [];
for idxFile = 1:numFile
    fileName = fileFolder(idxFile+2).name
    completePath = strcat(dirName, fileName);
    fid = fopen(completePath);
    teamHAMap = containers.Map(); 
    while 1 
        tline = fgetl(fid);        
        tline
        if ischar(tline) 
            if length(tline)<=1 % skip empty line
                continue;
            end
            if tline(1) < '0' || tline(1) > '9' % skip summary of team
                % extract team name and its homefield                
                posComma = find(tline == ':'); 
                posDoubleLeft = find(tline == '"');   
                teamName = tline(1:posComma-1);          
                teamHAName = tline(posDoubleLeft(3)+1:posDoubleLeft(4)-1);  
                if strcmp(teamHAName, 'G')
                    teamHAName = 'GABBA';
                end
                teamHAMap(teamName) = teamHAName;
                continue;
            end
            counter = counter + 1;
            disp(tline)
            % delete ( and )             
            posLeft = find(tline == '(');
            posRight = find(tline == ')');
            posSharp = find(tline =='#');
            posDoubleLeft = find(tline == '"');
            % remove possible space for homefiled in ""
            posSpace = find(tline(posDoubleLeft(1):posDoubleLeft(2)) == ' ')+posDoubleLeft(1)-1;
            
            needDeletePos = [posLeft posRight posSharp posDoubleLeft(1) posSpace posDoubleLeft(2)];
            tline(needDeletePos) = [];
            tline
            % extract team1 team2 score1 score2
            [junk, team1, team2, homefield, time, junk, junk, score1, junk, junk, score2] = strread(tline, '%s%s%s%s%s%d%d%d%d%d%d', 'delimiter', ' ');
            matchOutcome{counter, 1} = team1;
            matchOutcome{counter, 2} = team2;      
            matchOutcome{counter, 3} = score1;
            matchOutcome{counter, 4} = score2;
            if strcmp( lower(teamHAMap(cell2str(team1))), lower(homefield) )
                matchFlagHA(counter, 1) =  1;
            else
                matchFlagHA(counter, 1) =  0;
            end
            if strcmp( lower(teamHAMap(cell2str(team2))), lower(homefield) )
                matchFlagHA(counter, 2) =  1;
            else
                matchFlagHA(counter, 2) =  0;
            end                      
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
matchOutcomeAFL_AH = [matchOutcomeAFL matchFlagHA];
save matchOutcomeAFL_AH matchOutcomeAFL_AH;