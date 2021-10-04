import numpy 
import sys 
from pdb import set_trace as bp  #################added break point
from scipy.io import wavfile
from aud_feats_no_vad_3Channel import aud_feats_no_vad_3Channel


inList       = "/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Old_EnvC_wpe_gev_BF_Estimation/matlab_mc/test.list" #sys.argv[1]

I = 1
f = open(inList, "r")
for x in f:
  print("inlist is = " + str(x)) 
  x = x.rstrip('\n')
  xa = x.split(' ')
  xaa = xa[0]
  xab = xa[1]
  xac = xa[2]
  print('Processing ' + str(I) + 'th file...')
  aud_feats_no_vad_3Channel(xaa, xab, xac)
  I += 1



