function cAveraged = averageClusterByStim(cResponse,stim_idx)
nClusters   = size(cResponse,1);
nFrames     = size(cResponse,2);
nStims      = length(unique(stim_idx));
cAveraged   = zeros(nClusters,nFrames,nStims);
for ii = 1:nStims
    currentInd          = stim_idx == ii;
    currentResponse     = mean(cResponse(:,:,currentInd),3);
    cAveraged(:,:,ii)   = currentResponse;
end

end