#!/bin/bash

inwav=$1
outfea=$2
format='raw'
sr=16000

echo "cd /home/sriram/speech/ibm/Home/speech/codes/aurora4/logmel/; disp('xaa'); aud_feats_no_vad('$inwav','$outfea','$sr');disp(datestr(now));exit"


echo "cd /home/sriram/speech/ibm/Home/speech/codes/aurora4/logmel/; disp('xaa'); aud_feats_no_vad('$inwav','$outfea','$sr');disp(datestr(now));exit" | /usr/local/MATLAB/R2015b/bin//matlab -nodesktop -nojvm -nosplash -singleCompThread
