function feats=feats_low_scale_low_rate(samples,sr,num_ceps,flag_delta,energy,t_bandWidths,f_bandWidths)

    if nargin < 1;  error('In sufficient parameters');end
    if nargin < 2 ; sr = 8000; end
    if nargin < 3 ; num_ceps=14; end
    if nargin < 4;  flag_delta = 0; end
    if nargin < 5;  energy = 1; end
    if nargin < 7
	    %% generate modulation filters
	    %temporal modulations
	    %0.5 to 12 Hz
	    t_bandWidths={[0.5,12]};
	    f_bandWidths={[0,1]};
    end

    specStreams=modulationFilt(samples, sr, t_bandWidths, f_bandWidths);
    
    feats=[];
    dim=size(specStreams);
    for i=1:dim(1)
        for j=1:dim(2)
            feats =getCepstra(specStreams{i,j},num_ceps,energy,flag_delta);
            %feats{i,j}=delta_3(specStreams{i,j});
        end
    end
    
end

function feats=getCepstra(postspectrum,num_ceps,energy,flag_delta)
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
