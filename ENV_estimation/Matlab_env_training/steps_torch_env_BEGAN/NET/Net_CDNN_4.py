import torch
import torch.nn as nn
from pdb import set_trace as bp  #################added break point accessor####################
################### ''' large kernel with 32 filters and 2 layer LSTM ''' ######################
class Net (nn.Module):
    def __init__(self):
        super(Net,self).__init__()
        self.conv1 = nn.Conv2d(1,32,kernel_size=(21,5), padding = (10,2))
        #self.B1    = nn.BatchNorm2d(32,track_running_stats=False)
        self.conv2 = nn.Conv2d(32,32,kernel_size=(21,5), padding = (10,2))
        self.pool1 = nn.MaxPool2d(kernel_size=(4,2))
        self.drop1 = nn.Dropout(0.2)
        self.conv3 = nn.Conv2d(32,32,kernel_size=(21,5), padding = (10,2))
        self.conv4 = nn.Conv2d(32,8,kernel_size=(21,5), padding = (10,2))
        self.drop2 = nn.Dropout(0.2)
        self.lstm  = nn.LSTM(200,128,num_layers=2,batch_first=True)
        self.fc3   = nn.Linear(128,198*36)
        self.relu  = nn.ReLU()
        

    def forward(self, x):
        x = self.relu(self.conv1(x))
        x = self.relu(self.conv2(x))
        x = self.pool1(self.drop1(x))
        x = self.relu(self.conv3(x))
        x = self.relu(self.conv4(x))
        x = self.drop2(x)
        x = x.transpose(1,2)
        x = torch.reshape(x,(-1,200,8*18))
        x = x.transpose(1,2)
        x,_ = self.lstm(x)
        x = x.transpose(0,1)
        x = self.relu(x[-1])
        x = self.fc3(x)
        return x

 
         
