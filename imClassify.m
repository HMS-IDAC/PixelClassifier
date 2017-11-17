function [imL,classProbs] = imClassify(imFeat,treeBag,nSubsets)

[nr,nc,nVariables] = size(imFeat);
rfFeat = reshape(imFeat,[nr*nc,nVariables]);

if nSubsets == 1
    % ----- single thread
    
    [~,scores] = predict(treeBag,rfFeat);
    [~,indOfMax] = max(scores,[],2);
else
    % ----- parallel
    
    indices = round(linspace(0,size(rfFeat,1),nSubsets+1));

    ftsubsets = cell(1,nSubsets);
    for i = 1:nSubsets
        ftsubsets{i} = rfFeat(indices(i)+1:indices(i+1),:);
    end

    scsubsets = cell(1,nSubsets);
    imsubsets = cell(1,nSubsets);
    parfor i = 1:nSubsets
        [~,scores] = predict(treeBag,ftsubsets{i});
        [~,indOfMax] = max(scores,[],2);
        scsubsets{i} = scores;
        imsubsets{i} = indOfMax;
    end

    scores = zeros(nVariables,length(treeBag.ClassNames));
    indOfMax = zeros(nVariables,1);
    for i = 1:nSubsets
        scores(indices(i)+1:indices(i+1),:) = scsubsets{i};
        indOfMax(indices(i)+1:indices(i+1)) = imsubsets{i};
    end
end

imL = reshape(indOfMax,[nr,nc]);
classProbs = zeros(nr,nc,size(scores,2));
for i = 1:size(scores,2)
    classProbs(:,:,i) = reshape(scores(:,i),[nr,nc]);
end

end