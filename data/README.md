# Data Inputs

This folder holds the single-subject inputs used by `run_hopf_mini.m`.

Required files:

- `subject_single_<subject_id>.mat`
- `SC_single.mat`

Required variables:

- `subject_single_<subject_id>.mat`: `FMRI`
- `SC_single.mat`: `SC`

Optional variables:

- `subject_single_<subject_id>.mat`: `subject_id`

Expected shapes:

- `FMRI`: `N x T` with regions in rows and timepoints in columns
- `SC`: `N x N`

Current example contents:

- `subject_single_100307.mat`: copied from subject `100307` in the linear/nonlinear comparison source data
- `subject_single_100408.mat`: copied from subject `100408` in the same source data
- `subject_single_101309.mat`: copied from subject `101309` in the same source data
- `SC_single.mat`: copied from the shared example SC used with that comparison data
