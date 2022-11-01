%% Setup
clear; clc; close all;

%% Get Session
% WT82      -> 012522 | 013122 | 021422
% TlxMH02   -> 
addpath(genpath('W:\Code\Becca'))
d_c = choose_experiment('C:\Users\Williamson_Lab\Documents\Tommy\GLM - 2AFC\2AFC_Data_Files - Tommy Analysis.csv');
rmpath(genpath('W:\Code\Becca'))

%% Set Config Structure
% config structure will have general configurations for all
% cross-validation folds of a single session
config.MouseID          = d_c{1,3}{1};
config.firstFrame       = 90;
config.lastFrame        = 105;
config.fs               = 30;
config.dimRedFolder     = 'C:\Users\Williamson_Lab\Documents\Tommy\GLM - 2AFC\CILDS Saved Files\Hierarchical Clustering\6 Clusters';
if (d_c{1,4}) < 100000
    config.sessionDate    = strcat('0',num2str(d_c{1,4}));
    config.analysisFolder = strcat(d_c{1,1}, d_c{1,2}, '\2P\', d_c{1,3}, '\0', num2str(d_c{1,4}), '\',d_c{1,6});
else
    config.sessionDate    = d_c{1,4};
    config.analysisFolder = strcat(d_c{1,1}, d_c{1,2}, '\2P\', d_c{1,3}, '\', num2str(d_c{1,4}), '\',d_c{1,6}');
end
config.analysisFolder       = config.analysisFolder{1};
% config.analysisFolder(1)    = 'W';
% ptInd                       = strfind(config.analysisFolder,'PT');
% if ~isempty(ptInd)
%     config.analysisFolder(ptInd) = 'E';
% end


%% Run Cross-Validated Bernoulli GLM
nFolds = 5;
[betas,predAcc] = fun_dimRedGLM_bernoulli(config,nFolds);


%% Save in summary file
load('GLM Summary Data 2.mat','summaryData');
s = struct('mouseID',[],'Date',[],'betas',[],'predAcc',[]);
numSessions = length(summaryData);
summaryData(numSessions+1).mouseID  = config.MouseID;
summaryData(numSessions+1).Date     = config.sessionDate;
summaryData(numSessions+1).betas    = betas;
summaryData(numSessions+1).predAcc  = predAcc;
save('GLM Summary Data 2.mat','summaryData')








