function [d0,dx,dy,dxx,dxy,dyy,eigVal1,eigVal2] = derivatives(I,sigma)

s = sigma;

w = ceil(4*s);
x = -w:w;

g = exp(-x.^2/(2*s^2)) / (sqrt(2*pi)*s);
gx = -x/s^2 .* g;
gxx = x.^2 .* g / s^4; % -1/s^2 term subtracted below

inputXT = padarray(I, [w w], 'symmetric');

f_blur = conv2(g, g, inputXT, 'valid') / s^2; % col, row kernel

f_xx = conv2(g, gxx, inputXT, 'valid') - f_blur;
f_xy = conv2(gx, gx, inputXT, 'valid');
f_yy = conv2(gxx, g, inputXT, 'valid') - f_blur;

dxx = f_xx;
dxy = f_xy;
dyy = f_yy;

d0 = f_blur;
dx = conv2(g,gx,inputXT,'valid');
dy = conv2(gx,g,inputXT,'valid');

alpha = (f_xx + f_yy)/2;
beta = sqrt((f_xx - f_yy) .^2 + 4*f_xy .^2)/2;
eigVal1 = alpha+beta;
eigVal2 = alpha-beta;

end