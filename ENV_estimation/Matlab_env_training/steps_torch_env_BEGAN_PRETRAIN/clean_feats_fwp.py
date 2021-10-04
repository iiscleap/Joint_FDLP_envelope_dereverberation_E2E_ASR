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
from pdb import set_trace as bp  #################added break point accessor####################
import scipy.io



exp        = sys.argv[1]
data       = sys.argv[2]
model_name = sys.argv[3]

model = exp + model_name

#cepstra_in= np.genfromtxt(data, delimiter=",")
cepstra_in= data.astype(np.float32)
cepstra_in = np.array(cepstra_in)
cepstra_in=cepstra_in.reshape(cepstra_in.shape[0],1,cepstra_in.shape[1])

print("########### Loading the trained model ##########")
net= Net()
net.load_state_dict(torch.load(model,map_location=lambda storage, loc: storage))
net.eval()

print("########### Forward Pass ###########")
cepstra_in= torch.from_numpy(cepstra_in)
outputs =net(cepstra_in)
outputs =outputs.detach().numpy()




                                                                                                                                                                                          1,1           Top

