# Crew HAPP Linux TUN build

This private source repository contains only the reproducible patch set and
release automation for the Linux/amd64 HAPP-compatible client used by Crew.
It does not contain subscriptions, profiles, device identities, endpoints, or
runtime data.

The build pins `GenkaOk/happ-cli` at `v0.0.4` and `tun2socks` at `v2.6.0`.
The patch preserves the upstream CLI's ordinary `Start` behavior, while adding
an embedding-only error-returning entrypoint. HAPP uses that entrypoint so a
TUN initialization failure returns through its cleanup path instead of ending
the process through `log.Fatalf`.

`scripts/build-linux-amd64.sh` clones the two exact tags, applies the two
reviewed patches, runs both module test suites, and writes
`dist/happ-linux-amd64.tar.gz`. Tagged commits build and publish that archive
as a private GitHub Release.
