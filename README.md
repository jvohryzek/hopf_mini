# hopf_mini

`hopf_mini` is a minimal, transparent, single-subject nonlinear Hopf workflow.
It is meant to be easy to read, easy to run, and close in spirit to the main
`hopf_core` workflow while keeping only the essential single-subject path.

## Overview

This repository keeps one explicit workflow:

1. load one BOLD/fMRI matrix and one structural connectivity matrix
2. detrend, bandpass-filter, and crop the empirical signal once
3. extract one regional frequency per node
4. build empirical `FC` and `FClag` targets from the same preprocessed signal
5. fit one nonlinear Hopf model
6. save one compact result file and optionally show simple diagnostic plots

The mini workflow uses the same Butterworth + `filtfilt` preprocessing family
as `hopf_core` and the MATLAB reference implementations.

## Repository Layout

- `run_hopf_mini.m`
  Main entry script with visible load, preprocess, fit, save, and plot steps.
- `fit_hopf_model_nonlinear.m`
  Single-subject nonlinear Hopf fitter.
- `utils/preprocess_empirical_signal.m`
  Detrend, bandpass-filter, and crop the empirical signal.
- `utils/fcn_extract_frequencies.m`
  Extract regional frequencies from the preprocessed empirical signal.
- `utils/fcn_Hopf_simulate_BOLD_from_GEC.m`
  Simulate BOLD-like signals from fitted effective connectivity.
- `utils/hopf_nl_step.m`
  One nonlinear Hopf integration step.
- `utils/compute_lagged_fc_matrix.m`
  Build the variance-normalized lagged FC target.

## Included Example Input

The repository ships with one example subject and one example SC matrix under
`data/`:

- `data/subject_single_100408.mat`
- `data/SC_single.mat`

Expected variables:

- `subject_single_100408.mat` must contain `FMRI`
- `subject_single_100408.mat` may also contain `subject_id`
- `SC_single.mat` must contain `SC`

Expected shapes:

- `FMRI`: `N x T` with regions in rows and timepoints in columns
- `SC`: `N x N` in the same region order

## Quick Start

From MATLAB:

```matlab
run('/Users/jakub/Codes/Projects/Project_hopf/hopf_mini/run_hopf_mini.m')
```

By default the script uses:

- subject file: `data/subject_single_100408.mat`
- SC file: `data/SC_single.mat`

These paths can be edited directly near the top of `run_hopf_mini.m`.

## Configuration

The main options are intentionally explicit in `run_hopf_mini.m`:

- empirical preprocessing:
  `TR`, `filter_low`, `filter_high`, `frequency_smoothing_sigma`,
  `post_filter_crop_TRs`
- nonlinear model:
  `Tau`, `sigma`, `a`, `learningRateFromFC`, `learningRateFromFClag`,
  `maxC`, `max_iterations`, `stop_check_interval`, `stop_improvement`,
  `initial_error`, `global_coupling`, `dt`, `warmup_time`
- sign mode:
  `allow_negative_gec = false` for non-negative GEC,
  `allow_negative_gec = true` for signed GEC

## Output

Each run saves one compact `results` struct under `results/` containing:

- subject metadata
- SC and BOLD matrices
- filtered signal before edge trimming
- filtered and post-cropped signal used for empirical targets
- frequency grid and extracted regional frequencies
- empirical FC and lagged FC
- fitted GEC
- final simulated FC
- fit history
- output path and summary

If `config.make_plots = true`, the script also opens simple diagnostic figures
for the fitted GEC and fit trajectories.

## Rights And Provenance

This repository is shared without an open-source license.

- Refactoring, simplification, and packaging: Jakub Vohryzek
- Underlying model code lineage: Yonatan Sanz Perl and Gustavo Deco

Please see `LICENSE.md` for the rights and reuse terms for this repository.
