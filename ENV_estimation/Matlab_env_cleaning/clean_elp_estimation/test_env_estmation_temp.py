import numpy 
from read_HTK import HTKFeat_read, HTKFeat_write
from pdb import set_trace as bp  #################added break point 
#from Net_full_cnn_deep import Net
from forward_pass_cepstra import forward_pass
from write_HTK import write_htk


in_channel = 1 
inputFeatDim = 36

def open(f, mode=None, veclen=36):
    """Open an HTK format feature file for reading or writing.
    The mode parameter is 'rb' (reading) or 'wb' (writing)."""
    
    if mode is None:
        if hasattr(f, 'mode'):
            mode = f.mode
        else:
            mode = 'rb'
    if mode in ('r', 'rb'):
        
        return HTKFeat_read(f) # veclen is ignored since it's in the file
    elif mode in ('w', 'wb'):
        return HTKFeat_write(f, veclen)
    else:
        raise Exception( "mode must be 'r', 'rb', 'w', or 'wb'")

def extract_feats_clean(data, data_out, exp, model_name,in_channel = 1,inputFeatDim = 36):
  data_in = open(data, 'rb') 
  data_original = data_in.getall()
  clean_data = forward_pass(data_original, exp, model_name, in_channel, inputFeatDim )
  print("########### cleaned the data ###########")      
  write_htk( data_out , clean_data , 100000.0 , 8267 )
  print("########### write HTK ###########")

bp()
data_in = open('c0ac020a.fea', 'rb') 
data_original = data_in.getall()
write_htk('temp_c0ac020a.fea', data_original, 100000.0 , 8267 )
data_temp = open('temp_c0ac020a.fea', 'rb') 
data_new = data_temp.getall()

#c3cc020c.fea
#extract_feats_clean('/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/Data_dir/REVERB_Real_dt/RealData_dt_for_1ch_far_room1_A/newfea/t6c020z.fea','out_t6c020z.fea',"/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/exp/torch_ENV_CLN_CNN_with_Net_larg_kernel","dnn_nnet_64.model")
#data = numpy.ones((36,800))
#extract_feats_clean('t6c020d.fea', 'out_t6c020d.fea',"/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/exp/torch_ENV_CLN_CNN_with_Net_larg_kernel_without_batchnorm","dnn_nnet_64.model")
#extract_feats_clean(data,'out.fea',"/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/exp/torch_ENV_CLN_CNN_with_Net_larg_kernel","dnn_nnet_64.model")


##########Old_EnvC_wpe_gev_BF_Estimation
