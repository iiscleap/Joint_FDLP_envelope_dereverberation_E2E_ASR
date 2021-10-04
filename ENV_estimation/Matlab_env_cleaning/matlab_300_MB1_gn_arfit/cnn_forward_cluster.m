function output=cnn_forward_cluster(input)

X(:,1,:)=input';
dlX1 = dlarray(X,'SCB');

weights_name='/home/anurenjan/Desktop/weight_matrices/weights_11_10.mat';
weights=load(weights_name);

conv1=weights.FrameStack{1,1};
conv1_b=weights.FrameStack{1,2};
weights_filter(:,1,:,1) = permute(conv1,[3 1 2]);
bias=conv1_b';
dlY1 = dlconv(dlX1,weights_filter,bias,'Stride',1,'DilationFactor',1);
%dlY1 = extractdata(dlY1);

confil=permute(conv1,[1 3 2]);
dlY1tp = zeros(32,216,796);
for i=1:32
    
    temp= conv2(input,fliplr(confil(i,:)),'valid');
    temp=temp+bias(i,1);
    dlY1tp(i,:,:)=temp;
end
dlY1tp=permute(dlY1tp,[3 1 2]);
dlY1 = relu(dlY1);
dlY1tp = max(0,dlY1tp(:,:,:));


bn_1_v=weights.FrameStack{1,3};
bn_1_b=weights.FrameStack{1,4};

V = var(dlY1tp,0,3);
V = sqrt(mean(V,1));
M = mean(dlY1tp,1);
M = mean(M,3);
for i=1:32
dlX2tp(:,i,:)=(dlY1tp(:,i,:)-M(1,i))/(V(1,i))*bn_1_v(1,i) + bn_1_b(1,i) ;
end


convol2=weights.FrameStack{1,5};
convol2_b=weights.FrameStack{1,6};
dlY2tp = zeros(792,216,8);
for i=1:216 %batchsize
    for j=1:8
        
        temp= conv2(dlX2tp(:,:,i)',flipud(fliplr(permute(convol2(j,:,:),[2 3 1]))),'valid');
        temp=temp+convol2_b(1,j);
        dlY2tp(:,i,j)=temp;
    end
end
dlY2tp(:,:,:) = max(0,dlY2tp(:,:,:));


bn_2_v=weights.FrameStack{1,7};
bn_2_b=weights.FrameStack{1,8};

for i=1:8
dlX3tp(:,:,i)=dlY2tp(:,:,i).*bn_2_v(1,i) + bn_2_b(1,i) ;
end


out=[];
for i=1:8
    temp=dlX3tp(:,:,i);
    out=cat(1,out,temp);
end
dlX3tp = out;

fc1=weights.FrameStack{1,9};
fc1_b=weights.FrameStack{1,10};

dlY3tp =fc1*dlX3tp +repmat(fc1_b',1,216);
dlY3tp(:,:) = max(0,dlY3tp(:,:));

bn3_g=weights.FrameStack{1,11};
bn3_b=weights.FrameStack{1,12};

dlX4tp = dlY3tp.*repmat(bn3_g',1,216) + repmat(bn3_b',1,216);

fc2=weights.FrameStack{1,13};
fc2_b=weights.FrameStack{1,14};
dlY4tp =fc2*dlX4tp +repmat(fc2_b',1,216);
dlY4tp(:,:) = max(0,dlY4tp(:,:));

bn4_g=weights.FrameStack{1,15};
bn4_b=weights.FrameStack{1,16};
dlX4tp = dlY4tp.*repmat(bn4_g',1,216) + repmat(bn4_b',1,216);

fc3=weights.FrameStack{1,17};
fc3_b=weights.FrameStack{1,18};
output =fc3*dlX4tp +repmat(fc3_b',1,216);
 



