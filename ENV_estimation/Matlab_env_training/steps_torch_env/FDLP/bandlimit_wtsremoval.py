#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 27 14:56:04 2019

@author: user
"""
import numpy
from pdb import set_trace as bp  #################added break point

#function [new_wts,new_idx] = bandlimit_wtsremoval(wts,idx,flen,sr,minfreq, maxfreq)


def bandlimit_wtsremoval(wts,idx,flen,sr,minfreq,maxfreq):
    cnt=0
    new_idx = []
    new_wts = []
    for I in range (wts.shape[0]):
        tmpx=numpy.zeros((flen,1))
        tmpx[idx[I,0]:idx[I,1]+1]=wts[I]
        
        y=max(tmpx)
        i=numpy.argmax(tmpx)
        #% freq of peak
        f=i*(sr/2)/flen
       
        if f >= minfreq and f<=maxfreq:
            new_idx.append(idx[I,:])
            new_wts.append(wts[I])
            cnt=cnt+1
    new_idx = numpy.asarray(new_idx)
    new_wts = numpy.asarray(new_wts)  
    return new_wts.T,new_idx
    