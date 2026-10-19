# Local agent instructions

## Tool use

Avoid using `bash` whenever possible, and prefer other specialized tools. Note that specialized
tools also accept absolute paths.

Take extra care of potential race condition when running multiple tools in parallel; for example,
when running `write` and `bash` in parallel, `bash` might not see the result of `write` at the time
it executes. Run tools in separate turn when needed.

Some notes about various built-in tools:

- `bash` runs in the working directory specified in the system prompt. Do not prepend `cd` if the
  desired working directory matches that of system prompt.
- `find` might not be able to find files ignored by Git, since it's the default behavior of `fd`.

## Writing tests

Avoid writing unit tests to cover all of the code paths. Instead, focus on user stories written in
natural language, and test them in the form of integration or E2E tests. Only write unit tests when
the user asks so.

## Running tests

Minimize outputs from the test harness \(e.g. `--quiet`\). Prefer `cargo nextest` when running Rust
tests.

## Local development environment

Manage the development environment with Nix. Do not use `apt`; use commands such as `nix shell` and
`nix run` when tools or dependencies are needed. You can search for packages using
`nh search packages <package>`.

When working with Python packages, check first if a virtual environment is active. Search for
installed packages only within the current environment. Prefer `uv` whenever possible.

Create Git worktree in `.worktrees/` at the repository root, if not specified. Create one if the
directory does not exist, and add `.worktrees/.gitignore` to ignore all subdirectories. The purpose
of this `.gitignore` is to ignore the whole `.worktrees` directory; write only `*`, and do not add
`!.gitignore` to the list.

## Reviewing

When reviewing a GitHub PR, checkout the PR first into a worktree:

```sh
gh pr checkout <PR> --detach --worktree .worktrees/<...>

# or, without gh:
git fetch upstream pull/<PR>/head && git worktree add .worktrees/<...> FETCH_HEAD
```
