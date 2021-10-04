#!/bin/bash

#E2E ASR FOR SAMSUNG 150 HRS

. ./path.sh || exit 1;
. ./cmd.sh || exit 1;

# general configuration
backend=pytorch
stage=8        # start from 0 if you need to start from data preparation
stop_stage=8
ngpu=1         # number of gpus ("0" uses cpu, otherwise use gpu)
debugmode=1
dumpdir=dump_FDLP   # directory to dump full features
N=0            # number of minibatches to be used (mainly for debugging). "0" uses all minibatches.
verbose=0      # verbose option
resume=        # Resume the training from snapshot
foreground_snrs="20:10:15:5:0"
background_snrs="20:10:15:5:0"

# feature configuration
do_delta=false

train_config=conf/train.yaml
decode_config=conf/decode.yaml

# decoding parameter
recog_model=model.loss.best # set a model to be used for decoding: 'model.acc.best' or 'model.loss.best'

# data #data will be mentioned in the wac.scp
data_corpus=

# exp tag
tag="C2LSTM_BEGAN_mse_01gan" # tag for managing experiments.

. utils/parse_options.sh || exit 1;

# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

lm_url=www.openslr.org/resources/11
train_data=train_clean_100_reverb
eval_data=Evaluation_Data_wpe

# This STAGE IS FOR LM IN KALDI, BUT FOR E2E WE DONT NEED THIS SECTION ####################################

if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ]; then
	echo "stage 1 create LM with this data"
	sam_local/download_lm.sh $lm_url data/local/lm
	mkdir -p data/${train_data}/corpus
	cat data/${train_data}/text | cut -f2- -d' ' > data/${train_data}/corpus/allText.txt
	sam_local/lm/train_lm.sh  data/${train_data}/ data/local/lm_new/norm/tmp data/local/lm_new/norm/norm_texts data/local/lm_new
	
	sam_local/prepare_dict.sh --stage 3 --nj 40 --cmd "$train_cmd" \
	   data/local/lm_new data/local/lm_new data/local/dict_nosp

	utils/prepare_lang.sh data/local/dict_nosp \
         "<UNK>" data/local/lang_tmp_nosp data/lang_nosp

	sam_local/format_lms.sh --src-dir data/lang_nosp data/local/lm

	utils/build_const_arpa_lm.sh data/local/lm/lm_tglarge.arpa.gz \
          data/lang_nosp data/lang_nosp_test_tglarge
  	utils/build_const_arpa_lm.sh data/local/lm/lm_fglarge.arpa.gz \
    	  data/lang_nosp data/lang_nosp_test_fglarge
fi

###############################################################################################################

# NOW WE SPECIFY THE TRAINING DATA, AND SPLIT IT IN TRAIN AND DEV

#utils/subset_data_dir_tr_cv.sh data/$train_data data/${train_data}_tr90 data/${train_data}_cv10
#train_set=${train_data}_tr90
#train_dev=${train_data}_cv10
#eval_set=Eval_latest # EVAL DATASET THAT WE MENTION

#train_set_voices=train_clean_100_reverb_wpe
train_set=train_clean_100_reverb_wpe
#train_set=train_clean_100_reverb_wpe
train_dev=Development_Data_wpe
eval_set=Evaluation_Data_wpe
################################################################################################################

# NOW WE EXTRACT THE FBANK FEATS OF THE DATA
folder_name=data-C2LSTM_BEGAN_mse_01gan

if [ ${stage} -le 2 ] && [ ${stop_stage} -ge 2 ]; then

 echo "stage 2: Feature Generation"
 fbankdir=fbank
 for x in ${train_set} ${train_dev} ${eval_set}; do 
 #for x in ${train_dev} ${eval_set} ; do 
     #steps/make_fbank.sh --cmd "$train_cmd" --nj 25 --write_utt2num_frames true \
     #     data-fbank/${x} exp/make_fbank/${x} ${fbankdir}
     utils/fix_data_dir.sh $folder_name/${x}
 done
 # AFTER EXTRACTING FBANK COPY THE TRAIN, DEV AND EVAL IN SOME FOLDER DATA_FBANK OR SOMETHING LIKE THIS FOR CONVENIENCE
 # HENCE EXTRACT CMVN FOR THE TRAINING DATA
 # WE ARE EXTRACTING GLOBAL CMVN
 
 #utils/combine_data.sh $folder_name/${train_set} $folder_name/${train_set_voices} $folder_name/train_si284
 compute-cmvn-stats scp:$folder_name/${train_set}/feats.scp $folder_name/${train_set}/cmvn.ark
