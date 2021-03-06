function output=cnn_forward_full_cnn(input)


dlX1 = dlarray(input,'SSCB');

weights_name='/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Old_EnvC_wpe_gev_BF_Estimation/exp/torch_ENV_full_CNN_DEEP/weights.mat';
weights=load(weights_name);

conv1=weights.FrameStack{1,1};
conv1_b=weights.FrameStack{1,2};
weights_filter = permute(conv1,[4 3 2 1]);
bias=conv1_b';
dlY1 = dlconv(dlX1,weights_filter,bias,'Stride',1,'DilationFactor',1,'Padding','same');
dlX2 = relu(dlY1);


conv2=weights.FrameStack{1,1};
conv1_b=weights.FrameStack{1,2};
weights_filter = permute(conv1,[4 3 2 1]);
bias=conv1_b';
dlY1 = dlconv(dlX1,weights_filter,bias,'Stride',1,'DilationFactor',1,'Padding','same');
dlX2 = relu(dlY1);


output = extractdata(dlY4);




