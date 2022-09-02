function plotClusterWeights(betas,nClusters,ntfilt,xAx)
% figure
% set(gcf,'Color','w')
baseInd = 1:ntfilt;
axLims  = [min(xAx) , max(xAx) , -max(abs(betas)) , max(abs(betas))];
for ii = 1:nClusters
    currentInd      = baseInd + ntfilt*(ii-1); % adjust window of plot
    currentBetas    = betas(currentInd);
    subplot(2,ceil(nClusters/2),ii)
    plot(xAx,currentBetas,'k','LineWidth',1.2)
    yline(0,'--');
    grid on
    title(['Cluster ',num2str(ii)])
    axis(axLims);
end
sgtitle('GLM Wights by Cluster')
han=axes(gcf,'visible','off'); 
han.Title.Visible   = 'on';
han.XLabel.Visible  = 'on';
han.YLabel.Visible  = 'on';
han.FontSize        = 14;
xlabel(han,'Time wrt Stim Onset (s)')
ylabel(han,'Weight Value')
end