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

nClusters   = 8;
nFrames     = 200; % frames per trial
nTrials     = 153;
nChoices    = 4;
nStims      = 9;

fs          = 30; % frame rate

firstFrame  = 75;
lastFrame   = 85;

cutIn       = 75:105; % frames of neural data fed into GLM
ntfilt      = length(cutIn); % Size of time filter

%% Set Figure
figure
set(gcf,'Color','w')


%% Generate AM noise stimulus
% Stimulus is amplitude modulated noise. Begins at frame 75 and lasts for
% 30 frames. Stimulus frames are nonzero integer and no-stim frames are
% zero
stims       = 1:nStims;
reps        = ones(size(stims))*nTrials/nStims;
stimOrder   = repelem(stims,reps);
stimOrder   = stimOrder(randperm(length(stimOrder)));
StimulusMat = zeros(nTrials,nFrames);
for n = 1:nTrials
    StimulusMat(n,firstFrame:lastFrame) = repelem(stimOrder(n),lastFrame-firstFrame+1);
end
% StimulusMat(:,firstFrame:lastFrame) = 1;
Stimulus    = reshape(StimulusMat',[1,nTrials*nFrames]);

paddedStim  = [zeros(1,ntfilt-1) , Stimulus];

plot(Stimulus(1:nFrames*5),'k','LineWidth',1.5)
title('Stimulus Waveform')
xlabel('Frames')
ylabel('Level (a.u.)')
grid on
axis tight


%% Create Clusters Activity (after dim reduction)
% first create prototypical shape for each cluster
shape = zeros(nClusters,nFrames);
for ii = 1:nClusters
    mu1     = firstFrame*0.8;
    mu2     = lastFrame*0.7;
    sigma1  = 0.5;
    sigma2  = 0.5;
    x       = (1:nFrames)';
    gauss1  = exp(-(x-mu1).^2/2/sigma1^2) * ii;
    gauss2  = 0.2*exp(-(x-mu2).^2/2/sigma2^2) * (nClusters-ii);
    shape(ii,:)   = gauss1+gauss2;
    shape(ii,:)   = shape(ii,:)/norm(shape);
end

% then make each trial's a function of the sound played
cResponse = zeros(nTrials,nFrames,nClusters); % cluster response
for ii = 1:nClusters
    randNoise = randn(nTrials,nFrames)*0.8;
    cResponse(:,:,ii) = shape(ii,:).*randNoise + 1./(stimOrder');
end
plot(cResponse(:,:,1)')

% Reshape Cluster Response as Design Matrix
% Design matrix is trials by timepoints*clusters
cResponse2  = cResponse(:,cutIn,:);
Xdsgn       = reshape(cResponse2,[nTrials,length(cutIn)*nClusters]);
imagesc(Xdsgn)
colorbar


%% Create Simulated Beta Weights
betaWeights = zeros(ntfilt,nClusters);
for ii = 1:nClusters
    mu1     = ntfilt - rand*ntfilt*0.5 - 0.5;
    mu2     = mu1 - rand*ntfilt*0.3 - 0.5;
    sigma1  = 0.5;
    sigma2  = 2;
    x       = (1:ntfilt)';
    gauss1  = exp(-(x-mu1).^2/2/sigma1^2);
    gauss2  = 0.2*exp(-(x-mu2).^2/2/sigma2^2);
    k       = gauss1-gauss2;
    k      = k/norm(k);
    betaWeights(:,ii)     = k;
end

plot(betaWeights,'LineWidth',2)
title('Generated Filter')
grid on

% reshape betaWeigths to match the design matrix
betas = reshape(betaWeights,[1,ntfilt*nClusters]);


%% Generate Response from Logistic function
instantRate = Xdsgn*betas';
instantProb = 1./(1+exp(-instantRate));
response    = binornd(1,instantProb);


%% Fit GLM to Data
logGLM  = glmfit(Xdsgn,response,'binomial');
const   = logGLM(1);
logGLM  = logGLM(2:end);

