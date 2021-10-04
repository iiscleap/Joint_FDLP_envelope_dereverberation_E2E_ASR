import torch
import torch.nn as nn
from pdb import set_trace as bp  #################added break point accessor####################

################### ''' large kernel = (10,3) with 32 filters with LSTM''' ######################
class Net (nn.Module):
    def __init__(self):
        super(Net,self).__init__()
        self.conv1 = nn.Conv2d(1,64,kernel_size=(41,3),padding=(20,1))
        self.conv2 = nn.Conv2d(64,1,kernel_size=(41,3),padding=(20,1))
        
        self.lstm1 = nn.LSTM(36, 1024 , batch_first=True)
        self.lstm2 = nn.LSTM(1024, 36 , batch_first=True)

        self.conv3 = nn.Conv2d(1,64,kernel_size=(41,3),padding=(20,1))
        self.conv4 = nn.Conv2d(64,1,kernel_size=(41,3),padding=(20,1))
        
        self.relu  = nn.ReLU()

    def forward(self, x):
        x = (self.relu(self.conv1(x)))
        x = (self.relu(self.conv2(x)))
      
        x = x.transpose(1,2)
        x = torch.reshape(x,(-1,800,36))
        x,_ = self.lstm1(x)
        x,_ = self.lstm2(x)
        x   = torch.reshape(x,(-1,1,800,36))
        
        x = (self.relu(self.conv3(x)))
        x = (self.relu(self.conv4(x)))
        x   = torch.reshape(x,(-1,800,36))
        return x

 
         
