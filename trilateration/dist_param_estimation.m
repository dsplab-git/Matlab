clc; clear; close all;

% addpath("trilateration","trilateration\sample")

sample_file = 'sample/dw1000_20230521.xlsx';
data = readmatrix(sample_file); % ID, measuere(m), power(db), GT distance(m)

%% ID별 분석용
ID = unique(data(:,1));


%% Training Set (dw1000)
x = data(:,2:3);
y = data(:,4);

%% Show Data
figure(1)
subplot(1,2,1)
scatter(x(:,1),y,'*k');
xlabel("Measurement(m)");
ylabel("Distance(m)")

%% Regression at Working Range (2m ~ 12m)
wr = and((x(:,1) > 1.8),(x(:,1) < 12.2));

X_k = x(wr);
Y_k = y(wr);

A = inv([X_k ones(length(X_k),1)]'*[X_k ones(length(X_k),1)])*[X_k ones(length(X_k),1)]'*Y_k;

x_predict = [min(x):0.1:max(x)];
y_predict = A(1)*x_predict + A(2);

%% Show Data
subplot(1,2,2)
scatter(x(:,1),y,'*k');
hold on
scatter(X_k,Y_k,'or');
xlabel("Measurement(m)");
ylabel("Distance(m)")
plot(x_predict, y_predict,'r');

%% Evaluate
error = Y_k - (A(1)*X_k(:,1) + A(2));
error_rmse = mean(sqrt(error.^2));

error_total = y - (A(1)*x(:,1) + A(2));
error_total_rmse = mean(sqrt(error_total.^2));

disp(['error_rmse : ', num2str(error_rmse),'     error_total_rmse : ', num2str(error_total_rmse)])
disp(['plot : measure =(',num2str(1/A(1)),')*realdist+(',num2str(-A(2)/A(1)),')'])
disp(['plot : measure =(',num2str(1/A(1)),')*realdist+(',num2str(-A(2)/A(1)),')'])
