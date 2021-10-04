function feats = fdlp_env_comp(x,sr,num_ceps,flag_delta,do_gain_norm)

% ---------------------------------------------------------------------
% feats = fdlp_mod_feats(x,sr,num_ceps,flag_delta,do_gain_norm)
% Function to compute the long-term Modulation spectral features based on FDLP
% processing. The input speech signal is decomposed into critical bands
% and the sub-band temporal envelopes are estimated using FDLP. 
% These envelopes are transformed to modulation spectral features 
% Optional parameter to normalize the gain of the sub-band envelopes.
% This is useful in the presence of convolutive noise. 

% 15-Oct-2008
% ---------------------------------------------------------------------

% ---------------------------------------------------------------------
% Sriram Ganapathy and Samuel Thomas
% Idiap Research Institute
% Switzerland
% {ganapathy,tsamuel}@idiap.ch
% ---------------------------------------------------------------------

%
% Copyright 2007 by IDIAP Research Institute
%                   http://www.idiap.ch
%
% See the file COPYING for the licence associated with this software.
%


%addpath /home/hltcoe/sganapathy/idiap/SPEECH/speech_rec/rastamat
%cepstra = rastaplp(x, sr, 0, 12);
%if flag_delta == 1
    
%    % Append deltas and double-deltas onto the cepstral vectors
%    del = deltas(cepstra);
    
    % Double deltas are deltas applied twice with a shorter window
%    ddel = deltas(deltas(cepstra,5),5);
    
    % Composite, 39-element feature vector, just like we use for speech recognition
%   feats = [cepstra;del;ddel];
%else
%    feats = cepstra;
%end

%return
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

% fp = number of fdlp poles
% sr = sampling rate (8000/16000)
% nb = number of bands 
% flen = analysis window in msecs
% folap = overlap window in msecs
% fdlplen = number of fdlp points 

% These params are pretty much 
dB     = 48;
flen=0.025*sr;                      % frame length corresponding to 25ms
fhop=0.010*sr;                      % frame overlap corresponding to 10ms

% cmpr =1;
 padlen=30;
% Padding the signal
x = [flipud(x(1:fhop*padlen)); x ; flipud(x(end -fhop*padlen+1:end))];

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

if length(x) < min_len
   x = [ditherit(zeros(1,round((min_len-length(x))/2)),1,'bit')'; x; ditherit(zeros(1,round((min_len-length(x))/2)),1,'bit')'];
   fdlplen = length(x);

   fnum = floor((length(x)-flen)/fhop)+1;

   % What's the last sample that feacalc will consider?
   send = (fnum-1)*fhop + flen;

end

ptmp = fdlpfit_full_sig(x,sr,dB,do_gain_norm, 'mel');
% ptmp = fdlpfit_full_sig(x,sr,dB,do_gain_norm, 'mel');

nb = size(ptmp,1);                                  % Number of Sub-bands            
p = cell(nb,1);                                     % Initialize the pole cell array        
start_band =1;
% Append the poles (for now I can only loop it)
for J=start_band:nb;
    p{J}=[p{J},ptmp{J}];
end

clear ptmp;

% ---------------------------------------------------------------------
%     Envelope Generation and Tranformation to Modulation Spectrum          
% ---------------------------------------------------------------------

ceps_time = cell(1,nb);
del = cell(1,nb);
env_all = cell(nb,1);

ENV = zeros(floor(fdlplen/factor), nb);
for J = start_band:(nb)
    ENV(:,J)  =  fdlpenv(p(J),floor(fdlplen/factor));
end

% disp(['plp2 smoothing'])
% % plp2 smoothing
% modelorder=24
% % do LPC
% lpcas = dolpc(ENV', modelorder);
% % convert lpc to spectra
% ENV = lpc2spec(lpcas, nb)';

% 
% for J = start_band:(nb)
%     %	ENV  =  fdlpenv(p(J),floor(fdlplen/factor));
%     ENV_mod = ENV(1:floor(send/factor),J)';
%     % ENV_log = log(1+ENV_mod);
%     ENV_log = (ENV_mod).^(1/2);
%     disp(['2 compression']);
%     ENV_log_new = [fliplr(ENV_log(1:mirr_len))  ENV_log fliplr(ENV_log(end-mirr_len+1:end))]; %#ok<AGROW>
%     
%     ENV_log_fr = frame_new(ENV_log_new,fdlpwin,fdlpolap);
%     ceps_time{J} = spec2cep_log(ENV_log_fr,num_ceps);
%   
% % Compute delta features using the Kollmeier Adaptative Compression model 
%     
%     if flag_delta == 1
%         ENV_new = [repmat(ENV_mod(:,1),1,floor(1000/factor)) ENV_mod];    % Initial mirroring to initialize the adaptation model 
% %        ENV_adpt = adapt_m(ENV_new/max(ENV_new),floor(sr/factor));
%         ENV_adpt = adapt_loops(ENV_new/max(ENV_new),floor(sr/factor),4);
%         ENV_adpt = ENV_adpt(round(end-send/factor+1):end);
%         ENV_adpt_new = [fliplr(ENV_adpt(1:mirr_len))  ENV_adpt fliplr(ENV_adpt(end-mirr_len+1:end))]; %#ok<AGROW>
%         ENV_adpt_fr = frame_new(ENV_adpt_new,fdlpwin,fdlpolap);
%         del{J} = spec2cep_log(ENV_adpt_fr,num_ceps);                % Envelope already in the compressed domain
%     end
%     %env_all{J} = ENV_mod;
% end
feats = [];

flag_freq_delta=1;
ENV = ENV.^(0.1);  % 0.1 compression


if flag_freq_delta == 1
    del = zeros(size(ENV));
    for J = start_band : nb
        if J == 1
            del(:,J) = -ENV(:,J)+ ENV(:,J+1);
        elseif J ==nb
            del(:,J) = -ENV(:,J-1)+ ENV(:,J);
        else
            del(:,J) = -ENV(:,J-1) + ENV(:,J+1);
        end
    end
end

if flag_delta == 1
		
    for J = start_band : nb                             % get last 19 bands only
        feats = [feats ceps_time{J}' del{J}']; %#ok<AGROW>
%        feats = [feats del{J}']; %#ok<AGROW>
    end
else
    for J = start_band : nb
        feats = [feats ceps_time{J}']; %#ok<AGROW>
    end 
end

feats = feats'; % Inorder to have the notion of feature vectors    

if fnum_old ~= fnum
    pad = (fnum - fnum_old)/2;
    feats = feats(:,pad+1:end-pad);
end

%%% Unpadding
feats = feats(:,padlen+1:end-padlen);     
