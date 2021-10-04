function spec_feats(infile,outfile,inext,fs)
% ---------------------------------------------------------------------
% spec_feats(list,inpdir,outdir,inext,fs)
% Function to generate the spectral features based on FDLP.
% Read the input inexts from the inpdir using the list and generate features
% to dump into outdir.
% Function assumes that inexts are in wav inext. If other inexts are
% input, a string 'inext' indicates the inext, along with the sample rate.
% -------------------------------------------------------------------------
% Sriram Ganapathy
% May 25 2010, Watson Labs IBM.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------Parameter Check ------------------
tic;
if nargin < 2; error('Not enough input parameter: Usage spec_feats(list,inpdir,oupdir)');end
if nargin < 3; inext='wav';end
if nargin < 4; fs='8000';end

if ~(strcmp(inext,'wav')) && ~(strcmp(inext,'nist')) && ~(strcmp(inext,'raw'))
    error('Input inext it not recognized, Use wav,nist or raw');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------- Set the flags -------------------
do_gain_norm = 0;
do_delta = 1;
ceps = 14;
do_c0 =1;
if nargin > 3 ; fs = str2num(fs); end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------- Feature Extraction -------

there = exist(outfile);

if there
    % Skip feature generation if output file exists
    disp([outfile,' exists already. ',datestr(now)]);
else
    % Read sampled from the input file
    disp(infile);
    if strcmp(inext,'wav')
        [x,fs] = wavread(infile);
        x = x*2^(15); % conversion from wav to raw
    elseif strcmp(inext,'nist')
        fid = fopen(infile,'rb','l');
        x = fread(fid,inf,'int16');
        fclose(fid);
        x = x(513:end);
    elseif strcmp(inext,'raw')
        fid = fopen(infile,'rb','l');
        x = fread(fid,inf,'int16');
        fclose(fid);
    end
    if length(x) < 400
        error('File lenght too small');
    end
    A = x(:); % make sure it's vector
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % --------------- Split into Frames --------------
    
    flen=0.032*fs;  % frame length 25ms
    fhop=0.010*fs;  % frame overlap 10ms
    
    
    fnum = floor((length(A)-flen)/fhop)+1;   % Number of frames
    send = (fnum-1)*fhop + flen; % Number of samples upto the last frame
    
    A = A(1:send);
    
    fdlpwin = 10*fs;         % 10s window on the input file
    fdlpolap = 0.030*fs;        % 20 ms olap
    [X,add_samp] = frame_new(A,fdlpwin,fdlpolap);
    
    cepstra = [];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ---------- Go over each frame and compute features ------
    
    
    for i = 1 :size(X,2)
        
        x = X(:,i);
        if (i == size(X,2))
            x = X(1:end,i);  % Remove nasty silence samples present in the last chunk
        end
        
        
        x = ditherit(x);           % Dither (make sure the original samples)
        x = x - mean(x);           % mean removal to avoid any dc component in the signal
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ------- FDLP processing -------------------
        
        feat_fr = fdlpspec_plp2(x,fs,ceps,do_delta,do_gain_norm,'mel',do_c0);
        cepstra = [cepstra feat_fr];
        
        
    end
    cepstra = cepstra(:,1:fnum);
    toc;
    VFloatMatrixWrite( outfile, cepstra')
end



