from pdb import set_trace as bp  #################added break point
from scipy.io import wavfile
import numpy
from generate_env_feats import generate_env_feats
def aud_feats_no_vad_3Channel(infile, outfile, fs):
 ## %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ## % -------- Feature Extraction -------
 ## Read samples from the input file
 noc=1
 infile2 = infile.replace('ch1','ch2')
 outfile2 = (outfile.replace('ch1','ch2')).replace('_A/','_B/')
 fs, y1 = wavfile.read(infile)
 y1 = numpy.expand_dims(y1,axis=0)
 nochan=y1.shape[0]

 

 cepstra = generate_env_feats(y1,fs,nochan); #to extract from FDLP



 #cep1=cepstra(1:nochan:end,:)
 #cep2=cepstra(2:nochan:end,:)
 #cep3=cepstra(3:nochan:end,:)
 #cep4=cepstra(4:nochan:end,:)
 #cep5=cepstra(5:nochan:end,:)


 #writehtkf_new(outfile,cepstra_cln_int,100000.0,8267); 


