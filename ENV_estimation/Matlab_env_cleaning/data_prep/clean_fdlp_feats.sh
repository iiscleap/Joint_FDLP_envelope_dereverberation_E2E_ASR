echo "generate feats init"

feaDir=$1
list=$2

cnt=`cat $list | wc -l | awk '{print int ($1 / 20) +1 }'`
mkdir -p ${feaDir} || exit 1;
split -l $cnt $list ${feaDir}/segments_
echo "$cnt"

for file in `ls ${feaDir}/segments_*`
do
  echo $file
  python /data2/multiChannel/ANURENJAN/VOICES/ENV_estimation/Matlab_env_cleaning/clean_elp_estimation/process_list.py $file
done
