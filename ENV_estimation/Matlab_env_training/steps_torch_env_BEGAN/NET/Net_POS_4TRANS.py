import torch
import torch.nn as nn
from torch.nn import TransformerEncoder, TransformerEncoderLayer
from pdb import set_trace as bp  
#################added break point accessor####################

################### ''' large kernel = (10,3) with 32 filters with LSTM''' ######################
class Net (nn.Module):
    def __init__(self):
        super(Net,self).__init__()
	#from torch.nn import TransformerEncoder, TransformerEncoderLayer
        self.conv1 = nn.Conv2d(1,32,kernel_size=(41,3),padding=(20,1))
        #self.drop1 = nn.Dropout(0.2)
        self.conv2 = nn.Conv2d(32,32,kernel_size=(41,3),padding=(20,1))
        #self.drop2 = nn.Dropout(0.2)
        self.conv3 = nn.Conv2d(32,64,kernel_size=(21,5),padding=(10,2))
        #self.drop3 = nn.Dropout(0.2)
        self.conv4 = nn.Conv2d(64,64,kernel_size=(21,5),padding=(10,2))
        #self.drop4 = nn.Dropout(0.2)
        self.lstm1 = nn.LSTM(36*64, 1024 , batch_first=True) 
        self.lstm2 = nn.LSTM(1024, 36 , batch_first=True)
        self.relu  = nn.ReLU()

	#Added the Transformer on 14/02/2021 {Happy Valentines Day :p}

	#Creating the instance of TransformerEncoderLayer() class
        self.pos = nn.Linear(36,256)
        #36*32
        encoder_layer = TransformerEncoderLayer(256,8)
        self.transformer_encoder = TransformerEncoder(encoder_layer,4)
        self.decoder = nn.Linear(256,36)

    def forward(self, x):
        #bp()
        #x = (self.relu(self.conv1(x)))
        #x = (self.relu(self.conv2(x)))
        #bp()
        #x = (self.relu(self.conv3(x)))
        #x = (self.relu(self.conv4(x)))
        x = x.transpose(1,2)
        #bp()        
        x = torch.reshape(x,(-1,800,36))
        x = self.relu(self.pos(x))
        x = self.transformer_encoder(x)
        x = self.decoder(x)
        #x,_ = self.lstm1(x)
        #x,_ = self.lstm2(x)   
        return x

 
         
