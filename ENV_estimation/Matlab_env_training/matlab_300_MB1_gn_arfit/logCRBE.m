function logCRBEs=logCRBE(samples,sr,nbands)

% first compute power spectrum
pspectrum = powspec(samples, sr);

% next group to critical bands
aspectrum = audspec(pspectrum, sr,nbands);
nbands = size(aspectrum,1);
logCRBEs=log10(aspectrum); 
% do final auditory compressions
%postspectrum = postaud(aspectrum, sr);

end