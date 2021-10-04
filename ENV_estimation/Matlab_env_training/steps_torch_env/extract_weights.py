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
from Net_larg_kernel import Net
#torch.cuda.current_device()
import time
from pdb import set_trace as bp  #################added break point accessor####################
import scipy.io


#bp()
exp = sys.argv[1]
model=exp + '/dnn_nnet_64.model'
#bp()
net= Net()
net.load_state_dict(torch.load(model,map_location=lambda storage, loc: storage))
net.eval()
#bp()
L = list(net.parameters())
FrameStack = np.empty((len(L),), dtype=np.object)
for i in range(len(L)):
    FrameStack[i] = L[i].data.numpy()
#bp()
scipy.io.savemat('/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Matlab_RAW_features/exp/torch_ENV_CLN_CNN_with_Net_larg_kernel_without_batchnorm/weights.mat', {'FrameStack':FrameStack})
