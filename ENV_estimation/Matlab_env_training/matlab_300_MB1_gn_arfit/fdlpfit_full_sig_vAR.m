function ENVall = fdlpfit_full_sig_vAR(x,sr,dB,do_gain_norm,band_decom,npts,nochan)

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
if nargin < 6;  nochan  = 1;           end
% fixed parameters for sub-band decomposition
cmpr = 1;
lo_freq = sr/320 ; hi_freq = (sr/2) * (19/20); % parameters used in ibm MFCC

% Take the DCT
x = dct(x')'; %(flen x fnum)    

nchan = size(x,1);

% % Get the frame length for FDLP input 
 flen = size(x,2);



% Make the new weights (and cross our fingers!)
if strcmp(band_decom,'bark') 
    [wts,idx] = barkweights(flen,sr);
    fp = round(flen/(100));     % apprx. 18 times reduction for sub-band 1 and 8 samples per/pole
elseif strcmp(band_decom,'mel') 
    [wts,idx] = melweights_mod(flen,sr);
    factor=300;                    %%%%%% Number of poles in the estimate ...
    
    fp = round(flen/(factor));     % apprx. 37 times reduction for sub-band
                                % 1 and 8 samples per/pole
    [wts,idx]=bandlimit_wtsremoval(wts,idx,flen,sr,200,6500);     %changed from (50,7000) to match with fbank 

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
ENVall = zeros(nb*nochan,npts);
%nb=2;

 K=1;

% Time envelope estimation per band and per frame.

for I = 1:K:nb,                                 % 3 sub-band merging 
    currBands = unique(I:min(I+K-1,nb)); % 
    arrCurrBands = []; 
    lenCurrBands = min (idx(currBands,2) - idx(currBands,1));

for K = 1 : length(currBands)
%         temp = x(idx(currBands(K),1):idx(currBands(K),2),:)'.*wts{currBands(K)};
%         temp = temp(1:lenCurrBands) ;
%         arrCurrBands = [arrCurrBands ; temp];
    
        temp = x(:,idx(currBands(K),1):idx(currBands(K),2)).*repmat(wts{currBands(K)},nchan,1);
        temp = temp(:,1:lenCurrBands) ;
        arrCurrBands = [arrCurrBands ; temp];
  
end


    tempENV = env_hlpc_vAR(arrCurrBands,fp,npts,do_gain_norm);
    ENVall(1+(floor(I/K)-1)*K*nochan:(floor(I/K)-1)*K*nochan+K*nochan,:) = tempENV;
% cep1=ENVall(1:nochan:end,:);
% [r,c]=size(cep1);
% f=linspace(1,r,r);
% n=linspace(1,c,c);
% subplot(1,1,1);
% surf(n, f, cep1, 'EdgeColor', 'none');
% axis xy; 
% axis tight; 
% colormap(jet); view(0,90);
% xlabel('Frame index');
% colorbar;
% ylabel('Band no.');
% title('FDLP');          

end
ENVall = ENVall';
%plot(popt,'k');
% disp('here');