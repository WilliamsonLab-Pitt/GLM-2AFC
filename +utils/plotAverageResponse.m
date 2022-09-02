function plotAverageResponse(cResponse,fs,firstFrame,cutIn)
cResponse   = cResponse(:,cutIn,:);
nClusters   = size(cResponse,1);
nStims      = size(cResponse,3);
% nFrames     = size(cResponse,2);
colors      = ["b","b","b","b","w","r","r","r","r"];
xAx         = ((cutIn)-firstFrame)/fs;
axLims      = [min(xAx),max(xAx),0,0.6];

for ii = 1:nClusters
    for jj = 1:nStims
        currentCurve = cResponse(ii,:,jj);
        subplot(2,ceil(nClusters/2),ii)
        hold on
        plot(xAx,currentCurve,'k','LineWidth',0.8,'Color',colors(jj))
        title(['Cluster ',num2str(ii)])
        xline(0,'--')
        axis(axLims);
    end
    hold off
end
sgtitle('Average Response Per Stimulus')
han=axes(gcf,'visible','off'); 
han.Title.Visible   = 'on';
han.XLabel.Visible  = 'on';
han.YLabel.Visible  = 'on';
han.FontSize        = 14;
xlabel(han,'Time wrt Stim Onset (s)')
ylabel(han,'Normalized Spikes (z-scored)')
end