#!/bin/bash
############################## Set The Stage ############################## 
set -e
stage=3
nj=15
############################## Run Cmd.sh and Path.sh ##############################
. ./cmd.sh
. ./path.sh

############################## Set the Directory names ############################## 
sdir=/data2/multiChannel/ANURENJAN/VOICES/ENV_estimation/Matlab_env_training
pwdr=/data2/multiChannel/ANURENJAN/VOICES/ENV_estimation/Matlab_env_training/WSJ_DATA
pwd=/data2/multiChannel/ANURENJAN/VOICES/ENV_estimation/Matlab_env_training/

hcopybin=/data2/multiChannel/ANURENJAN/VOICES/ENV_estimation/Matlab_env_training/data_prep/generate_fdlp_feats_mc.sh
matlab_path=/data2/multiChannel/ANURENJAN/VOICES/ENV_estimation/Matlab_env_training/matlab_300_MB1_gn_arfit

inputfeat_dir="data-WSJ"

dir=/data2/multiChannel/ANURENJAN/VOICES/ENV_estimation/Matlab_env_training/


#subset_dir=data-data-Input_raw_data_for_cleaning/REVERB_tr_cut/SimData_tr_for_1ch

############################## Make Directories ############################## 

if [ $stage -le 1 ] ; then
echo "Extracting features only for training datas"
bash data_prep/make_feat_dir.sh $sdir $pwdr
echo "############################## Feat Directory is ready ############################## "
fi


#exit

if [ $stage -le 2 ] ; then
echo "Splitting the jobs to generate the features from matlab"
bash data_prep/step1_fdlp_gen.sh $pwdr $hcopybin $matlab_path $nj
fi

#exit

if [ $stage -le 3 ] ; then
echo "Generation fea.scp from the raw features extracted"
bash data_prep/make_fea_scp.sh $pwdr $pwd $inputfeat_dir
fi
exit

if [ $stage -le 4 ] ; then
echo "Clean the features and extracting new features"
############ "Change the model path in process_list.py, copy the Net into the clean_elp_estimation/NET folder and import this new Net in the forward_pass_cepstra.py before running this" #######################
bash data_prep/step1_fdlp_cleaning.sh $pwd/$inputfeat_dir $inputfeat_dir

echo "Done"
fi



#exit


false&&
{
if [ $stage -le 5 ] ; then
echo "Convert to kaldi Reverb data"
bash data_prep/Convert_to_kaldi.sh $inputfeat_dir $dir  
fi

#if [ $stage -le 6 ] ; then
#echo "Create subset for the training and cross validation"
#bash data_prep/subset.sh $subset_dir
#fi
}



