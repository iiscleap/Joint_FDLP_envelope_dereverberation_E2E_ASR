#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov  4 15:26:41 2019

@author: user
"""
import numpy
from pdb import set_trace as bp  #################added break point
import math
from buffer import buffer
from ditherit import ditherit
from scipy import signal
from fdlp_env_comp_100hz import fdlp_env_comp_100hz

def generate_env_feats(A,fs,nochan):
    sr=fs
    do_gain_norm = 0
    
    ceps = 14 
    do_delta = 1 
    do_c0 = 1
    
    flen = 0.025*sr                      # frame length corresponding to 25ms
    fhop = 0.010*sr                      # frame overlap corresponding to 10ms
    
    fnum = math.floor((A.shape[1]-flen)/fhop)+1
    # What's the last sample that feacalc will consider?
    send = (fnum-1)*fhop + flen
    A = A[:,0:int(send)]
    fdlpwin = int(min(2*fs,send))  #Taking full signal as one window sr       # 2s window on the input file
    fdlpolap =int(0.020*sr)  # 20 ms olap 
    for j in range(nochan):
       X_frame = numpy.expand_dims(buffer(A[j,:], fdlpwin,fdlpolap,'nodelay'), axis=0)
       if j == 0:
           X = X_frame
       else :
           X = numpy.concatenate((X, X_frame),axis=0)

    add_samples = ((fdlpwin * X.shape[2]) - A.shape[1]- ((X.shape[2]-1) *  fdlpolap))
    cepstra = []
   
    for i in range(X.shape[2]):
        
        flagbrk =0
        x = X[:,:,i]
        if X.shape[2] == 1:
           x = X[:,0:X.shape[1]-add_samples,i]                              # Remove nasty silence samples present in the last chun

        if i == (X.shape[2] -1)  and (X.shape[2] != 1):
           x = numpy.append(X[:,:,i].T,X[:,fdlpolap:X.shape[1]-add_samples,i].T)
           x = numpy.expand_dims(x,axis=1)
           x = x.T
           flagbrk = 1
        #bp()
        # Now lets dither (make sure the original waves are not normalized!)
        x = ditherit(x,1,'bit')
        
        x = signal.detrend(x,axis=1,type='constant')
        
        
        if x.shape[1] < 400:
           print("File: lenght too small : ") 
        else:
           flag_delta=1 
           temp =  fdlp_env_comp_100hz(x,sr,ceps,flag_delta, do_gain_norm,nochan)
           cepstra = cepstra.append(cepstra,temp)
           cepstra = numpy.asarray(cepstra)
        if flagbrk ==1:
    	      break

