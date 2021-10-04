#!/bin/bash 

# Copyright 2012-2013 Brno University of Technology (Author: Mirko Hannemann, Karel Vesely)
# Apache 2.0
# To be run from .. (one directory up from here):wq
# see ../run.sh for example

# Begin configuration section.  
nj=4 #limit the number of files processed at once
cmd=run.pl

stage=0
skip_segments=false
bypass_f0_in_segments=false
delete_htk_data=false

hcopybin=/home/sriram/speech/reverb/vAR_pole200_K3_2s_specgram_23Band_Gain/local/expt/logmel/generate_feats.sh
hlistbin=/home/sriram/installers/htk/HTKTools/HList
# End configuration section.

echo "$0 $@"  # Print the command line for logging

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

if [ $# != 3 ]; then
   echo "usage: make_plp_f0.sh [options] <data-dir> <log-dir> <path-to-featdir>";
   echo "  --nj <nj>                                        # number of parallel jobs"
   echo "  --cmd (utils/run.pl|utils/queue.pl <queue opts>) # how to run jobs."
   echo "  --plp_config <config-file>                       # config passed to compute-plp-feats"
   echo "  --f0_config <config-file>                        # config passed to f0estim"
   echo "  --vtln-map <map-file>                            # warping factor for each file"
   echo ""
   echo "  --skip-segments <bool>                           # skip segment extraction (last stage)"
   echo "  --bypass-f0-in-segments <bool>                   # extract segments from PLP features w/o f0"
   exit 1;
fi

data=$1
logdir=$2
plpdir=$3

echo "Data Directory is $data" 

# make absolute pathnames
[ ${plpdir:0:1} != '/' ] && plpdir=$PWD/$plpdir
[ ${logdir:0:1} != '/' ] && logdir=$PWD/$logdir

# use "name" as part of name of the archive.
name=`basename $data`
dirbase=`dirname $plpdir`

mkdir -p $logdir || exit 1;
mkdir -p $logdir/hcopy || exit 1;

scp=$data/wav.scp
segments=$data/segments

required="$scp $f0_config $plp_config"
for f in $required; do
  [ ! -f $f ] && echo "$0: Missing file $f" && exit 1;
done

rm $logdir/done.* 2>/dev/null

# Number of recordings
N=$(cat $scp | wc -l);
N1=$(cat $scp | wc -l | awk '{ print int ( $1/10 ) }');


#######################################################################
# Compute PLPs using HTK
featdir=${dirbase}/$name.htk; mkdir -p $featdir || exit 1;
rm -f $featdir/filelist.scp
if [ $stage -le 0 ]; then
  # generate PLP features with HTK (either with or without VTLN)
  if [ $vtln_map ]; then
    # make a mapping of warping factors for each file to make cmd less complicated
    cat $scp | awk -v vtln=$vtln_map 'BEGIN{while(getline < vtln > 0){wf[$1]=$2;} } { split($1,a,"_"); print $1,$2,wf[a[1]]; }' > $scp.wf
    echo "Computing Features (HTK)"
    $cmd -tc $nj JOB=1:$N $logdir/hcopy/hcopy-vtln.JOB.log \
      eval "wav=\$(cat $scp.wf | head -n JOB | tail -n 1 | awk '{ print \$2 }');" '&&' \
      eval "name=\$(cat $scp.wf | head -n JOB | tail -n 1 | awk '{ print \$1 }');" '&&' \
      eval "wf=\$(cat $scp.wf | head -n JOB | tail -n 1 | awk '{ print \$3 }');" '&&' \
      eval "conf=\$(mktemp)" '&&' \
      cp $plp_config \$conf '&&' \
      echo "HPARM: WARPFREQ    = \$wf" '>>' \$conf '&&' \
      echo "HPARM: WARPLCUTOFF = 3375" '>>' \$conf '&&' \
      echo "HPARM: WARPUCUTOFF = 3375" '>>' \$conf '&&' \
      $hcopybin -A -D -T 5 -C \$conf \$wav $featdir/\$name.fea
  else
    echo "Computing Features (MATLAB)"
     for  JOB in `seq 1 $N` ; do  
      wav=`cat $scp | head -n $JOB | tail -n 1 | awk '{ print $(NF) }'` 
      name=`cat $scp | head -n $JOB | tail -n 1 | awk '{ print $1 }'` 
      echo "$wav ${featdir}/${name}.fea 16000" >> ${featdir}/filelist.scp
     done
  fi 
fi

echo "Generating Features From List"
$hcopybin $featdir/filelist.scp

sleep 15s
echo "Waiting for Feats to be done ..."
cnter=`ls $featdir/*.fea | wc -l | awk '{print $1}'`

while [ "$cnter" -lt $N ]
do
   sleep 15s
   cnter=`ls $featdir/*.fea | wc -l | awk '{print $1}'`

done

echo "Feats Done "
#######################################################################
# Compute f0 using f0estim (normalize)
#######################################################################
# Convert htk features into kaldi
name=`echo ${featdir} | awk -F'/' '{print $NF}' | awk -F'.' '{print $1}'`

if [ $stage -le 1 ]; then
  echo "Converting Features to kaldi format"
  # Convert PLPs
  # prepare scpfiles with HTK features (2col kaldi-style)
  featdir=$dirbase/$name.kaldi; mkdir -p $featdir || exit 1;
  htkfeatdir=$dirbase/$name.htk
  echo $name
  find $htkfeatdir -name *.fea | \
    awk '{ file=$1; label=$1; gsub(/.*\//,"",label); gsub(/\..*/,"",label); print label" "file; }' | \
    sort > $htkfeatdir.scp
  # split into several files so we can convert in parallel
  split_scps=""
  for ((n=1; n<=nj; n++)); do
    split_scps="$split_scps $htkfeatdir.$n.scp"
  done
  echo Generated $htkfeatdir.scp
  utils/split_scp.pl $htkfeatdir.scp $split_scps || exit 1;
  # import features
  $cmd JOB=1:$nj $logdir/import/import_plp.JOB.log \
    copy-feats --htk-in=true scp:$htkfeatdir.JOB.scp \
     ark,scp:$featdir/logmel_${name}.JOB.ark,$featdir/logmel_${name}.JOB.scp || exit 1;
  # concatenate the .scp files
  for ((n=1; n<=nj; n++)); do
    cat $featdir/logmel_${name}.${n}.scp || exit 1;
  done > $data/feats.scp
  rm $htkfeatdir.*.scp
fi
exit 0;
#######################################################################
# Merge the features
#######################################################################
# Split the features with default segmentation

if [ $stage -le 2 ]; then
  echo "Segmenting (default segmentation : $data/segments)";
  if ! $skip_segments; then
    # check we have segments
    [ ! -r $data/segments ] && echo "$data/segments not found, cannot resegment features in $data" && exit 1
    # Select scp with "long features" to segment
    if ! $bypass_f0_in_segments; then
      featdir=$plpdir/$name.plp-f0.segments; mkdir -p $featdir || exit 1;
      long_feat_scp=$data/feats_plp-f0norm.scp
    else
      featdir=$plpdir/$name.plp.segments; mkdir -p $featdir || exit 1;
      long_feat_scp=$data/feats_plp.scp
    fi
    feat_type=$(basename $long_feat_scp .scp | sed 's|feats_||')
    # split segments into several files so we can run in parallel
    split_segs=""
    for ((n=1; n<=nj; n++)); do
      split_segs="$split_segs $featdir/segments.$n"
    done
    utils/split_scp.pl $data/segments $split_segs || exit 1;
    # segment features
    $cmd JOB=1:$nj $logdir/segments/extract_segments.JOB.log \
      extract-feature-segments --frame-rate=100 --max-overshoot=0.05 scp:$long_feat_scp $featdir/segments.JOB \
        ark,scp:$featdir/features.$feat_type.JOB.ark,$featdir/features.$feat_type.JOB.scp
    # concatenate the .scp files
    for ((n=1; n<=nj; n++)); do
      cat $featdir/features.$feat_type.$n.scp || exit 1;
    done > $data/feats.scp
    # cleanup
    rm $featdir/segments.*
  fi
fi

echo
echo "Succeeded creating features for '$name'"
exit 0
