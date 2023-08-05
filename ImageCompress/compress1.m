clc;clear;close all;
img = imread('cameraman.png');

img_array = reshape(img,[1,size(img,1)*size(img,2)]);

img_hist = hist(double(img_array),0:255);
img_proba = img_hist/(size(img,1)*size(img,2));
img_proba_value = zeros(size(img_proba));

img_proba_value(1) = img_proba(1) / 2;
for end_i = 2 : 256
    img_proba(end_i) = img_proba(end_i) + img_proba(end_i-1);
    img_proba_value(end_i) = (img_proba(end_i) + img_proba(end_i-1))/2;
end

n = 8;

%% Encoding
data = img(150,1:n)

data_enc = 1;
high = 1;
low = 0;
for end_i = 1 : n
    range = high - low;
    high = low + range * img_proba(data(end_i));
    if(data(end_i) ~= 0)
        low = low + range * img_proba(data(end_i)-1);
    else
        low = low;
    end
    data_enc = low + (high-low)/2;
end
data_enc


% dec
data_dec = zeros(1,n);
high = 1;
low = 0;
for end_i = 1 : n
    range = high - low;
    c = (data_enc - low) / range;
    for k = 1 : size(img_proba,2)
        if c < img_proba(k)
            break;
        end
    end
    data_dec(end_i) = k;
    high = low + range * img_proba(k);
    if(k ~= 0)
        low = low + range * img_proba(k-1);
    else
        low = low;
    end
end

data_dec