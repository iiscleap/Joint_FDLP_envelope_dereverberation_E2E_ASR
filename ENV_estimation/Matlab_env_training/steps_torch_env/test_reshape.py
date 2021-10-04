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
import tables




bp()
input_t = '/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/matlab_mc/test_reshape.mat'
ip_lin = '/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/matlab_mc/test_reshape_lin.mat'
bp()
file = tables.openFile(input_t)
inp = file.root.ip[:]
bp()
mat_ip = scipy.io.loadmat(ip)
mat_ip_lin = scipy.io.loadmat(ip_lin)

scipy.io.savemat('/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/exp/torch_ENV_CLN_CNN_with_pool4/weights.mat', {'FrameStack':FrameStack})
