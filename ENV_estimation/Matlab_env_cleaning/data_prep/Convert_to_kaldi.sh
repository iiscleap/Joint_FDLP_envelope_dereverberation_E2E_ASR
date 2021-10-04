#!/bin/bash
. ./path.sh
fbankdir=$1
cmvn_dir=$2
folder_name=$3


name="arFeat"
nj=5;
while read x
do

dirhtk=${fbankdir}/${x}
echo $dirhtk
dirbase=`echo $dirhtk ` #| sed -e 's/_A//g'` 
dataDirbase=`echo "data-${fbankdir}/${x}"` #| sed -e 's/_A//g'`
echo $x
echo "Converting Features to kaldi format"
  # Convert PLPs
  # prepare scpfiles with HTK features (2col kaldi-style)
refdirbase=`echo "/home/anirudhs/tmp/anu/REVERB_BF_8_FDLP_MB3_with_gainnorm/data_Beamform_ref/$x" | sed -e 's/_A.htk//g'` #changed here from reverb
echo $refdirbase

htkfeatdir=${dirhtk}
echo "htkfeatdir is ${htkfeatdir}"
find $htkfeatdir -name *.fea | awk '{ file=$1; label=$1; gsub(/.*\//,"",label); gsub(/\..*/,"",label); print label" "file; }' | sort > ${htkfeatdir}.scp

  echo Generated ${htkfeatdir}.scp 
  featdir=${dirbase}.kaldi; mkdir -p $featdir || exit 1;
  data=${dataDirbase}; mkdir -p $data || exit 1;
  refdirdata="${refdirbase}" #changed here from reverb
  echo " refdirdata is $refdirdata"
  utils/copy_data_dir.sh ${refdirdata} ${data}
  #rm $data/cmvn.scp
  #rm $data/skp_map
  #rm $data/utt_map
  cp -r ${refdirdata}/utt2spk ${data} #changed here from reverb
  cp -r ${refdirdata}/text ${data}  #changed here from reverb
  cp -r ${refdirdata}/spk2utt ${data}  #changed here from reverb
  split_scps=""
  for n in `seq 1 $nj`; do  
    split_scps="$split_scps ${htkfeatdir}.$n.scp"
  done
  echo $split_scps
  utils/split_scp.pl ${htkfeatdir}.scp $split_scps || exit 1;
  # import features
  for JOB in `seq 1 $nj` ; do 
    copy-feats --htk-in=true scp:${htkfeatdir}.${JOB}.scp \
     ark,scp:$featdir/logmel_${name}.${JOB}.ark,$featdir/logmel_${name}.${JOB}.scp || exit 1;
   done
  # concatenate the .scp files
  for n in `seq 1 $nj`; do
    cat $featdir/logmel_${name}.${n}.scp | sed -e "s/_${chn} / \/home\/data2\/ANURENJAN\/REVERB\/ENV_estimation\/$folder_name\//g" || exit 1;
  done > $data/feats.scp
  rm ${htkfeatdir}.*.scp
  
  steps/compute_cmvn_stats.sh \
      $cmvn_dir/$data exp/make_${fbankdir}/${x} $featdir || exit 1;
#done

done < dirList_2