fi
 
echo "Stage 2 Completed"

#exit

###################################################################################################################

# CREATE THE DUMP FOLDER WHERE WE LATER ON PUT FEATS AND DATA.JSON

feat_tr_dir=${dumpdir}/${train_set}/delta${do_delta}; mkdir -p ${feat_tr_dir}
feat_dt_dir=${dumpdir}/${train_dev}/delta${do_delta}; mkdir -p ${feat_dt_dir}
feat_eval_dir=${dumpdir}/${eval_set}/delta${do_delta}; mkdir -p ${feat_eval_dir}

# CREATE THE DICTIONARY FOR DATA TRAINING
#dict=data/lang_1char/${train_set}_units.txt
dict=data/lang_1char/Train_cleaned_tr90_units.txt
nlsyms=data/lang_1char/non_lang_syms.txt

echo "dictionary: ${dict}"
if [ ${stage} -le 3 ] && [ ${stop_stage} -ge 3 ]; then
 ### Task dependent. You have to check non-linguistic symbols used in the corpus.
 echo "stage 3: Dictionary and Json Data Preparation"
 #mkdir -p data/lang_1char/
 
 echo "make a non-linguistic symbol list"
 #cut -f 2- data-fbank/${train_set}/text | tr " " "\n" | sort | uniq | grep "<" > ${nlsyms}
 cat $folder_name/${train_set}/text| awk -F ' ' '{print $2}' | tr " " "\n" | sort | uniq | grep "<" > ${nlsyms}
 cat ${nlsyms}
 
 echo "make a dictionary"
 echo "<unk> 1" > ${dict}
 text2token.py -s 1 -n 1 -l ${nlsyms} $folder_name/${train_set}/text | cut -f 2- -d" " | tr " " "\n" \
 | sort | uniq | grep -v -e '^\s*$' | awk '{print $0 " " NR+1}' >> ${dict}
 wc -l ${dict}
   
fi

echo "Stage 3 Completed"

#exit

##########################################################################################################################

# DUMP THE FEATS.SCP IN THE DUMP FOLDER

if [ ${stage} -le 4 ] && [ ${stop_stage} -ge 4 ]; then
    echo "[STAGE 4]: dump features for training..."
    dump.sh --cmd "$train_cmd" --nj 32 --do_delta ${do_delta} $folder_name/${train_set}/feats.scp $folder_name/${train_set}/cmvn.ark exp/dump_feats/train ${feat_tr_dir}
    dump.sh --cmd "$train_cmd" --nj 4 --do_delta ${do_delta} $folder_name/${train_dev}/feats.scp $folder_name/${train_set}/cmvn.ark exp/dump_feats/dev ${feat_dt_dir}
    dump.sh --cmd "$train_cmd" --nj 4 --do_delta ${do_delta} $folder_name/${eval_set}/feats.scp $folder_name/${train_set}/cmvn.ark exp/dump_feats/eval ${feat_eval_dir}
fi

echo "Stage 4 completed"

#exit

#############################################################################################################################

# NOW THIS STAGE CREATE THE JSON FILE NEEDED TO TRAIN THE ASR

if [ ${stage} -le 5 ] && [ ${stop_stage} -ge 5 ]; then
    echo "[STAGE 5]: make json files..."
    data2json.sh --feat ${feat_tr_dir}/feats.scp --nlsyms ${nlsyms} $folder_name/${train_set} ${dict} > ${feat_tr_dir}/data.json
    data2json.sh --feat ${feat_dt_dir}/feats.scp --nlsyms ${nlsyms} $folder_name/${train_dev} ${dict} > ${feat_dt_dir}/data.json
    data2json.sh --feat ${feat_eval_dir}/feats.scp --nlsyms ${nlsyms} $folder_name/${eval_set} ${dict} > ${feat_eval_dir}/data.json
fi

echo "Stage 5 completed"

#exit

###############################################################################################################################

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




################################################################################################################################
if [ -z ${tag} ]; then
    expname=${train_set}_${backend}_$(basename ${train_config%.*})
    if ${do_delta}; then
        expname=${expname}_delta
    fi
else
    expname=${train_set}_${backend}_${tag}
fi
expdir=exp/${expname}
mkdir -p ${expdir}

