#pwdr=/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Env_wpe_gev_BF_estimation_python
pwdr=$1
new_dir=$2
#source ~/.bashrc
for y in $pwdr/* ; do
 #for y in $x/* ; do
   echo $y
   
   rm -rf $y/newfea
   rm -rf $y/splits
   a=1
   featdir=$y/newfea
   L=`wc -l <$y/fea.scp`

   N=$((L*a))
   echo "N is = $N"

   bash data_prep/fdlp_cleaning.sh $y $new_dir
		
   cnter=`ls $featdir/*.fea | wc -l | awk '{print $1}'`
   echo "center is = $cnter"


   while [ "$cnter" -lt "$N" ] ; do

     sleep 15s
     echo "waiting for $cnter to be equal to $N"
     cnter=`ls $featdir/*.fea | wc -l | awk '{print $1}'`
   done		
   echo "Feats  for $y is Done"
 done

#done
echo "Feats  for all directories Done"

