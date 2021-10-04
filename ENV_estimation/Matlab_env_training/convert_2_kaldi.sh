#!/bin/bash
. ./path.sh
fbankdir="Input_training_data"
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
refdirbase=`echo "/data2/multiChannel/ANURENJAN/VOICES/ASR/Fbank_ASR/data-fbank_dir/$x" | sed -e 's/_A.htk//g'` #changed here from reverb
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
    cat $featdir/logmel_${name}.${n}.scp | sed -e "s/_${chn} / \/data2\/ANURENJAN\/VOICES\/ENV_estimation\/Matlab_env_training\/$folder_name\//g" || exit 1;
  done > $data/feats.scp
  rm ${htkfeatdir}.*.scp
  
  cat data-fdlp_data/${data}/feats.scp | awk '{print $1" "$1}' > data-fdlp_data/${data}/utt2spk
  cat data-fdlp_data/${data}/feats.scp | awk '{print $1" "$1}' > data-fdlp_data/${data}/spk2utt 
  steps/compute_cmvn_stats.sh \
      /data2/multiChannel/ANURENJAN/VOICES/ENV_estimation/Matlab_env_training/$data exp/make_${fbankdir}/${x} $featdir || exit 1;
#done

done < dirList_kaldi
