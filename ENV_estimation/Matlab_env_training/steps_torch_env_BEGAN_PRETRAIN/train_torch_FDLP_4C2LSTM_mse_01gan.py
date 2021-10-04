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
# You can change the model accordingly
#from NET.Net_CNN_2LSTM_padding_64filters_last2 import Net
from NET.Net_CNN_2LSTM_padding_64filters_last2_baseline_model import Net
torch.cuda.current_device()
import time
from pdb import set_trace as bp 
################################################################################################
"""
This code will be modified to incoporate the began loss
"""
################################################################################################
sys.path.append('/data2/multiChannel/ROHITK/Workspace/FDLP_Feats_Extraction/egs/REVERB/Length_trial_train/steps_torch_env_BEGAN_3/utils')
from process_yaml_model import YamlModelProcesser
import yaml
from began_loss import BEGANRecorder, BEGANLoss
from optim_step import *
ymp = YamlModelProcesser()
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
learning = {'rate' : 0.00001,
            'minEpoch' : 25,
            'lrScale' : 0.5,
            'batchSize' : 16,
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
trainloader=trGen
testloader=cvGen
print (trainloader.batchSize)
print (testloader.batchSize)

# This particular section will call the discriminator and will set its optimizer
dis_high = ymp.construct_model(f"/data2/multiChannel/ROHITK/Workspace/FDLP_Feats_Extraction/egs/REVERB/Length_trial_train/steps_torch_env_BEGAN_3/model_config/dis0/1.yaml")
dis_high = dis_high.cuda()
opt_dis = optim.Adam(dis_high.parameters(),lr=1e-4)

class Train():
     def __init__(self):
      self.losscv_previous_1=10.0
      self.losscv_previous_2=0.0
      self.losscv_current=0.0 

      self.gan_losscv_previous_1=10.0
      self.gan_losscv_previous_2=0.0
      self.gan_losscv_current=0.0
      # This part is to initilise the value of k in the BEGAN
      gamma = 1.0
      lambda_k = 0.01
      init_k = 0.0
      self.recorder = BEGANRecorder(lambda_k, init_k, gamma)
      self.k = self.recorder.k.item()

     def fit (self, net,dis_high, trGen, cvGen,criterion,optimizer,opt_dis,epoch,totalepoch):
        net.train()
        dis_high.train()
        print('epoch = %d/%d'%(epoch+1,totalepoch))
        running_loss_tr =0.0
        running_gan_loss_tr =0.0
        correct_tr = 0.0
        total_tr = 0.0
        
        for i, data in enumerate(trGen,0):
        #for i, data in enumerate(trGen):
         inputs, labels =data
         #labels=labels.astype(numpy.int64)
         labels= torch.from_numpy(labels)
         labels=labels.cuda().float()
         inputs = Variable(torch.from_numpy(inputs))
         #optimizer.zero_grad()
         outputs =net(inputs.cuda().float())
         loss_gan, loss_dis, real_dloss, fake_dloss = BEGANLoss(dis_high, labels, outputs, self.k)
         loss_mse =criterion(outputs, labels)
         loss = loss_mse + 0.1*loss_gan
         #loss = loss_gan
         OptimStep([(net, optimizer, loss, True),
         (dis_high, opt_dis, loss_dis, False)], 3)
         self.k, convergence = self.recorder(real_dloss, fake_dloss, update_k=True)
         #loss.backward()
         #optimizer.step()
         running_loss_tr += loss.item()
         running_gan_loss_tr += loss_dis.item()
         torch.cuda.empty_cache()
         #_,predicted =outputs.data[0]
         #total_tr += labels.size(0)
         #correct_tr += (predicted == labels).sum().item()
         if i % 4000 ==(4000 - 1):
#          print ('[%d,%5d] loss_tr: %.3f' % (epoch+1,i+1,running_loss_tr/trGen.numSteps))
          print ('TRAIN ==> [%d,%5d] LOSS: %.3f '%(epoch+1,i+1,running_loss_tr/4000))
          print ('TRAIN ==> [%d,%5d] LOSS: %.3f '%(epoch+1,i+1,running_gan_loss_tr/4000))
          running_loss_tr =0.0
          running_gan_loss_tr = 0.0
#          print ('ACCURACY_TR  : %.3f %%' % (100 * correct_tr / total_tr))
          break
        print ('Finished Training')

#cross validation step   
        correct_cv = 0.0
        total_cv = 0.0
        net.eval()
        dis_high.eval()
        
        running_loss_cv=0.0
        running_gan_loss_cv=0.0

        for j, data in enumerate(cvGen,0):
         images,label=data
         #label=label.astype(numpy.int64)
         label= torch.from_numpy(label)
         label=label.float()
         label=label.cuda()
         images = Variable(torch.from_numpy(images))
         output=net(images.cuda().float())
         loss_cv =criterion(output, label.detach())
         loss_gan, loss_dis, real_dloss, fake_dloss = BEGANLoss(dis_high, label, output, self.k)
         loss_cvv = loss_cv + 0.1*loss_gan
         #loss_cvv = loss_gan
         running_loss_cv += loss_cvv.item()
         running_gan_loss_cv += loss_dis.item()

         #total_cv += label.size(0)
         #_,predicted =torch.max(output.data,1)
         #correct_cv += (predicted == label).sum().item()
         if j % (400) == ((400) - 1):
           self.losscv_current=running_loss_cv/(400)
           self.gan_losscv_current=running_gan_loss_cv/(400)
           
           print ('VALID ==> [%d,%5d] LOSS_CV: %.3f '%(epoch+1,j+1,running_loss_cv/(400)))
           print ('GAN_VALID ==> [%d,%5d] GAN_LOSS_CV: %.3f '%(epoch+1,j+1,running_gan_loss_cv/(400)))
           running_loss_cv =0.0
           running_gan_loss_cv =0.0

           self.losscv_previous_2=self.losscv_previous_1
           self.losscv_previous_1=self.losscv_current
           self.gan_losscv_previous_2=self.gan_losscv_previous_1
           self.gan_losscv_previous_1=self.losscv_current
           print('loss previous[-1] =%f '%(self.losscv_previous_1))
           print('loss previous[-2] =%f '%(self.losscv_previous_2))

           if self.gan_losscv_previous_1 < self.gan_losscv_previous_2:
               torch.save(dis_high.state_dict(),exp + '/best_model_dis.model')
           if self.losscv_previous_1 < self.losscv_previous_2:
               torch.save(net.state_dict(),exp + '/best_model_enh.model')
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

# This section is being added to see if the checkpoint are working well in e2e

path_of_model = '/data2/multiChannel/ANURENJAN/VOICES/ENV_estimation/Matlab_env_training/exp/torch_ENV_CLN_Net_CNN_2Layer_LSTM_arfit_after-revamp/dnn_nnet_64.model'
net.load_state_dict(torch.load(path_of_model))


#train minimum of 4 epoch. Save the model only if it improves

for epoch in range(learning['minEpoch']-1):
 if(epoch >= 1):
         net.load_state_dict(torch.load(exp + '/best_model_enh.model'))
         dis_high.load_state_dict(torch.load(exp + '/best_model_dis.model'))
 t0 = time.time()
 abc=train1.fit(net,dis_high, trGen, cvGen,criterion,optimizer,opt_dis,epoch,4)
 print('{} seconds'.format(time.time() - t0))

#load the best model, and retrain with the same learning rate only if the model improves
valErrorDiff = learning['minValError']
while valErrorDiff >= learning['minValError']:
 print(valErrorDiff)
 net=Net()
 net=net.cuda() 
 dis_high = ymp.construct_model(f"/data2/multiChannel/ROHITK/Workspace/FDLP_Feats_Extraction/egs/REVERB/Length_trial_train/steps_torch_env_BEGAN_3/model_config/dis0/1.yaml")
 dis_high = dis_high.cuda()
 net.load_state_dict(torch.load(exp + '/best_model_enh.model'))
 dis_high.load_state_dict(torch.load(exp + '/best_model_dis.model'))
 t0 = time.time()
 abd=train1.fit(net,dis_high,trGen, cvGen,criterion,optimizer,opt_dis,0,1)
 valErrorDiff = train1.losscv_previous_2 - train1.losscv_previous_1
 print('{} seconds'.format(time.time() - t0))


#load the previous best model, lower the learning rate and run the model untill the value of loss is same for two models
while learning['rate'] > 0.0000001 :
    learning['rate'] *= learning['lrScale']
    print ('Learning rate: %f' % learning['rate'])
    learning['lrScaleCount'] -= 1
    net.load_state_dict(torch.load(exp + '/best_model_enh.model'))
    dis_high.load_state_dict(torch.load(exp + '/best_model_dis.model'))
   #optimizer =optim.SGD(net.parameters(),lr=learning['rate'],weight_decay=0,momentum=0.5,nesterov=True)
    optimizer =optim.Adam(net.parameters(),lr=learning['rate'],amsgrad=True)
    t0 = time.time()
    abe=train1.fit(net,dis_high,trGen, cvGen,criterion,optimizer,opt_dis,0,1)
    err = train1.losscv_previous_2 - train1.losscv_previous_1
    sys.stdout.flush()
    sys.stderr.flush() 
    print('{} seconds'.format(time.time() - t0))

