featdir=$1

for x in A ;do
utils/subset_data_dir_tr_cv.sh ${featdir}_${x} ${featdir}_${x}_tr90 ${featdir}_${x}_cv10
done
