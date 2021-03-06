function find_avg_mod_spec(list)
% Find the Average Two Dimensional Modulation Spectrum for Various RATS
% Channels

[files,arb] = textread(list,'%s %s');
S = 1000 ;     
avg = zeros(33,12001); count = 0;
for ii = 1 : length(files)
    infile = files{ii};
    audSpectrum = VFloatBZ2MatrixRead([infile '.bz2']);
    engy = audSpectrum(:,129);
    good = find(engy > mean(engy));
    audSpectrum = audSpectrum(:,40:125)'; 
                              % Require Size of Spectrogram
    N = floor(size(audSpectrum,2)/S);
    
    for I =  1 : N
        spec_curr = audSpectrum ( :,(I-1)*S + 1 : I *S) ;
%         spec_curr = spec_curr - repmat(mean(spec_curr,1)',1,size(spec_curr,1))';
%         spec_curr = spec_curr - repmat(mean(spec_curr,2),1,size(spec_curr,2));
%         hammm = hamming(size(spec_curr,1))*hamming(size(spec_curr,2))';
%         ac = fftshift(fft2(spec_curr.*hammm,513,20001));
%         ab = (abs(ac(225:257,[4000:16000])));
        aaa = mean(spec_curr,1);
        aaa = aaa - mean(aaa);
        ab = abs(fftshift(fft(aaa,101)));
        avg = avg + ab;
%         avg = avg + spec_curr;
        count = count + 1 ;
        
    end
end
avg = avg / N ;
% avg = mean(avg,1);
% avg = avg - mean(avg);

% figure (1); 
% hold on ; plot([-50:50],avg,'m'); 

% 
% 
% 
figure; imagesc([-6000:6000]/200,[0:32]/20,(avg));
end

function feats=getCepstra_log(postspectrum,num_ceps,energy,flag_delta)
    if energy == 0
        cepstra = spec2cep_log(postspectrum,num_ceps+1);
        cepstra = cepstra(2:end,:);
    else 
        cepstra = spec2cep_log(postspectrum,num_ceps);
    end

    cepstra = lifter(cepstra, 0.6);

    if flag_delta == 1
        feats=delta_3(cepstra);
    else
        feats = cepstra;
    end
    
end

function feats=delta_3(feats)

        % Append deltas and double-deltas onto the cepstral vectors
        del = deltas(feats);

        % Double deltas are deltas applied twice with a shorter window
        ddel = deltas(deltas(feats,5),5);


        % Triple deltas are deltas applied thrice with a shorter window
        dddel = deltas( deltas(deltas(feats,5),5),5) ;

        % Composite, 52-element feature vector, just like we use for speech recognition
        feats = [feats;del;ddel;dddel];

end
