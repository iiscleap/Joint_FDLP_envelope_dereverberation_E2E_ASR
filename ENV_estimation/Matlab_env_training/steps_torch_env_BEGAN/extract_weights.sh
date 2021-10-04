#!/bin/bash
./cmd.sh
./path.sh
source ~student1/.bashrc

cpython="/state/partition1/softwares/Miniconda3/bin/python"
model_dir="/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Matlab_RAW_features/exp/torch_ENV_CLN_CNN_with_Net_larg_kernel_without_batchnorm"





echo "extracting weights using python"


${cpython} /home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Matlab_RAW_features/steps_torch_env/extract_weights.py ${model_dir} 

