import torch
import torch.nn as nn
from pdb import set_trace as bp  #################added break point accessor####################

################### ''' large kernel = (20,5) with 32 filters with LSTM''' ######################
class Net (nn.Module):
    def __init__(self):
        super(Net,self).__init__()
        self.conv1 = nn.Conv2d(1,32,kernel_size=(20,5))
        #self.B1    = nn.BatchNorm2d(32,track_running_stats=False)
        self.conv2 = nn.Conv2d(32,32,kernel_size=(20,5))
        self.pool1 = nn.MaxPool2d(kernel_size=(4,2))
        self.drop1 = nn.Dropout(0.2)
        self.conv3 = nn.Conv2d(32,32,kernel_size=(20,5))
        self.conv4 = nn.Conv2d(32,8,kernel_size=(20,5))
        self.drop2 = nn.Dropout(0.2)
        #self.pool2 = nn.MaxPool2d(kernel_size=(4,2))
        self.lstm  = nn.LSTM(48 , 1024 , batch_first=True) 
        #self.fc1   = nn.Linear(38*3*8,1024)
        #self.drop3 = nn.Dropout(0.2)
        #self.fc2   = nn.Linear(1024,1024)
        #self.drop4 = nn.Dropout(0.2)
        self.fc3   = nn.Linear(1024,800*36)
        self.relu  = nn.ReLU()
        #self.tanh  = nn.Tanh()

    def forward(self, x):
        
        x = self.relu(self.conv1(x))
        x = self.relu(self.conv2(x))
        x = self.pool1(self.drop1(x))
        x = self.relu(self.conv3(x))
        x = self.drop2(self.relu(self.conv4(x)))
        #x = self.pool2(self.drop2(x))
        x = x.transpose(1,2)
        x = torch.reshape(x,(-1,152,8 * 6)) ###### seq length is 8*6
        #x = x.transpose(1,2)
        x,_ = self.lstm(x)          ## output shape == (32,152,128) take only the last output of the LSTM in the next step
        x = self.relu(x[:,151,:])   ############### (B,seq_len, 128) ==>> remove seq_len to get (32,128) try the other way as well i.e.,(B,48)
	x = self.fc3(x)
        return x

 
         
