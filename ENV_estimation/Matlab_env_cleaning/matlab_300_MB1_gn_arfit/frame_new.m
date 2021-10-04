function [xtr,add_samp] =frame_new(x,FRAME,R)

% description : xtr=frame(x,FRAME,R)
% structuration of signal x to the frames with length FRAME and overlap R

NB_FR=ceil((length(x)-FRAME)/(FRAME-R)+1);
req_len = FRAME + (NB_FR-1)*(FRAME-R);

[l,c]=size(x);
if(l>c)
x=x';
end
add_samp = req_len-length(x);
x = [x ditherit(zeros(1,req_len-length(x)),1,'bit')];


if (NB_FR ~= 0)
    xtr =  enframe(x,FRAME,FRAME-R);
    xtr = xtr';
else disp(' can not create frames')
end


