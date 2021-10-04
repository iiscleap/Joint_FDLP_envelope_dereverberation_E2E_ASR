clc;
clear all;
close all;
ip=randn(1,8,47,6);
save('test_reshape','ip');
ip_lin=reshape(ip,[8*47*6,1,1]);
save('test_reshape_lin','ip_lin');
