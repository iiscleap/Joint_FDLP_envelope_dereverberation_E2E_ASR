#!/usr/bin/python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov  4 14:41:28 2019

@author: Anurenjan P. R.
"""
import numpy as np
import sys
from struct import unpack, pack
from pdb import set_trace as bp  #################added break point accessor####################

def write_htk( name , MAT ,  sampPeriod = 100000 , paramKind = 8267 ): 
	P = MAT.shape[0]          ## To calculate sample size 
	nSamples = MAT.shape[1]   ## Number of samples
	sampSize = P*4            ## Sample size
	fh = open(name, 'w')
	fh.write(pack(">IIHH", nSamples, sampPeriod, sampSize, paramKind)) #writing header
	np.array(MAT, 'f').byteswap().tofile(fh)                           #writing matrix
	fh.close()
