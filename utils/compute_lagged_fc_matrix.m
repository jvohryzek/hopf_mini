function FClag = compute_lagged_fc_matrix(signal_matrix, Tau)
% Compute the variance-normalized lagged FC matrix at lag Tau.
% Author: Jakub Vohryzek
% Email: jakub.vohryzel@upf.edu
% Adapted and simplified from code by Yonatan Sanz Perl and Gustavo Deco.

COVemp = cov(signal_matrix');
tst = signal_matrix';
N = size(signal_matrix, 1);
sigratio = zeros(N, N);
FClag = zeros(N, N);

for i = 1:N
    for j = 1:N
        denom_i = max(COVemp(i, i), eps);
        denom_j = max(COVemp(j, j), eps);
        sigratio(i, j) = 1 / sqrt(denom_i) / sqrt(denom_j);
        FClag(i, j) = lagged_covariance(tst(:, i), tst(:, j), Tau) / size(tst, 1);
    end
end

FClag = FClag .* sigratio;
end

function value = lagged_covariance(x, y, Tau)
x = x(:);
y = y(:);

if numel(x) ~= numel(y)
    error('Signals must have the same length.');
end
if abs(Tau) >= numel(x)
    value = 0;
    return;
end

if Tau >= 0
    value = sum(x(1 + Tau:end) .* y(1:end - Tau));
else
    lag = abs(Tau);
    value = sum(x(1:end - lag) .* y(1 + lag:end));
end
end
