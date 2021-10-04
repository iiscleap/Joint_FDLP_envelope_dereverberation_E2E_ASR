#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov  6 14:52:42 2019

@author: user
"""
import numpy
import numpy.matlib
import math
from pdb import set_trace as bp  #################added break point

def  melweights_mod(flen,sr): 
    type = 'gauss'
    par  = 1
    dB   = float(48)
    
    
    # DCT length
   # flen = flen
    
    # How many output bands? (copied from rasta/init.c)
    maxmel = hz2mel_int(sr/2)
    nbands = numpy.ceil(maxmel)+1
    nbands = 42  # Hard-coded to have only 23 bands
    
    # bark per filt
    step = maxmel/(nbands - 1)
    # mel frequency of every bin in FFT
    bin = hz2mel(((numpy.linspace(0,(flen-1),num=flen))) * (sr/2)/(flen-1))
    # Weights to collapse FFT bins into aud channels

    wts = []
    
    # Initialize idx with full range
    idx = numpy.matlib.repmat((1,flen),nbands,1)
    
    # Defining Gaussian windows
    for I in range(nbands):
                
        f_mel_mid = (I) * step
        wts.append(numpy.exp((-1.0/2.0)*(bin - f_mel_mid)**2))
        #(-1/2)*(np.power((bin - f_mel_mid), 2))
        
    # convert dB to linear scale
    lin = 10**(-dB/20)
    wts=numpy.asarray(wts)
    # Finding the begin and end points
    # adjust windows and keep indices
    wts_return=[]
    for I in range(nbands):
        tmpidx   = numpy.argwhere(wts[I]>=lin)
        idx[I,:] = [min(tmpidx),max(tmpidx)]
        wts_return.append(wts[I,tmpidx])
    wts_return=numpy.asarray(wts_return)

    return wts_return, idx

def hz2mel(freq, htk=0):
    if htk == 1:
         z = 2595 * math.log10(1+f/700);
    else:
               
        	f_0 = 0
        	f_sp = 200.0/3.0
        	brkfrq = 1000.0
        	brkpt  = (brkfrq - f_0)/f_sp  # starting mel value for log region
        	logstep = numpy.exp(numpy.log(6.4)/27)  
                z = 0*freq
                linpts = (freq < brkfrq) 
         	# fill in parts separately
                
        	z = (freq[linpts] - f_0)/f_sp
        	z_not = brkpt + (numpy.log(freq[numpy.logical_not(linpts)]/brkfrq))/numpy.log(logstep)
                z_concat = numpy.concatenate((z,z_not))
    return z_concat

def hz2mel_int (freq, htk=0):
       if htk == 1:
         z = 2595 * math.log10(1+f/700);
       else:
          f_0 = 0
          f_sp = 200.0/3.0
          brkfrq = 1000.0
          brkpt  = (brkfrq - f_0)/f_sp  # starting mel value for log region
          logstep = numpy.exp(numpy.log(6.4)/27)
          z = 0*freq
          if(freq < brkfrq):
            z_concat = (freq - f_0)/f_sp   
            
          else:
            z_concat = brkpt + (numpy.log(freq/brkfrq)) / numpy.log(logstep)
          # fill in parts separately
          #z = (freq[linpts] - f_0)/f_sp
          #z_not = brkpt + (numpylog(freq[numpy.logical_not(linpts)]/brkfrq))*numpy.log(logstep)
          #z_concat = numpy.concatenate((z,z_not))
       return z_concat

