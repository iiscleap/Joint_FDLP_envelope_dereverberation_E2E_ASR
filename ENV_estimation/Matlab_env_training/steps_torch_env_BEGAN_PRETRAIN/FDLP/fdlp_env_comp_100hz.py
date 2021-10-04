#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov  4 18:24:26 2019

@author: use"""

import math
import numpy
from fdlpfit_full_sig_vAR import fdlpfit_full_sig_vAR
from pdb import set_trace as bp  #################added break point




def fdlp_env_comp_100hz(x,sr,num_ceps,flag_delta,do_gain_norm,nochan):
   
    
    # These params are pretty much 
    dB     = 48
    flen=0.025*sr                      # frame length corresponding to 25ms
    fhop=0.010*sr                      # frame overlap corresponding to 10ms
    #size(x)
    
    # cmpr =1
    padlen=0
    # Padding the signal
    

    y = numpy.append(numpy.fliplr(x[:,1:int(fhop*padlen)]), x)  
    x = numpy.append(y, numpy.fliplr(x[: , int(x.shape[1]-fhop*padlen):x.shape[1]]))
    x = numpy.expand_dims(x, axis=0)
    fdlplen = x.shape[1]
    
    fnum = int(math.floor((len(x)-flen)/fhop)+1)
    send = (fnum-1)*fhop + flen
    
    
    
    factor=40
    flen=int(math.floor(0.025*sr/factor) )                     # frame length corresponding to 25ms
    fhop=int(math.floor(0.010*sr/factor) )                      # frame overlap corresponding to 10ms
    # What's the last sample that feacalc will consider?
    
    
    trap = 10                  # 10 FRAME context duration
    mirr_len = trap*fhop
    
    fdlpwin = int(math.floor((0.225*sr)/factor) )        # Modulation spectrum Computation Window.
    fdlpolap = fdlpwin - fhop
    min_len = 0.11*sr
    
    # ---------------------------------------------------------------------
    #                    FDLP !!!
    # ---------------------------------------------------------------------
    fnum_old = fnum
    npts = int(math.floor(fdlplen/factor))

    ENV = fdlpfit_full_sig_vAR(x,sr,dB,do_gain_norm, 'mel',npts,nochan)
    
    
    nb = ENV.shape[1]                                  # Number of Sub-bands            
    start_band = 1 
    
    
    
    #############################################################
    # ---------------   Short-Term Integration ------------------Commented by
    
    return ENV.T
       
