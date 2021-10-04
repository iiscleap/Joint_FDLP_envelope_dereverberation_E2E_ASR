function x = estimate_mvar_ARFIT(AModel,Q,N,E,do_gain_norm)
% Estimate the multi-autoregressive model estimate ...
% Multivariate autoregressive model estimate 

p = size(AModel,2)/size(Q,1) ; % A has columns corresponding to various lags
d = size(Q,1);

AR = cell(p,1);
for k = 1 : p
    AR{k} = AModel(:,(k-1)*d+1:k*d);
end


I = eye(d);

x = zeros(d,N);
A = cell(d,d);
z = zeros(d,N);

for i = 1 : d
    for j = 1 : d
        temp = zeros(1,p);
        for q = 1 : p
            temp(q) = AR{q}(i,j);
        end
        
        currSeries = [I(i,j) -temp];
        currSeriesF = fft(currSeries,2*N-1);
        A{i,j} = currSeriesF(1:N);
        
    end
end

% Gain normalization
% if do_gain_norm 
%     Q = I;
% end


for n = 1 : N 
    Af = zeros(d,d);
    for i = 1 : d
        for j = 1 : d 
            Af(i,j) = A{i,j}(n);
        end
    end
    Hf = inv(Af);
    x(:,n) = 2*real(diag(Hf * Q * Hf')); %#ok<*MINV>
end
%   E = sum(x,2) ; % ./E;
% 
%   x = bsxfun(@rdivide,x,E);
