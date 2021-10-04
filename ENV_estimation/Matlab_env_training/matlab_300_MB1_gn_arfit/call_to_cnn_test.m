clc;
clear all;
close all;
%ip=rand(36,800);
%op=cnn_forward(ip);

myDir = '/home/anirudhs/tmp/ENV_DNN/REVERB_ENV_DNN/mat_files_target/'; %gets directory
myFiles = dir(fullfile(myDir,'*.mat')); %gets all mat files in struct
for k = 1:1  %length(myFiles)
  baseFileName = myFiles(k).name;
  name_tgt = fullfile(myFiles(k).folder, baseFileName);
  name_rvb = strrep(name_tgt,'mat_files_target','mat_files_reverb');
  name_est = strrep(name_tgt,'mat_files_target','mat_files_log');
  cep_rvb=load(name_rvb).cep1;
  cep_tgt=load(name_tgt).cepstra;
  cep_est=load(name_est).outputs;
  
  for j=1:36
      [X(j,:,:),add_samp] = frame_new(cep_rvb(j,:),800,0);
  end
  cep_cln_temp = cat(1,X(:,:,1),X(:,:,2),X(:,:,3),X(:,:,4),X(:,:,5),X(:,:,6));
  cep_cln_temp_new = (cnn_forward(cep_cln_temp))';
  
  
  [r,c] = size(cep_tgt);
  m=ceil(c/800);
  cep_est_final=[];
  for i=1:m
      temp = cep_est_final;
      cep_est_final = cat(2,cep_est_final,cep_est(1+(i-1)*36:i*36,:));
  end
  cep_est_final = cep_est_final(:,1:c);
  cep_est_final = cep_est_final + cep_rvb;
  
  cep_rvb=exp(cep_rvb);
  cep_tgt=exp(cep_tgt);
  cep_est=exp(cep_est_final);
  cepstra_est=generate_env_feats_factor_40(cep_est,400,36);
  cepstra_rvb=generate_env_feats_factor_40(cep_rvb,400,36);
  cepstra_tgt=generate_env_feats_factor_40(cep_tgt,400,36);
  
  
  subplot(1,3,1);
  imagesc(flipud(log(cepstra_tgt)));
  title('target spectra');
  xlabel('Frame index');
  ylabel('Band no.');
  subplot(1,3,2);
  imagesc(flipud(log(cepstra_est)));
  title('estimated spectra');
  xlabel('Frame index');
  ylabel('Band no.');
  subplot(1,3,3);
  imagesc(flipud(log(cepstra_rvb)));
  title('reverberated spectra');
  xlabel('Frame index');
  ylabel('Band no.');
  
  D1=cepstra_tgt-cepstra_est;
  D2=cepstra_tgt-cepstra_rvb;
  a=sum(sum(abs(D1(:,:))));
  b=sum(sum(abs(D2(:,:))));
  
end