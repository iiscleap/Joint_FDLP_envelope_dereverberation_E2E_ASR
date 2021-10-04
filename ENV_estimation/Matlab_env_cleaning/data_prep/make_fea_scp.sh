#sdir=/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation
#sdir=/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Env_wpe_gev_BF_estimation_python/Input_raw_data
#pwdr=/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Env_wpe_gev_BF_estimation_python
sdir=$1
pwdr=$2
   
##### generates the fea.scp to get the features for forwardpassing in python

#make_dir=64_filters_Input_raw_data  
make_dir=$3

for y in $sdir/*
do

	
	#for y in $x/*
	#	do	
	        echo $y
		tpp=`echo $y | sed -e "s/Input_raw_data_E2E_voices_only/$make_dir/g"` 
		echo $tpp
		mkdir -p $tpp
		rm -f $tpp/wav.scp
		cp $y/utt2spk $tpp/utt2spk
		cp $y/spk2utt $tpp/spk2utt
		output_wavfiles=$tpp/fea.scp
		rm -f $output_wavfiles
		find $y/newfea -type f -name "*.fea" | sort >> $output_wavfiles
		
		
#done
done


