#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov  4 14:41:28 2019

@author: user
"""

import torch
import numpy 
import sys
#from Net_full_cnn_deep import Net
#from Net_larg_kernel import Net
#from Net_full_cnn_deep_64filters import Net
from NET.Net_CNN_2LSTM_padding_64filters_last2_full_utt import Net
from pdb import set_trace as bp  #################added break point accessor####################
from fdlp_env_comp_100hz_factor_40 import fdlp_env_comp_100hz_factor_40
from read_HTK import HTKFeat_read, HTKFeat_write


def forward_pass(data_original, exp, model_name, in_channel=1, inputFeatDim=36):
  """Does forward pass, exponential and short term integration on the input 
    Returns the cepstra of the data"""   
  #bp()
  cepstra_in = numpy.expand_dims(numpy.expand_dims(data_original, axis=0),axis=0)
  cepstra_in= cepstra_in.astype(numpy.float32)

  model = exp + '/' + model_name

  print("########### Loading the trained model ##########")
  net= Net()
  net.eval()
  net.load_state_dict(torch.load(model,map_location=lambda storage, loc: storage))
  print("########### Forward Pass ###########")
  cepstraTorch = torch.from_numpy(cepstra_in)
  outputs = net(cepstraTorch)
  outputs = outputs.detach().numpy()
  #bp()
  outputs = numpy.squeeze(outputs, axis=0)
  outputs = outputs + data_original
  
  data_feat_unpack = outputs
  len_in = data_feat_unpack.shape[0]
  f=data_feat_unpack.shape[0]//800
  trim=800*f 
  #bp()
  untrim = numpy.zeros((800-data_feat_unpack.shape[0]+trim,36)) # (trim - len_in) == add_sample in matlab
  data_feat_unpack = numpy.concatenate((data_feat_unpack,untrim),axis=0)
  featListFirst =data_feat_unpack.reshape(1,in_channel,data_feat_unpack.shape[0],inputFeatDim)
  featListFinal_tp=numpy.empty((1,1,800,36))
   	
  for x in range(f+1):
     temp1=featListFinal_tp
     featListFinal_tp=numpy.concatenate((temp1,featListFirst[:,:,((x)*800):((x+1)*800),:]),axis=0)
  cepstra_in=featListFinal_tp[1:,:,:,:]
  
  #bp()
  print("########### adding exponential ###########")
  outExp = numpy.exp(cepstra_in)
  print("########### short term integration ###########")
  #cepstra = []
  if f == 0:
      data = numpy.transpose(outExp[f,0,:,:])
      Intout = fdlp_env_comp_100hz_factor_40(data[:,0:len_in],400, 36)
      cepstra = Intout
  else :     
      for i in range(f):
       if i == f-1 :
          data = numpy.transpose(numpy.concatenate((outExp[i,0,:,:],outExp[f,0,0:len_in-trim,:])))
          Intout = fdlp_env_comp_100hz_factor_40(data,400, 36)
       else : 
          data = numpy.transpose(outExp[i,0,:,:])
          #bp()
          Intout = fdlp_env_comp_100hz_factor_40(data,400, 36)
       if i == 0:
          cepstra = Intout
       else :
          cepstra = numpy.concatenate((cepstra,Intout),axis=1)  
  #cepstra = numpy.asarray(cepstra) 
  #bp()    
  return cepstra


def open(f, mode=None, veclen=36):
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

#data_in = open('ones.fea', 'rb') 
#data_original = data_in.getall()
#data_original = data_original.T
#bp()
#Intout = fdlp_env_comp_100hz_factor_40(data_original,400, 36)
#write_htk( 'python_ones_int.fea' , Intout , 100000 , 8267 )
#data_int = open('python_ones_int.fea', 'rb') 
#data_integrate = data_int.getall()
#print("################################# MATLAB OUTPUT ##############################################")
#data_mat = open('ones_int.fea', 'rb') 
#data_matint = data_mat.getall()
