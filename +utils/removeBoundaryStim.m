function [Xdsgn,response,stim2remove] = removeBoundaryStim(Xdsgn,response,outcomeList,stim2remove)
trials2remove   = outcomeList == stim2remove;
Xdsgn(trials2remove,:)      = [];
response(trials2remove,:)   = [];
end