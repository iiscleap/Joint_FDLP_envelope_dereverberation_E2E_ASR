import torch
import torch.nn as nn
from pdb import set_trace as bp  #################added break point accessor####################

################### ''' large kernel = (20,5) with 32 filters with LSTM''' ######################
class Net (nn.Module):
    def __init__(self):
        super(Net,self).__init__()
        self.conv1 = nn.Conv2d(1,32,kernel_size=(21,5),padding=(10,2))
        self.conv2 = nn.Conv2d(32,32,kernel_size=(21,5),padding=(10,2))
        self.drop1 = nn.Dropout(0.2)
        self.conv3 = nn.Conv2d(32,32,kernel_size=(21,5),padding=(10,2))
        self.conv4 = nn.Conv2d(32,8,kernel_size=(21,5),padding=(10,2))
        self.drop2 = nn.Dropout(0.2)
        self.lstm  = nn.LSTM(288, 36 , num_layers=2 , batch_first=True) 
        self.relu  = nn.ReLU()

    def forward(self, x):
        x = self.relu(self.conv1(x))
        x = self.relu(self.conv2(x))
        x = self.relu(self.conv3(x))
        x = self.drop2(self.relu(self.conv4(x)))
        x = x.transpose(1,2)
        x = torch.reshape(x,(-1,800,36*8)) 
        x,_ = self.lstm(x)          
        x = self.relu(x)   
        return x

 
         
