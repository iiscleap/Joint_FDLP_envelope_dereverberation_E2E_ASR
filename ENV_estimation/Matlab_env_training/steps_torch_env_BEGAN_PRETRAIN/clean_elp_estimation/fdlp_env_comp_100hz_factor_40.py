#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import numpy
from buffer import buffer
import scipy.io
import math
from scipy import signal
from pdb import set_trace as bp  #################added break point accessor####################

def fdlp_env_comp_100hz_factor_40(x, sr=400, nochan=36):
  dB     = 48
  flen   =0.025*sr                      # frame length corresponding to 25ms
  fhop   =0.010*sr                      # frame overlap corresponding to 10ms
  fdlplen = x.shape[1]
  fnum = int((x.shape[1]-flen)//fhop)+1
  send = (fnum-1)*fhop + flen
  factor=1
  flen=int(0.025*sr//factor)                      # frame length corresponding to 25ms
  fhop=int(0.010*sr//factor)                      # frame overlap corresponding to 10ms
  trap = 10                                        # 10 FRAME context duration
  mirr_len = trap*fhop

  fdlpwin =int((0.225*sr)//factor)               # Modulation spectrum Computation Window.
  fdlpolap = fdlpwin - fhop
  min_len = 0.11*sr

#---------------------------------------------------------------------
#                    FDLP !!!
# ---------------------------------------------------------------------
  fnum_old = fnum
  npts = (fdlplen//factor)
  ENV = x
  nb = ENV.shape[0]                                  # Number of Sub-bands            
  start_band = 1 
# ---------------   Short-Term Integration ------------------Commented by
# So the new signal (after truncation) is:
  fdlp_spec = ENV[:,0:int(math.floor(send/factor))]
  opt = 'nodelay'
 
# compute the energy in each band for a window of 32 ms, with a 10 ms shift
  bandenergy = numpy.zeros((nb,fnum))
  wind = signal.hamming(flen)
  for band in range (nb):
      #bp()
      banddata = numpy.transpose(buffer(fdlp_spec[band,:],flen,(flen-fhop),opt))
      bandenergy[band,:] =numpy.transpose(numpy.matmul(banddata,wind))
  
  banddata = None
  ENV=bandenergy
  ENV = ENV**(0.10)
  flag_freq_delta=0
  feats = ENV 
  
  padlen = 0 
### Unpadding
  feats = feats[:,fhop*padlen:feats.shape[1]-fhop*padlen]
  return feats
