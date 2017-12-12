function I = imreadGrayscaleDouble(path)
    I = imread(path);
    if size(I,3) == 2 || size(I,3) > 3
        I = I(:,:,1);
    elseif size(I,3) == 3
        I = rgb2gray(I);
    end
    if isa(I,'uint8')
        I = double(I)/255;
    elseif isa(I,'uint16')
        I = double(I)/65535;
    else
        warning('did not recognize image class')
    end
end