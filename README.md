# PPVGO Backup

Private backup of PPVGO's Bash manager and AMD64/ARM64 executables.

## Required configuration

In Settings > Secrets and variables > Actions > Variables, add `PPVGO_SCRIPT_URL` with the **direct raw Bash script URL**. The homepage https://ppvgo.168.us.kg is not verified as a raw script URL.

Configured binary sources:
- https://ppv.168.us.kg/x/ru/ppv_amd
- https://ppv.168.us.kg/x/ru/ppv_arm

## Run and retention

Actions > PPVGO full backup > Run workflow. Also scheduled weekly Sunday 03:23 UTC.

All three downloads must succeed and pass shell/ELF validation before publishing. Each successful run produces a ZIP and SHA256 file as a workflow artifact (90 days) and a dated private GitHub Release. Previous releases are preserved if a later run fails.

The downloaded binaries are never executed by the workflow. Verify the provenance before using them.
