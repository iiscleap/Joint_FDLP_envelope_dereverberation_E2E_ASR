sdir=/home/data2/multiChannel/ANURENJAN/VOICES/train_clean_100_reverb/AUDIO_VOICES_WPE
pwdr=/home/data2/multiChannel/ANURENJAN/VOICES/ASR/FDLP_ASR/fdlp_data




for x in Development_Data Evaluation_Data ; do
   	
     mkdir -p $pwdr/$x
     cp  $sdir/$x/text $sdir/$x/spk2utt $sdir/$x/utt2spk $pwdr/$x 
     
     output_wavfiles=$pwdr/$x/wav.scp 
     rm -f $output_wavfiles
     find $sdir/$x/newfea | grep .wav | sort >> $output_wavfiles 

done	
