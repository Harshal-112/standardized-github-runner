
# Standardized GitHub Actions Runner - Tool Inventory

## Target Environment

- Operating System: Ubuntu 24.04 LTS
- Architecture: x86_64
- Runner: GitHub Actions self-hosted runner
- Runner execution user: harshal (non-root)
- Provisioning: Ansible

## Pinned Tool Versions

| Tool | Exact Version | Installation Method | Purpose |
|---|---|---|---|
| Git | 2.43.0-1ubuntu7.4 | APT | Repository checkout and version control |
| curl | 8.5.0-2ubuntu10.16 | APT | HTTP requests and downloads |
| jq | 1.7.1-3ubuntu0.24.04.2 | APT | JSON parsing |
| GNU tar | 1.35+dfsg-3ubuntu0.4 | APT | Archive creation and extraction |
| zip | 3.0-13ubuntu0.2 | APT | ZIP archive creation |
| unzip | 6.0-28ubuntu4.1 | APT | ZIP archive extraction |
| GNU Make | 4.3-4.1build2 | APT | Build and lint commands |
| Node.js | 22.23.5 | Official binary archive | Node.js application builds and tests |
| npm | 10.9.9 | Bundled with Node.js installation | Node.js dependency management |
| Python | 3.12.3-1ubuntu0.17 | APT | Python application execution |
| Python venv | 3.12 standard library | APT | Isolated Python environments |
| pip | 24.0 | APT | Python dependency installation |
| HashiCorp Vault | 2.2.2 | Official binary archive | Lab secret-management integration |
| GitHub CLI | 2.45.0-1ubuntu0.3 | APT | GitHub release and repository operations |

## Version Verification

The Ansible role installs the specified versions.

The validation script at `scripts/validate-tools.sh` checks:

- Exact APT package versions using dpkg.
- Exact Node.js, npm, Python, pip, and Vault versions.
- Git repository and commit functionality.
- curl and jq functionality.
- tar, zip, and unzip archive operations.
- GNU Make execution.
- GitHub CLI version.

The GitHub Actions workflow `.github/workflows/runner-check.yml` executes this validation on the self-hosted runner.

## Version Management

Tool versions must be updated in the Ansible role, this inventory, and the validation script together.

Changes should be tested on a lab VM before being proposed for deployment.

## Security and Execution

- Runner jobs execute as a non-root user.
- No runner registration tokens or Vault secrets are stored in the repository.
- Vault integration uses a local development server for lab testing.
- Testing and provisioning are restricted to the project owner's lab environment.

## Scope

The inventory covers the tools required by the runner validation and example workflows. Additional tools should only be introduced when a documented workflow requires them.
