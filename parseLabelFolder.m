function [imageList,labelList,classIndices] = parseLabelFolder(dirPath)

files = dir(dirPath);

% how many annotated images (all that don't have 'Class' in the name)
nImages = 0;
for i = 1:length(files)
    fName = files(i).name;
    if ~contains(fName,'Class') && ~contains(fName,'.mat') && fName(1) ~= '.'
        nImages = nImages+1;
        imagePaths{nImages} = [dirPath filesep fName];
    end
end

% list of class indices per image
classIndices = [];
[~,imName] = fileparts(imagePaths{1});
for i = 1:length(files)
    fName = files(i).name;
    k = strfind(fName,'Class');
    if contains(fName,imName) && ~isempty(k)
        [~,imn] = fileparts(fName);
        classIndices = [classIndices str2double(imn(k(1)+5:end))];
    end
end
nClasses = length(classIndices);

% read images/labels
imageList = cell(1,nImages);
labelList = cell(1,nImages);
for i = 1:nImages
    I = imreadGrayscaleDouble(imagePaths{i});
    [imp,imn] = fileparts(imagePaths{i});
    L = uint8(zeros(size(I)));
    for j = 1:nClasses
        classJ = imread([imp filesep imn sprintf('_Class%d.png',classIndices(j))]);
        classJ = (classJ(:,:,1) > 0);
        L(classJ) = j;
    end
%     imshow([repmat(255*I,[1 1 3]) label2rgb(L,'winter','k')]), pause

    imageList{i} = I;
    labelList{i} = L;
end

end