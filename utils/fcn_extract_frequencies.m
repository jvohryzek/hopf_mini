function [regional_frequencies, details] = fcn_extract_frequencies(signal_empirical, TR, frequency_smoothing_sigma)
% Extract one regional peak frequency per node from one post-filter, post-crop BOLD matrix.
% Author: Jakub Vohryzek
% Email: jakub.vohryzel@upf.edu
% Adapted and simplified from code by Yonatan Sanz Perl and Gustavo Deco.

if nargin < 3 || isempty(frequency_smoothing_sigma)
    frequency_smoothing_sigma = 0.01;
end

[NPARCELLS, TT] = size(signal_empirical);

Ts = TT * TR;
freq = (0:TT / 2 - 1) / Ts;
PowSpect = zeros(length(freq), NPARCELLS);

for seed = 1:NPARCELLS
    pw = abs(fft(signal_empirical(seed, :)));
    PowSpect(:, seed) = pw(1:floor(TT / 2)) .^ 2 / (TT / TR);
end

Power_Areas = PowSpect;
for seed = 1:NPARCELLS
    Power_Areas(:, seed) = gaussfilt(freq, Power_Areas(:, seed)', frequency_smoothing_sigma);
end

[~, index] = max(Power_Areas);
regional_frequencies = freq(index);

nonzero_mask = regional_frequencies ~= 0;
if any(nonzero_mask)
    regional_frequencies(~nonzero_mask) = mean(regional_frequencies(nonzero_mask));
end

details = struct();
details.frequency_grid = freq(:);
details.power_spectra = PowSpect;
details.signal_empirical = signal_empirical;
end
