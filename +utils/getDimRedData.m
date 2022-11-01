function [clusterResponse,nClusters,d] = getDimRedData(analysisFolder,dimRedFolder,loadName)
% Prep file names. Make sure they match if there is an error
analysisFile    = [analysisFolder,filesep,'initial_analysis.mat'];
load(analysisFile,'d');

clusterFile     = fullfile(dimRedFolder,loadName);
load(clusterFile,'clusterResponse')

nClusters = size(clusterResponse,1);

end