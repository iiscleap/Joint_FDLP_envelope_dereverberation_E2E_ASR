function generate_feats(infile,outfile,inext,fs)
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
    % disp(infile);
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
    cepstra = feats_no_filt(A,fs);
    toc;
    VFloatMatrixWrite( outfile, cepstra')
end



