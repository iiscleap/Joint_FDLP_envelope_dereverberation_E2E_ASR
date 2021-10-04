function output=cnn_forward_large(input)


dlX1 = dlarray(input,'SSCB');

weights_name='/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/exp/torch_ENV_CLN_CNN_with_Net_larg_kernel_without_batchnorm/weights.mat';
weights=load(weights_name);

conv1=weights.FrameStack{1,1};
conv1_b=weights.FrameStack{1,2};
weights_filter = permute(conv1,[4 3 2 1]);
bias=conv1_b';
dlY1 = dlconv(dlX1,weights_filter,bias,'Stride',1,'DilationFactor',1);
dlY1 = relu(dlY1);
% bn_1_s=weights.FrameStack{1,3};
% bn_1_b=weights.FrameStack{1,4};
% offset=bn_1_b';
% scalefac=bn_1_s';
dlX2 = dlY1;


conv2=weights.FrameStack{1,3};
conv2_b=weights.FrameStack{1,4};
weights_filter2 = permute(conv2,[4 3 2 1]);
bias=conv2_b';
dlY2 = dlconv(dlX2,weights_filter2,bias,'Stride',1,'DilationFactor',1);
dlY2 = relu(dlY2);


% bn_2_s=weights.FrameStack{1,7};
% bn_2_b=weights.FrameStack{1,8};
% offset=bn_2_b';
% scalefac=bn_2_s';
dlX3 = dlY2;
dlX3=maxpool(dlX3,[2 4],'Stride',[2 4]);

conv3=weights.FrameStack{1,5};
conv3_b=weights.FrameStack{1,6};
weights_filter3 = permute(conv3,[4 3 2 1]);
bias=conv3_b';
dlY3 = dlconv(dlX3,weights_filter3,bias,'Stride',1,'DilationFactor',1);
dlY3 = relu(dlY3);

% bn_3_s=weights.FrameStack{1,11};
% bn_3_b=weights.FrameStack{1,12};
% offset=bn_3_b';
% scalefac=bn_3_s';
dlX4 = dlY3;

conv4=weights.FrameStack{1,7};
conv4_b=weights.FrameStack{1,8};
weights_filter4 = permute(conv4,[4 3 2 1]);
bias=conv4_b';
dlY4 = dlconv(dlX4,weights_filter4,bias,'Stride',1,'DilationFactor',1);
dlY4 = relu(dlY4);

% bn_4_s=weights.FrameStack{1,15};
% bn_4_b=weights.FrameStack{1,16};
% offset=bn_4_b';
% scalefac=bn_4_s';
dlX5 = dlY4;
dlX5=maxpool(dlX5,[2 4],'Stride',[2 4]);

dlX5 = extractdata(dlX5);
[a b c d]=size(dlX5);
%dlX5 = permute(dlX5,[3 4 2 1]);
dlX5 = reshape(dlX5,[44*3*8 1 d]);
dlX5 = dlarray(dlX5,'SCB');

fc1=weights.FrameStack{1,9};
fc1_b=weights.FrameStack{1,10};
weights_fc1(:,:,1)= fc1;
bias_fc1 = fc1_b';
dlY5 = fullyconnect(dlX5,weights_fc1,bias_fc1);
dlY5 = relu(dlY5);

% bn3_s=weights.FrameStack{1,19};
% bn3_b=weights.FrameStack{1,20};
% offset=bn3_b';
% scalefac=bn3_s';
dlX6 = dlY5;

fc2=weights.FrameStack{1,11};
fc2_b=weights.FrameStack{1,12};
weights_fc2(:,:,1)= fc2;
bias_fc2 = fc2_b';
dlY6 = fullyconnect(dlX6,weights_fc2,bias_fc2);
dlY6 = relu(dlY6);

% bn4_s=weights.FrameStack{1,23};
% bn4_b=weights.FrameStack{1,24};
% offset=bn4_b';
% scalefac=bn4_s';
dlX7 = dlY6;

fc3=weights.FrameStack{1,13};
fc3_b=weights.FrameStack{1,14};
weights_fc3(:,:,1)= fc3;
bias_fc3 = fc3_b';
dlY7 = fullyconnect(dlX7,weights_fc3,bias_fc3);
output = extractdata(dlY7);




