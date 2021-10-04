#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov  4 14:41:28 2019

@author: user
"""

import torch
import numpy 
import sys
from Net_full_cnn_deep import Net
from pdb import set_trace as bp  #################added break point accessor####################
from fdlp_env_comp_100hz_factor_40 import fdlp_env_comp_100hz_factor_40


def forward_pass(data_original, exp, model_name, in_channel=1, inputFeatDim=36):
  """Does forward pass, exponential and short term integration on the input 
    Returns the cepstra of the data"""   
  data_feat_unpack = data_original
  len_in = data_feat_unpack.shape[0]
  f=data_feat_unpack.shape[0]//800
  trim=800*f 

  untrim = numpy.zeros((800-data_feat_unpack.shape[0]+trim,36)) # (trim - len_in) == add_sample in matlab
  data_feat_unpack = numpy.concatenate((data_feat_unpack,untrim),axis=0)
  featListFirst =data_feat_unpack.reshape(1,in_channel,data_feat_unpack.shape[0],inputFeatDim)
  featListFinal_tp=numpy.empty((1,1,800,36))
   	
  for x in range(f+1):
     temp1=featListFinal_tp
     featListFinal_tp=numpy.concatenate((temp1,featListFirst[:,:,((x)*800):((x+1)*800),:]),axis=0)
  cepstra_in=featListFinal_tp[1:,:,:,:]
  cepstra_in= cepstra_in.astype(numpy.float32)

  model = exp + '/' + model_name

  print("########### Loading the trained model ##########")
  net= Net()
  net.load_state_dict(torch.load(model,map_location=lambda storage, loc: storage))
  net.eval()

  print("########### Forward Pass ###########")
  cepstraTorch= torch.from_numpy(cepstra_in)
  outputs =net(cepstraTorch)
  outputs =outputs.detach().numpy()
  outputs = outputs + cepstra_in
  print("########### adding exponential ###########")
  outExp = numpy.exp(outputs)
  print("########### short term integration ###########")
  for i in range(f):
   if i == f-1 :
      data = numpy.transpose(numpy.concatenate((outExp[i,0,:,:],outExp[f,0,0:len_in-trim,:])))
      Intout = fdlp_env_comp_100hz_factor_40(data,400, 36)
   else : 
      data = numpy.transpose(outExp[i,0,:,:])
      Intout = fdlp_env_comp_100hz_factor_40(data,400, 36)
   
   if i == 0:
      cepstra = Intout
   else :
      cepstra = numpy.concatenate((cepstra,Intout),axis=1)  
  return cepstra