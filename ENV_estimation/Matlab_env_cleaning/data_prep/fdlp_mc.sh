sdir=$1
pwdr=$1

scp=$sdir/wav.scp
hcopybin=$2 ############ /home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Matlab_RAW_features/data_prep/generate_fdlp_feats_mc.sh ########
#cpython="/state/partition1/softwares/Miniconda3/bin/python"
matlab_path=$3
nj=$4

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
  echo -n "${x}.fea 16000" | sed -e "s/\.wav//" | awk -F '/' -v var="$sdir/newfea" '{print " "var"/"$NF}'

done > $input_arrays < $output_wavfiles


echo "input_arrays is $input_arrays"
echo "spliting the tasks to create $nj jobs"
echo "pwdr is ${pwdr}"
python utils/split_scp.py --splits $nj --file ${pwdr}/filelist.scp --prefix filelist --dest ${pwdr}/splits



true&&{
echo "Generating Features From List"
for job in `seq 1 $nj`; do
  out=`echo "${pwdr}/splits/feats_file.$job.out"`
  err=`echo "${pwdr}/splits/feats_file.$job.err"`
 qsub -q long.q -l hostname=compute-0-[4-6] -e $err -o $out -S /bin/bash $hcopybin $matlab_path ${pwdr}/newfea/split_$job \
                                      ${pwdr}/splits/filelist.$job.scp 
done
}
