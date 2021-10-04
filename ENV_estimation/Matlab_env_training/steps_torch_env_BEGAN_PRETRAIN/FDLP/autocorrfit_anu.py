#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 28 14:53:40 2019

@author: user
"""

def autocorrfit_anu(v, p):

    
    
    str=mautcov(v,p)
    
    [r,c]=v.shape
    R{1}=str.r0;
    for i=1:p-1
        R{i+1}=str.r(:,:,i);
        
    
    Rn{1}=str.r(:,:,p);
    
    Q=R;%blocks
    n=length(Q);
    result = cell2mat(Q(toeplitz(1:n)));
    for i=1:p-1
        for j=1:i
            
        result(1+i*c:(i+1)*c,1+(j-1)*c:(j)*c) = result(1+i*c:(i+1)*c,1+(j-1)*c:(j)*c)';
        end
    end  
    
    L=-cell2mat({R{2:p},Rn{1}});
    
    
    A=inv(result)*L';
    
    
    E=cell2mat({R{1:p},Rn{1}});
    F= cat(1,eye(c),A);
    s=zeros(c,c);
    for i=1:p+1
        temp=E(:,1+(i-1)*c:c+(i-1)*c)*F(1+(i-1)*c:c+(i-1)*c,:);
        s=s+temp;
    end
    C=s;
    Cnorm=C;
    
    
    for i=1:p
        B(:,1+(i-1)*c:c+(i-1)*c)=-A(1+(i-1)*c:c+(i-1)*c,:)';
        
    end
    A=B;
