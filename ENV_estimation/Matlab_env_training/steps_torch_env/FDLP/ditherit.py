#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov  4 17:54:05 2019

@autho"""
import numpy
def ditherit(x,db=-96,type1='db'):
    if str(type1) =='db':
        x = x + (10^(db/20))*numpy.random.randn(x.shape[0], x.shape[1])
    else:
        x = x + numpy.round(2*db*numpy.random.rand(x.shape[0], x.shape[1])-db)
    return x