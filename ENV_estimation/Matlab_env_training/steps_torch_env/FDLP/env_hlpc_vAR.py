#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 28 11:49:18 2019

@author: user
"""

def env_hlpc_vAR(Y,nAR,N,do_gain_norm):
# Function to perform vector Autoregressive modeling and envelope
# generation
# Input Y has time along the columns and dimensions along the rows
# Typical input is sub-band DCT along the rows
# Sriram Ganapathy - 25-10-2016

    if Y.shape[1] > Y.shape[0]: 
        Y = Y.T
    
    
    #size(Y)
    E =  sum(Y**2)  # For energy matching property
    
    # # Matlab vgx model
    # tic 
    # Mdl = vgxset('n',size(Y,2),'nAR',nAR,'Constant',false)
    # EstMdl = vgxvarx(Mdl,Y,[],[],'CovarType','full')
    # ENV = estimate_mvar(EstMdl,N,E')
    # toc 
    # ArFit Model
    # tic 
    # addpath /home/sriram/speech/software/ARFIT
    # do_gain_norm=0
    #[w, A, C_cln_arfit,Cnorm_near_arfit]= arfit(Y, nAR,nAR,'zero')
    #  ENV1 = estimate_mvar_ARFIT_fast(A,C,N,E',do_gain_norm)
    # 
    # if do_gain_norm
    #      ENV = estimate_mvar_ARFIT_fast(A,Cnorm,N,E',do_gain_norm)
    #  else 
    #     ENV = estimate_mvar_ARFIT_fast(A,C,N,E',do_gain_norm)
    #  end
    # 
    [A, C, Cnorm] = autocorrfit_anu(Y, nAR)
     
    
    
    if do_gain_norm == 1:
         ENV = estimate_mvar_ARFIT_fast(A,C,N,E.T,do_gain_norm)
    else :
        ENV = estimate_mvar_ARFIT_fast(A,C,N,E.T,do_gain_norm)
    
    
    # toc 
    # disp('Done')