#!/bin/bash
set -e
stage=1
nj=10
. ./cmd.sh
. ./path.sh
#source ~student1/.bashrc
#cpython="/state/partition1/softwares/Miniconda3/bin/python"

## Configurable directories
fbankdir="data-Input_training_data"
traindir="train_clean_100_reverb_wpe_tr90"
devdir="train_clean_100_reverb_wpe_cv10"

train=${fbankdir}/${traindir}
dev=${fbankdir}/${devdir}
target_tr=${fbankdir}/train_clean_100_tr90
target_cv=${fbankdir}/train_clean_100_cv10
echo $train
echo $dev
ali=exp/tri4b_ali_clean_100
exp=exp/torch_ENV_CLN_Net_C2LSTM_BEGAN_mse_01gan_batch_32
mkdir -p $exp

ab=`nvidia-smi --query-gpu=index,memory.used --format=csv`
echo $ab
zero=`echo $ab | awk '{print $5}'`
one=`echo $ab | awk '{print $8}'`
gpu=0
if [ $zero -le  100 ] ;then
gpu=0
elif [ $one -le 100 ]; then
gpu=1
else
echo "GPUs not free, please run again"
exit
fi
echo "using gpu $gpu"


## Train
if [ $stage -le 1 ] ; then

echo "`pwd`"

CUDA_VISIBLE_DEVICES=${gpu}  python steps_torch_env_BEGAN/train_torch_FDLP_4C2LSTM_mse_01gan.py ${dev}  ${train} ${target_tr} ${target_cv} $exp ${ali}

echo "Done training"
fi
