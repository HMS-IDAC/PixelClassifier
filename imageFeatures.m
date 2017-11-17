function F = imageFeatures(I,sigmas,offsets,osSigma,radii,cfSigma,logSigmas,sfSigmas)

F = [];
for sigma = sigmas
    D = zeros(size(I,1),size(I,2),8);
    [D(:,:,1),D(:,:,2),D(:,:,3),D(:,:,4),D(:,:,5),D(:,:,6),D(:,:,7),D(:,:,8)] = derivatives(I,sigma);
    F = cat(3,F,D);
    F = cat(3,F,sqrt(D(:,:,2).^2+D(:,:,3).^2)); % edges
end

if ~isempty(offsets)
    J = filterGauss2D(I,osSigma);
    for r = offsets
        for a = 0:pi/4:2*pi-pi/4
            v = r*[cos(a) sin(a)];
            T = imtranslate(J,v,'OutputView','same');
            F = cat(3,F,T);
        end
    end
end

if ~isempty(radii)
    for r = radii
        [C1,C2] = circlikl(I,r,cfSigma,16,0.5);
        F = cat(3,F,C1);
        F = cat(3,F,C2);
    end
end

if ~isempty(logSigmas)
    for sigma = logSigmas
        F = cat(3,F,filterLoG(I,sigma));
    end
end

if ~isempty(sfSigmas)
    for sigma = sfSigmas
        F = cat(3,F,steerableDetector(I,4,sigma));
    end
end

end