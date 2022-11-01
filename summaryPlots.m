load('GLM Summary Data 2.mat','summaryData')
catDims = [1,2,3;4,5,6]; % each row is a category (ET, IT)
[nCats,nStages] = size(catDims);
meanPred = zeros(nStages);
allPred  = zeros(1,numel(catDims));
allErr   = zeros(1,numel(catDims));
for ii = 1:numel(catDims)
    allPred(ii) = mean(summaryData(ii).predAcc);
    allErr(ii)  = std(summaryData(ii).predAcc) / sqrt(numel(summaryData(ii).predAcc));
end


figure
bar(1:3,allPred(1:3),'FaceColor','b')
hold on
bar(4:6,allPred(4:6),'FaceColor','g')
errorbar(1:3,allPred(1:3),allErr(1:3),'Color','k','LineStyle','none')
errorbar(4:6,allPred(4:6),allErr(4:6),'Color','k','LineStyle','none')
axis padded
hold off
set(gca,'XTick',1:6)
set(gca,'XTickLabel',{'Early','Middle','Late','Early','Middle','Late'})