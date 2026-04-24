# Fileverse MCP Server Setup

## Overview
Fileverse MCP server provides blockchain-backed document storage and retrieval capabilities. Connected via Cloudflare Worker endpoint.

## Endpoint
```
https://fileverse-cloudflare-worker.donny-a53.workers.dev
```

## Connection Details
- **Type**: MCP (Model Context Protocol) HTTP/SSE
- **Auth**: None (public endpoint)
- **Status**: ✅ Connected and verified

## Available Tools

| Tool | Description |
|------|-------------|
| `fileverse_list_documents` | List all stored documents |
| `fileverse_get_document` | Get a single document by ID |
| `fileverse_create_document` | Create new document (blockchain-backed) |
| `fileverse_update_document` | Update document title/content |
| `fileverse_delete_document` | Delete a document by ID |
| `fileverse_search_documents` | Text search across documents |
| `fileverse_get_sync_status` | Check blockchain sync status |
| `fileverse_retry_failed_events` | Retry failed sync events |

## Installation

Added to Hermes configs via direct YAML edit (CLI had issues in non-TTY mode):

```bash
# Manual command (requires TTY):
hermes mcp add fileverse --url https://fileverse-cloudflare-worker.donny-a53.workers.dev
hermes mcp test fileverse
```

Configs updated in:
- `/root/.hermes/config.yaml` — Hermes main
- `/root/.hermes/profiles/athena/config.yaml` — Athena profile
- `/root/.hermes/profiles/apollo/config.yaml` — Apollo profile

## Verify Connection

```bash
hermes mcp test fileverse
hermes mcp list
```

## Notes

- CLI `hermes mcp add` requires interactive TTY — was run via direct YAML manipulation
- No authentication required (public Worker endpoint)
- Tool names prefixed with `fileverse_` to avoid namespace collisions