

source /home/sriram/MatlabRuntime_R2015b.sh

list=$1
feaDir=`dirname $list`

cnt=`cat $list | wc -l | awk '{print int ($1 / 20) +1 }'`
echo $cnt $list
split -l $cnt $list ${feaDir}/segments_


for file in `ls ${feaDir}/segments_*`
do
  echo $file
  scr=`echo "${file}.sh"`
  out=`echo "${file}.out"`
  err=`echo "${file}.err"`

  echo "source /home/sriram/MatlabRuntime_R2015b.sh" > $scr
  echo "/home/sriram/speech/reverb/Matlab/vAR_pole200_K3_2s_specgram_23Band_Gain/process_list $file" >> $scr
  qsub -e $err -o $out -S /bin/bash $scr 
done 
