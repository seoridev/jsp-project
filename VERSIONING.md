# Versioning

This workspace uses semantic versioning.

- `v1.0.0`: Saved baseline of the current project.
- `1.0.1`: Next development version.

Release tags use the `v` prefix, for example `v1.0.0`.

## Git Flow

- `master`: stable release branch.
- `develop`: integration branch for the next version.
- `feature/*`: feature work branched from `develop`.
- `release/*`: release stabilization before tagging.
- `hotfix/*`: urgent fixes branched from `master`.

Feature work should be merged into `develop`. Releases should be tagged from `master` with the `v` prefix.
