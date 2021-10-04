function feats=process_aud_spec(infile,outfile,energy_file,sr,num_ceps,flag_delta,energy,t_bandWidths,f_bandWidths)
    audSpectrum = VFloatBZ2MatrixRead([infile '.bz2']);
    vad = audSpectrum(:,end);  % Last frame contains energy
    VFloatMatrixWrite( energy_file, vad);
    audSpectrum = audSpectrum(:,1:128)';
    if nargin < 3;  error('In sufficient parameters');end
    if nargin < 4 ; sr = 8000; end
    if nargin < 5 ; num_ceps=14; end
    if nargin < 6;  flag_delta = 0; end
    if nargin < 7;  energy = 1; end
    if nargin < 8
	    %% generate modulation filters
	    %temporal modulations
	    %0.5 to 12 Hz
%             t_bandWidths={[0.5,12]};%,[10,22]};
%             f_bandWidths={[0,1]};%,[0.5,2]};
%                 t_bandWidths={[0.25,12]};
%                  f_bandWidths={[0.01,1]};
            t_bandWidths={[10,22]};
            f_bandWidths={[0.5,2]};
    end
    band_start = 44; band_end = 123 ; % 80 bands with high energy concentration 
    aspectrum=aud2modulationFilt(audSpectrum(band_start:band_end,:), t_bandWidths, f_bandWidths);
        %Downsampling the spectrograms  
    
    %s=size(specStreams{1,1});    
    %aspectrum=zeros(s(1)/4,s(2));
    %for j=1:s(2)
    %    aspectrum(:,j)=decimate(specStreams{1,1}(:,j),4); %to produce 32 band output
    %end
    
    feats =getCepstra_log(aspectrum{1,1},num_ceps,energy,flag_delta);
%     feats2 =getCepstra_log(aspectrum{1,2}(band_start:band_end,:),num_ceps,energy,flag_delta);
%     feats3 =getCepstra_log(aspectrum{2,1}(band_start:band_end,:),num_ceps,energy,flag_delta);
%     feats4 =getCepstra_log(aspectrum{2,2},num_ceps,energy,flag_delta);
%     feats = [feats1 ; feats2; feats3 ];
    %feats{i,j}=delta_3(specStreams{i,j});
    VFloatMatrixWrite( outfile, feats');
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
