sdir=$1
pwdr=$2   
scr_cln=$3

################### Creating wav.scp for Matlab feature extraction... ##################################


#tpp=`echo $y | sed "s~${1}~${2}~"`		
#tpp=`echo $y | sed -e 's/WPE_GEV_BF_AUDIO/ENV_estimation\/Matlab_RAW_features\/Data_dir/g'`
#echo $tpp
mkdir -p $pwdr
output_wavfiles=$pwdr/wav.scp
rm -f $output_wavfiles
find $sdir | grep .wav | sort >> $output_wavfiles 
cp  $scr_cln/text $scr_cln/spk2utt $scr_cln/utt2spk $pwdr  

