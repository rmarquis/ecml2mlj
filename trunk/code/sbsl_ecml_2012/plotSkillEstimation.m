function plotSkillEstimation(xInd, y, error, axisLim, tit, fileName)
x = [xInd; xInd; xInd]';
figure1 = figure('PaperSize',[20.98 29.68]);
% Create axes
axes1 = axes('Parent',figure1,'FontSize',20,'FontName','Times New Roman');
box(axes1,'on');
hold(axes1,'all');
% Create multiple error bars using matrix input to errorbar
errorbar1 = errorbar(x, y, error);
set(errorbar1(3),'Marker','v','DisplayName','Gaussian-SD', 'Color',[0 0.749 0.749]);
set(errorbar1(2),'Marker','<','DisplayName','Gaussain-S', 'Color',[0 0.498 0]);
set(errorbar1(1),'Marker','o','DisplayName','Poisson');
title(tit,'FontSize',20,'FontName','Times New Roman')
legend1 = legend(axes1,'show');
set(legend1,'Location','Best','FontSize',16);
xlabel('Proportion of data used for training','FontSize',20,...
    'FontName','Times New Roman');
ylabel('Average player skill esitmation','FontSize',20,...
    'FontName','Times New Roman');
axis(axisLim )
saveas(figure1, fileName, 'pdf');
end