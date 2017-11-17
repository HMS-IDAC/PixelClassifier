function [treeBag,featImp,oobPredError] = rfTrain(rfFeat,rfLbl,ntrees,minleafsize)
% ntrees = 20; minleafsize = 60;

opt = statset('UseParallel',true);
treeBag = TreeBagger(ntrees,rfFeat,rfLbl,'MinLeafSize',minleafsize,'oobvarimp','on','opt',opt);
if nargout > 1
    featImp = treeBag.OOBPermutedVarDeltaError;
end
if nargout > 2
    oobPredError = oobError(treeBag);
end

end