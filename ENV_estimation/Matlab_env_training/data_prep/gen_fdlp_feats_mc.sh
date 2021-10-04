echo "generate feats init"
source /home/anirudhs/MatlabRuntime_R2019b.sh
matlab_path=$1
feaDir=$2
list=$3


cnt=`cat $list | wc -l | awk '{print int ($1 / 20) +1 }'`
mkdir -p ${feaDir} || exit 1;
split -l $cnt $list ${feaDir}/segments_
echo "$cnt"

for file in `ls ${feaDir}/segments_*`
do
  echo $file
  #cd /home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/matlab_mc/
  cd $matlab_path
  #matlab -nodisplay -nodesktop -r "process_list('/home/anirudhs/IISC/Chime3/fdlp/dt05_orig_clean.htk/split_1/segments_aa',1);exit;" 
  /home/student1/softwares/Matlab2019b_final/bin/matlab -nodisplay -nodesktop -r "process_list('$file');exit;" 
  cd ..
  cd ..
  #echo `pwd`
  #scr=`echo "${file}.sh"`
  #echo "hello123"
  #echo "source /home/anirudhs/MatlabRuntime_R2015b.sh" > $scr
  #echo "/home/anirudhs/IISC/Chime3/Matlab/Chime3_1/process_list $file " >> $scr
  #echo $scr
  #/bin/bash $scr
done

