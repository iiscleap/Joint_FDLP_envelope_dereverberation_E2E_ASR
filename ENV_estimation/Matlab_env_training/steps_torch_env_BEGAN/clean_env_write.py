#!/usr/bin/python3

##  Copyright (C) 2016 D S Pavan Kumar
##  dspavankumar [at] gmail [dot] com
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os
import os.path
import torch
import torch.nn as nn
#import torch.nn.functional as F
#import torch.optim as optim
#from torch.autograd import Variable
import numpy as np
import sys
from Net_LSTM_BatchNorm_NIN import Net
#torch.cuda.current_device()
import time
from pdb import set_trace as bp  #################added break point accessor####################
import scipy.io



exp = sys.argv[1]
data  = sys.argv[2]
model=exp + '/dnn_nnet_64.model'
print ("Predicting the ENVS")
#bp()
name = data.split('/')
name = name[7]
name = name.split('.')
name = name[0]
name = '/home/anirudhs/tmp/ENV_DNN/REVERB_ENV_DNN/mat_files/' + name + '.mat'
cepstra_in= np.genfromtxt(data, delimiter=",")
cepstra_in= cepstra_in.astype(np.float32)
cepstra_in = np.array(cepstra_in) # For converting to a NumPy array
cepstra_in=cepstra_in.reshape(cepstra_in.shape[0],1,cepstra_in.shape[1])
net= Net()
net.load_state_dict(torch.load(model,map_location=lambda storage, loc: storage))
net.eval()
cepstra_in= torch.from_numpy(cepstra_in)
outputs =net(cepstra_in)
outputs =outputs.detach().numpy()
