function [muPost, sigmaPost] = slicesampling(s, muPrior, sigmaPrior) % Define a function proportional to a multi-modal density

% function handle for the exact postrior unnormalized
f = @(x) poisspdf( s, exp(x) ) .* normpdf(x, muPrior, sigmaPrior); 

% Generate a sample based on this density
N = 1000;
x = slicesample(muPrior,N,'pdf',f,'thin',5,'burnin',1000);

muPost = mean(x); 
sigmaPost = std(x); 
% 
% % Plot a histogram of the sample
% [binheight,bincenter] = hist(x,50);
% h = bar(bincenter,binheight,'hist');
% set(h,'facecolor',[0.8 .8 1]);
% 
% % Superimpose the f function scaled to have the same area
% hold on
% xd = get(gca,'XLim');
% xgrid = linspace(xd(1),xd(2),1000);
% binwidth = (bincenter(2)-bincenter(1));
% y = (N*binwidth/area) * f(xgrid);
% plot(xgrid,y,'r','LineWidth',2)
% hold off