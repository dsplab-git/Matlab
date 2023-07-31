clc; clear; close all;

sample_file = 'dw1000.xlsx';
data = readmatrix(sample_file); % ID, measuere(m), power(db), GT distance(m)

%% ID별 분석용
ID = unique(data(:,1));


%% Training Set (dw1000)
x = data(:,2:3);
y = data(:,4);

%% Show Data
figure(1)
scatter(x(:,1),y,'*k');
xlabel("Measurement(m)");
ylabel("Distance(m)")
%%
X_k = x(835:8020,1);
Y_k = y(835:8020);

A = inv([X_k ones(length(X_k),1)]'*[X_k ones(length(X_k),1)])*[X_k ones(length(X_k),1)]'*Y_k;

x_predict = [0:0.1:15];
y_predict = A(1)*x_predict + A(2);

%% Show Data
figure(2)
scatter(X_k,Y_k,'*k');
hold on
xlabel("Measurement(m)");
ylabel("Distance(m)")
plot(x_predict, y_predict,'r'   );

%% Evaluate
error = Y_k - (A(1)*X_k(:,1) + A(2));
error_rmse = mean(sqrt(error.^2))

error_total = y - (A(1)*x(:,1) + A(2));
error_total_rmse = mean(sqrt(error_total.^2))

1/A(1)
-A(2)/A(1)