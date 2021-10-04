import torch
import torch.nn as nn
from pdb import set_trace as bp  #################added break point accessor####################

################### ''' large kernel = (10,3) with 32 filters with LSTM''' ######################
class Net (nn.Module):
    def __init__(self):
        super(Net,self).__init__()
        self.conv1 = nn.Conv2d( 1,64,kernel_size=(41,3),padding=(20,1))
        self.conv2 = nn.Conv2d(64,64,kernel_size=(41,3),padding=(20,1))
        self.conv3 = nn.Conv2d(64,64,kernel_size=(21,5),padding=(10,2))
        self.conv4 = nn.Conv2d(64,64,kernel_size=(21,5),padding=(10,2))
        self.lstm1 = nn.LSTM(36*64, 1024 , batch_first=True) 
        self.lstm2 = nn.LSTM(1024, 36 , batch_first=True)
        self.relu  = nn.ReLU()

    def forward(self, x):
        x1 = (self.relu(self.conv1(x)))
        x2 = (self.relu(self.conv2(x1)))
        x1_skip = x1 + x2   # skip connection from x1 sum with conv2's output
        x3 = (self.relu(self.conv3(x1_skip)))
        x2_skip = x2 + x3   # skip connection from x2 sum with conv3's output
        x4 = (self.relu(self.conv4(x2_skip)))
        x  =  x3 + x4       # skip connection from x3 sum withconv4's output
        x = x.transpose(1,2)     
        x = torch.reshape(x,(-1,800,36*64))
        x,_ = self.lstm1(x)
        x,_ = self.lstm2(x)   
        return x

 
        
