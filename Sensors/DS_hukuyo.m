
data_array = zeros(1,1081*6);
index = 1;
for i = 1 : size(data_array,2)
    if rawData(i) == 10
        index = index - 1;        
    else
        data_array(index) = rawData(i)-48;
        if(data_array(index) < 0)
            disp(data_array(index))
        end
        index = index + 1;
    end
end

% data_array = data_array(1:end-1);
data_array_dis = zeros(1081,3);
data_array_int = zeros(1081,3);

data_dis = zeros(1,1081);
data_int = zeros(1,1081);
for i = 1 : 6 : size(data_array,2)
    if data_array(i) ~= 15
        intensity = data_array(i)*64*64 + data_array(i+1)*64+ data_array(i+2);
    else 
        intensity = 500;
    end
    data_array_int(floor(i/6)+1,:) = [data_array(i),data_array(i+1),data_array(i+2)];
    if data_array(i+3) ~= 15
        distance = data_array(i+3)*64*64 + data_array(i+4)*64 + data_array(i+5);
    else
        distance = 4000;
    end
    data_array_dis(floor(i/6)+1,:) = [data_array(i+3),data_array(i+4),data_array(i+5)];
    
    data_dis(floor(i/6)+1) = distance;
    data_int(floor(i/6)+1) = intensity;
end

figure(1)
clf
hold on
polar(deg2rad(-45):deg2rad(0.25):deg2rad(270-45),data_dis,'b')
polar(0:deg2rad(0.25):deg2rad(270),data_int,'r')

figure(2)
clf
hold on
plot(data_dis,'b')
plot(data_int,'r')