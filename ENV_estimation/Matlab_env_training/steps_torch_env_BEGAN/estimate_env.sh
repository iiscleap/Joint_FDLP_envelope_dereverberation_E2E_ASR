#!/bin/bash
./cmd.sh
./path.sh
source ~student1/.bashrc

cpython="/state/partition1/softwares/Miniconda3/bin/python"
model_dir="/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/exp/torch_ENV_CLN_CNN_with_Net_larg_kernel"
data="c02c0202.csv"

${cpython} /home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/steps_torch_env/estimate_env.py ${model_dir} ${data}
exit

for x in $data/csv_files/*
do
echo "$x"
echo "estimating env using python"
${cpython} /home/anirudhs/tmp/ENV_DNN/REVERB_ENV_DNN/steps_torch_env/estimate_env.py ${model_dir} ${data}
exit
done 
