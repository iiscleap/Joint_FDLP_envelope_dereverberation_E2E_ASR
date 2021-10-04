#!/bin/bash


. ./path.sh || exit 1;
. ./cmd.sh || exit 1;



path="/data2/multiChannel/ANURENJAN/VOICES_E2E/Joint_modeling/Pre_processing"

data_folder="data-Input_training_data_2_sec_gn_auto"

#after preprocess, your feats are stored in this folder
save_folder="TEST2"

stage=3
stop_stage=100

if [ ${stage} -le 0 ] && [ ${stop_stage} -ge 0 ]; then
	echo "Stage 0: Creat the folder"
	for x in 'REVERB_tr_cut/SimData_tr_for_1ch_A_tr90' 'cleanTrain/cleanTrain_cut_tr90' 'REVERB_tr_cut/SimData_tr_for_1ch_A_cv10' 'cleanTrain/cleanTrain_cut_cv10';do
		mkdir -p $save_folder/$x
		mkdir -p $save_folder/$x
	done
fi

#exit


if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ]; then
	echo "Stage 1: Apply cmvn and save the feats"
	for x in 'REVERB_tr_cut/SimData_tr_for_1ch_A_tr90' 'cleanTrain/cleanTrain_cut_tr90' 'REVERB_tr_cut/SimData_tr_for_1ch_A_cv10' 'cleanTrain/cleanTrain_cut_cv10';
	do
	python code_utils/code_apply_cmvn.py --path $path --loc $data_folder --dest $save_folder --folder $x
	done
fi


#exit


if [ ${stage} -le 2 ] && [ ${stop_stage} -ge 2 ]; then
	echo "Stage 2: Combining the feats of clean and noisy in a single array"
	python code_utils/combine_in_scp.py --path $path --loc $save_folder
	python code_utils/create_feat.py --path $path --loc $save_folder	
fi


#exit


. ./path.sh || exit 1;
. ./cmd.sh || exit 1;


nlsyms=data/lang_1char/non_lang_syms.txt
dict=data/lang_1char/tr_simu_8ch_si284_units.txt

if [ ${stage} -le 3 ] && [ ${stop_stage} -ge 3 ]; then
	echo "Stage 3: Creation of data.json file"
	mkdir -p $save_folder/tr_90
	mv $save_folder/feats_trn90.1.ark $save_folder/tr_90/feats.1.ark
	mv $save_folder/feats_trn90.scp $save_folder/tr_90/feats.scp
	
	mkdir -p $save_folder/cv_10
	mv $save_folder/feats_cvn10.1.ark $save_folder/cv_10/feats.1.ark
	mv $save_folder/feats_cvn10.scp $save_folder/cv_10/feats.scp

	for rtask in tr_90 cv_10;do
	data2json.sh --feat $save_folder/$rtask/feats.scp --nlsyms ${nlsyms} data/${rtask} ${dict} > $save_folder/$rtask/data.json
	done
fi



