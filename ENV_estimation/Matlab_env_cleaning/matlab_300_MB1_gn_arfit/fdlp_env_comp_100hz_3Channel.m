function [feats feats1 feats2] = fdlp_env_comp_100hz_3Channel(x,x1,x2,sr,num_ceps,flag_delta,do_gain_norm)

% ---------------------------------------------------------------------
%                       Argument check
% ---------------------------------------------------------------------

if nargin < 1;  error('Damn it !!! Not Enough Input parameters');end
if nargin < 2 ; sr = 8000; end
if nargin < 3 ; num_ceps=14; end
if nargin < 4;  flag_delta = 0; end
if nargin < 5;  do_gain_norm = 0; end

% ---------------------------------------------------------------------
%                      Definition of parameters
% ---------------------------------------------------------------------


% These params are pretty much 
dB     = 48;
flen=0.025*sr;                      % frame length corresponding to 25ms
fhop=0.010*sr;                      % frame overlap corresponding to 10ms

% cmpr =1;
 padlen=50;
% Padding the signal
x = [flipud(x(1:fhop*padlen)); x ; flipud(x(end -fhop*padlen+1:end))];
x1 = [flipud(x1(1:fhop*padlen)); x1 ; flipud(x1(end -fhop*padlen+1:end))];
x2 = [flipud(x2(1:fhop*padlen)); x2 ; flipud(x2(end -fhop*padlen+1:end))];



fdlplen = length(x);
fnum = floor((length(x)-flen)/fhop)+1;
send = (fnum-1)*fhop + flen;



factor=40;
flen=floor(0.025*sr/factor);                      % frame length corresponding to 25ms
fhop=floor(0.010*sr/factor);                      % frame overlap corresponding to 10ms
% What's the last sample that feacalc will consider?


trap = 10;                  % 10 FRAME context duration
mirr_len = trap*fhop;

fdlpwin = floor((0.225*sr)/factor);         % Modulation spectrum Computation Window.
fdlpolap = fdlpwin - fhop;
min_len = 0.11*sr;

% ---------------------------------------------------------------------
%                    FDLP !!!
% ---------------------------------------------------------------------
fnum_old = fnum;
npts = floor(fdlplen/factor);
% ptmp = fdlpfit_full_sig_noise(x,sr,dB,do_gain_norm, 'mel');
[ENV ENV1 ENV2] = fdlpfit_full_sig_vAR_3Channel(x,x1,x2,sr,dB,do_gain_norm, 'mel',npts);
nb = size(ENV,1);                                  % Number of Sub-bands            
start_band = 1 ;


%   ptmp = fdlpfit_full_sig(x,sr,dB,do_gain_norm, 'mel');
% % 
%  p1 = cell(nb,1);
%  for J=start_band:nb; p1{J}=[p1{J},ptmp{J}]; end
%  ENV2 = zeros(floor(fdlplen/factor), nb);
%  for J = start_band:(nb) ; ENV2(:,J)  =  fdlpenv(p1(J),floor(fdlplen/factor)); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------   Short-Term Integration ------------------

% So the new signal (after truncation) is:
fdlp_spec = ENV(:,1:floor(send/factor));
fdlp_spec1 = ENV1(:,1:floor(send/factor));
fdlp_spec2 = ENV2(:,1:floor(send/factor));



opt = 'nodelay';

% compute the energy in each band for a window of 32 ms, with a 10 ms shift
bandenergy = zeros(nb,fnum);
bandenergy1 = zeros(nb,fnum);
bandenergy2 = zeros(nb,fnum);
wind = hamming(floor(flen));
for band = 1 : nb
    
    banddata=buffer(fdlp_spec(band,:),floor(flen),floor((flen-fhop)),opt)';
    bandenergy(band,:) = banddata*wind;
    banddata1=buffer(fdlp_spec1(band,:),floor(flen),floor((flen-fhop)),opt)';
    bandenergy1(band,:) = banddata1*wind;
    banddata2=buffer(fdlp_spec2(band,:),floor(flen),floor((flen-fhop)),opt)';
    bandenergy2(band,:) = banddata2*wind;

end
clear banddata  
clear banddata1
clear banddata2

ENV=bandenergy.^(0.10);
ENV1=bandenergy1.^(0.10);
ENV2=bandenergy2.^(0.10);

feats = ENV; % Inorder to have the notion of feature vectors    
feats1 = ENV1; % Inorder to have the notion of feature vectors    
feats2 = ENV2; % Inorder to have the notion of feature vectors    

%%% Unpadding
feats = feats(:,padlen+1:end-padlen);     
feats1 = feats1(:,padlen+1:end-padlen);   
feats2 = feats2(:,padlen+1:end-padlen);     
