function aud_feats_no_vad(infile,outfile,fs)
% ---------------------------------------------------------------------
% spec_feats_fdlp(wavfile,st,en,opfile)
% Function to generate the spectral features based on FDLP.
% Read the infile in raw format sampling and the start and end duration
% Ouput file is Attila format
% -------------------------------------------------------------------------
% Sriram Ganapathy
% Sept. 25 2012, Watson Labs IBM.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------Parameter Check ------------------
tic;
if nargin < 3; error('Not enough input parameter: Usage aud_feats(infile,outfile,fs)');end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------- Set the flags -------------------
there = exist(outfile);

 if there
%     % Skip feature generation if output file exists
     disp([outfile,' exists already. ',datestr(now)]);
 else
    % Read sampled from the input file

if isstr(fs)
   fs = str2num(fs); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------- Feature Extraction -------
% Read samples from the input file
disp(infile);
% [x,fs] = wavread(infile);
[x,fs] = audioread(infile); % read from wav file
samples = x(:) * 2^15; % make sure it's vector
cepstra=generate_env_feats(samples,fs); %to extract from FDLP 

toc;
writehtkf_new(outfile,cepstra,100000.0,8267);
 end


