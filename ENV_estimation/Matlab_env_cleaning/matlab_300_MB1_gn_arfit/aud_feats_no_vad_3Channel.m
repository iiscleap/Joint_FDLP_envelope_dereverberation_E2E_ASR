function aud_feats_no_vad_3Channel(infile,outfile,fs)
% ---------------------------------------------------------------------
% Multi-Channel FDLP feature processing.
% spec_feats_fdlp(wavfile,st,en,opfile)
% Function to generate the spectral features based on FDLP.
% Read the infile in raw format sampling and the start and end duration
% Ouput file is Attila format
% -------------------------------------------------------------------------
% Sriram Ganapathy
% March 5 2018, Indian Institute of Science, Bangalore.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------Parameter Check ------------------
%tic;
if nargin < 3; error('Not enough input parameter: Usage aud_feats(infile,outfile,fs)');end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------- Set the flags -------------------
% there = exist(outfile);
% 
%  if there
% %     % Skip feature generation if output file exists
%      disp([outfile,' exists already. ',datestr(now)]);
%  else
%     % Read sampled from the input file

if isstr(fs)
   fs = str2num(fs); 
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % -------- Feature Extraction -------
% Read samples from the input file
% infile2 = strrep(infile,'ch1','ch2');
% infile3 = strrep(infile,'ch1','ch3');
% infile4 = strrep(infile,'ch1','ch4');
% infile5 = strrep(infile,'ch1','ch5');
% % % infile6 = strrep(infile,'ch1','ch6');
% % % infile7 = strrep(infile,'ch1','ch7');
% % % infile8 = strrep(infile,'ch1','ch8');
% % 
% outfile2 = strrep(strrep(outfile,'ch1','ch2'),'_A/','_B/');
% outfile3 = strrep(strrep(outfile,'ch1','ch3'),'_A/','_C/');
% outfile4 = strrep(strrep(outfile,'ch1','ch4'),'_A/','_D/');
% outfile5 = strrep(strrep(outfile,'ch1','ch5'),'_A/','_E/');
% outfile6 = strrep(strrep(outfile,'ch1','ch6'),'_A/','_F/');
% outfile7 = strrep(strrep(outfile,'ch1','ch7'),'_A/','_G/');
% outfile8 = strrep(strrep(outfile,'ch1','ch8'),'_A/','_H/');

% [x,fs] = wavread(infile);
[y1(1,:),fs]=audioread(infile);
% [y1(2,:),fs]=audioread(infile2);
% [y1(3,:),fs]=audioread(infile3);
% [y1(4,:),fs]=audioread(infile4);
% [y1(5,:),fs]=audioread(infile5);
% [y1(6,:),fs]=audioread(infile6);
% [y1(7,:),fs]=audioread(infile7);
% [y1(8,:),fs]=audioread(infile8);


[r,c]=size(y1);
nochan=r;
samples = y1(:,:).* 2^15; % make sure it's vector
cepstra=generate_env_feats(samples,fs,nochan); %to extract from FDLP
cepstra=log(cepstra);
writehtkf_new(outfile,cepstra,100000.0,8267); 

% % cep1=cepstra(1:nochan:end,:);
% % cep2=cepstra(2:nochan:end,:);
% % cep3=cepstra(3:nochan:end,:);
% % cep4=cepstra(4:nochan:end,:);
% % cep5=cepstra(5:nochan:end,:);
% % % cep6=cepstra(6:nochan:end,:);
% % % cep7=cepstra(7:nochan:end,:);
% % % cep8=cepstra(8:nochan:end,:);
% 
% [r,h] = size(cepstra);
% m=ceil(h/800);
% 
% 
% 
%  cep=zeros(36,800,1,m);
%   for i=1:m-1
%       
%       cep(:,:,1,i) = cepstra(:,800*(i-1)+1:800*i);
%   end
%   
%   trim=m*800-h;
%   last=cat(2,cepstra(:,800*(m-1)+1:h),zeros(36,trim));
% 
%   
%   cep(:,:,1,m) = last;
%   %csvwrite('c02c0202.csv',cep);
% 
%   cep_cln = cnn_forward_large(cep);
%   cep_cln = reshape(cep_cln,[36 800 m]);
%   
%   cep_cln_final = [];
%   for i=1:m
%       temp = cep_cln_final;
%       cep_cln_final = cat(2,cep_cln_final,cep_cln(:,:,i));
%   end
% % clean_pyth=load('anu.mat').outputs;
% % clean_pyth=clean_pyth';
% % [g d]=size(clean_pyth);
% % clean_pyth=clean_pyth+cepstra(:,1:d);
% %   clean_pyth=exp(clean_pyth);
% %   cepstra_cln_int_pyth=generate_env_feats_factor_40(clean_pyth,400,36);
% 
%   cep_cln_final = cep_cln_final(:,1:h);
%   cep_cln_final = cep_cln_final + cepstra;
%   cep_cln_final=exp(cep_cln_final);
%   %cepstra=exp(cepstra);
%   %cepstra_rvb=generate_env_feats_factor_40(cepstra,400,36);
%   
%   
%   cepstra_cln_int=generate_env_feats_factor_40(cep_cln_final,400,36);
%   %writehtkf_new('/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Env_wpe_gev_BF_estimation_python/clean_elp_estimation/mat_int_out_t6c020d.fea',cepstra_cln_int,100000.0,8267);
%   
%   %writehtkf_new(outfile,cepstra_cln_int,100000.0,8267); 
%   
%   
%    subplot(1,2,1);
%   imagesc(flipud(log(cepstra_cln_int)));
%   title('cepstra clean');
%   xlabel('Frame index');
%   ylabel('Band no.');
%   subplot(1,2,2);
%   imagesc(flipud(log(cepstra_orig_int)));
%   title('reverberent spectra');
%   xlabel('Frame index');
%   ylabel('Band no.');
%   
