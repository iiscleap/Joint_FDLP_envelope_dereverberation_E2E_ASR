import numpy
import scipy.io 
from fdlp_env_comp_100hz_factor_40 import fdlp_env_comp_100hz_factor_40
from read_HTK import HTKFeat_read, HTKFeat_write
from pdb import set_trace as bp  #################added break point 
#from Net_full_cnn_deep import Net
#from forward_pass_cepstra_LSTM import forward_pass
from forward_pass_cepstra import forward_pass
from write_HTK import write_htk
#from write_HTK_temp import write_htk


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
  data_original_no_cmvn = data_in.getall()
  data_original = (data_original_no_cmvn - data_original_no_cmvn.mean(axis=0)) / data_original_no_cmvn.std(axis=0)
  #bp()
  #data_original_int = fdlp_env_comp_100hz_factor_40(numpy.transpose(numpy.exp(data_original)),400, 36)
  #scipy.io.savemat('/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Env_wpe_gev_BF_estimation_python/clean_elp_estimation/c02c0202_int.mat', {'data_original_int':data_original_int})
  #bp()
  clean_data = forward_pass(data_original, exp, model_name, in_channel, inputFeatDim )
  #bp()
  clean_data = clean_data.astype("float32")
  #scipy.io.savemat('/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Env_wpe_gev_BF_estimation_python/clean_elp_estimation/c02c0202_int_clean.mat', {'clean_data':clean_data})
  #bp()
  print("########### cleaned the data ###########")
  write_htk( data_out , clean_data , 100000 , 8267 )
  print("########### write HTK ###########")
  



#c3cc020c.fea
#extract_feats_clean('/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/Data_dir/REVERB_Real_dt/RealData_dt_for_1ch_far_room1_A/newfea/t6c020z.fea','out_t6c020z.fea',"/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/EnvC_wpe_gev_BF_Estimation/exp/torch_ENV_CLN_CNN_with_Net_larg_kernel","dnn_nnet_64.model")
#data = numpy.ones((36,800))
#extract_feats_clean('/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Env_wpe_gev_BF_estimation_python/Input_raw_data/REVERB_Real_dt/RealData_dt_for_1ch_near_room1_A/newfea/t6c020h.fea', 'out_t6c020d.fea',"/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Matlab_RAW_features/exp/torch_ENV_CLN_CDNN_Net_3","dnn_nnet_64.model")
#extract_feats_clean('/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Env_wpe_gev_BF_estimation_python/Input_raw_data/REVERB_Real_dt/RealData_dt_for_1ch_near_room1_A/newfea/t6c020h.fea','out.fea',"/home/data2/multiChannel/ANURENJAN/REVERB/ENV_estimation/Matlab_RAW_features/exp/torch_ENV_CLN_CDNN_Net_LSTM","dnn_nnet_64.model")

##########Old_EnvC_wpe_gev_BF_Estimation
