clc; clear; close all; 


anchor_a = [0,0,2.38];
anchor_b = [-2.65,5.52,2.39];
anchor_c = [2,6.40,2.38];
anchor_d = [7.33,5.02,2.38];


real = [12,4,0];

d1_ideal = norm(anchor_a - real);
d2_ideal = norm(anchor_b - real);
d3_ideal = norm(anchor_c - real);
d4_ideal = norm(anchor_d - real);



d1 = d1_ideal;
d2 = d2_ideal;
d3 = d3_ideal;
d4 = d4_ideal;


A = 2* [
   (anchor_b-anchor_a);
   (anchor_c-anchor_a);
   (anchor_d-anchor_a);
   (anchor_c-anchor_b);
   (anchor_d-anchor_b);
   (anchor_d-anchor_d);
];

A_inv = inv(A' * A) * A';

b = [
   d1^2 - d1^2 + sum(anchor_b.^2-anchor_a.^2);
   d1^2 - d2^2 + sum(anchor_c.^2-anchor_a.^2);
   d1^2 - d3^2 + sum(anchor_d.^2-anchor_a.^2);
   d2^2 - d2^2 + sum(anchor_c.^2-anchor_b.^2);
   d2^2 - d3^2 + sum(anchor_d.^2-anchor_b.^2);
   d3^2 - d3^2 + sum(anchor_d.^2-anchor_c.^2);
];

[x,y,z] = (A_inv*b);


