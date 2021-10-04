function tfStreams = aud2modulationFilt(audSpectrum,t_bandWidths, f_bandWidths)
   
    %toolbox
    tWindow=size(audSpectrum,2);
 
    t={};
    f={};
    for i=1:length(t_bandWidths)
        t{i}=generateMBPFilters(t_bandWidths{i}(1),t_bandWidths{i}(2),'t',[0:50/tWindow:50]); 
    end
    
    
    channels=size(audSpectrum,1);
    freqSR=floor(channels/5.3); %the sampling frequency on frequency axis
    
    %spectral modulations
    for i=1:length(f_bandWidths)
        f{i}=generateMBPFilters(f_bandWidths{i}(1),f_bandWidths{i}(2),'f',[0:freqSR/channels:freqSR]);
    end    
    
%% do modulation bandpass filtering of the spectrum

    %time modulation
    fStreams=freqModFilter(audSpectrum,f);
    tfStreams={};
    
    %frequency modulation filtering on time modulation filtered spectra
    for i=1:length(fStreams)
        temp=timeModFilter(fStreams{i},t,tWindow);
        for j=1:length(temp)
            tfStreams{i,j}=temp{j};
        end 
    end
   
    
end


function tStreams=timeModFilter(audSpectrum,tFilters,tWindow)
    
    
    
    temp={};
    for i=1:length(tFilters)
        tStreams{i}=zeros(size(audSpectrum));
    end
    
    for k=1:length(tFilters)
        tFilters{k}=tFilters{k}(:);
    end
    
    %time modulation
    for i=1:size(audSpectrum,1) %temporal modulation filtering in each sub-band
        sbAudSpecFramed=enframe(audSpectrum(i,:),tWindow,tWindow-2); %2 frame overlap to later smooth the boundary portions
        temp={};
        for k=1:length(tFilters)
            temp{k}=zeros(size(sbAudSpecFramed));
        end
        
        %frame and filter
        for j=1:size(sbAudSpecFramed,1) %since enframe returns each frame in a row
            for k=1:length(tFilters)
                temp{k}(j,:)=idct(dct(sbAudSpecFramed(j,:)').*tFilters{k}(1:length(sbAudSpecFramed(j,:))));
            end
        end
        
        
        %interpolate the boundaries
        nr=size(temp{1});
        fl=nr(2);
        nr=nr(1);
        
        for j=1:nr-1
            for k=1:length(tFilters)
                temp{k}(j,end-2:end)=(temp{k}(j,end-2:end)+temp{k}(j+1,1:2))./2;
                startInd=(fl*(j-1))+1;
                tStreams{k}(i,startInd:startInd+fl)=temp{k}(j,:);
            end
        end
        
        startInd=(fl*(nr-1))+1;
        if nr==1
            for k=1:length(tFilters)
                tStreams{k}(i,startInd:startInd+fl-1)=temp{k}(end,1:end);
            end
        else
            for k=1:length(tFilters)
                tStreams{k}(i,startInd:startInd+fl-1-2)=temp{k}(end,3:end);
            end
        end
        
    end
    
end

function fStreams=freqModFilter(audSpectrum,fFilters)

    logAudSpec=audSpectrum;
    nb=size(logAudSpec,1);
    
    for k=1:length(fFilters)
        fFilters{k}=fFilters{k}(:);
        fStreams{k}=zeros(size(logAudSpec));
    
        for j=1:size(logAudSpec,2) %for each time instant
            fStreams{k}(:,j)=idct(dct(logAudSpec(:,j)).*fFilters{k}(1:nb));
        end
    end
end


function postspectrum=getAudSpec(samples,sr,ncrb,paras)
    
    if nargin < 3
        %set no of critical band filters to 32
        ncrb=32;
    end
    
    
    % first compute power spectrum
    pspectrum = powspec(samples, sr);

    % next group to critical bands
    aspectrum = audspec(pspectrum, sr,ncrb); 
    nbands = size(aspectrum,1);

    % do final auditory compressions
    postspectrum = postaud(aspectrum, sr);

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
    pspectrum = wav2aud(samples,paras)';
    s=size(pspectrum);
    aspectrum=pspectrum;
    postspectrum = aspectrum .^ (.33);
%     postspectrum = log(aspectrum);
    %calculate the number of frames calculated by feacalc
    flen=0.032*sr;                      % frame length corresponding to 25ms
    fhop=0.010*sr;                      % frame overlap corresponding to 10ms
    % What's the number of analysis frames that feacalc consider?
    fnum = floor((length(samples)-flen)/fhop)+1;
    postspectrum = postspectrum(:,1:fnum);
    
end
