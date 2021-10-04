function feats = fdlp_spec_feats(x,sr,num_ceps,flag_delta,do_gain_norm,band_decom,energy)

% ---------------------------------------------------------------------
% feats = fdlp_spec_feats(x,sr,num_ceps,flag_delta,do_gain_norm)
% Function to compute the short-term spectral features based on FDLP
% processing. The input speech signal is decomposed into critical bands
% and the sub-band temporal envelopes are estimated using FDLP. 
% These envelopes are integrated to give short-term energy features 
% which are converted to cepstral features. 
% Optional parameter to normalize the gain of the sub-band envelopes.
% This is useful in the presence of convolutive noise. 
% Band-Decompostion can be Bark scale, Mel scale or linear with 96 uniform
% bands.The output feats start from the zeroth cepstral co-efficient.

% ---------------------------------------------------------------------
% Sriram Ganapathy
% IBM Watson Labs
% June 22, 2010
% ---------------------------------------------------------------------

% ---------------------------------------------------------------------
%                       Argument check
% ---------------------------------------------------------------------

if nargin < 1;  error('Oh Boy !!! Not Enough Input parameters');end
if nargin < 2 ; sr = 8000; end
if nargin < 3 ; num_ceps=13; end
if nargin < 4;  flag_delta = 0; end
if nargin < 5;  do_gain_norm = 0; end
if nargin < 6;  band_decom = 'bark'; end
if nargin < 7;  energy = 0; end

if strcmp(band_decom,'bark') == 0 && strcmp(band_decom,'mel') == 0 && strcmp(band_decom,'linear') == 0 && strcmp(band_decom,'gammatone') == 0
   error('Oh Boy !!! Sub-band decomposition Undefined. Try bark, mel or linear');
end 

if length(x) < 500
      error('Oh Boy !!! FDLP needs more input speech samples');
end 

% ---------------------------------------------------------------------
%                      Definition of parameters
% ---------------------------------------------------------------------

% fp = number of fdlp poles
% sr = sampling rate (8000/16000)
% nb = number of bands 
% flen = analysis window in msecs
% folap = overlap window in msecs
% fdlplen = number of fdlp points 

% These params are pretty much fixed
dB     = 48;
flen=0.032*sr;                      % frame length corresponding to 25ms
fhop=0.010*sr;                      % frame overlap corresponding to 10ms
padlen=20;
% Padding the signal
x = [flipud(x(1:fhop*padlen)); x ; flipud(x(end -fhop*padlen+1:end))];

factor = 20;
fdlplen = floor(length(x)/factor);                % Input signal size
modelorder=12;
% ---------------------------------------------------------------------
%                    FDLP !!!
% ---------------------------------------------------------------------

ptmp = fdlpfit_full_sig(x,sr,dB,do_gain_norm,band_decom);
nb = size(ptmp,1);                                  % Number of Sub-bands            
p = cell(nb,1);                                     % Initialize the pole cell array        

% Append the poles (for now I can only loop it)
for J=1:nb; 
    p{J}=[p{J},ptmp{J}]; 
end

clear ptmp;

% ---------------------------------------------------------------------
%                   Envelope Generation            
% ---------------------------------------------------------------------
      
fdlp_spec =zeros(nb,fdlplen);                    % Array Containing the FDLP temporal envelopes
cmpr =1;

for J = 1:(nb)
    fdlp_spec(J,:) =  fdlpenv(p(J),fdlplen)';            % Envelope generation from poles by polynomial interpolation     
end
       
fdlp_spec = fdlp_spec(:,1:fdlplen);
clear ENV ENV_mod p;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------   Short-Term Integration ------------------

% Number of analysis frames
fnum = floor((length(x)-flen)/fhop)+1;

% Number of samples used
send = (fnum-1)*fhop + flen;

% So the new signal (after truncation) is:
fdlp_spec = fdlp_spec(:,1:floor(send/factor));

opt = 'nodelay';

% compute the energy in each band for a window of 32 ms, with a 10 ms shift
bandenergy = zeros(nb,fnum);
wind = hamming(floor(flen/factor));
for band = 1 : nb
    banddata=buffer(fdlp_spec(band,:),floor(flen/factor),floor((flen-fhop)/factor),opt)';
    bandenergy(band,:) = banddata*wind;
end
clear banddata;

feats = bandenergy ;

% % do LPC
% lpcas = dolpc(bandenergy, modelorder);
% % convert lpc to cepstra
% feats = lpc2spec(lpcas, nb);

%%% Unpadding
feats = feats(:,padlen+1:end-padlen);

     

