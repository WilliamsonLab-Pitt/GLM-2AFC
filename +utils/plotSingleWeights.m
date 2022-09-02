function plotSingleWeights(betas,nClusters)
clusterStr  = strcat("Cluster ",num2str((1:nClusters)'));
xAx         = 1:nClusters;
stem(xAx,abs(betas))
set(gca,'XTick',xAx)
set(gca,'XTickLabel',clusterStr)
xlim([0.5,nClusters(end)+0.5])
title('LNP Weights')
ylabel('Weight Magnitude')
set(gca,'FontSize',14)

end