function mel_feats(infile,outfile,fs)
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
%tic;
if nargin < 3; error('Not enough input parameter: Usage aud_feats(infile,outfile,fs)');end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------- Set the flags -------------------
there = exist(outfile);

 if there
%     % Skip feature generation if output file exists
     disp([outfile,' exists already. ',datestr(now)]);
 else
    % Read sampled from the input file

ceps = 13;
do_delta =0;
if isstr(fs)
   fs = str2num(fs); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------- Feature Extraction -------
% Read samples from the input file
disp(infile);
[x,fs] = audioread(infile);


A = x(:); % make sure it's vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------- Split into Frames --------------

flen=0.025*fs;  % frame length 25ms
fhop=0.010*fs;  % frame overlap 10ms

fnum = floor((length(A) - flen) / fhop) + 1 ;
req_len = (flen-1)*fhop + flen;  % Final number of required frames
samples = A ;

cepstra = melfcc(samples,fs);  % mel filterbank features
cepstra = log(cepstra) ; % Log mel FB features
%cepstra = cepstra(:,1:fnum);
[r,c]=size(cepstra);
f=linspace(1,r,r);
n=linspace(1,c,c);
subplot(1,1,1);
surf(n, f, cepstra, 'EdgeColor', 'none');
axis xy; 
axis tight; 
colormap(jet); view(0,90);
xlabel('Frame index');
colorbar;
ylabel('Band no.');
title('FBANK');
    

%toc;
%writehtkf_new(outfile,feat,100000.0,8267);
writehtkf_new(outfile,cepstra,100000.0,8267);  % for only saving directly mel filterbank energy (MelFBE) *****************************CHECK ************
 end
