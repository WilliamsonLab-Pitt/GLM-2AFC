%% Setup
clear; clc; close all;

%% Get Session
% WT82      -> 012522 | 013122 | 021422
% TlxMH02   -> 060822 | 061622 | 070522
addpath(genpath('W:\Code\Becca'))
d_c = choose_experiment('W:\Code\Tommy\GLM Data\2AFC_GLM\2AFC_Data_Files - Tommy Analysis.csv');
rmpath(genpath('W:\Code\Becca'))

%% Set Config Structure
% config structure will have general configurations for all
% cross-validation folds of a single session
config.MouseID          = d_c{1,3}{1};
config.nClusters        = 6;
config.firstFrame       = 76;
config.lastFrame        = 91;
config.fs               = 30;
config.nFolds           = 4;
config.dimRedFolder     = 'W:\Code\Tommy\GLM Data\2AFC_GLM\CILDS Saved Files\Hierarchical Clustering\6 Clusters';
% config.dimRedFolder     = 'W:\Code\Tommy\GLM Data\2AFC_GLM\CILDS Saved Files\K-Means Clustering\6 Clusters';
if (d_c{1,4}) < 100000
    config.sessionDate    = strcat('0',num2str(d_c{1,4}));
    config.analysisFolder = strcat(d_c{1,1}, d_c{1,2}, '\2P\', d_c{1,3}, '\0', num2str(d_c{1,4}), '\',d_c{1,6});
else
    config.sessionDate    = d_c{1,4};
    config.analysisFolder = strcat(d_c{1,1}, d_c{1,2}, '\2P\', d_c{1,3}, '\', num2str(d_c{1,4}), '\',d_c{1,6}');
end
config.analysisFolder       = config.analysisFolder{1};


%% Run Cross-Validated Bernoulli GLM
[betas,predAcc,XdsgnCell,figArray] = fun_dimRedGLM_bernoulli(config,'nFolds',config.nFolds,'knockSize',1);
set(figArray,'Visible','on')


%% Save in summary file
choice   = input('Save data? [y/n] ','s');
baseSave = 'W:\Code\Tommy\GLM Data\2AFC_GLM\Analysis Output\Partial Models';
if strcmp(choice,'y')
    saveName = [baseSave,filesep,config.MouseID,'_',config.sessionDate];
    save([saveName,'.mat'],'config','predAcc','betas','XdsgnCell')
    saveas(figArray,[saveName,'.fig'])
end
