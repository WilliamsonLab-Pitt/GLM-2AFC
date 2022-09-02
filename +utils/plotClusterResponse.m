function plotClusterResponse(spike_zscores,division,nClusters)
categories  = unique(division);
categories(isnan(categories)) = [];
nCats       = length(categories);
colors = [0 0 1 ; 1 0 0];
for ii = 1:nClusters
    for n = nCats
        subplot(2,ceil(nClusters/2),ii)
        plot(spike_zscores,'Color',colors(n,:))
    end
    grid on
    title(['Cluster ',num2str(ii)])
    axis(axLims);
end
end