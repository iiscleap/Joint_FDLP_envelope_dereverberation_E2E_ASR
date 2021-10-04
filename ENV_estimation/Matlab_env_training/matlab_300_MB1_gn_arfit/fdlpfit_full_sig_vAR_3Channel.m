function [ENVall ENVall1 ENVall2] = fdlpfit_full_sig_vAR_3Channel(x,x1,x2,sr,dB,do_gain_norm,band_decom,npts)

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
x1 = dct(x1); %(flen x fnum)    
x2 = dct(x2); %(flen x fnum)    

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
    factor=375;                    %%%%%% Number of poles in the estimate ...
    
    fp = round(flen/(factor));     % apprx. 37 times reduction for sub-band
                                % 1 and 8 samples per/pole
    [wts,idx]=bandlimit_wtsremoval(wts,idx,flen,sr,50,7000);

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
ENVall = zeros(nb,npts);
ENVall1 = zeros(nb,npts);
ENVall2 = zeros(nb,npts);

% Time envelope estimation per band and per frame.
for I = 1:nb,                                 % 3 sub-band merging for VAR
    temp = x(idx(I,1):idx(I,2),:)'.*wts{I};
    temp1 = x1(idx(I,1):idx(I,2),:)'.*wts{I};
    temp2 = x2(idx(I,1):idx(I,2),:)'.*wts{I};
    arrCurrBands = [temp ; temp1 ; temp2]; 
    tempENV = env_hlpc_vAR(arrCurrBands,fp,npts,do_gain_norm);
    ENVall(I,:) = tempENV(1,:);
    ENVall1(I,:) = tempENV(2,:);
    ENVall2(I,:) = tempENV(3,:);
end
