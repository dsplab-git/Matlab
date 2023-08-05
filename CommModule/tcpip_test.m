% Client
clear; close all; clc;

client = tcpclient('192.168.0.10',10940,'Timeout',20) % 실제 IP 주소와 포트 번호를 입력하세요.
pause(1)
rawData = readline(client);
disp(rawData);

%%
writeline(client,"BM")
rawData = readline(client);
disp(rawData);

%%
rawData = read(client);
%%

writeline(client, "GE0000108000")

%%
rawData = readline(client);
rawData = readline(client);
rawData = readline(client);
rawData = read(client);

data_array = [];
index = 1;
for i = 1 : size(rawData,2)-3
    if rawData(i) == 10
        index = index - 1;
    else
        data_array(index) = rawData(i)-48;
        index = index + 1;
    end
end

data_dis = [];
data_int = [];
for i = 1 : 6 : size(data_array,2)-1
    i
    intensity = data_array(i)*2^12 + data_array(i+1)*2^6 + data_array(i+2);
    distance = data_array(i+3)*2^12 + data_array(i+4)*2^6 + data_array(i+5);

    data_dis = [data_dis,distance];
    data_int = [data_int, intensity];
end

figure(1)
clf
hold on
polar(deg2rad(-45):deg2rad(0.25):deg2rad(270-45),data_dis,'b')
% polar(deg2rad(-45):deg2rad(0.25):deg2rad(270-45),data_int,'r')
drawnow()