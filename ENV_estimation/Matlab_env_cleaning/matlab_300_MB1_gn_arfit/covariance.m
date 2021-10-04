addpath('/home/anirudhs/tmp/anu/REVERB_MCSB_without_GN_3DCNN/matlab');
clc;
clear all;
close all;


load('clean_cov','C_cln_arfit','C1_cln_auto');
load('clean_rev_far','C_far_arfit','C1_far_auto');
load('clean_rev_near','C_near_arfit','C1_near_auto');

subplot(2,3,1);
imagesc(C_cln_arfit);
title('5 x 5 Covariance matrix for clean data - found using all five channels replaced with the same clean audio...(arfit)');
subplot(2,3,2);
imagesc(C_near_arfit);
title('5 x 5 Covariance matrix for near room  data(arfit)');
subplot(2,3,3);
imagesc(C_far_arfit);
title('5 x 5 Covariance matrix for far room  data(arfit)');

subplot(2,3,4);
imagesc(C1_cln_auto);
title('5 x 5 Covariance matrix for clean data - found using all five channels replaced with the same clean audio...(autocorfit)');
subplot(2,3,5);
imagesc(C1_near_auto);
title('5 x 5 Covariance matrix for near room  data(arfit)');
subplot(2,3,6);
imagesc(C1_far_auto);
title('5 x 5 Covariance matrix for far room  data(autocorfit)');

