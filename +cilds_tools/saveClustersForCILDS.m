function saveClustersForCILDS(d,latentDims,clusterList,saveName,savePath)
nClusters = length(unique(clusterList));
for ii = 1:nClusters
    %% Reconstruct data structure
    currentList         = clusterList==ii;
    data                = d;
    data.spike_zscores  = data.spike_zscores(currentList,:,:);
    data.dF_F           = data.dF_F(currentList,:,:);

    %% Reshape Calcium Data
    % Create "Observation" structure array, that has as many dimensions as
    % trials and in each only one field called "y". Inside of that field is a
    % matrix of neurons (rows) by time per trial
    Observation = struct('y',[]);
    nNeurons    = size(data.spike_zscores,1);
    nTrials     = size(data.spike_zscores,3);

    for jj = 1:nTrials
        %Observation(ii).y = data.calcium_traces{ii};
        Observation(jj).y = data.dF_F(:,:,jj);
    end

    %% Create Run Parameters
    % Create structure "RunParam" that CILDS code uses to get number of
    % neurons, latent dimensions and division of training and testing data for
    % cross validation
    % Default division for cross validation: First half of trials is used for
    % training and second half for testing. If odd number of trials, the
    % testing half will be one element larger than training
    % RunParam            = struct('N_LATENT',[],'N_NEURON',[],'TRAININD',[],'TESTIND',[]);
    RunParam            = struct('N_LATENT',[],'N_NEURON',[]);
    RunParam.N_LATENT   = latentDims; % set arbitrary number
    RunParam.N_NEURON   = nNeurons;
    % RunParam.TRAININD   = 1:floor(nTrials/2);
    % RunParam.TESTIND    = floor(nTrials/2)+1:nTrials;

    %% Save Parameters in MAT File
    % Save "Observation" and "RunParam" in a mat file under the name and path
    % indicated below
    % saveName    = 'WT102_041122_Active_preCILDS.mat';
    % savePath    = 'C:\Users\tomsu\Box\CMU Research\Williamson Lab\CILDS\Tommy Saved Files';
    newSaveName = [saveName,'_clst_',num2str(ii),'.mat'];
    save(fullfile(savePath,newSaveName) , 'Observation','RunParam')

end
end
