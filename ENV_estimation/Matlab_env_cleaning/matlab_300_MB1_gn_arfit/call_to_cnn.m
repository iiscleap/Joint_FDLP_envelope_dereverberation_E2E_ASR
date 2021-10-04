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
  ip=rand(36,800,1,1);
  
  cep_cln_temp_new = (cnn_forward(ip))';
  cep_cln_temp_new = reshape(cep_cln_temp_new,[36 800]);
  cep_cln_temp_new_cluster = (cnn_forward_cluster(cep_cln_temp))';

  [r,c] = size(cep_tgt);
  m=ceil(c/800);
  cep_est_final=[];
  for i=1:m
      temp = cep_est_final;
      cep_est_final = cat(2,cep_est_final,cep_est(1+(i-1)*36:i*36,:));
  end
  cep_est_final = cep_est_final(:,1:c);
  cep_est_final = cep_est_final + cep_rvb;
  
  cep_est_final_mat=[];
  for i=1:m
      temp = cep_est_final_mat;
      cep_est_final_mat = cat(2,cep_est_final_mat,cep_cln_temp_new(1+(i-1)*36:i*36,:));
  end
  cep_est_final_mat = cep_est_final_mat(:,1:c);
  cep_est_final_mat = cep_est_final_mat + cep_rvb;
  
  
  cep_est_final_mat_cluster=[];
  for i=1:m
      temp = cep_est_final_mat_cluster;
      cep_est_final_mat_cluster = cat(2,cep_est_final_mat_cluster,cep_cln_temp_new_cluster(1+(i-1)*36:i*36,:));
  end
  cep_est_final_mat_cluster = cep_est_final_mat_cluster(:,1:c);
  cep_est_final_mat_cluster = cep_est_final_mat_cluster + cep_rvb;
  
  
  plot(cep_est_final(10,1:100),'r');
  hold on;
  plot((cep_est_final_mat(10,1:100)+0),'b');
  hold on;
  plot((cep_est_final_mat_cluster(10,1:100)+0),'g');
  cep_rvb=exp(cep_rvb);
  cep_tgt=exp(cep_tgt);
  cep_est=exp(cep_est_final);
  cep_est_mat=exp(cep_est_final_mat);
  cepstra_est=generate_env_feats_factor_40(cep_est,400,36);
  cepstra_est_mat=generate_env_feats_factor_40(cep_est_mat,400,36);
  cepstra_rvb=generate_env_feats_factor_40(cep_rvb,400,36);
  cepstra_tgt=generate_env_feats_factor_40(cep_tgt,400,36);
  subplot(1,2,1);
  imagesc(flipud(log(cepstra_est)));
  title('estimated spectra_pytorch');
  xlabel('Frame index');
  ylabel('Band no.');
  subplot(1,2,2);
  imagesc(flipud(log(cepstra_est_mat)));
  title('estimated spectra_matlab');
  xlabel('Frame index');
  ylabel('Band no.');
end