if [ ${stage} -le 6 ] && [ ${stop_stage} -ge 6 ]; then
    echo "[STAGE 6]: Network Training"

    CUDA_VISIBLE_DEVICES=${gpu} ${cuda_cmd} --gpu ${ngpu} ${expdir}/train.log \
        asr_train.py \
        --config ${train_config} \
        --ngpu ${ngpu} \
        --backend ${backend} \
        --outdir ${expdir}/results \
        --tensorboard-dir tensorboard/${expname} \
        --debugmode ${debugmode} \
        --dict ${dict} \
        --debugdir ${expdir} \
        --minibatches ${N} \
        --verbose ${verbose} \
        --resume ${resume} \
        --train-json ${feat_tr_dir}/data.json \
        --valid-json ${feat_dt_dir}/data.json #\
        #--preprocess-conf conf/specaug.yaml
fi

echo "Stage 6 completed"

#exit

###############################################################################################################################################

lmtag=
lm_config=conf/lm.yaml
use_wordlm=true     # false means to train/use a character LM
lm_vocabsize=65000
# It takes a few days. If you just want to end-to-end ASR without LM,
# you can skip this and remove --rnnlm option in the recognition (stage 5)
if [ -z ${lmtag} ]; then
    lmtag=$(basename ${lm_config%.*})
    if [ ${use_wordlm} = true ]; then
        lmtag=${lmtag}_word${lm_vocabsize}
    fi
fi
lmexpname=train_rnnlm_${backend}_${lmtag}
lmexpdir=exp/${lmexpname}
mkdir -p ${lmexpdir}

recog_set="Evaluation_Data_wpe Development_Data_wpe"

if [ ${stage} -le 7 ] && [ ${stop_stage} -ge 7 ]; then
    echo "stage 7: Decoding"
    nj=30

    pids=() # initialize pids
    for rtask in ${recog_set}; do
    (
        decode_dir=decode_${rtask}_$(basename ${decode_config%.*})
        if [ ${use_wordlm} = true ]; then
            decode_dir=${decode_dir}_wordrnnlm_${lmtag}
        else
            decode_dir=${decode_dir}_rnnlm_${lmtag}
        fi
        if [ ${use_wordlm} = true ]; then
            recog_opts="--word-rnnlm ${lmexpdir}/rnnlm.model.best"
        else
            recog_opts="--rnnlm ${lmexpdir}/rnnlm.model.best"
        fi
        feat_recog_dir=${dumpdir}/${rtask}/delta${do_delta}

        mkdir -p ${expdir}/${decode_dir}_with_jobs/log

        # split data
        splitjson.py --parts ${nj} ${feat_recog_dir}/data.json


        for JOBS in `seq 1 $nj`; do
        qsub -q med.q -l hostname=compute-0-[2-4] -V -cwd -e ${expdir}/${decode_dir}_with_jobs/log/decode.${JOBS}.log -o ${expdir}/${decode_dir}_with_jobs/log/decode.${JOBS}.log -S /bin/bash asr.sh ${decode_config} ${ngpu} ${backend} ${debugmode} ${feat_recog_dir}/split${nj}utt/data.${JOBS}.json ${expdir}/${decode_dir}_with_jobs/data.${JOBS}.json ${expdir}/results/${recog_model} ${recog_opts}
        sleep 5s
        done

    )
    done

    echo "Finished"
fi


if [ ${stage} -le 8 ] && [ ${stop_stage} -ge 8 ]; then
    echo "stage 8: Decoding Results"
    nj=25

    pids=() # initialize pids
    for rtask in ${recog_set}; do
    (
        decode_dir=decode_${rtask}_$(basename ${decode_config%.*})
        if [ ${use_wordlm} = true ]; then
            decode_dir=${decode_dir}_wordrnnlm_${lmtag}
        else
            decode_dir=${decode_dir}_rnnlm_${lmtag}
        fi
        if [ ${use_wordlm} = true ]; then
            recog_opts="--word-rnnlm ${lmexpdir}/rnnlm.model.best"
        else
            recog_opts="--rnnlm ${lmexpdir}/rnnlm.model.best"
        fi
        feat_recog_dir=${dumpdir}/${rtask}/delta${do_delta}

        #mkdir -p ${expdir}/${decode_dir}_with_jobs/log
        # split data
        #splitjson.py --parts ${nj} ${feat_recog_dir}/data.json

        #### use CPU for decoding
        ngpu=0

        score_sclite.sh --wer true --nlsyms ${nlsyms} ${expdir}/${decode_dir}_with_jobs ${dict}

    )
    done
fi


echo "DECODING COMPLETED"

















 





