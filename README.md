# hopf_mini

`hopf_mini` is a minimal, transparent MATLAB workflow for fitting a
single-subject nonlinear Hopf model from one BOLD/fMRI matrix and one
structural connectivity matrix.

It is designed to be easy to read, easy to run, and close in spirit to the
main `hopf_core` workflow while keeping only the essential single-subject
path.

## At a Glance

| Item | Value |
| --- | --- |
| Scope | Single-subject nonlinear Hopf fitting |
| Language | MATLAB |
| Entry point | `run_hopf_mini.m` |
| Inputs | One `FMRI` matrix and one `SC` matrix |
| Main outputs | `GEC`, `FCsim`, fit history, compact `results` struct |
| Included example | `data/subject_single_100408.mat`, `data/SC_single.mat` |

The mini workflow uses the same Butterworth + `filtfilt` preprocessing family
as `hopf_core` and the MATLAB reference implementations.

## Workflow

This repository keeps one explicit path:

1. load one BOLD/fMRI matrix and one structural connectivity matrix
2. detrend, bandpass-filter, and crop the empirical signal once
3. extract one regional frequency per node
4. build empirical `FC` and `FClag` targets from the same preprocessed signal
5. fit one nonlinear Hopf model
6. save one compact result file and optionally show simple diagnostic plots

## Repository Layout

| Path | Purpose |
| --- | --- |
| [`run_hopf_mini.m`](run_hopf_mini.m) | Main script with visible load, preprocess, fit, save, and plot steps |
| [`fit_hopf_model_nonlinear.m`](fit_hopf_model_nonlinear.m) | Single-subject nonlinear Hopf fitter |
| [`utils/preprocess_empirical_signal.m`](utils/preprocess_empirical_signal.m) | Detrend, bandpass-filter, and crop the empirical signal |
| [`utils/fcn_extract_frequencies.m`](utils/fcn_extract_frequencies.m) | Extract regional frequencies from the preprocessed signal |
| [`utils/fcn_Hopf_simulate_BOLD_from_GEC.m`](utils/fcn_Hopf_simulate_BOLD_from_GEC.m) | Simulate BOLD-like signals from fitted effective connectivity |
| [`utils/hopf_nl_step.m`](utils/hopf_nl_step.m) | One nonlinear Hopf integration step |
| [`utils/compute_lagged_fc_matrix.m`](utils/compute_lagged_fc_matrix.m) | Build the variance-normalized lagged FC target |
| [`data/`](data/) | Example single-subject input files |
| [`results/`](results/) | Saved compact `.mat` outputs |

## Example Inputs

The repository ships with one example subject and one example SC matrix in
`data/`.

| File | Required variable | Expected shape | Notes |
| --- | --- | --- | --- |
| [`data/subject_single_100408.mat`](data/subject_single_100408.mat) | `FMRI` | `N x T` | May also contain `subject_id` |
| [`data/SC_single.mat`](data/SC_single.mat) | `SC` | `N x N` | Must use the same region order as `FMRI` |

See [`data/README.md`](data/README.md) for a short note on the bundled example
files.

## Quick Start

From MATLAB:

```matlab
cd('/path/to/hopf_mini')
run('run_hopf_mini.m')
```

By default the script:

- uses `data/subject_single_100408.mat`
- uses `data/SC_single.mat`
- writes outputs to `results/`
- enables plots with `config.make_plots = true`
- runs the signed-GEC fit with `allow_negative_gec = true`

If you want to use a different subject or SC matrix, edit the paths near the
top of [`run_hopf_mini.m`](run_hopf_mini.m).

## Configuration and Defaults

All main options are set near the top of `run_hopf_mini.m`.

### Parameter Groups

- empirical preprocessing: `TR`, `filter_low`, `filter_high`,
  `frequency_smoothing_sigma`, `post_filter_crop_TRs`
- nonlinear model: `Tau`, `sigma`, `a`, `learningRateFromFC`,
  `learningRateFromFClag`, `maxC`, `max_iterations`,
  `stop_check_interval`, `stop_improvement`, `initial_error`,
  `global_coupling`, `dt`, `warmup_time`
- sign mode: `allow_negative_gec = false` for non-negative GEC,
  `allow_negative_gec = true` for signed GEC

### Default Parameters

#### Input / Output

| Option | Default |
| --- | --- |
| `subject_data_file` | `data/subject_single_100408.mat` |
| `structural_connectivity_file` | `data/SC_single.mat` |
| `subject_index` | `1` |
| `output_dir` | `results/` |
| `make_plots` | `true` |

#### Empirical Preprocessing

| Option | Default |
| --- | --- |
| `TR` | `0.72` |
| `filter_low` | `0.008` |
| `filter_high` | `0.09` |
| `frequency_smoothing_sigma` | `0.01` |
| `post_filter_crop_TRs` | `10` |

#### Nonlinear Model

| Option | Default |
| --- | --- |
| `Tau` | `1` |
| `sigma` | `0.01` |
| `a` | `-0.02` |
| `learningRateFromFC` | `0.0002` |
| `learningRateFromFClag` | `0.00004` |
| `maxC` | `0.1` |
| `max_iterations` | `5000` |
| `stop_check_interval` | `100` |
| `stop_improvement` | `0.001` |
| `initial_error` | `100000` |
| `global_coupling` | `1` |
| `dt` | `0.1 * TR / 2 = 0.036` |
| `warmup_time` | `3000` |
| `allow_negative_gec` | `true` |
| `verbose` | `true` |

> If `fit_hopf_model_nonlinear.m` is called directly with missing options, it
> uses the same fallback defaults except `allow_negative_gec = false`.

## Output

Each run saves one compact `results` struct under `results/`.

The saved output includes:

- subject metadata and input file paths
- raw `FMRI` and `SC` matrices
- filtered signal before trimming and final empirical signal after trimming
- extracted regional frequencies and the frequency grid
- empirical `FC` and lagged `FC`
- fitted `GEC`
- final simulated `FC`
- fit history, final metrics, and model options
- output path and a short summary message

If `config.make_plots = true`, the script also opens simple diagnostic figures
for the fitted `GEC` and the fit trajectories.

See [`results/README.md`](results/README.md) for a short note about saved
outputs.

## Rights And Provenance

This repository is shared without an open-source license.

- Refactoring, simplification, and packaging: Jakub Vohryzek
- Underlying model code lineage: Yonatan Sanz Perl and Gustavo Deco

Please see `LICENSE.md` for the rights and reuse terms for this repository.
