function [F,featNames] = imageFeatures(I,sigmas,offsets,osSigma,radii,cfSigma,logSigmas,sfSigmas)

F = [];
featIndex = 0;
featNames = {};

derivNames = {'d0','dx','dy','dxx','dxy','dyy','hessEV1','hessEV2'};
for sigma = sigmas
    for i = 1:length(derivNames)
        featIndex = featIndex+1;
        featNames{featIndex} = [sprintf('sigma%d',sigma) derivNames{i}];
    end
    D = zeros(size(I,1),size(I,2),8);
    [D(:,:,1),D(:,:,2),D(:,:,3),D(:,:,4),D(:,:,5),D(:,:,6),D(:,:,7),D(:,:,8)] = derivatives(I,sigma);
    F = cat(3,F,D);
    featIndex = featIndex+1;
    featNames{featIndex} = sprintf('sigma%dedges',sigma);
    F = cat(3,F,sqrt(D(:,:,2).^2+D(:,:,3).^2)); % edges
end

if ~isempty(offsets)
    J = filterGauss2D(I,osSigma);
    for r = offsets
        aIndex = 0;
        for a = 0:pi/4:2*pi-pi/4
            aIndex = aIndex+1;
            v = r*[cos(a) sin(a)];
            T = imtranslate(J,v,'OutputView','same');
            F = cat(3,F,T);
            featIndex = featIndex+1;
            featNames{featIndex} = sprintf('offset%da%d',r,aIndex);
        end
    end
end

if ~isempty(radii)
    for r = radii
        [C1,C2] = circlikl(I,r,cfSigma,16,0.5);
        featIndex = featIndex+1;
        featNames{featIndex} = sprintf('circfeat%dC1',r);
        F = cat(3,F,C1);
        featIndex = featIndex+1;
        featNames{featIndex} = sprintf('circfeat%dC2',r);
        F = cat(3,F,C2);
    end
end

if ~isempty(logSigmas)
    for sigma = logSigmas
        featIndex = featIndex+1;
        featNames{featIndex} = sprintf('sigma%dlog',sigma);
        F = cat(3,F,filterLoG(I,sigma));
    end
end

if ~isempty(sfSigmas)
    for sigma = sfSigmas
        featIndex = featIndex+1;
        featNames{featIndex} = sprintf('sigma%dsteer',sigma);
        F = cat(3,F,steerableDetector(I,4,sigma));
    end
end

end