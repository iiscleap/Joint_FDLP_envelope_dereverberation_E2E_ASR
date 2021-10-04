sdir=$1
pwdr=$1
new_dir=$2
scp=$sdir/fea.scp
hcopybin=/data2/multiChannel/ANURENJAN/VOICES/ENV_estimation/Matlab_env_cleaning/data_prep/clean_fdlp_feats.sh
#cpython="/state/partition1/softwares/Miniconda3/bin/python"
nj=50

rm -rf $sdir/newfea
rm -rf $sdir/splits
mkdir -p $sdir/newfea
mkdir -p $sdir/splits

# we use the following channel signals, and remove 2nd channel signal, which located on the back of
# tablet, and behaves very different from the other front channel signals.


output_wavfiles=$scp

input_arrays=$sdir/filelist.scp
rm -f $input_arrays
while IFS="" read -r y || [ -n "$y" ]
do
 x=`echo $y | awk -F ' ' '{print $NF}'`

  echo -n "$x"
  echo " ${x} 16000" | sed -e "s/Input_raw_data_E2E_voices_only/$new_dir/g" 

done > $input_arrays < $output_wavfiles


echo "input_arrays is $input_arrays"
echo "spliting the tasks to create $nj jobs"
echo "pwdr is ${pwdr}"
python /data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Env_wpe_gev_BF_estimation_python/utils/split_scp.py --splits $nj --file ${pwdr}/filelist.scp --prefix filelist --dest ${pwdr}/splits



true&&{
echo "Generating Features From List"
for job in `seq 1 $nj`; do
  out=`echo "${pwdr}/splits/feats_file.$job.out"`
  err=`echo "${pwdr}/splits/feats_file.$job.err"`
 qsub -q med.q -l hostname=compute-0-[0-5] -e $err -o $out -S /bin/bash $hcopybin ${pwdr}/newfea/split_$job \
                                      ${pwdr}/splits/filelist.$job.scp 
done
}
