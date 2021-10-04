function H=generateMBPFilters(lowerCutOff,higherCutOff,modType,range)
    
    if strcmp(modType,'t')~=0
        if nargin<4
            range=[0:0.01:50]'; %assuming 100 frame window is applied in time
        end
        
    elseif strcmp(modType,'f')~=0
        if nargin<4
            range=[0:1/32:3]'; %since there are 32 bands 
        end
    else
        sprintf('Unknown mod type')
        1/0
    end
    range=range(:);
    
    
    m=zeros(length(range),1);
    
    m(find(range<lowerCutOff))=1/lowerCutOff;
    m(find(lowerCutOff<=range & range<=higherCutOff))=1./range(lowerCutOff<=range & range<=higherCutOff);
    m(find(range>higherCutOff))=1/higherCutOff;
    
    
    G=m.*range;
    H=(G.^2).*(exp(1-G.^2));
    
    if lowerCutOff == 0
       H(1)=1;
    end
end