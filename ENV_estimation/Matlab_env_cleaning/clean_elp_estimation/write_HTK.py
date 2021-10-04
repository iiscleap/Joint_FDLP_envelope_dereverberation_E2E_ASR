#!/usr/bin/python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov  4 14:41:28 2019

@author: Anurenjan P. R.
"""
import numpy as np
import struct
import sys
from pdb import set_trace as bp  #################added break point accessor####################

def write_htk( name , MAT ,  sampPeriod = 100000 , paramKind = 8267 ): 
	P = MAT.shape[0]          ## To calculate sample size 
	nSamples = MAT.shape[1]   ## Number of samples
	sampSize = P*4            ## Sample size
	fh = open(name, 'w')
	#bp()
	fh.buffer.write(struct.pack(">IIHH", nSamples, sampPeriod, sampSize, paramKind)) #writing header
	    
	#fh.buffer.write (MAT.byteswap())
	for i in range(MAT.shape[1]):
          np.array(MAT[:,i], 'f').byteswap().tofile(fh)                           #writing matrix
	fh.close()
