% Function to create several copies of the design matrix with "knocked"
% clusters - create partial models from the same full model

% Output: 
%   XdsgnFinal - cell array with as many rows as models to run (one for
%   each knocked scenario and one for the full model if knockSize>1) and
%   two columns. The first column is the design matrix for a given setting
%   and the second column is the IDs of the variables removed from the
%   original design matrix. Every combination of knocks of size knockSize
%   will be performed, total number of models will be a combination without
%   repetition (nchoosek) of clusters plus the full model

function XdsgnFinal = knockDesgnMatrix(Xdsgn,knockSize,nClusters)

knockGroups = nchoosek(1:nClusters,knockSize);
totalKnocks = size(knockGroups,1);

XdsgnFinal  = cell(size(knockGroups,1)+1,2);


for ii = 1:totalKnocks % iterate through every combination of knockings
    if isequal(1:nClusters,knockGroups) %don't remove any cluster if knockedSize is 1
        currentKeep = 1:nClusters;
    else
        currentKeep = setdiff(1:nClusters,knockGroups(ii,:));
    end
    XdsgnFinal{ii,1} = Xdsgn(:,currentKeep);
    XdsgnFinal{ii,2} = currentKeep;
end

if totalKnocks > 1
    XdsgnFinal{end,1} = Xdsgn;
    XdsgnFinal{end,2} = 1:nClusters;
end