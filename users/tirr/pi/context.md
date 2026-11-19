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

Do not write unit tests for internal components, or failure paths of the code, unless explicitly
asked so. Instead, focus on writing E2E tests, which can be described in plain natural language.

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

## Using development tools

Minimize outputs from the build tool and test harness (e.g. `--quiet` for `cargo build`).

Prefer `cargo nextest` when running Rust tests.

## Reviewing

When reviewing a GitHub PR, checkout the PR first into a worktree:

```sh
gh pr checkout <PR> --detach --worktree .worktrees/<...>

# or, without gh:
git fetch upstream pull/<PR>/head && git worktree add .worktrees/<...> FETCH_HEAD
```

## Handling discrepancy between documentation and code

When documentation and existing code disagree, follow the conventions used in the existing code, and
in your final reply point out each inconsistency you found between the documentation and the code.
