function sim_TS = fcn_Hopf_simulate_BOLD_from_GEC(GEC, regionalFrequencies, sigma, T, TR, options)
% Simulate BOLD-like x-components from the nonlinear Hopf model.
% Author: Jakub Vohryzek
% Email: jakub.vohryzel@upf.edu
% Adapted and simplified from code by Yonatan Sanz Perl and Gustavo Deco.

if nargin < 6 || isempty(options)
    options = struct();
end
if ~isfield(options, 'a') || isempty(options.a)
    options.a = -0.02;
end
if ~isfield(options, 'dt') || isempty(options.dt)
    options.dt = 0.1 * TR / 2;
end
if ~isfield(options, 'warmup_time') || isempty(options.warmup_time)
    options.warmup_time = 3000;
end
if ~isfield(options, 'global_coupling') || isempty(options.global_coupling)
    options.global_coupling = 1;
end

N = size(GEC, 1);
wC = options.global_coupling * GEC;
sumC = repmat(sum(wC, 2), 1, 2);
dt = options.dt;
noise_scale = sqrt(dt) * sigma;

omega = repmat(2 * pi * regionalFrequencies(:), 1, 2);
omega(:, 1) = -omega(:, 1);

z = 0.1 * ones(N, 2);
steps_per_TR = max(1, round(TR / dt));
warmup_steps = round(options.warmup_time / dt);

for step = 1:warmup_steps
    z = hopf_nl_step(z, wC, sumC, omega, noise_scale, options);
end

sim_TS = zeros(N, T);
for sample_idx = 1:T
    for step = 1:steps_per_TR
        z = hopf_nl_step(z, wC, sumC, omega, noise_scale, options);
    end
    sim_TS(:, sample_idx) = z(:, 1);
end
end
