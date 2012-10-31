% delete draw
% posDraw = [];
% for idxMatch = 1:size(matchOutcome, 1)
%     if matchOutcome(idxMatch, 3) == matchOutcome(idxMatch, 4)
%         posDraw = [posDraw; idxMatch];
%     end
% end
% matchOutcome(posDraw, :) = [];

% % delete players that have played less than 10 matches
% numPlayers = max(max(matchOutcome(:, 1:2)));
% needDelete = [];
% threshold  = 3;
% for idxPlayer = 1:numPlayers 
%     if length(find([matchOutcome(:, 1) matchOutcome(:, 2)] == idxPlayer))< threshold
%         needDelete = [needDelete idxPlayer];
%     end
% end
% delPlayer1 = [];
% delPlayer2 = [];
% for i = 1:length(needDelete)
%     if ~isempty(find(matchOutcome(:, 1) == needDelete(i)))
%         delPlayer1 = [ delPlayer1; find(matchOutcome(:, 1) == needDelete(i))];
%     end
%     if ~isempty(find(matchOutcome(:, 2) == needDelete(i)))
%         delPlayer2 = [ delPlayer2; find(matchOutcome(:, 2) == needDelete(i))];
%     end
% end
% del = unique([delPlayer1; delPlayer2]);
% matchOutcome(del, :) = [];

% delete neg score
% negScore1 = find(matchOutcome(:,3)<0);
% negScore2 = find(matchOutcome(:,4)<0);
% needDel = unique([negScore1; negScore2]);
% matchOutcome(needDel, :) = [];