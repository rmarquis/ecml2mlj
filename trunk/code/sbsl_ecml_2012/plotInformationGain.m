function plotInformationGain(xInd, y, error, axisLim, tit, fileName)

% flag indicating if we show both VB and Sampling or not
markers = 15;
fontSize = 28;
lwid = 3; 
figure1 = figure('PaperOrientation', 'landscape', 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1]);
% Create axes
axes1 = axes('Parent',figure1,'FontSize',fontSize,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');

x = [xInd; xInd; xInd; xInd; xInd]';
% Create multiple error bars using matrix input to errorbar
errorbar1 = errorbar(x, y, error);

% set(errorbar1(7),'Marker','*', 'MarkerSize', markers, 'DisplayName','Gaussian-OD-AH', 'LineWidth',lwid);
% set(errorbar1(6),'Marker','d', 'MarkerSize', markers, 'DisplayName','Poisson-VB-AH', 'LineWidth',lwid);
set(errorbar1(5),'Marker','v', 'MarkerSize', markers, 'DisplayName','Gaussian-SD', 'LineWidth',lwid, 'color', 'm');
set(errorbar1(4),'Marker','^', 'MarkerSize', markers, 'DisplayName','TrueSkill',   'LineWidth',lwid, 'color', 'c');
set(errorbar1(3),'Marker','<', 'MarkerSize', markers, 'DisplayName','Gaussian-OD',  'LineWidth',lwid, 'color', 'r');
set(errorbar1(2),'Marker','>', 'MarkerSize', markers, 'DisplayName','Poisson-OD(Sampling)',   'LineWidth',lwid, 'color', 'g');
set(errorbar1(1),'Marker','o', 'MarkerSize', markers, 'DisplayName','Poisson-OD(VB)',     'LineWidth',lwid, 'color', 'b');

title(tit,'FontSize',fontSize,'FontName','Times New Roman')
legend1 = legend(axes1,'show');
% if strcmp(tit, 'UK-PL')
    set(legend1,'Location','best','FontSize', 18, 'Visible', 'on');
% else
%    set(legend1,'Location','best','FontSize', fontSize, 'Visible', 'off');
% end
xlabel('Proportion of data used for training','FontSize',fontSize,...
    'FontName','Times New Roman');
ylabel('Average information gain','FontSize',fontSize,...
    'FontName','Times New Roman');
axis(axisLim);
saveas(figure1, fileName, 'pdf');
end