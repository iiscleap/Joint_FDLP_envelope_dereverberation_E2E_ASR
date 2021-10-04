#!/bin/bash
./cmd.sh
./path.sh
source ~student1/.bashrc

cpython="/state/partition1/softwares/Miniconda3/bin/python"

data_ip="/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/matlab_mc/test_reshape.mat"
data_ip_lin="/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/matlab_mc/test_reshape_lin.mat"

${cpython} /home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/steps_torch_env/test_reshape.py ${date_ip} ${date_ip_lin}

