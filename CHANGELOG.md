# Changelog

All notable changes to the `StellarClear` Soroban smart contract repository (`stellarclear-contract`) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **M-of-N Observer Quorum Threshold Logic**:
  - Configurable per-case observer quorum requirement defaulting to 1 (`DEFAULT_OBSERVER_QUORUM = 1`) preserving full backward compatibility.
  - Dedicated configuration endpoint `set_case_quorum(case_id, quorum)` and public query `get_case_quorum(case_id)`.
  - Observer quorum attestation submission endpoint `submit_observer_attestation(case_id, observer, commitment)` and query `get_attested_observers(case_id)`.
  - Quorum satisfied only by distinct, active registered observers; duplicate submissions and non-observer impersonation rejected.
  - Enforced in `finalize_case` across both `Matched` and `Resolved` branches.
  - Emitted `CaseQuorumSet` event on configuration.
  - Added `InvalidObserverQuorum` and `ObserverQuorumNotMet` error codes.
- **Dispute Expiration TTL & Permissionless Timeout Mechanism**:
  - Deterministic ledger-based dispute TTL stored on dispute opening (`DEFAULT_DISPUTE_TTL_LEDGERS = 17_280` ledgers / ~24 hours).
  - Configurable TTL dispute opening endpoint `open_dispute_with_ttl(initiator, case_id, dispute_commitment, ttl_ledgers)` and query `get_dispute_expiration(case_id)`.
  - Permissionless `expire_dispute(case_id)` function transitioning unaddressed disputes deterministically from `Disputed` back to `Break` without forging false mutual agreement.
  - Cleans up pending resolution submissions and dispute expiration on expiration.
  - Mandated counterparty presence when opening disputes to prevent unresolvable deadlock states.
  - Rejected late resolution submissions after dispute expiration with `DisputeAlreadyExpired`.
  - Emitted `DisputeExpired` event recording expiration and closing ledger sequence numbers.
  - Added `DisputeNotExpired` and `DisputeAlreadyExpired` error codes.
- **State Machine & Terminal Immutability Enforcement**:
  - Validated state transition `(Disputed, Break)` in authorization state machine.
  - Enforced terminal read-only immutability on finalized cases across all attestation and quorum mutation endpoints.

---

## [0.1.0] - 2026-09-30

### Added
- **SettlementRegistry Soroban Contract**:
  - Authoritative on-chain state machine (`Open` $\rightarrow$ `Observed` $\rightarrow$ `Matched`/`Break` $\rightarrow$ `Disputed` $\rightarrow$ `Resolved` $\rightarrow$ `Finalized`).
  - Terms commitment anchoring (`BytesN<32>`) and on-chain observation recording with transaction hash and ledger index.
  - Granular reconciliation breaks with standardized typed `BreakCode` enum (`AmountMismatch`, `DestinationMismatch`, `AssetMismatch`, `MemoMismatch`, `MissingTransaction`, `UnexpectedTransaction`, `TimingViolation`, `Other`).
  - Two-party dispute resolution agreement protocol (`open_dispute`, `submit_resolution`).
  - Cryptographic multi-party attestations (`Owner`, `Counterparty`, `Observer`) via `submit_attestation`.
  - Terminal-state immutability and permanent state locking on finalized settlement cases.
  - Comprehensive contract events emitted for 100% of state-mutating actions.
- **Security & Quality Regression Suites**:
  - Full authorization boundaries and adversarial test matrix.
  - Malformed-input and resource-boundary scaling coverage.
  - Terminal-state immutability and duplicate call prevention tests.
  - 102 automated tests passing with zero warnings.
- **Reproducible Release Artifact Packaging & Verification**:
  - Deterministic WebAssembly compilation (`wasm32v1-none`) with SHA-256 checksum `60d38795a59b31cd9dd15605b7269957fc88e8ff19a16bd8eee8cb2d5e78b30d`.
  - Machine-readable release provenance manifest (`artifacts/release-manifest.json` and `artifacts/v0.1.0/`).
  - Release chain integration verification test suite (`tests/release_artifact.rs`).
  - Programmatic deployed testnet verification matrix (`tests/deployed_testnet.rs`).
  - Shell automation scripts for building (`scripts/build.sh`), checking (`scripts/check.sh`), packaging (`scripts/release.sh`), artifact verification (`scripts/verify-artifact.sh`), and testnet deployment verification (`scripts/verify-deployment.sh`, `scripts/testnet-verification.sh`).
- **CI / CD Infrastructure**:
  - GitHub Actions workflows for continuous integration (`.github/workflows/ci.yml`), release verification (`.github/workflows/release-verification.yml`), and security regression testing (`.github/workflows/security-verification.yml`).
  - Automated system dependency provisioning (`dbus`, `libdbus-1-dev`, `pkg-config`, `libssl-dev`, `libudev-dev`).
- **Documentation**:
  - Security model, authorization matrix, threat model, and audit status in `SECURITY.md`.
  - Production/testnet release checklist, verification chain, and packaging specification in `RELEASE.md`.
  - Step-by-step deployment guide and testnet verification instructions in `DEPLOYMENT.md`.

