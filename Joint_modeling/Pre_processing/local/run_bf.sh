#!/bin/bash

# Copyright 2015, Mitsubishi Electric Research Laboratories, MERL (Author: Shinji Watanabe)
# Copyright 2018, Johns Hopkins University (Author: Aswin Shanmugam Subramanian)

. ./cmd.sh
. ./path.sh

# Config:
nj=20
cmd=run.pl

. utils/parse_options.sh || exit 1;

if [ $# != 1 ]; then
   echo "Wrong #arguments ($#, expected 1)"
   echo "Usage: local/run_beamform.sh [options] <wav-out-dir>"
   echo "main options (for others, see top of script file)"
   echo "  --nj <nj>                                # number of parallel jobs"
   echo "  --cmd <cmd>                              # Command to run in parallel with"
   exit 1;
fi

odir=$1
dir=${PWD}/data/local/data
echo $KALDI_ROOT

#if [ -z $BEAMFORMIT ] ; then
#  export BEAMFORMIT=$KALDI_ROOT/tools/extras/BeamformIt
  #echo "Hell0"
  #export BEAMFORMIT=/state/partition1/softwares/Kaldi_Sept_2020/kaldi/tools/extras/BeamformIt
#fi
#echo ${PATH}
#export PATH=${PATH}:$BEAMFORMIT

export BEAMFORMIT=/state/partition1/softwares/ESPNET/espnet/tools/installers/BeamformIt
export PATH=${PATH}:${BEAMFORMIT}

! hash BeamformIt && echo "Missing BeamformIt, run 'cd ../../../tools/; extras/install_beamformit.sh;'"

