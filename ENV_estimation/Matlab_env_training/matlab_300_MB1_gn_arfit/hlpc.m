function a = hlpc(x,N,cmpr)
% HLPC Hynek's spectral transformation lpc
%   a = hlpc(x,N,cmpr)
%
%   It calculates everything with complex math and checks for real input
%   similar to the new version of lpc.m from Mathworks
%
%   x:    input signal (frame per column)
%   N:    order of the predictor
%   cmpr: spectral compression factor (1 is the regular lpc)
%
%   a:    matrix of filter coefficients (filter per column)
%         includes the gain which can be retrieved as 1./a(1,:)

% ------- hlpc.m -------------------------------------------
% Marios Athineos, marios@ee.columbia.edu
% http://www.ee.columbia.edu/~marios/
% Copyright (c) 2003-4 by Columbia University.
% All rights reserved.
% ----------------------------------------------------------

% Default value for compression is 1 which gives traditional LPC
if nargin < 3; cmpr = 1; end;

% Get the size of our framed signal
[flen,fnum] = size(x);

% Compute autocorrelation vector or matrix
X = fft(x,2^nextpow2(2*flen-1));

% '.' is just accelerated conjugation
R = ifft((X.*X'.'/flen).^cmpr);

% Do it fast with levinson (works with complex)
[a,g2] = levinson(R,N);

% Filter per column
a = a.';

% Get the gain ...
g = sqrt(g2);
% ... and embed it in the polynomial
% (I like this pattern more than the repmat one)
a = full(a*diag(sparse(1./g)));

% Get rid of the nasty imaginary roundoff if x is real
if isreal(x)
    a = real(a);
end
