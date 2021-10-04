function y = conv_all_strf(x,ASRNeuron)
% Function to convolve the given input crbe with all the strf's given by
% Nima in ASRNeuron file.

N_fr = size(x,2);
nbands = size(x,1);
rate_high_thr = 21.6;
rate_lo_thr = 16.1;
scale_high_thr = 1.258;
scale_lo_thr = 0.7125;
%gud_set = find(cat(2,ASRNeuron(1:end).predxc_154) > 0.1 & cat(2,ASRNeuron(1:end).scale_154)<1 & cat(2,ASRNeuron(1:end).rate_154)>20) ; % High rate Low scale 
%gud_set  = find(cat(2,ASRNeuron(1:end).predxc_154) > 0.1 & cat(2,ASRNeuron(1:end).scale_154)>1.1 & cat(2,ASRNeuron(1:end).rate_154)<19.5); % rev exp Low rate High Scale 
z = zeros(size(x));
gud_set = find(cat(2,ASRNeuron(1:end).predxc_154) > 0.1);
%gud_set = 1:503;
y = zeros(length(gud_set),N_fr); % 502 input neurons
for ii = 1:length(gud_set)
    neur = gud_set(ii); 
    strf = ASRNeuron(neur).strf154;
    
    strf_len = size(strf,2);
                               
    stim = [fliplr(x(:,1:(strf_len-1))) x fliplr(x(:,end-strf_len+2:end))]; % padded strf
    
    temp =[];
    for cnt2=1:nbands
         strf_lag = find(strf(cnt2,:) == max(strf(cnt2,:)),1);                                 % Estimated Group delay of the strf 
%          strf_lag =8;
         oup =conv(stim(cnt2,:),strf(cnt2,:));
         temp(cnt2,:) = oup(strf_len+strf_lag-1:strf_len+strf_lag-2+N_fr);
    end
    %z = temp;
    y(ii,:) = mean(temp,1);      % Final Neural response   
end

y =  spec2cep_log(y,length(gud_set));


