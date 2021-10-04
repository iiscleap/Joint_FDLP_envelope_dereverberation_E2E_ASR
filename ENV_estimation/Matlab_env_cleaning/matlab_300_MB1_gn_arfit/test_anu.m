clc;
clear all;
close all;
A=[1,1;2,2];
B=[2,2;3,3];
C=[3,3;4,4];
Q={A,B,C};
n=length(Q);
result0 = cell2mat(Q(toeplitz(1:n)));

result = cell2mat(Q(toeplitz(1:n)));
p=3;
c=2;

for i=1:p-1
    for j=1:i
        
    result(1+i*c:(i+1)*c,1+(j-1)*c:(j)*c) = result(1+i*c:(i+1)*c,1+(j-1)*c:(j)*c)';
    end
end
