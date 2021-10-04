% LOADLOAD load colormap, filterbank and parameters
%	loadload;
%	
%	LOADLOAD sets up the toolbox environment
%	-- loads specific colormap [a1map] for complex number display;
%	-- loads cochlear filterbank coefficients [COCHBA] and sets this
%	   matrix to be a global variable;
%	-- initiates cochlear model parameter [paras];
%	-- sets default rate vector [rv], scale vectors [sv];
%	See also: WAV2AUD, AUD2WAV, AUD2COR, COR2AUD

% Auther: Powen Ru (powen@isr.umd.edu), NSL, UMD
% v1.00: 01-Jun-97
% v1.01: 30-Jul-97
clear COCHBA TICKLABEL VER a1map;
global COCHBA TICKLABEL VER a1map;

% load complex colormap
load /homes/hlthome01.4/sganapa/speech/codes/sad_rats_13/cortical/modulation_bandpass/a1map_a.mat 

% load cochlear filter coefficients
load /homes/hlthome01.4/sganapa/speech/codes/sad_rats_13/cortical/modulation_bandpass/aud24.mat

% cochlear parameter
if ~exist('paras', 'var'), paras = [8 8 -2 -1]; end;

% rate, scale vector
if ~exist('rv', 'var'), rv = 2 .^ (2:5); end;
if ~exist('sv', 'var'), sv = 2 .^ (-2:3); end;

% gap between v4 and v5
VER = version;
R1 = findstr('.', VER);
if isempty(R1),
	VER = str2num(VER);
else,
	VER = str2num(VER(1:R1(1)-1));
end;

if VER < 5,
	TICKLABEL = 'ticklabels';
else,
	TICKLABEL = 'ticklabel';
end;
