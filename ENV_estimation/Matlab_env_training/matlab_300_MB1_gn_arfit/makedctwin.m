function y = makedctwin(x,flen,sr)
% Function to make smooth DCT windows so as to bandpass telephone filter.

lo_freq_stop = round((200/(sr/2)) *flen)  ; 
lo_freq_pass = round((250/(sr/2)) *flen)  ; 

hi_freq_pass = round((3300/(sr/2)) *flen)  ;
hi_freq_stop = round((3400/(sr/2)) *flen)  ;

y = x(lo_freq_stop:hi_freq_stop);

lo_len = lo_freq_pass - lo_freq_stop+1;
hi_len = hi_freq_stop - hi_freq_pass +1;

beginwin = gausswin(2*lo_len + 1);
y(1:lo_len) = x(1:lo_len).*beginwin(1:lo_len);

endwin = gausswin(2*hi_len + 1);
y(end-hi_len+1:end) = x(end-hi_len+1:end).*endwin(end-hi_len+1:end);
