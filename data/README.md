# Data Inputs

This folder holds the single-subject inputs used by `run_hopf_mini.m`.

Required files:

- `subject_single_100408.mat`
- `SC_single.mat`

Required variables:

- `subject_single_100408.mat`: `FMRI`
- `SC_single.mat`: `SC`

Optional variables:

- `subject_single_100408.mat`: `subject_id`

Expected shapes:

- `FMRI`: `N x T` with regions in rows and timepoints in columns
- `SC`: `N x N`

Current example contents:

- `subject_single_100408.mat`: copied from subject `100408` in the same source data
- `SC_single.mat`: copied from the shared example SC used with that comparison data
