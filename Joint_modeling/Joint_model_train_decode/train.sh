#!/bin/bash

. ./cmd.sh
. ./path_jt.sh

python asr_2.py --config conf/train.yaml --ngpu 1 --backend pytorch --outdir exp/SimData_tr_for_1ch_A_tr90_pytorch_Joint_Training/results --tensorboard-dir tensorboard/SimData_tr_for_1ch_A_tr90_pytorch_Joint_Training --debugmode 1 --dict data/lang_1char/SimData_tr_for_1ch_A_tr90_units.txt --debugdir exp/SimData_tr_for_1ch_A_tr90_pytorch_Joint_Training --minibatches 0 --verbose 0 --resume --train-json dump_UNSUP-GEV_BF_TRAIN/tr_simu_8ch_si284/deltafalse/data.json --valid-json dump_UNSUP-GEV_BF_TRAIN/dt_mult_1ch/deltafalse/data.json 

