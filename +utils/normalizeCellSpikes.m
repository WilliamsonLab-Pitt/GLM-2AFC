function normalized_spike_zscores = normalizeCellSpikes(spike_zscores)
nCells = size(spike_zscores,1);
normalized_spike_zscores = zeros(size(spike_zscores));
for ii = 1:nCells
    % normalize every cell by separate
    lLim = min(spike_zscores(ii,:,:),[],'all');
    uLim = prctile(spike_zscores(ii,:,:),95,'all');
    normalized_spike_zscores(ii,:,:) = rescale(spike_zscores(ii,:,:),...
        'InputMin',lLim,'InputMax',uLim);
end

end