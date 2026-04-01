function [GEC, FC_corr, FCsim, details] = fit_hopf_model_nonlinear(preprocessed, SC, options)
% Fit nonlinear Hopf effective connectivity from one subject.
% Author: Jakub Vohryzek
% Email: jakub.vohryzel@upf.edu
% Adapted and simplified from code by Yonatan Sanz Perl and Gustavo Deco.
%
% Inputs:
% preprocessed: struct with empirical targets and regional frequencies
% SC: N-by-N structural connectivity matrix
% options.allow_negative_gec:
%   false -> clamp negative fitted edges to zero
%   true  -> allow signed fitted edges

if nargin < 3 || isempty(options)
    options = struct();
end
if ~isfield(preprocessed, 'TR') || isempty(preprocessed.TR)
    error('preprocessed.TR is required.');
end

options = apply_model_defaults(options, preprocessed.TR);

SC = double(SC);
signal_empirical = double(preprocessed.signal_empirical);
regional_frequencies = double(preprocessed.regional_frequencies(:));
FCemp = double(preprocessed.FCemp);
FClag_emp = double(preprocessed.FClag_emp);
T = preprocessed.n_timepoints;
TR = preprocessed.TR;

[N, ~] = size(signal_empirical);
if size(SC, 1) ~= N
    error('SC size must match the number of rows in the preprocessed signal.');
end
if numel(regional_frequencies) ~= N
    error('Regional frequencies must have one value per node.');
end

SC = 0.2 .* SC ./ max(SC(:));
mask_update = SC ~= 0;
mask_tril = tril(true(N), -1);

GEC = SC;
olderror = options.initial_error;
errorFC = zeros(1, options.max_iterations);
errorFClag = zeros(1, options.max_iterations);
corrFC = zeros(1, options.max_iterations);
corrFClag = zeros(1, options.max_iterations);

for iter = 1:options.max_iterations
    if options.verbose && mod(iter, options.stop_check_interval) == 0
        fprintf('iter = %d\n', iter);
    end

    sim_TS = fcn_Hopf_simulate_BOLD_from_GEC(GEC, regional_frequencies, options.sigma, T, TR, options);
    FCsim = corrcoef(sim_TS');
    FClagSim = compute_lagged_fc_matrix(sim_TS, options.Tau);

    errorFC(iter) = mean(mean((FCemp - FCsim) .^ 2));
    errorFClag(iter) = mean(mean((FClag_emp - FClagSim) .^ 2));
    corrFC(iter) = corr(FCsim(mask_tril), FCemp(mask_tril));
    corrFClag(iter) = corr(FClagSim(mask_tril), FClag_emp(mask_tril));

    if mod(iter, options.stop_check_interval) == 0
        errornow = errorFC(iter) + errorFClag(iter);
        relative_improvement = (olderror - errornow) / max(errornow, eps);
        if relative_improvement < options.stop_improvement || olderror < errornow
            errorFC = errorFC(1:iter);
            errorFClag = errorFClag(1:iter);
            corrFC = corrFC(1:iter);
            corrFClag = corrFClag(1:iter);
            break;
        end
        olderror = errornow;
    end

    for i = 1:N
        for j = 1:N
            if mask_update(i, j)
                GEC(i, j) = GEC(i, j) ...
                    + options.learningRateFromFC * (FCemp(i, j) - FCsim(i, j)) ...
                    + options.learningRateFromFClag * (FClag_emp(i, j) - FClagSim(i, j));

                if ~options.allow_negative_gec && GEC(i, j) < 0
                    GEC(i, j) = 0;
                end
            end
        end
    end

    scale_factor = max(GEC(:));
    if scale_factor > 0
        GEC = GEC / scale_factor * options.maxC;
    end
end

FC_corr = corr(FCsim(mask_tril), FCemp(mask_tril));

details = struct();
details.mode_label = mode_label(options.allow_negative_gec);
details.regional_frequencies = regional_frequencies(:);
details.frequency_grid = preprocessed.frequency_grid(:);
details.fit_history = struct( ...
    'errorFC', errorFC, ...
    'errorFClag', errorFClag, ...
    'corrFC', corrFC, ...
    'corrFClag', corrFClag);
details.final_metrics = struct( ...
    'errorFC', errorFC(end), ...
    'errorFClag', errorFClag(end), ...
    'corrFC', corrFC(end), ...
    'corrFClag', corrFClag(end));
details.model_options = options;
end

function options = apply_model_defaults(options, TR)
defaults = struct();
defaults.Tau = 1;
defaults.sigma = 0.01;
defaults.a = -0.02;
defaults.learningRateFromFC = 0.0002;
defaults.learningRateFromFClag = 0.00004;
defaults.maxC = 0.1;
defaults.max_iterations = 5000;
defaults.stop_check_interval = 100;
defaults.stop_improvement = 0.001;
defaults.initial_error = 100000;
defaults.global_coupling = 1;
defaults.dt = 0.1 * TR / 2;
defaults.warmup_time = 3000;
defaults.allow_negative_gec = false;
defaults.verbose = true;

option_fields = fieldnames(defaults);
for idx = 1:numel(option_fields)
    name = option_fields{idx};
    if ~isfield(options, name) || isempty(options.(name))
        options.(name) = defaults.(name);
    end
end
end

function label = mode_label(allow_negative_gec)
if allow_negative_gec
    label = 'signed_gec';
else
    label = 'nonnegative_gec';
end
end
