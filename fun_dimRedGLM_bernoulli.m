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

function [betas,predAcc,XdsgnFinal,figArray] = fun_dimRedGLM_bernoulli(config,varargin)
%% Input Parsing
p               = inputParser;
defaultKnock    = config.nClusters;
defaultFolds    = 1;
addOptional(p,'nFolds',defaultFolds)
addOptional(p,'knockSize',defaultKnock)
parse(p,varargin{:})


%% Variable Setup
% create variables from config, one variable with the name of each field of
% config, each one with the contents of each field in the structure
cellfun(@(x,y) assignin('caller',x,y),fieldnames(config),struct2cell(config));

analysisFolder = [config.analysisFolder,filesep,'MAT'];

nFolds      = p.Results.nFolds;
knockSize   = p.Results.knockSize;
cutIn       = firstFrame:lastFrame; % frames of neural data fed into GLM

% Set Figure
figArray = gobjects(0);


%% Get Session Data
% clusterResponse array: clusters by frames by trials
% dimRedFolder    = 'C:\Users\Williamson_Lab\Documents\Tommy\GLM - 2AFC\CILDS Saved Files\K-Means Clustering';
loadName        = [MouseID,'_',sessionDate,'_cluster1Dim.mat'];
% [clusterResponse,nClusters,d] = utils.getSessionData(analysisFolder,'cluster_identities');
[clusterResponse,nClusters,d] = utils.getDimRedData(analysisFolder,dimRedFolder,loadName);
nTrials     = size(d.spike_zscores,3);

%% Reshape Cluster Response
cResponse2      = clusterResponse(:,cutIn,:);
% Xdsgn           = reshape(cResponse2,[nTrials,length(cutIn)*nClusters]);
cResponse2Ave   = squeeze(mean(cResponse2,2));
% cResponse2Ave   = squeeze(max(cResponse2,[],2));
% cResponse2Ave   = squeeze(median(cResponse2,2));
Xdsgn           = cResponse2Ave';
figArray(end+1) = figure('Color','w','Visible','off');
imagesc(Xdsgn)
colorbar


%% Average Cluster Response by Trial Type
cResponse3 = utils.averageClusterByStim(clusterResponse,d.stim_idx);
figArray(end+1) = figure('Color','w','Visible','off');
plotting.plotAverageResponse(cResponse3,fs,75,60:120)


%% Find list of choices
% uniqueChoices = unique(currentData.trial_outcome);
uniqueChoices   = {'Left Hit','Left Miss','Right Hit','Right Miss','No Go'};
choiceList      = zeros(nTrials , 1);
for ii = 1:numel(uniqueChoices)
    choiceIdx = strcmp(d.trial_outcome,uniqueChoices{ii});
    choiceList(choiceIdx) = ii;
end

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
% plotting.plotClusterResponse(cResponse2,d.stim_idx,nClusters)


%% Remove Boundary Stimulus
% Make sure uncategorizable stimulus is not input into the GLM
% [Xdsgn2,response2] = utils.removeBoundaryStim(Xdsgn,response,d.stim_idx,5);


%% Allow Cluster Knocking
XdsgnFinal  = utils.knockDesgnMatrix(Xdsgn,knockSize,nClusters);
totalModels = size(XdsgnFinal,1);

%% Iterate thorugh Knocks
betas   = cell(1,totalModels);
predAcc = cell(1,nFolds);
for jj = 1:totalModels
    %% Choose "Knocked" design matrix
    XdsgnNow        = XdsgnFinal{jj,1};
    currentClusters = size(XdsgnNow,2);
    %% Make Cross Validation Folds
    currentBeta     = zeros(nFolds,currentClusters);
    currentPredAcc  = zeros(1,nFolds);
    trialsPerFold   = floor(nTrials / nFolds);
    for ii = 1:nFolds
        testTrials  = (ii-1)*trialsPerFold+1 :(ii)*trialsPerFold;
        if isequal(testTrials,nTrials)
            trainTrials = setdiff(1:nTrials,testTrials);
        else
            trainTrials = testTrials;
        end
        Xtrain      = XdsgnNow(trainTrials,:);
        responseTn  = response(trainTrials);
        Xtest       = XdsgnNow(testTrials,:);
        responseTs  = response(testTrials);


        %% Fit GLM to Data
        logGLM  = glmfit(Xtrain,responseTn,'binomial');
        const   = logGLM(1);
        logGLM  = logGLM(2:end);

        %% Calculate Proportion of Correct Trials
        instRate            = (Xtest*logGLM + const);
        resp                = exp(instRate)./(1+exp(instRate));
        resp2               = zeros(size(resp));
        resp2(resp>0.5)     = 1;
        equalInd            = responseTs == resp2;
        propCorrect         = sum(equalInd)/numel(equalInd);
%         fprintf('GLM predicts %.2f%% of trials correctly\n',propCorrect*100)

        %% Save Weights for current fold
        currentBeta(ii,:) = logGLM;
        currentPredAcc(ii) = propCorrect;
    end
    betas{jj}   = currentBeta;
    predAcc{jj} = currentPredAcc;
end

%% Plot Final Data
% Plot Cluster Weights
% stimFrame   = 75;
% timeVec     = (cutIn-stimFrame)/fs;
% figArray(end+1) = figure('Color','w','Visible','off');
% plotting.plotClusterWeights(mean(betas{end}),nClusters,ntfilt,timeVec);

% Plot Cluster Response within CutIn
set(gcf,'Color','w')
figArray(end+1) = figure('Color','w','Visible','off');
plotting.plotAverageResponse(cResponse3,fs,75,cutIn)

% Plot Single Weights
set(gcf,'Color','w')
figArray(end+1) = figure('Color','w','Visible','off');
plotting.plotSingleWeights(mean(abs(betas{end})),nClusters)