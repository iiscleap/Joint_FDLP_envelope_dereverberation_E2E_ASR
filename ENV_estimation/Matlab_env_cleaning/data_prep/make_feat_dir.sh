sdir=$1
pwdr=$2   




for x in Development_Data Evaluation_Data ; do
   	
     mkdir -p $pwdr/$x
     cp  $sdir/$x/text $sdir/$x/spk2utt $sdir/$x/utt2spk $pwdr/$x 
     output_wavfiles=$pwdr/$x/wav.scp 
     rm -f $output_wavfiles
     find $sdir/$x/newfea | grep .wav | sort >> $output_wavfiles 

done	

tr_dir=/home/data2/multiChannel/ANURENJAN/VOICES/train_clean_100_reverb/AUDIO_VOICES_WPE/train_clean_100_reverb/newfea/
scr_cln=/home/sriram/speech/VOiCES/data/train_clean_100
     
mkdir -p $pwdr/Training_Data

output_wavfiles=$pwdr/Training_Data/wav.scp
rm -f $output_wavfiles
find $tr_dir | grep .wav | sort >> $output_wavfiles 

cp  $scr_cln/text $scr_cln/spk2utt $scr_cln/utt2spk $pwdr/Training_Data 

     


