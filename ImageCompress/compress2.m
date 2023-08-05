clc;clear;close all;
img = imread('cameraman.png');

n = 512;

data = img(150,1:n)

DPCM = zeros(size(data));

DPCM(1) = data(1);
for i = 2 : length(data)
    DPCM(i) = data(i) - data(i-1);
end
DPCM