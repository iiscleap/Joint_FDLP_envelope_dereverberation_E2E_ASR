#!/bin/bash

. ./cmd.sh
. ./path.sh

decode_config=$1
ngpu=$2
backend=$3
debugmode=$4
data_file=$5
result_l=$6
model=$7
re_opt=$8

#python asr_recog.py --config ${decode_config} --ngpu ${ngpu} --backend ${backend} --debugmode ${debugmode} --recog-json $data_file --result-label $result_l --model $model $re_opt

asr_recog.py --config conf/decode.yaml --ngpu 0 --backend pytorch --debugmode 1 --recog-json $data_file --result-label $result_l --model $model --word-rnnlm exp/train_rnnlm_pytorch_lm_word65000/rnnlm.model.best
