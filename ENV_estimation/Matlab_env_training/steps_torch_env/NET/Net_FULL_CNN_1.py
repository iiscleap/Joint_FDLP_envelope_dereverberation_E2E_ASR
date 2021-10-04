import torch
import torch.nn as nn
########################### filter =128 kernel= (11,5) padding = (5,2) ############################### 
class Net (nn.Module):
    def __init__(self):
        super(Net,self).__init__()
        self.conv1 = nn.Conv2d(1,128,kernel_size=(11,5), padding=(5,2))
        #self.B1    = nn.BatchNorm2d(32,track_running_stats=False)
        self.drop1 = nn.Dropout(0.2)
        self.conv2 = nn.Conv2d(128,128,kernel_size=(11,5), padding=(5,2))
        #self.B2    = nn.BatchNorm2d(32,track_running_stats=False)
        self.drop2 = nn.Dropout(0.2)
        self.conv3 = nn.Conv2d(128,64,kernel_size=(11,5), padding=(5,2))
        #self.B3    = nn.BatchNorm2d(32,track_running_stats=False)
        self.drop3 = nn.Dropout(0.2)
        self.conv4 = nn.Conv2d(64,32,kernel_size=(11,5), padding=(5,2))
        #self.B4    = nn.BatchNorm2d(8,track_running_stats=False)
        self.drop4 = nn.Dropout(0.2)
        self.conv5 = nn.Conv2d(32,1,kernel_size=(11,5), padding=(5,2))
        self.relu  = nn.ReLU()
        #self.tanh  = nn.Tanh()

    def forward(self, x):
        
        x = self.drop1(self.relu(self.conv1(x)))
        x = self.drop2(self.relu(self.conv2(x)))
        x = self.drop3(self.relu(self.conv3(x)))
        x = self.drop4(self.relu(self.conv4(x)))
        x = self.conv5(x)
        return x

 
         
