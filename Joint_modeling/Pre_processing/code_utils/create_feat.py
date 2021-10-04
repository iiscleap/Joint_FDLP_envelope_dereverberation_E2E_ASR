#!/bin/python

import kaldiio
from pdb import set_trace as bp
from kaldiio import WriteHelper
import argparse, configparser

print('Converting to kaldi feats')
parser = argparse.ArgumentParser()
parser.add_argument('--path',required=True)
parser.add_argument('--loc',required=True)
args = parser.parse_args()

path = args.path
loc=args.loc

path_1=path+'/'+loc+'/feats_tr90.scp'

d = kaldiio.load_scp(path_1)
feats_file=path+'/'+loc+'/feats_trn90.scp'
ark_file=path+'/'+loc+'/feats_trn90.1.ark'

with  WriteHelper('ark,scp:'+ark_file+','+feats_file) as writer:
    for x in d:
        writer(x, d[x])


path_1=path+'/'+loc+'/feats_cv10.scp'

d = kaldiio.load_scp(path_1)
feats_file=path+'/'+loc+'/feats_cvn10.scp'
ark_file=path+'/'+loc+'/feats_cvn10.1.ark'

with  WriteHelper('ark,scp:'+ark_file+','+feats_file) as writer:
    for x in d:
        writer(x, d[x])


print('DONE')
