clc; clear; close all
%%
cplot = @(r,x0,y0) plot(x0 + r*cos(linspace(0,2*pi)),y0 + r*sin(linspace(0,2*pi)),'-');

%%
r=0.2;
sim_t = 1;
dt = 0.1;
m= 1;
g = 9.8;
w = 0;
simulation_step = sim_t / dt;

parabolic_x = -5:0.01:5;
parabolic_y = 0.5 * parabolic_x.*parabolic_x;

plot(parabolic_x,parabolic_y)


d_f = parabolic_x;
cos_ball1 = zeros(size(parabolic_x));
sin_ball1 = zeros(size(parabolic_x));

for i = 1: size(parabolic_x,2)
    x = parabolic_x(i);
    [ball_x(i), ball_y(i)] = pos_ball(x, r);
end
% hold on

%%
% for i = 1 : 50 :  size(parabolic_x,2)
%     h = images.roi.Circle(gca,'Center',[ball_x(i),ball_y(i)],'Radius',r);
% end
% scatter(ball_x(1:40:end),ball_y(1:40:end),1200,'or')

% para_x = -2;
% ball_x = 

para_x = -4;
ball_v = 0;
para_vx = 0;
para_vy = 0;
result = zeros(simulation_step,10);
Total_P = 100;
para_y = 0.5*para_x*para_x;
for step = 1 : 80
    % 현재 비탈면 접촉점 para_x 을 기준으로
%     [ball_x, ball_y] = pos_ball(para_x, r);

    cosx = sqrt(1/(1+para_x^2));
    if(para_x > 0)
        sinx = -sqrt(1-cosx^2);
    else
        sinx = sqrt(1-cosx^2);
    end
    % Present Energy
%     P_E = m*g*ball_y;
%     V_E = 0.5*m*ball_v^2;
    M_E = 0.5*0.5*m*r^2*w^2;

    % Force
    A_V = -g*cosx;
    A_H = g*sinx;
    
    dvx = A_H * dt;
    dvy = A_V * dt;

    % Ball Move    
    dx = para_vx * dt + 0.5 * dvx * dt;
    dy = para_vy * dt + 0.5 * dvy * dt;

    para_vx = para_vx + dvx;
    para_vy = para_vx + dvy;

    

%     dv = sqrt(abs(2*g*dy));
%     if(dy > 0); dv = dv * -1; end
    
    
    para_x = para_x + dx;
    para_y = para_y + dy; %0.5*para_x*para_x;

    dv = sqrt(para_vx^2 + para_vy^2);
    V_E = 0.5*m*dv*dv;
    P_E = m*g*para_y;

    force_x = para_x + A_H*dt;
    force_y = para_y + A_V*dt;
    
%     ball_v = ball_v + dv;
%     ball_x = ball_x + dx;
%     ball_y = ball_y + dy;

%     para_x = para_x + 0.1;
%     para_y = 0.5*para_x*para_x;

    result(step,1:4) = [dv,V_E,P_E,P_E+ V_E];

    % show now
    figure(1)
    clf
    plot(parabolic_x,parabolic_y)
    hold on
    [ball_x, ball_y] = pos_ball(para_x, r);
    cplot(r,ball_x,ball_y);
    scatter(para_x,0.5*para_x*para_x,'.r')
    plot([para_x,force_x],[para_y,force_y])
    drawnow
    pause(0.01)


    
    % Energy Move
%     V_E_new = V_E + L_P2O;

    % New Pose Velocity
%     dh = L_P2O/m/g;

end

function [ball_x, ball_y] = pos_ball(x, r)
    cos_ball = sqrt(1/(1+x^2));

    if(x > 0)
        sin_ball = -sqrt(1-cos_ball^2);
    else
        sin_ball = sqrt(1-cos_ball^2);
    end

    ball_x = x + sin_ball * r;
    ball_y = 0.5*x^2 + cos_ball * r;
end
