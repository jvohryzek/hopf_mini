%% MINIMAL SINGLE-SUBJECT NONLINEAR HOPF WORKFLOW
%
%
% Expected input format:
%   FMRI: N-by-T BOLD matrix with regions in rows and timepoints in columns
%   subject_id: optional scalar or string label
%   SC: N-by-N structural connectivity matrix using the same region order
%
% Author: Jakub Vohryzek
% Email: jakub.vohryzel@upf.edu
% Based on code by Yonatan Sanz Perl and Gustavo Deco.

clearvars;

script_dir = fileparts(mfilename('fullpath'));
addpath(script_dir);
addpath(fullfile(script_dir, 'utils'));

config = struct();

% Local single-subject inputs for the mini workspace.
% Choose one of the example files in data/, for example:
% - subject_single_100408.mat

config.subject_data_file = fullfile(script_dir, 'data', 'subject_single_100408.mat');
config.structural_connectivity_file = fullfile(script_dir, 'data', 'SC_single.mat');
config.subject_index = 1;

% fMRI acquisition and frequency-extraction settings.
config.TR = 0.72;
config.filter_low = 0.008;
config.filter_high = 0.09;
config.frequency_smoothing_sigma = 0.01;
config.post_filter_crop_TRs = 10;

% Save compact outputs inside this workspace.
config.output_dir = fullfile(script_dir, 'results');
config.make_plots = true;

% Explicit GEC-sign toggle:
% false -> standard non-negative GEC fit
% true  -> signed GEC fit
allow_negative_gec = true;

% Nonlinear Hopf model settings.
config.model = struct();
config.model.Tau = 1;
config.model.sigma = 0.01;
config.model.a = -0.02;
config.model.learningRateFromFC = 0.0002;
config.model.learningRateFromFClag = 0.00004;
config.model.maxC = 0.1;
config.model.max_iterations = 5000;
config.model.stop_check_interval = 100;
config.model.stop_improvement = 0.001;
config.model.initial_error = 100000;
config.model.global_coupling = 1;
config.model.dt = 0.1 * config.TR / 2;
config.model.warmup_time = 3000;
config.model.allow_negative_gec = allow_negative_gec;
config.model.verbose = true;

%% Load one subject and one SC matrix
subject_blob = load(config.subject_data_file);
FMRI = double(subject_blob.FMRI);

if isfield(subject_blob, 'subject_id')
    subject_id = subject_blob.subject_id;
else
    subject_id = config.subject_index;
end

sc_blob = load(config.structural_connectivity_file);
SC = double(sc_blob.SC);

%% Preprocess empirical inputs
[signal_filtered, signal_empirical] = preprocess_empirical_signal( ...
    FMRI, ...
    config.TR, ...
    config.filter_low, ...
    config.filter_high, ...
    config.post_filter_crop_TRs);

[regional_frequencies, frequency_details] = fcn_extract_frequencies( ...
    signal_empirical, ...
    config.TR, ...
    config.frequency_smoothing_sigma);

