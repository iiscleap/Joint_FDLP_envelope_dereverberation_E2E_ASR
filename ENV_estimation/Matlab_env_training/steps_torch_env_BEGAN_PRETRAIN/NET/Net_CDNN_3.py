import torch
import torch.nn as nn
################### ''' large kernel = (20,5) with 32 filters without dropouts (Net1 without dropouts) ''' ######################
class Net (nn.Module):
    def __init__(self):
        super(Net,self).__init__()
        self.conv1 = nn.Conv2d(1,32,kernel_size=(20,5))
        #self.B1    = nn.BatchNorm2d(32,track_running_stats=False)
        self.conv2 = nn.Conv2d(32,32,kernel_size=(20,5))
        self.pool1 = nn.MaxPool2d(kernel_size=(4,2))
        #self.drop1 = nn.Dropout(0.2)
        self.conv3 = nn.Conv2d(32,32,kernel_size=(20,5))
        self.conv4 = nn.Conv2d(32,8,kernel_size=(20,5))
        #self.drop2 = nn.Dropout(0.2)
        self.pool2 = nn.MaxPool2d(kernel_size=(4,2))
        self.fc1   = nn.Linear(38*3*8,1024)
        #self.drop3 = nn.Dropout(0.2)
        self.fc2   = nn.Linear(1024,1024)
        #self.drop4 = nn.Dropout(0.2)
        self.fc3   = nn.Linear(1024,800*36)
        self.relu  = nn.ReLU()
        #self.tanh  = nn.Tanh()

    def forward(self, x):
        
        x = self.relu(self.conv1(x))
        #x = self.B1(x)
        x = self.relu(self.conv2(x))
        #x = self.B2(x)
        x = self.pool1(x)
        x = self.relu(self.conv3(x))
        #x = self.B3(x)
        x = self.relu(self.conv4(x))
        #x = self.B4(x)
        x = self.pool2(x)
	#print (x.shape)
        x = x.view(-1,38*3*8)
        x = self.relu(self.fc1(x))
        #x = self.B5(x)
        #x = self.drop3(x)
        x = self.relu(self.fc2(x))
        #x = self.B6(x)
        #x = self.drop4(x)
	x = self.fc3(x)
        return x

 
         