#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov  4 18:29:18 2019

@author: user"""
import numpy 
import math
from scipy import fftpack
from melweights_mod import melweights_mod
from pdb import set_trace as bp  #################added break point
from bandlimit_wtsremoval import bandlimit_wtsremoval
import numpy.matlib
from env_hlpc_vAR import env_hlpc_vAR



def fdlpfit_full_sig_vAR(x,sr,dB,do_gain_norm,band_decom,npts,nochan):
    
    # fixed parameters for sub-band decomposition
    cmpr = 1
    lo_freq = sr/320 
    hi_freq = (sr/2) * (19/20) # parameters used in ibm MFCC

    # Take the DCT
    x = fftpack.dct(x,norm='ortho') #(flen x fnum)    
    
    nchan = x.shape[0]
    
    # # Get the frame length for FDLP input 
    flen = x.shape[1]
    
    
    
    # Make the new weights (and cross our fingers!)
#    if str(band_decom) == 'bark' :
#        [wts,idx] = barkweights(flen,sr)
#        fp = round(flen/(100))     # apprx. 18 times reduction for sub-band 1 and 8 samples per/pole
    if str(band_decom) == 'mel': 

        [wts,idx] = melweights_mod(flen,sr)
        #[wts,idx] = librosa.filters.mel(sr,)
        factor=300                    ###### Number of poles in the estimate ...
        
        fp = round(flen/(factor))     # apprx. 37 times reduction for sub-band
                                    # 1 and 8 samples per/pole
        [wts,idx]=bandlimit_wtsremoval(wts,idx,flen,sr,200,6500)     #changed from (50,7000) to match with fbank 
#    elif str(band_decom) =='oct': 
#        [wts,idx] = octweights(flen,sr)
#        fp = round(flen/(100))     # apprx. 37 times reduction for sub-band
#                                    # 1 and 8 samples per/pole
#    elif str(band_decom) == 'gammatone' :
#        nb = 60
#        fcoefs = MakeERBFilters(sr,nb,100)
#        #y = ERBFilterBank([1 numpy.zeros((1,2*flen-1))], fcoefs) ############################################################################
#        resp = fftpack.dct(y.T,flen)
#        resp = resp[1:flen,:]
#        lin = -1000
#        fp = round(flen/(150))     # apprx. 37 times reduction for sub-band 1 and 8 samples per/pole
#        idx = zeros(nb,1)
#    else:
#    #     nbands = 24    
#        nbands = min(96,round(length(x)/100))                # This parameter can be varied... REF. IEEE SP letter, 2008.                       
#        [wts,idx]  = unif_rect_wind_fixed(nbands,flen)
     #  fp = round((idx(1,2)-idx(1,1))/6)     # apprx. 6 samples per/pole ######################################################################
    #fp = 20
    
    
    if fp < 1 :
        print('Oh Boy !!! FDLP needs more input speech samples')
     
          
    nb = idx.shape[0]           # Number of sub-bands ...
    ENVall = numpy.zeros((nb*nochan,npts))
    #nb=2
    
    K=1
    
    # Time envelope estimation per band and per frame.
    
    for I in range(nb):
        K=1                                 # 3 sub-band merging 
        currBands = numpy.unique(numpy.arange(I,min(I+K-1,nb)+1)) # 
        arrCurrBands = [] 
        lenCurrBands = min (idx[currBands,1] - idx[currBands,0])
        bp()
        for K in range(0,len(currBands)):    
            temp = x[:,idx[currBands[K],0]:idx[currBands[K],1]+1] * (numpy.matlib.repmat(wts[currBands[K]],nchan,1)).T
            temp = temp[:,0:lenCurrBands] 
#           arrCurrBands = [arrCurrBands  temp]
      
   
    
    
    tempENV = env_hlpc_vAR(arrCurrBands,fp,npts,do_gain_norm)
    #tempENV = ENVall(1+(int(math.floor(I/K))-1)*K*nochan:(int(math.floor(I/K))-1)*K*nochan+K*nochan,:) 
             
    bp()    
    ENVall = ENVall.T
