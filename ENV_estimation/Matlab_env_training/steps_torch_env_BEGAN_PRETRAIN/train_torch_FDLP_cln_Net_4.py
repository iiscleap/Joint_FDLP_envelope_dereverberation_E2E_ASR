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
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.autograd import Variable
from data_gen.dataGeneratorCNN_multiAll import dataGeneratorCNN_multiAll
import numpy
import sys
#from Net_larg_kernel_64_filters import Net
from NET.Net_CDNN_4 import Net
torch.cuda.current_device()
import time
from pdb import set_trace as bp  #################added break point accessor####################


if __name__ != '__main__':
    raise ImportError ('This script can only be run, and can\'t be imported')

if len(sys.argv) != 7:
    raise TypeError ('USAGE: train.py data_cv  data_tr target_tr dnn_dir')

data_cv = sys.argv[1]
tgt_tr  = sys.argv[3]
tgt_cv  = sys.argv[4]
data_tr = sys.argv[2]
ali_tr  = sys.argv[6]
#gmm     = sys.argv[5]
exp     = sys.argv[5]

print(data_cv)
print(data_tr)
## Learning parameters
learning = {'rate' : 0.0001,
            'minEpoch' : 5,
            'lrScale' : 0.5,
            'batchSize' : 32,
            'lrScaleCount' : 18,
            'spliceSize' : 1, 
            'minValError' : 0.002}

#os.makedirs (exp, exist_ok=True)
def mkdir_p(exp):
    try:
        os.makedirs(exp)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(exp):
            pass
        else:
            raise
#bp()
trGen = dataGeneratorCNN_multiAll (data_tr, tgt_tr, ali_tr, exp ,learning['batchSize'],learning['spliceSize'])
cvGen = dataGeneratorCNN_multiAll (data_cv, tgt_cv, ali_tr, exp ,learning['batchSize'],learning['spliceSize'])

#bp()
print('number of tr steps =%d ' % (trGen.numSteps_tr))
#cvGen.numSteps=(786//cvGen.batchSize)
print('number of cv steps =%d ' % (cvGen.numSteps_cv))
#a, b = trGen.getNextSplitData()
#print(a.shape)
#print(b.shape)



numpy.random.seed(512)
print (trGen.x.shape)
print (trGen.outputFeatDim)

#bp()

trainloader=trGen
testloader=cvGen
print (trainloader.batchSize)
print (testloader.batchSize)

class Train():
     def __init__(self):
      self.losscv_previous_1=10.0
      self.losscv_previous_2=0.0
      self.losscv_current=0.0 

     def fit (self, net, trGen, cvGen,criterion,optimizer,epoch,totalepoch):
        net.train()
        print('epoch = %d/%d'%(epoch+1,totalepoch))
        running_loss_tr =0.0
        correct_tr = 0.0
        total_tr = 0.0
        for i, data in enumerate(trGen,0):
         inputs, labels =data
         #labels=labels.astype(numpy.int64)
         labels= torch.from_numpy(labels)
         labels=labels.cuda().float()
         inputs = Variable(torch.from_numpy(inputs))
         optimizer.zero_grad()
         outputs =net(inputs.cuda().float())
         loss =criterion(outputs, labels)
         loss.backward()
         optimizer.step()
         running_loss_tr += loss.item()
         #_,predicted =outputs.data[0]
         #total_tr += labels.size(0)
         #correct_tr += (predicted == labels).sum().item()
         if i % 750 ==(750 - 1):

#          print ('[%d,%5d] loss_tr: %.3f' % (epoch+1,i+1,running_loss_tr/trGen.numSteps))
          print ('TRAIN ==> [%d,%5d] LOSS: %.3f '%(epoch+1,i+1,running_loss_tr/750))
          running_loss_tr =0.0
#          print ('ACCURACY_TR  : %.3f %%' % (100 * correct_tr / total_tr))
          break