FCemp = corrcoef(signal_empirical');
FClag_emp = compute_lagged_fc_matrix(signal_empirical, config.model.Tau);

preprocessed = struct();
preprocessed.subject_id = subject_id;
preprocessed.TR = config.TR;
preprocessed.n_timepoints = size(signal_empirical, 2);
preprocessed.signal_filtered = signal_filtered;
preprocessed.signal_empirical = signal_empirical;
preprocessed.FCemp = FCemp;
preprocessed.FClag_emp = FClag_emp;
preprocessed.regional_frequencies = regional_frequencies(:);
preprocessed.frequency_grid = frequency_details.frequency_grid(:);

%% Fit one nonlinear Hopf model
[GEC, FC_corr, FCsim, fit_details] = fit_hopf_model_nonlinear(preprocessed, SC, config.model);

%% Save compact results
mode_label = fit_details.mode_label;
subject_label = subject_id_to_label(subject_id, config.subject_index);
output_file = fullfile(config.output_dir, ['hopf_mini_' subject_label '_' mode_label '.mat']);

if exist(config.output_dir, 'dir') ~= 7
    mkdir(config.output_dir);
end

results = struct();
results.subject_id = subject_id;
results.subject_index = config.subject_index;
results.allow_negative_gec = config.model.allow_negative_gec;
results.mode_label = mode_label;
results.input_files = struct( ...
    'subject_data_file', config.subject_data_file, ...
    'structural_connectivity_file', config.structural_connectivity_file);
results.TR = config.TR;
results.filter_low = config.filter_low;
results.filter_high = config.filter_high;
results.post_filter_crop_TRs = config.post_filter_crop_TRs;
results.SC = SC;
results.FMRI = FMRI;
results.signal_filtered = signal_filtered;
results.signal_empirical = signal_empirical;
results.frequency_grid = frequency_details.frequency_grid(:);
results.regional_frequencies = regional_frequencies(:);
results.FCemp = FCemp;
results.FClag_emp = FClag_emp;
results.GEC = GEC;
results.FCsim = FCsim;
results.FC_corr = FC_corr;
results.fit_history = fit_details.fit_history;
results.final_metrics = fit_details.final_metrics;
results.model_options = fit_details.model_options;
results.output_file = output_file;
results.summary = struct( ...
    'subject_label', subject_label, ...
    'mode_label', mode_label, ...
    'n_regions', size(SC, 1), ...
    'n_timepoints', size(FMRI, 2), ...
    'n_timepoints_after_crop', size(signal_empirical, 2), ...
    'message', sprintf('Finished %s Hopf fit for %s with FC correlation %.4f and FC error %.4g.', mode_label, subject_label, FC_corr, fit_details.final_metrics.errorFC));

save(output_file, 'results');

if config.make_plots && can_make_plots()
    fc_sim_plot = results.FCsim;
    fc_sim_plot(1:size(fc_sim_plot, 1) + 1:end) = NaN;

    fc_emp_plot = results.FCemp;
    fc_emp_plot(1:size(fc_emp_plot, 1) + 1:end) = NaN;

    figure;
    subplot(1, 3, 1);
    imagesc(results.GEC);
    axis square;
    colormap(jet);
    colorbar;
    title(sprintf('Fitted GEC (%s)', strrep(mode_label, '_', ' ')));

    subplot(1, 3, 2);
    fc_sim_handle = imagesc(fc_sim_plot);
    set(fc_sim_handle, 'AlphaData', ~isnan(fc_sim_plot));
    axis square;
    colorbar;
    title({ ...
        'Simulated FC (diagonal removed)', ...
        sprintf('FC corr = %.4f', results.final_metrics.corrFC)});

    subplot(1, 3, 3);
    fc_emp_handle = imagesc(fc_emp_plot);
    set(fc_emp_handle, 'AlphaData', ~isnan(fc_emp_plot));
    axis square;
    colorbar;
    title('Empirical FC (diagonal removed)');

    n_error_points = numel(results.fit_history.errorFC);
    n_corr_points = numel(results.fit_history.corrFC);

    figure;
    subplot(2, 1, 1);
    plot(results.fit_history.errorFC, 'LineWidth', 1.5);
    hold on;
    plot(results.fit_history.errorFClag, 'LineWidth', 1.5);
    hold off;
    if n_error_points > 1
        xlim([1, n_error_points]);
    end
    ylabel('Error');
    title('Fit Metrics Across Iterations');
    legend({'FC(0)', 'FClag'}, 'Location', 'best');

    subplot(2, 1, 2);
    plot(results.fit_history.corrFC, 'LineWidth', 1.5);
    hold on;
    plot(results.fit_history.corrFClag, 'LineWidth', 1.5);
    hold off;
    if n_corr_points > 1
        xlim([1, n_corr_points]);
    end
    xlabel('Iteration');
    ylabel('Correlation');
    legend({'FC(0)', 'FClag'}, 'Location', 'best');
elseif config.make_plots
    disp('Skipping plots because no graphics toolkit is available in this session.');
end

disp(results.summary.message);
disp(['Saved results to: ', results.output_file]);

function label = subject_id_to_label(subject_id, subject_index)
if isnumeric(subject_id) && isscalar(subject_id)
    label = ['sub' num2str(subject_id)];
elseif ischar(subject_id)
    label = ['sub' sanitize_label(subject_id)];
elseif isstring(subject_id) && isscalar(subject_id)
    label = ['sub' sanitize_label(char(subject_id))];
else
    label = ['sub' num2str(subject_index)];
end
end

function label = sanitize_label(value)
label = regexprep(value, '[^a-zA-Z0-9_-]', '_');
end

function tf = can_make_plots()
if exist('OCTAVE_VERSION', 'builtin') ~= 0
    tf = ~isempty(available_graphics_toolkits());
else
    tf = true;
end
end
