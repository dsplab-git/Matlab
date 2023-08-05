clc; clear; close all

w0 = 10000000; %10MHz
w1 = 40000000; %40MHz
w2 = 120000000; %120MHz %paper2

f0 = w0/(2*pi);
f1 = w1/(2*pi);
f2 = w2/(2*pi);

Vc = 299792458; % m/s

distance_array = (0.2:0.01:4.5);  % 0.05m ~ 5m within 0.01m

phase_array0 = 2*w0/Vc * distance_array; % 2*w(1/s)*d(m) / c (m/s)
phase_array1 = 2*w1/Vc * distance_array;
phase_array2 = 2*w2/Vc * distance_array;

figure(1)
hold on
plot(distance_array,phase_array0,'r')
plot(distance_array,phase_array1,'b')
plot(distance_array,phase_array2,'g')


Re0 = cos(phase_array0);
Im0 = sin(phase_array0);
Re1 = cos(phase_array1);
Im1 = sin(phase_array1);
Re2 = cos(phase_array2);
Im2 = sin(phase_array2);

figure(2)
hold on
plot(distance_array,Re0,'r')
plot(distance_array,Im0,'r*')
plot(distance_array,Re1,'b')
plot(distance_array,Im1,'b*')
% plot(distance_array,Re2,'g')
% plot(distance_array,Im2,'g*')

%% Paper 1
clc
ex_data = [0.4,1];

A = 1;
alpha = 0.01;
beta = 1;


ex_data_amp = zeros(1,length(ex_data));
ex_data_amp(1) = A * ex_data(1)^alpha * exp(-beta*ex_data(1));
ex_data_amp(2) = A * ex_data(2)^alpha * exp(-beta*ex_data(2));
ex_data_amp


ex_dist_index = zeros(1,length(ex_data));
[temp,ex_dist_index(1)] = max(distance_array == ex_data(1));
[temp,ex_dist_index(2)] = max(distance_array == ex_data(2));


ex_Re0 = ex_data_amp(1)*Re0(ex_dist_index(1)) + ex_data_amp(2)*Re0(ex_dist_index(2));
ex_Im0 = ex_data_amp(1)*Im0(ex_dist_index(1)) + ex_data_amp(2)*Im0(ex_dist_index(2));


ex_Re1 = ex_data_amp(1)*Re1(ex_dist_index(1)) + ex_data_amp(2)*Re1(ex_dist_index(2));
ex_Im1 = ex_data_amp(1)*Im1(ex_dist_index(1)) + ex_data_amp(2)*Im1(ex_dist_index(2));


[ex_Re0 ex_Im0 ex_Re1 ex_Im1]

%% Previous Method
atan(ex_Im0/ex_Re0)*Vc/(2*w0);
atan(ex_Im1/ex_Re1)*Vc/(2*w1);








