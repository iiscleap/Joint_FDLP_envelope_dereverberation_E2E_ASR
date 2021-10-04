function [new_wts,new_idx] = bandlimit_wtsremoval(wts,idx,flen,sr,minfreq, maxfreq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to perform bandlimiting by removing some elements of wts and idx
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cnt=1;
for I=1:length(wts)
    tmpx=zeros(flen,1);
    tmpx(idx(I,1):idx(I,2))=wts{I};
    
    [y,i]=max(tmpx);
    
    % freq of peak
    f=i*(sr/2)/flen;
    
    % is it inside range
    if (f >= minfreq && f<=maxfreq)
        new_idx(cnt,:)=idx(I,:);
        new_wts{cnt}=wts{I};
        cnt=cnt+1;
    end
end
new_wts=new_wts';
