#featdir=data-Input_training_data/train_clean_100_reverb_wpe
featdir=WSJ_Train/WSJ

utils/subset_data_dir_tr_cv.sh ${featdir} ${featdir}_tr90 ${featdir}_cv10

