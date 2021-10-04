#!/bin/python
"""
This code will take the feats,cmvn and utt2spk and will apply cmvn on the feats
How to use this code ?
Whichever feats you want normalise, you have to give the paths of those feats.scp,cmvn.scp and utt2spk
and then just run the code. 
Also you can specify the path feats_file,ark_file where you want to save those feats.
"""

from subprocess import Popen, PIPE
import kaldiIO
#import kaldi_io
from pdb import set_trace as bp
from kaldiio import WriteHelper
import kaldiio
import argparse, configparser

print('Normalising the feats ! Wait')
parser = argparse.ArgumentParser()
parser.add_argument('--path',required=True)
parser.add_argument('--loc',required=True)
parser.add_argument('--dest',required=True)
parser.add_argument('--folder',required=True)
args = parser.parse_args()

path=args.path
loc=args.loc
dest=args.dest
folder=args.folder.split('/')[0]
category=args.folder.split('/')[1]

feats = path+'/'+loc+'/'+folder+'/'+category+'/feats.scp'
cmvn =  path+'/'+loc+'/'+folder+'/'+category+'/cmvn.scp'
utt2sp =  path+'/'+loc+'/'+folder+'/'+category+'/utt2spk'

apply_cmvn = Popen(['apply-cmvn', '--print-args=false', '--norm-vars=true', '--norm-means=true',
		'--utt2spk=ark:' + utt2sp,'scp:' + cmvn,'scp:' + feats, 'ark:-'], stdout=PIPE)

d = kaldiio.load_scp(feats)

feats_file =  path+'/'+dest+'/'+folder+'/'+category+'/feats.scp'
ark_file= path+'/'+dest+'/'+folder+'/'+category+'/feats.1.ark'

with  WriteHelper('ark,scp:'+ark_file+','+feats_file) as writer:
	for x in d:
		uid, featMat = kaldiIO.readUtterance(apply_cmvn.stdout)
		writer(uid, featMat)

print('Done')