#        print ('Finished Training')
#corss validation step   
        correct_cv = 0.0
        total_cv = 0.0
        net.eval()
        running_loss_cv=0.0
        for j, data in enumerate(cvGen,0):
         images,label=data
         #label=label.astype(numpy.int64)
         label= torch.from_numpy(label)
         label=label.float()
         label=label.cuda()
         images = Variable(torch.from_numpy(images))
         output=net(images.cuda().float())
         loss_cv =criterion(output, label.detach())
         running_loss_cv += loss_cv.item()
         #total_cv += label.size(0)
         #_,predicted =torch.max(output.data,1)
         #correct_cv += (predicted == label).sum().item()
         if j % (75) == ((75) - 1):
#           print ('[%d,%5d] loss_cv: %.3f' % (epoch+1,j+1,running_loss_cv/cvGen.numSteps))
           self.losscv_current=running_loss_cv/(75)
           print ('VALID ==> [%d,%5d] LOSS_CV: %.3f '%(epoch+1,j+1,running_loss_cv/(75)))
           running_loss_cv =0.0
#           print ('ACCURACY_CV  : %.3f %%' % (100 * correct_cv / total_cv))
#           print ('Finished Crossvalidation')
    #       if self.losscv_current <= self.losscv_previous_1:
           self.losscv_previous_2=self.losscv_previous_1
           self.losscv_previous_1=self.losscv_current
           print('loss previous[-1] =%f '%(self.losscv_previous_1))
           print('loss previous[-2] =%f '%(self.losscv_previous_2))  
           torch.save(net.state_dict(),exp + '/dnn_nnet_64.model')
           print('Saved model')
           break
           #else:
           # break
        sys.stdout.flush()
        sys.stderr.flush()

net=Net()
net=net.cuda()
print (net)
train1=Train()
criterion =nn.MSELoss()
#optimizer =optim.SGD(net.parameters(),lr=learning['rate'],weight_decay=0,momentum=0.5,nesterov=True)
optimizer =optim.Adam(net.parameters(),lr=learning['rate'],amsgrad=True)


#train minimum of 4 epoch. Save the model only if it improves
for epoch in range(learning['minEpoch']-1):
 if(epoch >= 1):
         net.load_state_dict(torch.load(exp + '/dnn_nnet_64.model'))
 t0 = time.time()
 abc=train1.fit(net, trGen, cvGen,criterion,optimizer,epoch,4)
 print('{} seconds'.format(time.time() - t0))

#load the best model, and retrain with the same learning rate only if the model improves
valErrorDiff = learning['minValError']
while valErrorDiff >= learning['minValError']:
 print(valErrorDiff)
 net=Net()
 net=net.cuda() 
 net.load_state_dict(torch.load(exp + '/dnn_nnet_64.model'))
 t0 = time.time()
 abd=train1.fit(net,trGen, cvGen,criterion,optimizer,0,1)
 valErrorDiff = train1.losscv_previous_2 - train1.losscv_previous_1
 print('{} seconds'.format(time.time() - t0))


#load the previous best model, lower the learning rate and run the model untill the value of loss is same for two models
while learning['rate'] > 0.0000001 :
    learning['rate'] *= learning['lrScale']
    print ('Learning rate: %f' % learning['rate'])
    learning['lrScaleCount'] -= 1
    net.load_state_dict(torch.load(exp + '/dnn_nnet_64.model'))
   #optimizer =optim.SGD(net.parameters(),lr=learning['rate'],weight_decay=0,momentum=0.5,nesterov=True)
    optimizer =optim.Adam(net.parameters(),lr=learning['rate'],amsgrad=True)
    t0 = time.time()
    abe=train1.fit(net,trGen, cvGen,criterion,optimizer,0,1)
    err = train1.losscv_previous_2 - train1.losscv_previous_1
    sys.stdout.flush()
    sys.stderr.flush() 
    print('{} seconds'.format(time.time() - t0))


