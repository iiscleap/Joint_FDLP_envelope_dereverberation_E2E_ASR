#!/bin/python
from pdb import set_trace as bp
import argparse, configparser

parser = argparse.ArgumentParser()
parser.add_argument('--path',required=True)
parser.add_argument('--loc',required=True)
args = parser.parse_args()

print('Combining feats.scp')
path=args.path
loc=args.loc
ref_path=path+'/'+loc+'/cleanTrain/cleanTrain_cut_tr90/feats.scp'
flist=open(ref_path,'r'); #reverb_tr_cut.txt
ref_dict = {x.strip().split()[0]:x.strip().split()[1] for x in flist.readlines()}
flist.close()


path_1=path+'/'+loc+'/REVERB_tr_cut/SimData_tr_for_1ch_A_tr90/feats.scp'
flist=open(path_1,'r'); #reverb_tr_cut.txt
dict_1 = {x.strip().split()[0]:x.strip().split()[1] for x in flist.readlines()}
flist.close()


with open(path+'/'+loc+'/feats_tr90.scp','w') as f:
    for key,value in dict_1.items():
        clean_file = ref_dict[key]

        f.write(key+" "+"paste-feats"+" "+str(value)+" "+str(clean_file)+" - 2>/dev/null |"+'\n')


ref_path=path+'/'+loc+'/cleanTrain/cleanTrain_cut_cv10/feats.scp'
flist=open(ref_path,'r'); #reverb_tr_cut.txt
ref_dict = {x.strip().split()[0]:x.strip().split()[1] for x in flist.readlines()}
flist.close()


path_1=path+'/'+loc+'/REVERB_tr_cut/SimData_tr_for_1ch_A_cv10/feats.scp'
flist=open(path_1,'r'); #reverb_tr_cut.txt
dict_1 = {x.strip().split()[0]:x.strip().split()[1] for x in flist.readlines()}
flist.close()


with open(path+'/'+loc+'/feats_cv10.scp','w') as f:
    for key,value in dict_1.items():
        clean_file = ref_dict[key]

        f.write(key+" "+"paste-feats"+" "+str(value)+" "+str(clean_file)+" - 2>/dev/null |"+'\n')
print('Done!')
