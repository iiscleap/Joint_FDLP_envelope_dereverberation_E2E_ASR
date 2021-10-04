function x = estimate_mvar(mdl,N,E)
% Estimate the multi-autoregressive model estimate ...
% Multivariate autoregressive model estimate 

p = mdl.nAR ;
d = mdl.n ;

I = eye(d);

x = zeros(d,N);
A = cell(d,d);
z = zeros(d,N);

for i = 1 : d
    for j = 1 : d
        temp = zeros(1,p);
        for q = 1 : p
            temp(q) = mdl.AR{q}(i,j);
        end
        
        currSeries = [I(i,j) -temp];
        currSeriesF = fft(currSeries,2*N-1);
        A{i,j} = currSeriesF(1:N);
        
    end
end

for n = 1 : N 
    Af = zeros(d,d);
    for i = 1 : d
        for j = 1 : d 
            Af(i,j) = A{i,j}(n);
        end
    end
    Hf = inv(Af);
    x(:,n) = real(diag(Hf * mdl.Q * Hf')); %#ok<*MINV>
end
E = sum(x,2)./E;

x = bsxfun(@rdivide,x,E);
