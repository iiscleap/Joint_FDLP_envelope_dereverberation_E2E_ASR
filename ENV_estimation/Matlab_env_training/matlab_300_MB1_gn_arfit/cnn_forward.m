function output=cnn_forward(input)


dlX1 = dlarray(input,'SSCB');

weights_name='/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/exp/torch_ENV_CLN_CNN_with_pool4/weights.mat';
weights=load(weights_name);

conv1=weights.FrameStack{1,1};
conv1_b=weights.FrameStack{1,2};
weights_filter = permute(conv1,[4 3 2 1]);
bias=conv1_b';
dlY1 = dlconv(dlX1,weights_filter,bias,'Stride',1,'DilationFactor',1);
dlY1 = relu(dlY1);
bn_1_s=weights.FrameStack{1,3};
bn_1_b=weights.FrameStack{1,4};
offset=bn_1_b';
scalefac=bn_1_s';
dlX2 = batchnorm(dlY1,offset,scalefac);

dlX2 = maxpool(dlX2,[2 4],'Stride',[2 4]);

conv2=weights.FrameStack{1,5};
conv2_b=weights.FrameStack{1,6};
weights_filter2 = permute(conv2,[4 3 2 1]);
bias=conv2_b';
dlY2 = dlconv(dlX2,weights_filter2,bias,'Stride',1,'DilationFactor',1);
dlY2 = relu(dlY2);


bn_2_s=weights.FrameStack{1,7};
bn_2_b=weights.FrameStack{1,8};
offset=bn_2_b';
scalefac=bn_2_s';
dlX3 = batchnorm(dlY2,offset,scalefac);

dlX3=maxpool(dlX3,[2 4],'Stride',[2 4]);

dlX3 = extractdata(dlX3);
[a b c d]=size(dlX3);
dlX3 = permute(dlX3,[3 4 2 1]);
dlX3 = reshape(dlX3,[47*8*6 1 d]);
dlX3 = dlarray(dlX3,'SCB');

fc1=weights.FrameStack{1,9};
fc1_b=weights.FrameStack{1,10};
weights_fc1(:,:,1)= fc1;
bias_fc1 = fc1_b';
dlY3 = fullyconnect(dlX3,weights_fc1,bias_fc1);
dlY3 = relu(dlY3);

bn3_s=weights.FrameStack{1,11};
bn3_b=weights.FrameStack{1,12};
offset=bn3_b';
scalefac=bn3_s';
dlX4 = batchnorm(dlY3,offset,scalefac);

fc2=weights.FrameStack{1,13};
fc2_b=weights.FrameStack{1,14};
weights_fc2(:,:,1)= fc2;
bias_fc2 = fc2_b';
dlY4 = fullyconnect(dlX4,weights_fc2,bias_fc2);
dlY4 = relu(dlY4);

bn4_s=weights.FrameStack{1,15};
bn4_b=weights.FrameStack{1,16};
offset=bn4_b';
scalefac=bn4_s';
dlX4 = batchnorm(dlY4,offset,scalefac);

fc3=weights.FrameStack{1,17};
fc3_b=weights.FrameStack{1,18};
weights_fc3(:,:,1)= fc3;
bias_fc3 = fc3_b';
dlY4 = fullyconnect(dlX4,weights_fc3,bias_fc3);
output = extractdata(dlY4);




