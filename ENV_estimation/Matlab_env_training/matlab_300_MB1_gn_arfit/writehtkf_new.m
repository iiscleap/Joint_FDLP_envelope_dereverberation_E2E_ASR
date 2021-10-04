function writehtkf_new(name,MAT,sampPeriod,paramKind); 
% writehtkf(name,MAT,sampPeriod,paramKind); 
%
% Simple function to write an HTK file. 
% HTK deafult (BIG endian) on the output. 

[P,nSamples]=size(MAT);
sampSize = P*4;

%ff = fopen (name,'w','n');
ff = fopen(name,'w','b');  %default

% write header
fwrite (ff,nSamples,'int');
fwrite (ff,sampPeriod,'int');
fwrite (ff,sampSize,'short');
fwrite (ff,paramKind,'short');
% determine amount of data to read and read 
fwrite (ff, MAT , 'float');
fclose (ff);
