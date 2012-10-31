function plotSkillEsitmation(x, y, error, axisLim, tit, fileName)
figure1 = figure('PaperSize',[20.98 29.68]);
% Create axes
axes1 = axes('Parent',figure1,'FontSize',20,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
% Create multiple error bars using matrix input to errorbar
errorbar1 = errorbar(x, y, error);
set(errorbar1(5),'Marker','x','DisplayName','Gaussian-SD');
set(errorbar1(4),'Marker','>','DisplayName','Gaussian (D)');
set(errorbar1(3),'Marker','<','DisplayName','Gaussian (O)');
set(errorbar1(2),'Marker','^', 'DisplayName','Poisson (D)');
set(errorbar1(1),'Marker','v','DisplayName','Poisson (O)');
title(tit,'FontSize',20,'FontName','Times New Roman')
legend1 = legend(axes1,'show');
set(legend1,'Location','SouthEast','FontSize',16);
xlabel('Team Number','FontSize',20,...
    'FontName','Times New Roman');
ylabel('Estimated team skills','FontSize',20,...
    'FontName','Times New Roman');
axis(axisLim);
saveas(figure1, fileName, 'pdf');
end