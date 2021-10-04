function feats = conv_all_strf_mod_ceps(x,ASRNeuron);
% Function to convolve the given input crbe with all the strf's given by
% Nima in ASRNeuron file.

N_fr = size(x,2);
y = zeros(502,N_fr); % 502 input neurons
nceps = 40;
scales =[];
rates = [];
preds = [];
for neur = 1 : 502
    strf = ASRNeuron(neur).strf154;
    scales = [scales ASRNeuron(neur).scale_154];
    rates = [rates ASRNeuron(neur).rate_154];
    preds = [preds ASRNeuron(neur).predxc_154];
    stff_len = size(strf,2);
    [m,n] = find(strf == max(max((strf))));         % Determine the latency
    strf_lag = min(m);                       % Estimated Group delay of the strf 
    stim = [fliplr(x(:,1:(stff_len-strf_lag))) x fliplr(x(:,end-strf_lag+2:end))]; % padded strf
    
    temp =[];
    for cnt2=1:size(stim,1)
        temp(cnt2,:)=conv(stim(cnt2,:),strf(cnt2,:));
    end
    y(neur,:) = mean(temp(:,1:N_fr),1);      % Final Neural response   
end

% Sorting the Neurons for plosives
[val_r,ind_r] = sort(rates,'descend');       % For Getting the high rate guys 

trap = 10; 		                 % 10 FRAME context duration
mirr_len = trap;		
fdlpwin = 21;           		 % Modulation spectrum Computation Window.
fdlpolap = 20;
num_ceps_time =14;

% ---------------------------------------------------------------------
%                  Cepstral Features            
% ---------------------------------------------------------------------
ceps_time = cell(1,nceps);
del = cell(1,nceps);
feats = [];

for J = 1 :nceps
    neur = ind_r(J);
    ENV_mod_new = [fliplr(y(neur,1:mirr_len))  y(neur,:) fliplr(y(neur,end-mirr_len+1:end))]; %#ok<AGROW>
    ENV_mod_fr = frame_new(ENV_mod_new,fdlpwin,fdlpolap);
    ceps_time{J} = spec2cep_log(ENV_mod_fr,num_ceps_time);
    feats = [feats ceps_time{J}']; %#ok<AGROW>	
end

feats = feats'; % Inorder to have the notion of feature vectors 
