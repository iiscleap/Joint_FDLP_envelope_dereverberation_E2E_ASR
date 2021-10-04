#!/bin/bash

. ./cmd.sh
. ./path.sh

decode_config=conf/decode.yaml
ngpu=1
#data_file=dump_test_1/SimData_tr_for_1ch_A_cv10/deltafalse/split1utt/data.1.json

#data_file=dump_test_1_paste/dt_real_8ch_beamformit/deltafalse/data.json
data_file=dump_test_1_paste/dt_real_8ch_beamformit/deltafalse/data.json
#data_file=dump_test_1_paste/SimData_tr_for_1ch_A_tr90/deltafalse/data.json
#result_l=exp/tr_simu_8ch_si284_pytorch_EXP0_ENV_CLEAN_BASELINE_MODEL_ASR_TRANS/decode_SimData_tr_for_1ch_A_cv10_decode_wordrnnlm_lm_word65000_with_jobs/data.1.json

result_l=exp/tr_simu_8ch_si284_pytorch_EXP0_ENV_CLEAN_BASELINE_MODEL_ASR_TRANS/decode_SimData_tr_for_1ch_A_cv10_decode_wordrnnlm_lm_word65000_with_jobs/data.1.json
#model=/home/rohitk/Workspace/E2E/espnet/egs/reverb/asr5/exp/tr_simu_8ch_si284_pytorch_EXP0_ENV_CLEAN_BASELINE_MODEL_ASR_TRANS/results/model.loss.best

model=/home/rohitk/Workspace/E2E/espnet/egs/reverb/JT_ASR/exp/tr_simu_8ch_si284_pytorch_EXP0_ENV_CLEAN_BASELINE_MODEL_ASR_TRANS_WITH_WEIGHTS/results/model.loss.best


#python asr_recog.py --config ${decode_config} --ngpu ${ngpu} --backend ${backend} --debugmode ${debugmode} --recog-json $data_file --result-label $result_l --model $model $re_opt
ab=`nvidia-smi --query-gpu=index,memory.used --format=csv`
echo $ab
zero=`echo $ab | awk '{print $5}'`
one=`echo $ab | awk '{print $8}'`
gpu=0
if [ $zero -le  $one ] ;then
gpu=0
else
gpu=1
fi
echo "using gpu ${gpu}"


CUDA_VISIBLE_DEVICES=${gpu} python asr_2.py --config conf/decode.yaml --ngpu 0 --backend pytorch --debugmode 1 --recog-json $data_file --result-label $result_l --model $model --word-rnnlm /home/rohitk/Workspace/E2E/espnet/egs/reverb/asr1_test/exp/train_rnnlm_pytorch_lm_word65000/rnnlm.model.best
