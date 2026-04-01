function [signal_filtered, signal_empirical] = preprocess_empirical_signal(FMRI, TR, filter_low, filter_high, crop_trs)
% Detrend, bandpass-filter, and crop one empirical BOLD matrix.
% Author: Jakub Vohryzek
% Email: jakub.vohryzel@upf.edu
% Adapted and simplified from code by Yonatan Sanz Perl and Gustavo Deco.

fnq = 1 / (2 * TR);
Wn = [filter_low / fnq filter_high / fnq];
[bfilt, afilt] = butter(2, Wn);

signal_filtered = zeros(size(FMRI));
for seed = 1:size(FMRI, 1)
    node_signal = detrend(FMRI(seed, :) - mean(FMRI(seed, :)));
    signal_filtered(seed, :) = filtfilt(bfilt, afilt, node_signal);
end

if nargin < 5 || isempty(crop_trs) || crop_trs <= 0
    signal_empirical = signal_filtered;
    return;
end

if size(signal_filtered, 2) <= 2 * crop_trs
    error('post_filter_crop_TRs=%d is too large for signal length %d.', crop_trs, size(signal_filtered, 2));
end

signal_empirical = signal_filtered(:, crop_trs:end - crop_trs);
end
