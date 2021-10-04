function cepstra=generate_spectrogram(A,sr)
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

if nargin < 2;  error('Oh Boy !!! Not Enough Input parameters');end

fs = sr;
do_gain_norm = 1;

ceps = 14 ;
do_delta = 1 ;
do_c0 = 1;

flen=0.025*sr;                      % frame length corresponding to 25ms
fhop=0.010*sr;                      % frame overlap corresponding to 10ms

fnum = floor((length(A)-flen)/fhop)+1;
% What's the last sample that feacalc will consider?
send = (fnum-1)*fhop + flen;

A = A(1:send);

fdlpwin = sr;       % 10s window on the input file
fdlpolap = 0.020*sr;  % 20 ms olap 

[X,add_samp] = frame_new(A,fdlpwin,fdlpolap);

cepstra = [];
for i = 1 :size(X,2)
%	i
	flagbrk =0;
	x = X(:,i);
	if size(X,2) == 1
	    x = X(1:end-add_samp,i);                              % Remove nasty silence samples present in the last chunk
	end
	if i == size(X,2) - 1
	     x = [X(:,i); X(fdlpolap+1:end-add_samp,i+1)];  % Append
	    flagbrk =1;
	end
        % Now lets dither (make sure the original waves are not normalized!)
        x = ditherit(x,1,'bit');
        x = x - mean(x);
        

         if length(x) < 400
            disp(['File: ',infile,' lenght too small : ',datestr(now)]);
         else
            flag_delta=1; 
	    temp =  fdlp_env_comp_100hz_spectrogram(x,sr,ceps,flag_delta, do_gain_norm);

	    cepstra = [cepstra temp];
	    if flagbrk ==1
		break;
	    end
	end
end	
cepstra = cepstra(:,1:fnum);

