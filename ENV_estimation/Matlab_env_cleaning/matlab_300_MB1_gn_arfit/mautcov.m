function str=mautcov(y,lag)

[n,m]=size(y);
cv=zeros(m,m,lag); 
%autocorrelation at zero lag

r0=y'*y/n;

% autocorrelation matrices...
for i=1:lag
   r(:,:,i)=y(1:n-i,:)'*y(1+i:n,:)/(n);
end
% autocorrelation matrices

str.r0=r0; str.r=r;  
 [~,p] = chol(r(:,:,1));
t=2;