function y_smooth = gaussfilt(x, y, sigma)
% Smooth a 1D signal with a Gaussian kernel on grid x.
% Author: Jakub Vohryzek
% Email: jakub.vohryzel@upf.edu

x = x(:);
y = y(:);

if numel(x) ~= numel(y)
    error('x and y must have the same number of elements.');
end
if sigma <= 0 || numel(y) <= 1
    y_smooth = y;
    return;
end

dx = median(diff(x));
if ~isfinite(dx) || dx <= 0
    error('x must be a strictly increasing finite grid.');
end

kernel_half_width = max(1, ceil(4 * sigma / dx));
kernel_offsets = (-kernel_half_width:kernel_half_width)' * dx;
kernel = exp(-0.5 * (kernel_offsets / sigma) .^ 2);
kernel = kernel / sum(kernel);

y_smooth = conv(y, kernel, 'same');
normalization = conv(ones(size(y)), kernel, 'same');
y_smooth = y_smooth ./ normalization;
end
