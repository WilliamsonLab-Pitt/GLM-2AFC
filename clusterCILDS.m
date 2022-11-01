%% Load Session Data
latentDims      = 15;
mouseID         = 'TlxMH02';
sessionDate     = '070522';
partition       = '1-3-Session28Run14';
analysisFolder  = ['W:\Data\2AFC_Imaging\IT\2P\',num2str(mouseID),'\',num2str(sessionDate),'\',num2str(partition),'\MAT'];
savePath        = 'C:\Users\Williamson_Lab\Documents\Tommy\GLM - 2AFC\CILDS Saved Files';
clusterFile     = 'hier_clusters_n6';
[~,nClusters,d,clusterList] = utils.getSessionData(analysisFolder,clusterFile);
[~,nFrames,nTrials] = size(d.spike_zscores);
fprintf('[1]\tSession Data Loaded\n')


%% Set CILDS Paths
cildsPath       = 'C:\Users\Williamson_Lab\Documents\Tommy\CILDS - Project\cilds';
oasisPath       = 'C:\Users\Williamson_Lab\Documents\Tommy\OASIS - Project\OASIS_matlab';
badOasisPath    = 'C:\Users\Williamson_Lab\Documents\Tommy\CILDS - Project\cilds\oasis_matlab';
addpath(genpath(cildsPath))
addpath(genpath(oasisPath))
rmpath(genpath(badOasisPath))
fprintf('[2]\tCILDS Path Set\n')


%% Run Pre-CILDS
saveName                = [mouseID,'_',sessionDate];
addpath(savePath);
cilds_tools.saveClustersForCILDS(d,latentDims,clusterList,saveName,savePath);
fprintf('[3]\tPre-CILDS Settings Saved\n')


%% Run CILDS
for ii = 1:nClusters
    loadName    = [mouseID,'_',sessionDate,'_clst_',num2str(ii),'.mat'];
    load(loadName,'Observation','RunParam');
    [EstParam, Result, testll, trainll, InitParam, TrainResult] = cilds(Observation,RunParam,'maxIter',250);
    saveName    = [mouseID,'_',sessionDate,'_resultCIDLS_',num2str(latentDims),'D','_clst',num2str(ii),'.mat'];
    saveName    = fullfile(savePath,saveName);
    save(saveName,'EstParam','Result','testll','trainll','InitParam','TrainResult')
    fprintf('[4]\tCILDS Done\n')
end


%% Reduce CILDS Output to lower dimensional state with PCA
% don't forget to load the file
clusterResponse = zeros(nClusters,nFrames,nTrials);
for ii = 1:nClusters
    loadName    = [mouseID,'_',sessionDate,'_resultCIDLS_',num2str(latentDims),'D','_clst',num2str(ii),'.mat'];
    loadName    = fullfile(savePath,loadName);
    load(loadName,'Result');
    currentData = [Result.z]';
    currentPCA  = pca(currentData);
    coeff       = currentPCA(:,1);
    currentNE   = currentData*coeff;
    clusterResponse(ii,:,:) = reshape(currentNE,[1,nFrames,nTrials]);
    clusterResponse(ii,:,:) = rescale(clusterResponse(ii,:,:));
end
saveName = [mouseID,'_',sessionDate,'_cluster1Dim.mat'];
save(fullfile(savePath,saveName),'clusterResponse');


%% Cleanup
% Delete CILDS Temporary Files
searchClean = dir('.\*train.mat');
for ii = 1:length(searchClean)
    delete(fullfile(searchClean(ii).folder,searchClean(ii).name))
end

%% Send Slack Notification
webbhookURL = 'https://hooks.slack.com/services/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';
msgTxt      = ['CILDS preparation of ', mouseID , '\' , sessionDate , ' finished running'];
[~,~]       = SendSlackNotification(webbhookURL,msgTxt,[],'Mouse-Track','https://upload.wikimedia.org/wikipedia/commons/2/21/Matlab_Logo.png');



