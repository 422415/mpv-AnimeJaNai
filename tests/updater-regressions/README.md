# Updater regressions

Generate a disposable .NET 10 project with
`python tests/updater-regressions/generate.py PATH_TO_OUTPUT`, then run
`dotnet run --project PATH_TO_OUTPUT/Checks.csproj`.

The generator copies the current production migration and release-selection
methods verbatim into a wrapper. The HTTP-client factory is replaced by an
in-memory response handler; filesystem operations are real and confined to new
fixtures under the test output directory. No download, installer or user
configuration is used. Failed assertions return a nonzero exit code.

The replacement/deletion lock cases require Windows sharing semantics. Cases
cover preserved bindings after replacement failure, retry after retirement
failure, idempotence, CRLF, empty/absent legacy files, managed-block refresh, exact installed-release selection,
missing version/release, and application-update, local-pack and Linux-index controls.
