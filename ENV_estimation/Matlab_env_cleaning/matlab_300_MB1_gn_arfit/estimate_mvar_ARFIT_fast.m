function x = estimate_mvar_ARFIT_fast(AModel,Q,N,E,do_gain_norm)
% Estimate the multi-autoregressive model estimate ...
% Multivariate autoregressive model estimate 

p = size(AModel,2)/size(Q,1) ; % A has columns corresponding to various lags
d = size(Q,1);

I = eye(d,d) ; 
AR = [I -AModel] ;

AR_mod = reshape(AR,d*d,p+1);
A = fft(AR_mod,2*N-1,2);
A = A(:,1:N);


% Gain normalization
% if do_gain_norm
%     Q = I;
% end

x = zeros(d,N);

for n = 1 : N 
    H = inv(reshape(A(:,n),d,d)); 
    x(:,n) = 2*real(diag(H * Q * H'));
end
    
if do_gain_norm 
    x = x./repmat(sum(x,2),1,N);
end
