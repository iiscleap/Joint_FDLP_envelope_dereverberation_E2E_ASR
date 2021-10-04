import numpy 
from read_HTK import HTKFeat_read, HTKFeat_write
from pdb import set_trace as bp  #################added break point 

import os
import os.path
import torch
import torch.nn as nn
#import torch.nn.functional as F
#import torch.optim as optim
#from torch.autograd import Variable
import numpy as np
import sys
from Net_full_cnn_deep import Net
#torch.cuda.current_device()
from pdb import set_trace as bp  #################added break point accessor####################
import scipy.io

exp        = "/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/exp/torch_ENV_full_CNN_DEEP" #sys.argv[1]
data       = "c3cc020c.fea" #sys.argv[2]
model_name = "dnn_nnet_64.model" #sys.argv[3]
in_channel = 1 
inputFeatDim = 36



def open(f, mode=None, veclen=13):
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
        return HTKFeat_write(f, veclen)
    else:
        raise Exception( "mode must be 'r', 'rb', 'w', or 'wb'")

def forward_pass(data, exp, model_name):
  data_in = open(data, 'rb') 
  data_feat_unpack = data_in.getall()
  #bp()
  len_in = data_feat_unpack.shape[0]
  f=data_feat_unpack.shape[0]//800
  trim=800*f 
  untrim = numpy.zeros((800-data_feat_unpack.shape[0]+trim,36))
  data_feat_unpack = numpy.concatenate((data_feat_unpack,untrim),axis=0)
  featListFirst =data_feat_unpack.reshape(1,in_channel,data_feat_unpack.shape[0],inputFeatDim)
  featListFinal_tp=numpy.empty((1,1,800,36))
   	
  for x in range(f+1):
     temp1=featListFinal_tp
     featListFinal_tp=numpy.concatenate((temp1,featListFirst[:,:,((x)*800):((x+1)*800),:]),axis=0)
  cepstra_in=featListFinal_tp[1:,:,:,:]
  cepstra_in= cepstra_in.astype(np.float32)

  #bp()
  model = exp + '/' + model_name

  print("########### Loading the trained model ##########")
  net= Net()
  net.load_state_dict(torch.load(model,map_location=lambda storage, loc: storage))
  net.eval()

  print("########### Forward Pass ###########")
  cepstra_in= torch.from_numpy(cepstra_in)
  outputs =net(cepstra_in)
  outputs =outputs.detach().numpy()

  ####torch.Size([2, 1, 800, 36])
  #bp()
  out_mat_temp = numpy.empty((800,36))
  for x in range(f+1):
     temp = out_mat_temp
     out_mat_tp=numpy.concatenate((temp,outputs[x,0,:,:]),axis=0)
  out_mat = out_mat_tp[0:len_in,:]
  return out_mat

def write_to_htk(clean_data):
  




clean_data = forward_pass(data, exp, model_name)
print("clean data shape = " + str(clean_data.shape))
