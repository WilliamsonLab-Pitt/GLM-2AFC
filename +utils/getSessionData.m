function [clusterResponse,nClusters,d,clustID] = getSessionData(analysisFolder,clusterFile)
% Prep file names. Make sure they match if there is an error
listFile        = [analysisFolder,filesep,clusterFile,'.mat'];
analysisFile    = [analysisFolder,filesep,'initial_analysis.mat'];

% load(listFile,'clustID');
load(listFile,'ET_cluster_idx'); clustID = ET_cluster_idx;
load(analysisFile,'d');

nClusters = numel(unique(clustID));
[~,nFrames,nTrials] = size(d.spike_zscores);

clusterResponse = zeros(nClusters,nFrames,nTrials);

normalized_spike_zscores = utils.normalizeCellSpikes(d.spike_zscores); % get rescaled spikes (from 0 to 1)

for ii = 1:nClusters
    currentResponse         = normalized_spike_zscores(clustID==ii,:,:); % use rescaled data, not raw
    clusterResponse(ii,:,:) = mean(currentResponse);
end

end