# Work IQ plugin setup

This repository includes the hosted Work IQ MCP configuration and a helper to sync the **latest official Work IQ plugin and skill bundle** from [`microsoft/work-iq`](https://github.com/microsoft/work-iq). The upstream stable plugin was version **3.0.0** at reviewed commit [`206072a88695f14000fc72cddcd5f2f40871ba01`](https://github.com/microsoft/work-iq/tree/206072a88695f14000fc72cddcd5f2f40871ba01/plugins/workiq); the sync helper fetches the current upstream `main` when run.

## Sync the skills and plugin

On Windows PowerShell, from the repository root:

```powershell
.\scripts\update-workiq-plugin.ps1
```

This copies the official plugin package, including its `skills/workiq` skill and reference bundle, into `plugins/workiq`. It reports the upstream commit and package version. Use `-Force` to replace an existing `plugins/workiq` directory.

## Install in GitHub Copilot CLI

After syncing, run:

```powershell
copilot plugin install ./plugins/workiq
```

Restart the Copilot CLI session after installation or updates. Plugin installation is local to the CLI environment; this repository setup does not install it into other hosts. Use each other host's supported plugin loader and the bundled `.mcp.json` remote-MCP configuration.

The MCP endpoint is hosted by Microsoft. Availability, tenant consent, licensing, authentication and live tool behavior are managed separately; adding the configuration does not establish that the service is enabled for your tenant.
