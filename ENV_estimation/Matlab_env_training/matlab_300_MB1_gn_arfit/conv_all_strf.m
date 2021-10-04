function y = conv_all_strf(x,ASRNeuron)
% Function to convolve the given input crbe with all the strf's given by
% Nima in ASRNeuron file.

N_fr = size(x,2);
nbands = size(x,1);
rt = cat(2,ASRNeuron(1:end).rate_154);sc = cat(2,ASRNeuron(1:end).scale_154);pr = cat(2,ASRNeuron(1:end).predxc_154);


hi_ra = find(pr > 0.1 & rt > 22.65);
lo_ra = find(pr > 0.1 & rt < 17.75);
hi_sc = find(pr > 0.1 & rt > 17 & rt < 23.9 & sc > 1.17 & sc < 1.25);
lo_sc = find(pr > 0.1 & rt > 17 & rt < 23.9 & sc > 0.85 & sc < 0.93);
%all_st = find(pr > 0.2887  & rt > 17 & rt < 23.9 & sc > 0.85 & sc < 1.25);
all_st = find(pr > 0);

%gud_set = find(cat(2,ASRNeuron(1:end).predxc_154) > 0.1 & cat(2,ASRNeuron(1:end).scale_154)<1 & cat(2,ASRNeuron(1:end).rate_154)>20) ; % High rate Low scale 
%gud_set  = find(cat(2,ASRNeuron(1:end).predxc_154) > 0.1 & cat(2,ASRNeuron(1:end).scale_154)>1.1 & cat(2,ASRNeuron(1:end).rate_154)<19.5); % rev exp Low rate High Scale 
z = zeros(size(x));
%gud_set = find(cat(2,ASRNeuron(1:end).predxc_154) > 0.1);
gud_set = all_st;

y = zeros(length(gud_set),N_fr); % 502 input neurons
for ii = 1:length(gud_set)
    neur = gud_set(ii); 
    strf = ASRNeuron(neur).strf154;
    [m,n] = find(strf == max(max((strf))));         % Determine the latency
    strflag = min(n);                              % Estimated Group delay of the strf 
    strflen = size(strf,2);                              % Estimated Group delay of the strf 
    stim = [fliplr(x(:,1:(strflen-1))) x fliplr(x(:,end-strflen+2:end))]; % padded strf
    
    temp =[];
    for cnt2=1:nbands
         temp(cnt2,:)=conv(stim(cnt2,:),strf(cnt2,:));
    end
    %z = temp;
    oup = mean(temp(:,strflen+strflag-1:strflen+strflag-2+N_fr));      % Final Neural response   
    oup = oup-mean(oup);
    y(ii,:) = oup/std(oup);
end

%y = spec2cep_log(y,length(gud_set));
