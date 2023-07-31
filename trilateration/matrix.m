clc;
clear;

T = readtable("4anchor.csv");



%%
real = [2.3,1.1,0];

%%

anchor_a = [0, 0, 2.38];
anchor_b = [-2.65, 5.52, 2.39];
anchor_c = [2, 6.40, 2.38];
anchor_d = [7.33, 5.02, 2.39];

%%
result = [];
for k = 0 : 0.1 : 1
w = k;
arr_Result = zeros(1000,3);
for i = 1 : 1000
d1_real = norm(anchor_a - real) + w*randn(1);
d2_real = norm(anchor_b - real);
d3_real = norm(anchor_c - real);
d4_real = norm(anchor_d - real);

A = [ 2 * (anchor_b - anchor_a);
    2 * (anchor_c - anchor_a);
    2 * (anchor_d - anchor_a);
    2 * (anchor_c - anchor_b);
    2 * (anchor_d - anchor_b);
    2 * (anchor_d - anchor_c)];

A_inv = inv(transpose(A) * A) * transpose(A);

b = [ d1_real^2 - d2_real^2 + sum( anchor_b.^2 - anchor_a.^2);
    d1_real^2 - d3_real^2 + sum( anchor_c.^2 - anchor_a.^2);
    d1_real^2 - d4_real^2 + sum( anchor_d.^2 - anchor_a.^2);
    d2_real^2 - d3_real^2 + sum( anchor_c.^2 - anchor_b.^2);
    d2_real^2 - d4_real^2 + sum( anchor_d.^2 - anchor_b.^2);
    d3_real^2 - d4_real^2 + sum( anchor_d.^2 - anchor_c.^2); ];

X = A_inv * b;

arr_Result(i,:) = real - X';
end
ans = [w,
    mean(arr_Result(:,1)),
    mean(arr_Result(:,2)),
    mean(arr_Result(:,3)),
    var(arr_Result(:,1)),
    var(arr_Result(:,2)),
    var(arr_Result(:,3)),
    ];
result = [result;ans'];
end
return
%%
Result = zeros(278,7);
modified_a = 1.0097;
modified_b = -0.3351;
for i = 1:278
    d1_m = T(i,4).Variables;
    d2_m = T(i,5).Variables;
    d3_m = T(i,6).Variables;
    d4_m = T(i,7).Variables;

    d1 = d1_m * modified_a + modified_b -0.2;
    d2 = d2_m * modified_a + modified_b;
    d3 = d3_m * modified_a + modified_b;
    d4 = d4_m * modified_a + modified_b;

    A = [ 2 * (anchor_b - anchor_a);
        2 * (anchor_c - anchor_a);
        2 * (anchor_d - anchor_a);
        2 * (anchor_c - anchor_b);
        2 * (anchor_d - anchor_b);
        2 * (anchor_d - anchor_c)];

    A_inv = inv(transpose(A) * A) * transpose(A);

    b = [ d1^2 - d2^2 + sum( anchor_b.^2 - anchor_a.^2);

    d1^2 - d3^2 + sum( anchor_c.^2 - anchor_a.^2);
    d1^2 - d4^2 + sum( anchor_d.^2 - anchor_a.^2);
    d2^2 - d3^2 + sum( anchor_c.^2 - anchor_b.^2);
    d2^2 - d4^2 + sum( anchor_d.^2 - anchor_b.^2);
    d3^2 - d4^2 + sum( anchor_d.^2 - anchor_c.^2); ];

    X = A_inv * b;

    r = real - transpose(X);
    Result(i,1:3) = r;
    Result(i,4:end) = [d1_real,d2_real,d3_real,d4_real] - [d1,d2,d3,d4];
end

