# Standardized GitHub Actions Runner Tool Inventory

**Target OS:** Ubuntu 24.04 LTS  
**Architecture:** x86_64  
**Runner user:** Non-root

| Tool | Pinned version | Reason |
|---|---|---|
| Git | 2.53.0 | Required for repository checkout and version control |
| curl | 8.5.0 | Required for API requests and downloading resources |
| jq | 1.8.1 | Required for parsing JSON and extracting package metadata |
| GNU tar | 1.35 | Required for creating release archives |
| zip | 3.0 | Required for creating ZIP archives |
| unzip | 6.0 | Required for extracting downloaded ZIP releases |
| GNU Make | 4.3 | Required to execute project lint and build targets |
| Node.js | 22.23.5 | Required to build and test Node.js services |
| npm | 10.9.4 | Required for installing Node.js project dependencies |
| Python | 3.12.3 | Required to run Python services |
| pip | 24.0 | Required for installing Python dependencies |
| Python venv | Python 3.12 standard library | Required to create isolated Python environments |
| HashiCorp Vault | 2.2.2 | Required for retrieving secrets from the lab Vault server |
| GitHub CLI | 2.83.0 | Required for downloading GitHub releases |

## Version management

All tool versions must be verified by the runner self-check workflow. The Ansible role must install the documented versions and be safe to execute repeatedly.

The inventory is a proposed baseline pending mentor review.
