function aud_feats_vad(infile,outfile,vadfile,fs)
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
if nargin < 4; error('Not enough input parameter: Usage aud_feats(infile,outfile,vadfile,fs)');end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------- Set the flags -------------------
ceps = 14;
do_delta =1;
if isstr(fs)
   fs = str2num(fs); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------- Feature Extraction -------
% Read samples from the input file
disp(infile);
[fid,cnt] = fopen(infile,'rb','l');
[x,cnt] = fread(fid,inf,'int16');
fclose(fid);
vad_op= VFloatMatrixRead(vadfile);
vadlen = length(vad_op);

A = x(:); % make sure it's vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------- Split into Frames --------------

flen=0.032*fs;  % frame length 25ms
fhop=0.010*fs;  % frame overlap 10ms

req_len = (vadlen-1)*fhop + flen;  % Final number of required frames
A = [A ; zeros(req_len-length(A),1)];
fnum = floor((length(A)-flen)/fhop)+1;   % Number of frames

cepstra = feats_no_filt(A,fs,ceps);
if do_delta == 1
    
    % Append deltas and double-deltas onto the cepstral vectors
    del = deltas(cepstra);
    
    % Double deltas are deltas applied twice with a shorter window
    ddel = deltas(deltas(cepstra,5),5);
    
    % Composite, 39-element feature vector, just like we use for speech recognition
    cepstra = [cepstra;del;ddel];
end


cepstra = cepstra(:,1:vadlen);
vad_frames = find(vad_op==1);
if length(vad_frames) == 0
   vad_frames = [1:vadlen];
end
cepstra = cepstra(:,vad_frames);

toc;
VFloatMatrixWrite( outfile, cepstra')



