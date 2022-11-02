%% Setup
loadPath = 'W:\Code\Tommy\GLM Data\2AFC_GLM\Analysis Output\Partial Models';
loadName = 'WT82_021422.mat';
% loadName = 'TlxMH02_070522.mat';

%% Load Data
load(fullfile(loadPath,loadName),'config','predAcc','XdsgnCell')

%% Plot Change in Accuracy
meanPredAcc = cellfun(@mean,predAcc);
stdPredAcc  = cellfun(@std,predAcc);
err         = [stdPredAcc(1:end-1);-stdPredAcc(1:end-1)]/sqrt(config.nFolds);
figure('Color','w')
g(1) = bar(meanPredAcc(1:end-1));
hold on
errPlot = errorbar(1:config.nClusters,meanPredAcc(1:end-1),err(1,:),err(2,:),'Color','k','LineStyle','none');
g(2) = yline(meanPredAcc(end),'k--');
hold off
box off
ylim([0 1])
legend(g,{'Mean Prediction Accuracy','Accuracy of Full Model'})

title(['Partial Models ',config.MouseID,'/',config.sessionDate])
ylabel('Accuracy')
xlabel('Removed Cluster')