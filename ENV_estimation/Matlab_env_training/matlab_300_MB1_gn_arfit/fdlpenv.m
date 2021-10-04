function env = fdlpenv(p,npts)
%FDLPENV Calculate fdlp envelopes from FDLP poles
% env = fdlpenv(p,npts)
% input is one dimensional cell array
% 
% Computed by taking the poles and finding the inverse spectrum.  
% Adapted from Marios Athineos code
 
if nargin < 2
    npts = 1000;
end

[na,nf] = size(p{1});

% How many fft points to calculate
nfft = 2*(max(npts,na)-1);

% Calculate the LPC frequency response
h = fft(p{1},nfft);
h = h(1:(nfft/2)+1,:);

% Get half of it cause it is symmetric
h = 1./h(1:(nfft/2)+1,:);

% Power spectrum 
h = (h.*conj(h));

% Correcting energy factor
env = 2*h;


% Now get the values on the correct points in time
% pvec = (0:(npts-1))/(npts-1);
% env = qinterp1(linspace(0,1,(nfft/2)+1),h,pvec,	1); % Faster version

clear p pvec;
% env = interp1(linspace(0,1,(nfft/2)+1),h,pvec,'linear')'; % Faster
% version