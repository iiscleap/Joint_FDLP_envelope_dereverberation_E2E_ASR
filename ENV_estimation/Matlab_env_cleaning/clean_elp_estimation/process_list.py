import numpy 
import os
import sys 
from pdb import set_trace as bp  #################added break point
from scipy.io import wavfile
from test_env_estmation import extract_feats_clean


exp        = "/data2/multiChannel/ANURENJAN/VOICES/ENV_estimation/Matlab_env_training/exp/torch_ENV_CLN_Net_CNN_2Layer_LSTM_arfit_WSJ"
model_name  = "dnn_nnet_64.model"
 
inList       = sys.argv[1]

I = 1
f = open(inList, "r")
for x in f:
  print(x) 
  x = x.rstrip('\n')
  xa = x.split(' ')
  xaa = xa[0]
  xab = xa[1]
  print('Processing ' + str(I) + 'th file...')
  extract_feats_clean(xaa, xab, exp, model_name)
  I += 1



