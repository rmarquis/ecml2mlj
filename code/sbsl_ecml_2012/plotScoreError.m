function plotScoreError(xInd, y, error, axisLim, tit, fileName)
x = [xInd; xInd; xInd; xInd]';
markers = 15; 
fontSize = 28;
figure1 = figure('PaperOrientation', 'landscape', 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1]);
% Create axes
axes1 = axes('Parent',figure1,'FontSize',fontSize,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');

errorbar1 = errorbar(x, y, error);

% set(errorbar1(5),'Marker','*', 'MarkerSize', markers, 'DisplayName','Gaussian-OD-AH', 'LineWidth',3);
set(errorbar1(4),'Marker','p', 'MarkerSize', markers, 'DisplayName','AverageScore', 'LineWidth',3, 'color', 'k');
set(errorbar1(3),'Marker','<', 'MarkerSize', markers, 'DisplayName','Gaussian-OD',  'LineWidth',3, 'color', 'r');
set(errorbar1(2),'Marker','>', 'MarkerSize', markers, 'DisplayName','Poisson-OD(Sampling)',   'LineWidth',3, 'color', 'g');
set(errorbar1(1),'Marker','o', 'MarkerSize', markers, 'DisplayName','Poisson-OD(VB)',     'LineWidth',3, 'color', 'b');


title(tit,'FontSize',fontSize,'FontName','Times New Roman')
legend1 = legend(axes1,'show');
set(legend1,'Location','Best','FontSize', 18, 'Visible', 'on');
xlabel('Proportion of data used for training','FontSize', fontSize,...
    'FontName','Times New Roman');
ylabel('MAE of scores','FontSize', fontSize,...
    'FontName','Times New Roman');
axis(axisLim)
saveas(figure1, fileName, 'pdf');
end