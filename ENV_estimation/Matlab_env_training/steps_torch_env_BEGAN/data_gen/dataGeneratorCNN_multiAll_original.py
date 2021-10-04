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


from subprocess import Popen, PIPE
import tempfile
import kaldiIO
import pickle
import numpy
import os
from backports import tempfile
from pdb import set_trace as bp  #################added break point accessor####################

## Data generator class for Kaldi
class dataGeneratorCNN_multiAll:
    def __init__ (self, data, target, ali, exp, batchSize=32, spliceSize=1):
        self.data = data

        data1 = data.replace('_A','_B')
        data2 = data.replace('_A','_C')
        data3 = data.replace('_A','_D')
        data4 = data.replace('_A','_E')

        self.data1 = data1
        self.data2 = data2 
        self.data3 = data3
        self.data4 = data4 
	
	self.target = target

 
        self.ali = ali
        self.exp = exp
        self.batchSize = batchSize
        self.spliceSize = spliceSize
        self.frameLen = 800 
        ## Number of utterances loaded into RAM.
        ## Increase this for speed, if you have more memory.
        self.maxSplitDataSize = 500

        self.labelDir = tempfile.TemporaryDirectory()
        aliPdf = self.labelDir.name + '/alipdf.txt'
 
        ## Generate pdf indices
        Popen (['ali-to-pdf', ali + '/final.mdl',
                    'ark:gunzip -c %s/ali.*.gz |' % ali,
                    'ark,t:' + aliPdf]).communicate()

        ## Read labels
        with open (aliPdf) as f:
            labels, self.numFeats = self.readLabels (f)
        #bp()
        ## Normalise number of features
        self.numFeats = self.numFeats - self.spliceSize + 1

        ## Determine the number of steps
        self.numSteps = -(-self.numFeats//self.batchSize)
        #self.numSteps = 30000     
        self.inputFeatDim = 36 ## IMPORTANT: HARDCODED. Change if necessary.
        self.outputFeatDim = self.readOutputFeatDim()
        self.splitDataCounter = 0
        self.randomInd=[]
        self.x = numpy.empty ((0, 5, self.spliceSize , self.inputFeatDim), dtype=numpy.float32)
        self.x1 = numpy.empty ((0, self.inputFeatDim, self.spliceSize,1), dtype=numpy.float32)     # for channel 1
        self.x2 = numpy.empty ((0, self.inputFeatDim, self.spliceSize,1), dtype=numpy.float32)     # for channel 2
        self.x3 = numpy.empty ((0, self.inputFeatDim, self.spliceSize,1), dtype=numpy.float32)     # for channel 3
        self.x4 = numpy.empty ((0, self.inputFeatDim, self.spliceSize,1), dtype=numpy.float32)     # for channel 4
        self.x5 = numpy.empty ((0, self.inputFeatDim, self.spliceSize,1), dtype=numpy.float32)     # for channel 5

        self.t = numpy.empty ((0, self.inputFeatDim, self.spliceSize,1), dtype=numpy.float32)     # for target 


        self.y = numpy.empty ((0, 5,self.spliceSize , self.inputFeatDim), dtype=numpy.float32)
        self.batchPointer = 0
        self.doUpdateSplit = True

        ## Read number of utterances
        with open (data + '/utt2spk') as f:
            self.numUtterances = sum(1 for line in f)
        self.numSplit = - (-self.numUtterances // self.maxSplitDataSize)

        ## Split data dir per utterance (per speaker split may give non-uniform splits)
        if os.path.isdir (data + 'split' + str(self.numSplit)):
            shutil.rmtree (data + 'split' + str(self.numSplit))
        Popen (['utils/split_data.sh', '--per-utt', data, str(self.numSplit)]).communicate()

        if os.path.isdir (data1 + 'split' + str(self.numSplit)):
            shutil.rmtree (data1 + 'split' + str(self.numSplit))
        Popen (['utils/split_data.sh', '--per-utt', data1, str(self.numSplit)]).communicate()

        if os.path.isdir (data2 + 'split' + str(self.numSplit)):
            shutil.rmtree (data2 + 'split' + str(self.numSplit))
        Popen (['utils/split_data.sh', '--per-utt', data2, str(self.numSplit)]).communicate()

        if os.path.isdir (data3 + 'split' + str(self.numSplit)):
            shutil.rmtree (data3 + 'split' + str(self.numSplit))
        Popen (['utils/split_data.sh', '--per-utt', data3, str(self.numSplit)]).communicate()

        if os.path.isdir (data4 + 'split' + str(self.numSplit)):
            shutil.rmtree (data4 + 'split' + str(self.numSplit))
        Popen (['utils/split_data.sh', '--per-utt', data4, str(self.numSplit)]).communicate()


 ## Split target dir per utterance (per speaker split may give non-uniform splits)
       

	if os.path.isdir (target + 'split' + str(self.numSplit)):
            shutil.rmtree (target + 'split' + str(self.numSplit))
        Popen (['utils/split_data.sh', '--per-utt', target, str(self.numSplit)]).communicate()



 
        
    ## Determine the number of output labels
    def readOutputFeatDim (self):
        p1 = Popen (['am-info', '%s/final.mdl' % self.ali], stdout=PIPE)
        modelInfo = p1.stdout.read().splitlines()
        for line in modelInfo:
            if b'number of pdfs' in line:
                return int(line.split()[-1])

    ## Load labels into memory
    def readLabels (self, aliPdfFile):
        labels = {}
        numFeats = 0
        for line in aliPdfFile:
            line = line.split()
            numFeats += len(line)-1
            labels[line[0]] = numpy.array([int(i) for i in line[1:]], dtype=numpy.uint16) ## Increase dtype if dealing with >65536 classes
        return labels, numFeats
    
    ## Save split labels into disk
    def splitSaveLabels (self, labels):
        for sdc in range (1, self.numSplit+1):
            splitLabels = {}
            with open (self.data + '/split' + str(self.numSplit) + '/' + str(sdc) + '/utt2spk') as f:
                for line in f:
                    uid = line.split()[0]
                    if uid in labels:
                        splitLabels[uid] = labels[uid]
            with open (self.labelDir.name + '/' + str(sdc) + '.pickle', 'wb') as f:
                pickle.dump (splitLabels, f)

    ## Return a batch to work on
    def getNextSplitData (self):

        p1 = Popen (['apply-cmvn','--print-args=false','--norm-vars=false','--norm-means=false',
                '--utt2spk=ark:' + self.data + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/utt2spk',
                'scp:' + self.data + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/cmvn.scp',
                'scp:' + self.data + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/feats.scp','ark:-'],
                stdout=PIPE)
        p2 = Popen (['splice-feats','--print-args=false','--left-context=0','--right-context=0',
                'ark:-','ark:-'], stdin=p1.stdout, stdout=PIPE)
        p1.stdout.close()
        p3 = Popen (['add-deltas','--delta-order=0','--print-args=false','ark:-','ark:-'], stdin=p2.stdout, stdout=PIPE)
#        p3 = Popen (yy=None, stdin=p2.stdout, stdout=PIPE) # no deltas in processing

        p2.stdout.close()

        p1b = Popen (['apply-cmvn','--print-args=false','--norm-vars=false','--norm-means=false',
                '--utt2spk=ark:' + self.data1 + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/utt2spk',
                'scp:' + self.data1 + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/cmvn.scp',
                'scp:' + self.data1 + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/feats.scp','ark:-'],
                stdout=PIPE)
        p2b = Popen (['splice-feats','--print-args=false','--left-context=0','--right-context=0',
                'ark:-','ark:-'], stdin=p1b.stdout, stdout=PIPE)
        p1b.stdout.close()
        p3b = Popen (['add-deltas','--delta-order=0','--print-args=false','ark:-','ark:-'], stdin=p2b.stdout, stdout=PIPE)
#        p3 = Popen (yy=None, stdin=p2.stdout, stdout=PIPE) # no deltas in processing

        p2b.stdout.close()

        p1c = Popen (['apply-cmvn','--print-args=false','--norm-vars=false','--norm-means=false',
                '--utt2spk=ark:' + self.data2 + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/utt2spk',
                'scp:' + self.data2 + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/cmvn.scp',
                'scp:' + self.data2 + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/feats.scp','ark:-'],
                stdout=PIPE)
        p2c = Popen (['splice-feats','--print-args=false','--left-context=0','--right-context=0',
                'ark:-','ark:-'], stdin=p1c.stdout, stdout=PIPE)
        p1c.stdout.close()
        p3c = Popen (['add-deltas','--delta-order=0','--print-args=false','ark:-','ark:-'], stdin=p2c.stdout, stdout=PIPE)
#        p3 = Popen (yy=None, stdin=p2.stdout, stdout=PIPE) # no deltas in processing

        p2c.stdout.close()

        p1d = Popen (['apply-cmvn','--print-args=false','--norm-vars=false','--norm-means=false',
                '--utt2spk=ark:' + self.data3 + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/utt2spk',
                'scp:' + self.data3 + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/cmvn.scp',
                'scp:' + self.data3 + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/feats.scp','ark:-'],
                stdout=PIPE)
        p2d = Popen (['splice-feats','--print-args=false','--left-context=0','--right-context=0',
                'ark:-','ark:-'], stdin=p1d.stdout, stdout=PIPE)
        p1d.stdout.close()
        p3d = Popen (['add-deltas','--delta-order=0','--print-args=false','ark:-','ark:-'], stdin=p2d.stdout, stdout=PIPE)
#        p3 = Popen (yy=None, stdin=p2.stdout, stdout=PIPE) # no deltas in processing

        p2d.stdout.close()

        p1e = Popen (['apply-cmvn','--print-args=false','--norm-vars=false','--norm-means=false',
                '--utt2spk=ark:' + self.data4 + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/utt2spk',
                'scp:' + self.data4 + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/cmvn.scp',
                'scp:' + self.data4 + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/feats.scp','ark:-'],
                stdout=PIPE)
        p2e = Popen (['splice-feats','--print-args=false','--left-context=0','--right-context=0',
                'ark:-','ark:-'], stdin=p1e.stdout, stdout=PIPE)
        p1e.stdout.close()
        p3e = Popen (['add-deltas','--delta-order=0','--print-args=false','ark:-','ark:-'], stdin=p2e.stdout, stdout=PIPE)
#        p3 = Popen (yy=None, stdin=p2.stdout, stdout=PIPE) # no deltas in processing

        p2e.stdout.close()

# To read the target...

        p1f = Popen (['apply-cmvn','--print-args=false','--norm-vars=false','--norm-means=false',
                '--utt2spk=ark:' + self.target + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/utt2spk',
                'scp:' + self.target + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/cmvn.scp',
                'scp:' + self.target + '/split' + str(self.numSplit) + '/' + str(self.splitDataCounter) + '/feats.scp','ark:-'],
                stdout=PIPE)
        p2f = Popen (['splice-feats','--print-args=false','--left-context=0','--right-context=0',
                'ark:-','ark:-'], stdin=p1f.stdout, stdout=PIPE)
        p1f.stdout.close()
        p3f = Popen (['add-deltas','--delta-order=0','--print-args=false','ark:-','ark:-'], stdin=p2f.stdout, stdout=PIPE)
#        p3 = Popen (yy=None, stdin=p2.stdout, stdout=PIPE) # no deltas in processing

        featList = []
	outputList =[]

        while True:
	 uid, featMat = kaldiIO.readUtterance (p3.stdout) # no deltas used
	 #bp()
	 uid1, featMat1 = kaldiIO.readUtterance (p3b.stdout) # no deltas used
	 uid2, featMat2 = kaldiIO.readUtterance (p3c.stdout) # no deltas used
	 uid3, featMat3 = kaldiIO.readUtterance (p3d.stdout) # no deltas used
	 uid4, featMat4 = kaldiIO.readUtterance (p3e.stdout) # no deltas used
         uid5, featMat_tgt = kaldiIO.readUtterance (p3f.stdout) # no deltas used
	 
         if uid == None:
           #bp()
            return (numpy.vstack(featList), numpy.vstack(outputList))
         #bp()
	 #print(featMat.reshape(featMat.shape[0],1,self.spliceSize,self.inputFeatDim).shape)
	 #bp()
	 featListFirst = numpy.concatenate((featMat.reshape(featMat.shape[0],1,self.spliceSize,self.inputFeatDim), featMat1.reshape(featMat1.shape[0],1,self.spliceSize,self.inputFeatDim)),axis=1) 
	 #bp() 
	 featListSecond = numpy.concatenate((featListFirst,featMat2.reshape(featMat2.shape[0],1,self.spliceSize,self.inputFeatDim)),axis=1)
	 featListThird = numpy.concatenate((featListSecond,featMat3.reshape(featMat3.shape[0],1,self.spliceSize,self.inputFeatDim)),axis=1)
	 featListFinal = numpy.concatenate((featListThird,featMat4.reshape(featMat4.shape[0],1,self.spliceSize,self.inputFeatDim)),axis=1)
	 featMat_tgt = featMat_tgt.reshape(featMat_tgt.shape[0],1,self.spliceSize,self.inputFeatDim)
	 #bp()
	 featMat_tgt = numpy.concatenate((featMat_tgt,featMat_tgt,featMat_tgt,featMat_tgt,featMat_tgt),axis=1)
	 featList.append (featListFinal)
	 outputList.append (featMat_tgt)
         

    ## Make the object iterable
    def __iter__ (self):
        return self
    ## Retrive a mini batch
    def next (self):
        while (self.batchPointer + 1 >= (len (self.x)//self.frameLen)):
            if not self.doUpdateSplit:
                self.doUpdateSplit = True
                break

            self.splitDataCounter += 1
            x,y = self.getNextSplitData()
	    #bp()
            #print ("Size of xarray is ",x.shape)
            #print ("Size of yarray is ",y.shape)

            self.x = numpy.concatenate ((self.x[self.batchPointer:], x))
            self.y = numpy.concatenate ((self.y[self.batchPointer:], y))
            self.batchPointer = 0

            ## Shuffle data
            self.randomInd = numpy.array(range((len(self.x)//self.frameLen)))
            numpy.random.shuffle(self.randomInd)
#            self.x = self.x[randomInd]
#            self.y = self.y[randomInd]

            if self.splitDataCounter == self.numSplit:
                self.splitDataCounter = 0
                self.doUpdateSplit = False
	#bp()
        xMini_t = self.x[self.randomInd[self.batchPointer]*self.frameLen:(self.randomInd[self.batchPointer]+1)*self.frameLen]
        yMini_t = self.y[self.randomInd[self.batchPointer]*self.frameLen:(self.randomInd[self.batchPointer]+1)*self.frameLen]
	randomInd_c = numpy.array(range(5))
        numpy.random.shuffle(randomInd_c)
	randomInd_b = numpy.array(range(36))
	numpy.random.shuffle(randomInd_b)
	xMini_t=xMini_t[:,randomInd_c,:,:]
	yMini_t=yMini_t[:,randomInd_c,:,:]
	xMini_t=xMini_t[:,:,:,randomInd_b]
	yMini_t=yMini_t[:,:,:,randomInd_b]
	xMini_t=xMini_t.swapaxes(0,3)			
	yMini_t=yMini_t.swapaxes(0,3)
	#bp()
	xMini_t = numpy.concatenate((xMini_t[:,0,:,:],xMini_t[:,1,:,:],xMini_t[:,2,:,:],xMini_t[:,3,:,:],xMini_t[:,4,:,:]),axis=0)	
	yMini_t = numpy.concatenate((yMini_t[:,0,:,:],yMini_t[:,1,:,:],yMini_t[:,2,:,:],yMini_t[:,3,:,:],yMini_t[:,4,:,:]),axis=0)
	xMini=xMini_t[:,0,:]
	yMini=yMini_t[:,0,:]
	self.batchPointer += 1
	#bp()
	xMini=numpy.log(xMini)
	yMini=numpy.log(yMini)
	yMini=yMini-xMini
	xMini=xMini.reshape(xMini.shape[0],1,xMini.shape[1])
	#yMini=yMini.reshape(yMini.shape[0],1,yMini.shape[1])
	return (xMini, yMini)
