#!/bin/bash

# Copyright 2014, University of Edinburgh (Author: Pawel Swietojanski)

. ./path.sh

nj=$1
job=$2
numch=$3
meetings=$4
sdir=$5
odir=$6
wdir=$7

set -e
set -u

utils/split_scp.pl -j $nj $((job-1)) $meetings $meetings.$job
#sdir=   #Added extra
while read line; do

  mkdir -p $odir/$line
  echo $line
  /state/partition1/softwares/kaldi/tools/BeamformIt/BeamformIt -s $line -c $wdir/channels_$numch \
                        --config_file `pwd`/conf/ami_beamformit.cfg \
                        --source_dir $sdir \
                        --result_dir $odir/$line
 # echo 'src dir'
 # echo $sdir
  mkdir -p $odir/$line
  mv $odir/$line/${line}.del  $odir/$line/${line}_MDM$numch.del
  mv $odir/$line/${line}.del2 $odir/$line/${line}_MDM$numch.del2
  mv $odir/$line/${line}.info $odir/$line/${line}_MDM$numch.info
  mv $odir/$line/${line}.weat $odir/$line/${line}_MDM$numch.weat
  mv $odir/$line/${line}.wav  $odir/$line/${line}_MDM$numch.wav
  #mv $odir/$line/${line}.ovl  $odir/$line/${line}_MDM$numch.ovl # Was not created!

done < $meetings.$job

