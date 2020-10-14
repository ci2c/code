function smo_wav = wav_smooth(wav);
% function SMO_WAV = wav_smooth(WAV);
%
% Remove the small wavelet coefficients using the universal
% soft-thresholding procedure
%
% INPUTS
% ------
%    WAV        : Wavelet structure to smooth
%
% OUTPUT
% ------
%    SMO_WAV    : Soft-thresholded wavelet coefficients
%
% Pierre Besson, v. 0.1 June 11, 2008

% Test validity of the command line
if nargin ~= 1 & nagout ~= 1
    help smo_wav
    error('Incorrect use of the function')
end

% Copy the wavelet structure
smo_wav = wav;

% Smooth the data
for i = 1 : wav.depth
    Reshape = reshape(wav.wav{i}, size(wav.wav{i}, 1) * size(wav.wav{i}, 2), 1);
    Thr = median(abs(Reshape)) * sqrt(2 * log10(length(Reshape))) / 0.6745;
    smo_wav.wav{i}(abs(wav.wav{i}) < Thr) = 0;
    smo_wav.wav{i}(abs(wav.wav{i}) >= Thr) = wav.wav{i}(abs(wav.wav{i}) >= Thr) - sign(wav.wav{i}(abs(wav.wav{i}) >= Thr)) .* Thr;
end
    