#!/bin/bash
source ~student1/.bashrc
cpython="/state/partition1/softwares/Miniconda3/bin/python"
inlist="/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/matlab_sc_factor_40/test.txt"
${cpython} /home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Old_EnvC_wpe_gev_BF_Estimation/steps_torch_env/FDLP/process_list.py
