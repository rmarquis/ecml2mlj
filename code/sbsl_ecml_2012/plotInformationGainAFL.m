function plotInformationGain(xInd, y, error, axisLim, tit, fileName, flag)
if flag == 1
    x = [xInd; xInd; xInd; xInd; xInd]';
    figure1 = figure('PaperSize',[20.98 29.68]);
    % Create axes
    axes1 = axes('Parent',figure1,'FontSize',20,'FontName','Times New Roman');
    box(axes1,'on');
    hold(axes1,'all');
    % Create multiple error bars using matrix input to errorbar
    errorbar1 = errorbar(x, y, error);
    set(errorbar1(5),'Marker','v','DisplayName','Gaussian-SD');
    set(errorbar1(4),'Marker','^','DisplayName','TrueSkill');
    set(errorbar1(3),'Marker','<','DisplayName','Gaussian-S');
    set(errorbar1(2),'Marker','>', 'DisplayName','Logistic');
    set(errorbar1(1),'Marker','o','DisplayName','Poisson');
    title(tit,'FontSize',20,'FontName','Times New Roman')
    legend1 = legend(axes1,'show');
    set(legend1,'Location','SouthEast','FontSize',16);
    xlabel('Proportion of data used for training','FontSize',20,...
        'FontName','Times New Roman');
    ylabel('Average information gain','FontSize',20,...
        'FontName','Times New Roman');
    axis(axisLim);
    saveas(figure1, fileName, 'pdf');
elseif flag == 0
    fontSize = 28;
    x = [xInd; xInd; xInd; xInd]';
    y(:,2) = []; % delete the results for logistic
    error(:,2) = [];
%     figure1 = figure('PaperSize',[20.98 29.68]);
    figure1 = figure('PaperOrientation', 'landscape', 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1]);
    % Create axes
    axes1 = axes('Parent',figure1,'FontSize',fontSize,'FontName','Times New Roman');
    box(axes1,'on');
    hold(axes1,'all');
    % Create multiple error bars using matrix input to errorbar
    errorbar1 = errorbar(x, y, error);
    set(errorbar1(4),'Marker','v','DisplayName','Gaussian-SD');
    set(errorbar1(3),'Marker','^','DisplayName','TrueSkill');
    set(errorbar1(2),'Marker','<','DisplayName','Gaussian-OD');
    %set(errorbar1(2),'Marker','>', 'DisplayName','Logistic');
    set(errorbar1(1),'Marker','o','DisplayName','Poisson-OD');
    title(tit,'FontSize',fontSize,'FontName','Times New Roman')
    legend1 = legend(axes1,'show');
    set(legend1,'Location','best','FontSize', 22);
    legend(legend1, 'boxoff');
    xlabel('Proportion of data used for training','FontSize',fontSize,...
        'FontName','Times New Roman');
    ylabel('Average information gain','FontSize',fontSize,...
        'FontName','Times New Roman');
    axis(axisLim);
    saveas(figure1, fileName, 'pdf');
end
end