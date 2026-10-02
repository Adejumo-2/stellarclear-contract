# Contributing to stellarclear-contract

## Quick start

```bash
# 1. Install wasm target
rustup target add wasm32v1-none

# 2. Run local test suite
cargo test --workspace

# 3. Format and lint checks
cargo fmt --all -- --check
cargo clippy --all-targets -- -D warnings

# 4. Build contract WASM artifact
stellar contract build
```

Toolchain: Rust `1.84.0+`, Stellar CLI `28.1.0+`, Soroban SDK `27.0.4`.

## Development & Verification Scripts

The repository provides automated verification and build scripts under `./scripts/`:

- `./scripts/check.sh`: Full pre-flight verification suite (formatting, clippy with `-D warnings`, workspace unit and integration tests, contract build, artifact checksum verification).
- `./scripts/build.sh`: Deterministic WASM compilation with `--remap-path-prefix` and optimization flags.
- `./scripts/verify-artifact.sh`: Rebuilds contract from source and verifies byte-for-byte reproducibility against published release manifests.

## Branch Naming Conventions

Create branches off `main` using structured prefixes:

- `feat/<feature-name>`: New protocol features or contract capabilities
- `fix/<issue-name>`: Bug fixes, logic corrections, or security patches
- `docs/<doc-topic>`: Documentation additions, clarifications, or updates
- `chore/<task-name>`: Tooling, dependencies, or repository hygiene
- `test/<test-scope>`: New test cases, regressions, or fuzzers
- `refactor/<scope>`: Code structure improvements without behavior change

## Commit Message Conventions

We adhere to the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```text
<type>(<scope>): <short description in present tense>

[optional body with details]

[optional footer(s), e.g., Closes #123]
```

### Types
- `feat`: A new contract endpoint or protocol feature
- `fix`: A bug fix or security invariant correction
- `docs`: Documentation only changes
- `test`: Adding or adjusting tests
- `chore`: Maintenance, dependencies, or release packaging
- `ci`: CI workflow configuration

## Pull Request & Review Guidelines

- **One issue per PR**: Keep changes modular and focused.
- **Test Coverage**: Add or extend tests in `contracts/settlement-registry/src/test.rs`.
- **State-Machine Invariants**: State-machine changes must include invariant tests (no illegal transitions, terminal state immutability on finalized cases).
- **Pre-Push Checks**: Run `./scripts/check.sh` locally to ensure formatting, clippy, tests, and reproducible build checks pass.
- **Review & Branch Protection**: Merges into `main` require passing required CI status checks and an approving review.

All contributions under Apache-2.0.
