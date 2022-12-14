% Different GLM settings for two arm forced choice (Nathan Schneider).
% Random data is generated for cluster activity (dimensionality reduced)
% and response (licking)
% 
% By Tomas Suarez Omedas - 08/18/2022

% Experimental setup:
%   Stim duration 1s
%   8 clusters from cells
%   Stim starts at frames 75
%   Stim presented for 30 frames

%% Setup
clear; close all; clc

nOutcomes   = 4;
nStims      = 9;
fs          = 30; % frame rate

firstFrame  = 90;
lastFrame   = 105;

cutIn       = firstFrame:lastFrame; % frames of neural data fed into GLM
ntfilt      = length(cutIn); % Size of time filter

mouseID     = 'TlxMH02';
sessionDate = '070522';

% Set Figure
figure
set(gcf,'Color','w')


%% Get Session Data
% clusterResponse array: clusters by frames by trials
analysisFolder  = 'W:\Data\2AFC_Imaging\IT\2P\TlxMH02\070522\1-3-Session28Run14\MAT';
% dimRedFolder    = 'C:\Users\Williamson_Lab\Documents\Tommy\GLM - 2AFC\CILDS Saved Files\K-Means Clustering';
dimRedFolder    = 'C:\Users\Williamson_Lab\Documents\Tommy\GLM - 2AFC\CILDS Saved Files\Hierarchical Clustering\6 Clusters';
loadName        = [mouseID,'_',sessionDate,'_cluster1Dim.mat'];
% [clusterResponse,nClusters,d] = utils.getSessionData(analysisFolder,'cluster_identities');
[clusterResponse,nClusters,d] = utils.getDimRedData(analysisFolder,dimRedFolder,loadName);

nFrames     = size(d.spike_zscores,2);
nTrials     = size(d.spike_zscores,3);

%% Reshape Cluster Response
cResponse2      = clusterResponse(:,cutIn,:);
% Xdsgn           = reshape(cResponse2,[nTrials,length(cutIn)*nClusters]);
cResponse2Ave   = squeeze(mean(cResponse2,2));
% cResponse2Ave   = squeeze(max(cResponse2,[],2));
% cResponse2Ave   = squeeze(median(cResponse2,2));
Xdsgn           = cResponse2Ave';
imagesc(Xdsgn)
colorbar


%% Average Cluster Response by Trial Type
cResponse3 = utils.averageClusterByStim(clusterResponse,d.stim_idx);
utils.plotAverageResponse(cResponse3,fs,75,60:120)


%% Find list of choices
% uniqueChoices = unique(currentData.trial_outcome);
uniqueChoices   = {'Left Hit','Left Miss','Right Hit','Right Miss','No Go'};
choiceList      = zeros(nTrials , 1);
for ii = 1:numel(uniqueChoices)
    choiceIdx = strcmp(d.trial_outcome,uniqueChoices{ii});
    choiceList(choiceIdx) = ii;
end
choicePrint     = {'co','c^','ro','r^','k.'};
colorsByStim    = {'b','b','b','b','g','m','m','m','m'};
response        = zeros(size(choiceList));
response(choiceList == 1 | choiceList == 2) = 1; % left = true, right  = false
% response(choiceList == 5) = missing;


%% Visualize Data - Cluster Response by Stim Category (high or low)
% div1 = zeros(size(d.trial_outcome));
% div1(d.stim_idx<5) = 0;
% div1(d.stim_idx>5) = 1;
% div1(d.stim_idx==5) = NaN;
% categories = d.stim_idx;
% categories(categories==5) = [];
% utils.plotClusterResponse(cResponse2,d.stim_idx,nClusters)


%% Remove Boundary Stimulus
% Make sure uncategorizable stimulus is not input into the GLM
[Xdsgn2,response2] = utils.removeBoundaryStim(Xdsgn,response,d.stim_idx,5);

%% Fit GLM to Data
logGLM  = glmfit(Xdsgn2,response2,'binomial');
const   = logGLM(1);
logGLM  = logGLM(2:end);


%% Plot by Cluster
stimFrame   = 75;
timeVec     = (cutIn-stimFrame)/fs;
% utils.plotClusterWeights(logGLM,nClusters,ntfilt,timeVec);

%% Plot Cluster Response within CutIn
figure
set(gcf,'Color','w')
utils.plotAverageResponse(cResponse3,fs,75,cutIn)


%% Plot Single Weights
figure
set(gcf,'Color','w')
utils.plotSingleWeights(logGLM,nClusters)


%% Calculate Proportion of Correct Trials
instRate            = (Xdsgn2*logGLM + const);
resp                = exp(instRate)./(1+exp(instRate));
resp2               = zeros(size(resp));
resp2(resp>0.5)     = 1;
equalInd            = response2 == resp2;
propCorrect         = sum(equalInd)/numel(equalInd);
fprintf('GLM predicts %.2f%% of trials correctly\n',propCorrect*100)


%% Future directions
% calculate accuracuracy for low vs. high besides accuracy for choice
