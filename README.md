# hopf_mini

`hopf_mini` is a minimal, transparent, single-subject nonlinear Hopf workflow.

## Rights And Provenance

This workspace is shared without an open-source license.
Copyright remains with the relevant copyright holders.

- Refactoring, simplification, and packaging: Jakub Vohryzek
- Underlying model code lineage: Yonatan Sanz Perl and Gustavo Deco

Treat this repository as proprietary research code for private review and
collaboration only. Redistribution, relicensing, or reuse requires prior
written permission from the relevant copyright holders.

It keeps only one path:
- one participant
- one structural connectivity matrix
- one BOLD/fMRI matrix
- one extracted frequency vector
- one fitted nonlinear Hopf model
- one explicit GEC-sign toggle through `allow_negative_gec`

## Files

- `run_hopf_mini.m`: entry script with visible load, preprocess, fit, and save steps
- `fit_hopf_model_nonlinear.m`: nonlinear single-subject fitter
- `utils/preprocess_empirical_signal.m`: detrend, bandpass-filter, and crop one empirical BOLD matrix
- `utils/fcn_extract_frequencies.m`: regional frequency extraction from the preprocessed empirical signal
- `utils/fcn_Hopf_simulate_BOLD_from_GEC.m`: nonlinear Hopf simulation
- `utils/hopf_nl_step.m`: one nonlinear Hopf state update step

The mini workspace now uses the same Butterworth plus `filtfilt` frequency-preprocessing path as `hopf_core` and the MATLAB reference implementations.
It preprocesses once, then reuses that same detrended, filtered, post-cropped signal for both the extracted frequencies and the empirical `FC` / `FClag` targets.

## Data Folder

Put one subject and one SC matrix under `data/`:

- `subject_single_<subject_id>.mat` must contain `FMRI`
- `subject_single_<subject_id>.mat` may also contain `subject_id`
- `SC_single.mat` must contain `SC`

Expected shapes:

- `FMRI`: `N x T` with regions in rows and timepoints in columns
- `SC`: `N x N`

The workspace currently includes copied example inputs:

- `subject_single_100307.mat`: subject `100307` copied from the comparison dataset
- `subject_single_100408.mat`: subject `100408` copied from the comparison dataset
- `SC_single.mat`: the corresponding example SC copied from the shared comparison inputs

## Default behavior

The default script uses:
- subject file: `data/subject_single_100408.mat`
- SC file: `data/SC_single.mat`

Those defaults can be edited directly in `run_hopf_mini.m`.

## Run

From MATLAB:

```matlab
run('/Users/jakub/Codes/Projects/Project_hopf/hopf_mini/run_hopf_mini.m')
```

## Toggle non-negative versus signed GEC

Edit this line in `run_hopf_mini.m`:

```matlab
allow_negative_gec = true;
```

- `false`: standard non-negative GEC fit
- `true`: signed GEC fit

## Saved output

Each run saves one compact `results` struct under `results/` with:
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
