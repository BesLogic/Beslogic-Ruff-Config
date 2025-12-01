# Overview

This only works setups with a virtual environment at a known consistent location. This way of installing is a workaround until an official solution is available. See <https://github.com/astral-sh/ruff/issues/12352>.

[required-version](https://docs.astral.sh/ruff/settings/#required-version) and [project.dependencies](https://packaging.python.org/en/latest/guides/writing-pyproject-toml/#dependencies-and-requirements) are already set so you shouldn't be able to accidentally use an incompatible Ruff version.\
Although there's still an issue where config parsing may fail before `required-version` tells you about it: <https://github.com/astral-sh/ruff/issues/19922>

## Usage

To use, simply [extend](https://docs.astral.sh/ruff/settings/#extend) your Ruff configuration with the one from this project.

```toml
extend = ".venv/Beslogic-Ruff-Config/ruff.toml"
```

### Using in CI

GitHub action example:

```yaml
jobs:
  Ruff:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v7
        with:
          activate-environment: true
      - run: uv sync --locked --only-group=ruff
      - run: ruff check --output-format=github
      - run: ruff format --check --output-format=github
        # Check format even if the the previous step failed
        if: ${{ !cancelled() }}
```

Where the `ruff` [Dependency Group](https://packaging.python.org/en/latest/specifications/dependency-groups/) is configured as such in your `pyproject.toml`:

```toml
[dependency-groups]
ruff = [
  "beslogic-ruff-config",
  "ruff", # Version should come from beslogic-ruff-config and the lock file
]
dev = [
  {include-group = "ruff"},
]
```

### Additional configuration

If a rule doesn't seem to fit your need, try to see if it's configurable before disabling it: <https://docs.astral.sh/ruff/settings/#lint>

**Never** use the following settings, unless you **really know** that you want to overwrite entire config sections:

- [exclude](https://docs.astral.sh/ruff/settings/#exclude)
- [include](https://docs.astral.sh/ruff/settings/#include)
- [fixable](https://docs.astral.sh/ruff/settings/#lint_fixable)
- [per-file-ignores](https://docs.astral.sh/ruff/settings/#lint_per-file-ignores)
- [select](https://docs.astral.sh/ruff/settings/#lint_select)
- [safe-fixes](https://docs.astral.sh/ruff/settings/#lint_safe-fixes)
- [unsafe-fixes](https://docs.astral.sh/ruff/settings/#lint_unsafe-fixes)
- [flake8-gettext.function-names](https://docs.astral.sh/ruff/settings/#lint_flake8-gettext_function-names)
- [flake8-import-conventions.aliases](https://docs.astral.sh/ruff/settings/#lint_flake8-import-conventions_aliases)
- [flake8-self.ignore-names](https://docs.astral.sh/ruff/settings/#lint_flake8-self_ignore-names)
- [pep8-naming.ignore-names](https://docs.astral.sh/ruff/settings/#lint_pep8-naming_ignore-names)

Instead, **always** try to use:

- [extend-exclude](https://docs.astral.sh/ruff/settings/#extend-exclude)
- [extend-include](https://docs.astral.sh/ruff/settings/#extend-include)
- [extend-fixable](https://docs.astral.sh/ruff/settings/#lint_extend-fixable)
- [extend-per-file-ignores](https://docs.astral.sh/ruff/settings/#lint_extend-per-file-ignores)
- [extend-select](https://docs.astral.sh/ruff/settings/#lint_extend-select)
- [extend-safe-fixes](https://docs.astral.sh/ruff/settings/#lint_extend-safe-fixes)
- [extend-unsafe-fixes](https://docs.astral.sh/ruff/settings/#lint_extend-unsafe-fixes)
- [flake8-gettext.extend-function-names](https://docs.astral.sh/ruff/settings/#lint_flake8-gettext_extend-function-names)
- [flake8-import-conventions.extend-aliases](https://docs.astral.sh/ruff/settings/#lint_flake8-import-conventions_extend-aliases)
- [flake8-self.extend-ignore-names](https://docs.astral.sh/ruff/settings/#lint_flake8-self_extend-ignore-names)
- [pep8-naming.extend-ignore-names](https://docs.astral.sh/ruff/settings/#lint_pep8-naming_extend-ignore-names)

If you end up with additional configuration that you believe should be applied across all projects. Please open a PR to modify these shared configurations instead.

The following are not part of the default config and are good to know about:

- Use [extend-exclude](https://docs.astral.sh/ruff/settings/#extend-exclude) if you need to exclude any file from being checked. Usually for auto-generated files that can't fully be autofixed. Although even then we'd recommend using [extend-per-file-ignores](https://docs.astral.sh/ruff/settings/#lint_extend-per-file-ignores) instead.
- Use [lint.explicit-preview-rules = false](https://docs.astral.sh/ruff/settings/#lint_explicit-preview-rules) OR explicitly add a rule to [extend-select](https://docs.astral.sh/ruff/settings/#lint_extend-select) to use rules and behaviours still in preview.
- If you are writing a library and want to enforce documentation for all public symbols, consider adding [D1](https://docs.astral.sh/ruff/rules/#pydocstyle-d) rules to [extend-select](https://docs.astral.sh/ruff/settings/#lint_extend-select).
- Similarly, if you want to enforce documenting returns, yields and exceptions, [ignore](https://docs.astral.sh/ruff/settings/#lint_ignore): [D406](https://docs.astral.sh/ruff/rules/missing-new-line-after-section-name/) and [D407](https://docs.astral.sh/ruff/rules/missing-dashed-underline-after-section/) (as they are incompatible with [pydoclint](https://docs.astral.sh/ruff/rules/#pydoclint-doc)). Then [extend-select](https://docs.astral.sh/ruff/settings/#lint_extend-select): [DOC201](https://docs.astral.sh/ruff/rules/docstring-missing-returns/), [DOC402](https://docs.astral.sh/ruff/rules/docstring-missing-yields/) and/or [DOC501](https://docs.astral.sh/ruff/rules/docstring-missing-exception/) to your liking
- [missing-copyright-notice (CPY001)](https://docs.astral.sh/ruff/rules/missing-copyright-notice/) isn't enabled because most projects are either private or consider that setting the license project metadata is sufficient.
- The following rules are currently disabled because they shouldn't be blocking, but Ruff [doesn't support warnings](https://github.com/astral-sh/ruff/issues/1256) yet: [flake8-fixme (FIX)](https://docs.astral.sh/ruff/rules/#flake8-fixme-fix), [missing-todo-link (TD003)](https://docs.astral.sh/ruff/rules/missing-todo-link/), [try-except-in-loop (PERF203)](https://docs.astral.sh/ruff/rules/try-except-in-loop/)
  
<!--- I'd normally recommend setting rules that don't pass yet on a new project as temporary warning, but no warnings in Ruff yet: https://github.com/astral-sh/ruff/issues/1256 & https://github.com/astral-sh/ruff/issues/1774 --->

## Installation

Below you should replace `<rev>` with the latest revision/commit to pin the configuration version.

If you want to rely on the uv lockfile instead of using an explicit revision, you can run `uv lock --upgrade-package Beslogic-Ruff-Config` to update.

### Optimized dependency groups for use in CI

See [Using in CI](#using-in-ci)

### For a uv-based project

`uv add git+https://github.com/Beslogic/Beslogic-Ruff-Config --dev --rev <rev>`

Which should add the following to your pyproject.toml:

```toml
[dependency-groups]
dev = [
    "Beslogic-Ruff-Config",
]

[tool.uv.sources]
Beslogic-Ruff-Config = { git = "https://github.com/Beslogic/Beslogic-Ruff-Config@<rev>" }
```

### Using pip

`pip install git+https://github.com/microsoft/python-type-stubs.git@<rev>`
