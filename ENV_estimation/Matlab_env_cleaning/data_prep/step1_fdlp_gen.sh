#pwdr=/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation
pwdr=$1
hcopybin=$2
matlab_path=$3
nj=$4

 for y in $pwdr/* ; do
   echo $y
   a=1
   featdir=$y/newfea
   L=`wc -l <$y/wav.scp`

   N=$((L*a))
   echo "N is = $N"

   bash data_prep/fdlp_mc.sh $y $hcopybin $matlab_path $nj
   	
   cnter=`ls $featdir/*.fea | wc -l | awk '{print $1}'`
   echo "center is = $cnter"
   while [ "$cnter" -lt "$N" ] ; do
     sleep 15s
     echo "waiting for $cnter to be equal to $N"
     cnter=`ls $featdir/*.fea | wc -l | awk '{print $1}'`
   done		
   echo "Feats  for $y is Done"
 done

echo "Feats  for all directories Done"

