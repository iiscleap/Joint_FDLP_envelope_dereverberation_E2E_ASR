import numpy 
from read_HTK import HTKFeat_read, HTKFeat_write
from pdb import set_trace as bp  #################added break point 
import torch
import numpy as np
import sys
from Net_full_cnn_deep import Net
from pdb import set_trace as bp  #################added break point accessor####################
from fdlp_env_comp_100hz_factor_40 import fdlp_env_comp_100hz_factor_40 
from forward_pass_cepstra import forward_pass
from write_HTK import write_htk

#exp        = sys.argv[1] #"/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/exp/torch_ENV_full_CNN_DEEP" 
exp        = "/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/exp/torch_ENV_full_CNN_DEEP"
#data       = sys.argv[2] #"c3cc020c.fea" 
data       = "c3cc020c.fea" 
#model_name = sys.argv[3] #"dnn_nnet_64.model"
model_name = "dnn_nnet_64.model"
#data_out   = sys.argv[4]
data_out   = "out_c3cc020c.fea"
in_channel = 1 
inputFeatDim = 36

def open(f, data_head=None, mode=None, veclen=36):
    """Open an HTK format feature file for reading or writing.
    The mode parameter is 'rb' (reading) or 'wb' (writing)."""
    
    if mode is None:
        if hasattr(f, 'mode'):
            mode = f.mode
        else:
            mode = 'rb'
    if mode in ('r', 'rb'):
        
        return HTKFeat_read(f) # veclen is ignored since it's in the file
    elif mode in ('w', 'wb'):
        return HTKFeat_write(f,data_head, veclen)
    else:
        raise Exception( "mode must be 'r', 'rb', 'w', or 'wb'")

def extract_feats_clean(data, exp, model_name):
  data_in = open(data, 'rb') 
  data_original = data_in.getall()
  clean_data = forward_pass(data_original, exp, model_name, in_channel, inputFeatDim )
  #clean_data = clean_data
  print("########### cleaned the data ###########")    
  write_htk( data_out , clean_data , 100000 , 8267 ) 
  print("########### write HTK ###########")

extract_feats_clean(data, exp, model_name)
data_in = open("out_c3cc020c.fea", 'rb') 
data_original = data_in.getall()
