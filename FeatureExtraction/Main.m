clc; clear; close all;


%% Image Load
File_path_list = {
    'Capture_032041_863(96.345, 182.495, 41.710).bmp';
    'Capture_032000_153(96.345, 181.495, 41.710).bmp';
    'Capture_031911_222(96.345, 180.495, 41.710).bmp';
    'Capture_031830_368(96.345, 179.495, 41.710).bmp';
    'Capture_031720_490(96.345, 178.495, 41.710).bmp';
    'Capture_031617_929(96.345, 177.495, 41.710).bmp';
    'Capture_031402_911(96.345, 176.495, 41.710).bmp';
    'Capture_031224_373(96.345, 175.495, 41.710).bmp';
    'Capture_030803_703(94.345, 174.495, 41.710).bmp';
    'Capture_030445_824(175.430, 174.495, 41.710).bmp';
    'Capture_025737_899(175.435,67.535,41.710).bmp';
    'Capture_025359_012(94.755,67.535,41.710).bmp';
    };

% Folder_path = [pwd filesep 'SampleData'];
Folder_path = ['SampleData']

i = 5;
disp([Folder_path filesep File_path_list{i}])

img = imread([Folder_path filesep File_path_list{i}]);

figure("Name","Original Image")
imshow(img)


%% Image Feature Analysis
% h = histogram(img);
% 
% img_binary = imbinarize(img, "adaptive");
% figure
% imshow(img_binary)
% 
% img_label = bwlabel(img_binary);
% 
% figure
% mesh(img_label)

%% Edge Based Method
sigma = 5;
img_bulr = imgaussfilt(img,sigma);
img_canny = edge(img_bulr,'Canny',0.5,sigma);
figure("Name","Edge Image")
imshow(img_canny)


%% Edge Linking
[ Contour_x_array, Contour_y_array, Contour_p1_array, Contour_p2_array, Contour_count ] = LinkedList( img_canny, 0 );
figure("Name","Linked Image")
imshow(img)
hold on
for i = 1 : size(Contour_count,1)
    n = Contour_count(i);
    plot(Contour_x_array(i,1:n),Contour_y_array(i,1:n))
end

%%

Img_Tinning = bwmorph(img_canny,"skeleton");
nei = [-1 -1; -1 0; -1 1; 0 -1; 0 0; 0 1; 1 -1; 1 0; 1 1]; %r,c cw

nei2 = [0 1; 1 1; 1 0; 1 -1; 0 -1; -1 -1; -1 0; -1 1]; % r,c cw

Contour_type = string(zeros(size(Contour_x_array)));

figure("Name","Test Image")
imshow(img)
hold on
for i = 4%1 : size(Contour_count,1)
    n = Contour_count(i);
    scatter(Contour_x_array(i,1:n),Contour_y_array(i,1:n))
end

num_sample = 5;

for num = 4 %1 : size(Contour_count, 1)
    for count = 1 : Contour_count(num)
        x = Contour_x_array(num,count);
        y = Contour_y_array(num,count);
        p1 = Contour_p1_array(num,count);
        p2 = Contour_p2_array(num,count);

        plot([x+5*p2,x-5*p2],[y+5*p1,y-5*p1],'r')
        
        Sample_point = zeros(num_sample*2+1,1);
        for sample_index = -num_sample : num_sample
            x_sample = x+sample_index*p2;
            y_sample = y+sample_index*p1;
            Sample_point(sample_index) = img_bulr(y+sample_index*p1,x+sample_index*p2);
        end

        Delta_value = abs(double(Sample_point(2:end))-double(Sample_point(1:end-1)));
        x_value = 1:length(Delta_value);
        y_value = Delta_value;
        f = fit(x_value.',y_value,'gauss1');

        delta_value = f.b1-5;

        if(p1 ~= 0)
            y_hat = y + delta_value;
        else
            y_hat = y;
        end
        if(p2 ~= 0)
            x_hat = x + delta_value;
        else
            x_hat = x;
        end
        scatter(x_hat,y_hat,'*');
    end
end

%%
Delta_value = abs(double(Sample(2:end))-double(Sample(1:end-1)));%-double(Sample(3:end)));
x_value = 1:length(Delta_value);
y_value = Delta_value;
f = fit(x_value.',y_value,'gauss1');


figure
plot(1:length(Sample),Sample)

% +- 5개 점 해서 11개 점으로 중심 좌표 계산 fit gauss1
% Test_line = img(702,965:979);
% Delta_value = abs(double(Test_line(2:end))-double(Test_line(1:end-1)));
% x_value = 1:length(Delta_value);
% y_value = Delta_value;
% f = fit(x_value.',Delta_value.','gauss1');
% % f = fit(x.',y.','gauss2');
figure
plot(1:length(Sample),Sample)
hold on
plot(x_value,Delta_value)
plot(f,x_value,Delta_value);