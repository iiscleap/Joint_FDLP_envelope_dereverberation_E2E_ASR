function p = fdlpfit_full_sig2(x,sr,dB,do_gain_norm,band_decom)

% FDLPFIT Fit frequency-domain linear prediction model and return the poles
% Follows a Bark Scale decomposition

%
% Copyright 2007 by IDIAP Research Institute
%                   http://www.idiap.ch
%
% See the file COPYING for the licence associated with this software.

if nargin < 2;  sr = 8000;             end
if nargin < 3;  dB     = 48;           end
if nargin < 4;  do_gain_norm = 0;      end
if nargin < 5;  band_decom = 'bark';   end

% fixed parameters for sub-band decomposition
cmpr = 1;
lo_freq = sr/320 ; hi_freq = (sr/2) * (19/20); % parameters used in ibm MFCC

% Take the DCT
x = dct(x); %(flen x fnum)    

% % Use DCT from 125 Hz to 3800 only
%frac = (size(x,1)/(sr/2));
%x = x(round(lo_freq*frac):round(hi_freq*frac));

% % Get the frame length for FDLP input 
 flen = size(x,1);



% Make the new weights (and cross our fingers!)
if strcmp(band_decom,'bark') 
    [wts,idx] = barkweights(flen,sr);
    fp = round(flen/(100));     % apprx. 18 times reduction for sub-band 1 and 8 samples per/pole
elseif strcmp(band_decom,'mel') 
    [wts,idx] = melweights_mod(flen,sr);
    factor=2700;
    fp = round(flen/(factor));     % apprx. 37 times reduction for sub-band
                                % 1 and 8 samples per/pole
    [wts,idx]=bandlimit_wtsremoval(wts,idx,flen,sr,250,6500);

elseif strcmp(band_decom,'oct') 
    [wts,idx] = octweights(flen,sr);
    fp = round(flen/(100));     % apprx. 37 times reduction for sub-band
                                % 1 and 8 samples per/pole
elseif strcmp(band_decom,'gammatone') 
    nb = 60;
    fcoefs = MakeERBFilters(sr,nb,100);
    y = ERBFilterBank([1 zeros(1,2*flen-1)], fcoefs);
    resp = dct(y',flen);
    resp = resp(1:flen,:);
    lin = -1000;
    fp = round(flen/(150));     % apprx. 37 times reduction for sub-band 1 and 8 samples per/pole
    idx = zeros(nb,1);
else
%     nbands = 24;    
    nbands = min(96,round(length(x)/100));                % This parameter can be varied... REF. IEEE SP letter, 2008.                       
    [wts,idx]  = unif_rect_wind_fixed(nbands,flen);
   fp = round((idx(1,2)-idx(1,1))/6);     % apprx. 6 samples per/pole
%fp = 20;
end

if fp < 1
    error('Oh Boy !!! FDLP needs more input speech samples');
end 
      
nb = size(idx,1);           % Number of sub-bands ...
p  = cell(nb,1);
G  = zeros(nb,1);
popt = []; 

% Time envelope estimation per band and per frame.

for I = 1:nb,
    % Apply the weights and get poles (less memory needed)
    if strcmp(band_decom,'gammatone')
        idx = find(resp(:,I) >= lin);
        tmpx = repmat(resp(idx,I),1,size(x,2)).*x(idx,:);
    else
	K1 =(length(wts{I}));
        
%	wts{I}= kaiser(K1,3.2)+ 1./kaiser(K1,3.2);
%	wts{I}= hanning(K1);
        tmpx = full(diag(sparse(wts{I}))*x(idx(I,1):idx(I,2),:));
    end
     if do_gain_norm == 1
         p{I} = hlpc_no_gain(tmpx,fp,1); 
     else 
         p{I} = hlpc(tmpx,fp,cmpr);          % FDLP without Gain Normalization 
     end
%        p{I} = hlpc_ls(tmpx,fp,cmpr);
end
%plot(popt,'k');
% disp('here');
