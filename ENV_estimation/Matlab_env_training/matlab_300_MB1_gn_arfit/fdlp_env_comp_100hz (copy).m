function feats = fdlp_env_comp_100hz(x,sr,num_ceps,flag_delta,do_gain_norm)

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
ENV = fdlpfit_full_sig_vAR(x,sr,dB,do_gain_norm, 'mel',npts);
nb = size(ENV,2);                                  % Number of Sub-bands            
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
ENV=ENV';
fdlp_spec = ENV(:,1:floor(send/factor));

opt = 'nodelay';

% compute the energy in each band for a window of 32 ms, with a 10 ms shift
bandenergy = zeros(nb,fnum);
wind = hamming(floor(flen));
for band = 1 : nb
    banddata=buffer(fdlp_spec(band,:),floor(flen),floor((flen-fhop)),opt)';
    bandenergy(band,:) = banddata*wind;
end
clear banddata;
ENV=bandenergy;
% 
% 
% 
% plp2 smoothing
% modelorder=30;
% % do LPC
% lpcas = dolpc(ENV, modelorder);
% % convert lpc to spectra
% ENV_mod = lpc2spec(lpcas, nb);
% 
% %0.5 to 12 Hz
% t_bandWidths={[0.25,15]};
% f_bandWidths={[0.0,5.0]};

ENV_mod = bandenergy ; 
ENV = ENV_mod.^(0.10) ;
% ENV_cort=aud2modulationFilt(ENV_log, t_bandWidths, f_bandWidths);       % Envelope Cortical Filtering 
% ENV = ENV_cort{1}';
ENV = ENV';

mirr_len=10;
fdlpwin=21;
fdlpolap=20;
for J = start_band:(nb)
    %	ENV  =  fdlpenv(p(J),floor(fdlplen/factor));
    ENV_log = ENV(1:fnum,J)';
    ENV_log_new = [fliplr(ENV_log(1:mirr_len))  ENV_log fliplr(ENV_log(end-mirr_len+1:end))]; %#ok<AGROW>
    
    ENV_log_fr = frame_new(ENV_log_new,fdlpwin,fdlpolap);
    ceps_time{J} = spec2cep_log(ENV_log_fr,num_ceps);
  
% Compute delta features using the Kollmeier Adaptative Compression model 
    
%     if flag_delta == 1
%         ENV_new = [repmat(ENV_mod(:,1),1,floor(1000/factor)) ENV_mod];    % Initial mirroring to initialize the adaptation model 
% %        ENV_adpt = adapt_m(ENV_new/max(ENV_new),floor(sr/factor));
%         ENV_adpt = adapt_loops(ENV_new/max(ENV_new),floor(sr/factor),4);
%         ENV_adpt = ENV_adpt(round(end-send/factor+1):end);
%         ENV_adpt_new = [fliplr(ENV_adpt(1:mirr_len))  ENV_adpt fliplr(ENV_adpt(end-mirr_len+1:end))]; %#ok<AGROW>
%         ENV_adpt_fr = frame_new(ENV_adpt_new,fdlpwin,fdlpolap);
%         del{J} = spec2cep_log(ENV_adpt_fr,num_ceps);                % Envelope already in the compressed domain
%     end
    %env_all{J} = ENV_mod;
end
feats = [];

flag_freq_delta=1;

if flag_freq_delta == 1
    del = cell(1,nb);
    for J = start_band : nb
        if J == 1
            del{J} = -ceps_time{J}+ ceps_time{J+1};
        elseif J ==nb
            del{J} = -ceps_time{J-1}+ ceps_time{J};
        else
            del{J} = -ceps_time{J-1} + ceps_time{J+1};
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
