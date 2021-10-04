function cepstra=generate_env_feats_factor_40(A,sr,nochan)
% Wrapper code to obtain FDLP features given a list of files ...

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

% ---------------------------------------------------------------------
%                       Argument check
% ---------------------------------------------------------------------

if nargin < 3;  error('Oh Boy !!! Not Enough Input parameters');end
flag_delta=0;
fs = sr;
do_gain_norm = 0;

ceps = 14 ;
do_delta = 1 ;
do_c0 = 1;

flen=0.025*sr;                      % frame length corresponding to 25ms
fhop=0.010*sr;                      % frame overlap corresponding to 10ms

fnum = floor((length(A)-flen)/fhop)+1;
% What's the last sample that feacalc will consider?
send = (fnum-1)*fhop + flen;
A = A(:,1:send);
fdlpwin = min(2*fs,send) ; %Taking full signal as one window sr;       % 2s window on the input file
fdlpolap = 0.000*sr;  % 20 ms olap 
for j=1:nochan
[X(j,:,:),add_samp] = frame_new(A(j,:),fdlpwin,fdlpolap);
end
cepstra = [];
for i = 1 :size(X,3)
%	i
	flagbrk =0;
	x = X(:,:,i);
	if size(X,3) == 1
	    x = X(:,1:end-add_samp,i);                              % Remove nasty silence samples present in the last chunk
	end
	if i == size(X,3) - 1
	     x = [(X(:,:,i))'; (X(:,fdlpolap+1:end-add_samp,i+1))'];  % Append
         x=x';
	    flagbrk =1;
	end
        % Now lets dither (make sure the original waves are not normalized!)
        %size(x);
       
         
	    temp =  fdlp_env_comp_100hz_factor_40(x,sr,ceps,flag_delta, do_gain_norm,nochan);

	    cepstra = [cepstra temp];
	    if flagbrk ==1
		break;
	    end
	end
end

%cepstra = cepstra(:,1:fnum);

