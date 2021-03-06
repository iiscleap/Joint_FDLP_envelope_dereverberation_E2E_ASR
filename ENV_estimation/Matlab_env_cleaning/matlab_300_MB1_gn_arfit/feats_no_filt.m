function feats= feats_no_filt(samples,sr,num_ceps,flag_delta,energy,t_bandWidths,f_bandWidths)

    if nargin < 1;  error('In sufficient parameters');end
    if nargin < 2 ; sr = 8000; end
    if nargin < 3 ; num_ceps=7; end
    if nargin < 4;  flag_delta = 0; end
    if nargin < 5;  energy = 1; end
    if nargin < 7
	    %% generate modulation filters
	    %temporal modulations
	    %0.5 to 12 Hz
	    t_bandWidths={[0.25,15]};
	    f_bandWidths={[0.0,1.0]};
    end
    %pre-emphasis
    samples = samples - mean(samples);
    samples = samples - 0.97* [0 ; samples(1:end-1)];      
%     audSpectrum=getAudSpec_nsltool(samples,sr); %to extract from NSL
%     band_start = 38; band_end = 127 ; % 90 bands with high energy concentration
    audSpectrum=generate_spec_feats(samples,sr); %to extract from FDLP 
    aspectrum=aud2modulationFilt((audSpectrum).^(0.1), t_bandWidths,     f_bandWidths);
%     aspectrum=aud2modulationFilt(audSpectrum(band_start:band_end,:), t_bandWidths, f_bandWidths);
    feats =getCepstra_log(aspectrum{1,1},num_ceps,energy,flag_delta);

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

function postspectrum=getAudSpec_nsltool(samples,sr,ncrb,paras)
    
    if nargin < 3
        %set no of critical band filters to 32
        ncrb=32;
    end
    if nargin <4
        %set parameters for extraction of auditory spectrogram (chk readme
        %in NSL toolbox for details of parameters
        paras=[10,10,-2];
        if sr==16000
            paras(4)=0;
        elseif sr==8000
            paras(4)=-1;
        end
    end
    
    samples = unitseq(samples);
    loadload; %to load the parameters necessary for NSL toolbox. Very dangerous change if this function is to be used ion future
    postspectrum = wav2aud(samples,paras)';
    postspectrum = postspectrum .^ (.33);
    %calculate the number of frames calculated by feacalc
    flen=0.032*sr;                      % frame length corresponding to 32ms
    fhop=0.010*sr;                      % frame overlap corresponding to 10ms
    % What's the number of analysis frames that feacalc consider?
    fnum = floor((length(samples)-flen)/fhop)+1;
    postspectrum = postspectrum(:,1:fnum);
    
end

