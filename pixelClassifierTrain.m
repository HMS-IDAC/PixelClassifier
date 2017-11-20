clear, clc

%% set parameters

trainPath = '~/Workspace/DataForPC/Train';
% where images and labes are;
% images are assumed to have the same size;
% every image should have the same number of accompanied label masks,
% labeled <image name>_ClassX.png, where X is the index of the label;
% labels can be created using ImageAnnotationBot:
% https://www.mathworks.com/matlabcentral/fileexchange/64719-imageannotationbot

sigmas = [1 2 3];
% basic image features are simply derivatives (up to second order) in different scales;
% this parameter specifies such scales; details in imageFeatures.m

offsets = [3 5];
% in pixels; for offset features (see imageFeatures.m)
% set to [] to ignore offset features
osSigma = 2;
% sigma for offset features

radii = [15 20 25];
% range of radii on which to compute circularity features (see imageFeatures.m)
% set to [] to ignore circularity features
cfSigma = 2;
% sigma for circularity features

logSigmas = [1 2];
% sigmas for LoG features (see imageFeatures.m)
% set to [] to ignore LoG features

sfSigmas = [1 2];
% steerable filter features sigmas (see imageFeatures.m)
% set to [] to ignore steerable filter features

nTrees = 20;
% number of decision trees in the random forest ensemble

minLeafSize = 60;
% minimum number of observations per tree leaf

pctMaxNPixelsPerLabel = 1;
% percentage of max number of pixels per label (w.r.t. num of pixels in image);
% this puts a cap on the number of training samples and can improve training speed

modelPath = '~/Workspace/model.mat';
% path to where model will be saved

% 
% no parameters to set beyond this point
%

%% read images/labels

[imageList,labelList,labels] = parseLabelFolder(trainPath);
nLabels = length(labels);

%% training samples cap

maxNPixelsPerLabel = (pctMaxNPixelsPerLabel/100)*size(imageList{1},1)*size(imageList{1},2);
nImages = length(imageList);
for imIndex = 1:nImages
    L = labelList{imIndex};
    for labelIndex = 1:nLabels
        LLI = L == labelIndex;
        nPixels = sum(sum(LLI));
        rI = rand(size(L)) < maxNPixelsPerLabel/nPixels;
        L(LLI) = 0;
        LLI2 = rI & (LLI > 0);
        L(LLI2) = labelIndex;
    end
    labelList{imIndex} = L;
end

%% construct train matrix

ft = [];
lb = [];
tic
for imIndex = 1:nImages
    fprintf('computing features from image %d of %d\n', imIndex, nImages);
    [F,featNames] = imageFeatures(imageList{imIndex},sigmas,offsets,osSigma,radii,cfSigma,logSigmas,sfSigmas);
    L = labelList{imIndex};
    [rfFeat,rfLbl] = rfFeatAndLab(F,L);
    ft = [ft; rfFeat];
    lb = [lb; rfLbl];
end
fprintf('time spent computing features: %f s\n', toc);

%% training

fprintf('training...'); tic
[treeBag,featImp,oobPredError] = rfTrain(ft,lb,nTrees,minLeafSize);
figureQSS
subplot(1,2,1), barh(featImp), set(gca,'yticklabel',featNames'), set(gca,'YTick',1:length(featNames)), title('feature importance')
subplot(1,2,2), plot(oobPredError), title('out-of-bag classification error')
fprintf('training time: %f s\n', toc);

%% save model

model.treeBag = treeBag;
model.sigmas = sigmas;
model.offsets = offsets;
model.osSigma = osSigma;
model.radii = radii;
model.cfSigma = cfSigma;
model.logSigmas = logSigmas;
model.sfSigmas = sfSigmas;
save(modelPath,'model');

disp('done training')