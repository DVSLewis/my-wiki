---
title: XMCP Setup on Zo
created: 2026-04-23
updated: 2026-04-23 (allowlist expanded 21:40)
type: setup
tags: [x-api, mcp, twitter, tools, infrastructure, zo]
sources: [https://github.com/xdevplatform/xmcp]
---

# XMCP — X API MCP Server (Zo)

XMCP is the official X Developer Platform MCP server. It fetches the X API v2
OpenAPI spec at startup and exposes the endpoints as MCP tools via FastMCP.
Streaming and webhook endpoints are excluded automatically.

On Zo, it runs in read-only Bearer Token mode with a restricted allowlist.

Related: [[agent-build-order]] | [[cognee-setup]]

---

## Installation

Repo cloned to: /root/workspace/xmcp
Source: https://github.com/xdevplatform/xmcp

```
git clone https://github.com/xdevplatform/xmcp /root/workspace/xmcp
cd /root/workspace/xmcp
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Dependencies (requirements.txt):
- fastmcp
- httpx
- python-dotenv
- requests-oauthlib
- xai-sdk
- xdk

---

## Auth Mode: Bearer Token (Read-Only)

The upstream server.py only supported OAuth1. A patch was applied to support
Bearer Token-only mode when OAuth1 consumer keys are absent.

Patch behavior in server.py create_mcp():
- If X_OAUTH_CONSUMER_KEY + X_OAUTH_CONSUMER_SECRET are set -> OAuth1 flow (interactive)
- If only X_BEARER_TOKEN is set -> Bearer Token mode (read-only, no browser needed)
- If neither -> RuntimeError at startup

The Bearer Token is injected via an async httpx request hook (add_bearer_auth)
that sets the Authorization: Bearer <token> header on every request.

---

## Configuration (.env)

File: /root/workspace/xmcp/.env

```
# Auth: Bearer Token (read-only mode)
X_BEARER_TOKEN=<from /root/.hermes/profiles/athena/.env>

# X API settings
X_API_BASE_URL=https://api.x.com
X_API_TIMEOUT=30
X_API_DEBUG=1

# MCP server settings
MCP_HOST=127.0.0.1
MCP_PORT=8000

# Tool allowlist (read-only tools only — 20 tools, all GET operationIds)
X_API_TOOL_ALLOWLIST=getUsersByUsername,getUsersByUsernames,getUsersById,getUsersByIds,
  getUsersTimeline,getUsersPosts,getUsersMentions,getUsersFollowers,getUsersFollowing,
  getUsersLikedPosts,getPostsById,getPostsByIds,getPostsCountsRecent,searchPostsRecent,
  searchPostsAll,searchUsers,getTrendsByWoeid,getListsById,getListsMembers,getSpacesById
```

IMPORTANT: The .env token value is sourced from TWITTER_BEARER_TOKEN in
/root/.hermes/profiles/athena/.env. Never commit .env or expose the token.

---

## Tool Allowlist — What Actually Loads

The X_API_TOOL_ALLOWLIST is matched against OpenAPI operationIds. Only exact
matches load as MCP tools. As of 2026-04-23, the following tools load:

  LOADED (20 tools — full read-only surface):
  - getUsersByUsername      look up user by @handle (single)
  - getUsersByUsernames     look up users by @handles (batch)
  - getUsersById            look up user by numeric ID (single)
  - getUsersByIds           look up users by numeric IDs (batch)
  - getUsersTimeline        home/reverse-chron timeline for a user
  - getUsersPosts           posts authored by a user
  - getUsersMentions        posts mentioning a user
  - getUsersFollowers       followers list for a user
  - getUsersFollowing       following list for a user
  - getUsersLikedPosts      posts liked by a user
  - getPostsById            fetch a post by ID (single)
  - getPostsByIds           fetch posts by IDs (batch)
  - getPostsCountsRecent    post volume counts for a query (recent)
  - searchPostsRecent       full-text search, 7-day window
  - searchPostsAll          full-text search, full archive (Academic)
  - searchUsers             search users by keyword
  - getTrendsByWoeid        trending topics by location WOEID
  - getListsById            fetch a List by ID
  - getListsMembers         members of a List
  - getSpacesById           fetch a Space by ID

  NOT MATCHED (wrong operationIds — kept for historical reference):
  - getUsers        -> correct: getUsersById or getUsersByIds
  - getUserTimeline -> correct: getUsersTimeline or getUsersPosts
  - getTweetById    -> correct: getPostsById (X renamed tweets to posts)

To add more read-only tools in the future, update X_API_TOOL_ALLOWLIST in .env
and restart the server. Valid operationIds from the full list include:
  getUsersById, getUsersByIds, getUsersByUsernames, getUsersPosts,
  getUsersTimeline, getUsersMentions, getPostsById, getPostsByIds,
  getPostsCountsRecent, getTrendsByWoeid, getListsById, getListsMembers,
  searchPostsAll, searchUsers, getSpacesById, getUsersFollowers,
  getUsersFollowing, getUsersLikedPosts

---

## Running the Server

Start in background:

```
cd /root/workspace/xmcp
source .venv/bin/activate
python server.py &
```

Or use a process manager / systemd unit for persistence across reboots.

MCP endpoint: http://127.0.0.1:8000/mcp
Transport: HTTP + Server-Sent Events (SSE)

Health check (expects SSE client error, not a network error):
```
curl -s http://127.0.0.1:8000/mcp
# Expected: {"jsonrpc":"2.0","id":"server-error","error":{"code":-32600,"message":"Not Acceptable: Client must accept text/event-stream"}}
```

MCP initialize handshake test:
```
curl -s -X POST http://127.0.0.1:8000/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"0.1"}}}'
# Expected: event: message\r\ndata: {"jsonrpc":"2.0","id":1,"result":{"serverInfo":{"name":"X API MCP",...}}}
```

---

## Startup Sequence

On startup, server.py:
1. Loads .env (python-dotenv)
2. Detects auth mode (Bearer Token in this config)
3. Fetches live OpenAPI spec from https://api.x.com/2/openapi.json
4. Applies X_API_TOOL_ALLOWLIST filter
5. Prints loaded tool list to stdout
6. Starts FastMCP HTTP server on MCP_HOST:MCP_PORT

At startup on 2026-04-23 21:40, the server logged:
  Loaded 20 tools from OpenAPI:
  - getListsById, getListsMembers, getPostsById, getPostsByIds,
    getPostsCountsRecent, getSpacesById, getTrendsByWoeid,
    getUsersById, getUsersByIds, getUsersByUsername, getUsersByUsernames,
    getUsersFollowers, getUsersFollowing, getUsersLikedPosts,
    getUsersMentions, getUsersPosts, getUsersTimeline,
    searchPostsAll, searchPostsRecent, searchUsers

---

## Connecting an MCP Client

Any MCP-compatible client (Claude Desktop, Hermes native MCP, etc.) can
connect to this server.

Example config for claude_desktop_config.json:
```json
{
  "mcpServers": {
    "x-api": {
      "url": "http://127.0.0.1:8000/mcp"
    }
  }
}
```

For Hermes native MCP client, add to config.yaml:
```yaml
mcp:
  servers:
    x-api:
      url: http://127.0.0.1:8000/mcp
```

---

## Pitfalls

- OAuth1 flow requires X_OAUTH_CONSUMER_KEY + X_OAUTH_CONSUMER_SECRET and
  opens a browser for interactive consent. Do not set these if you only want
  Bearer Token mode — the server will try OAuth1 if both keys are present.

- Bearer Token access is read-only. Write operations (createPosts, likePost,
  etc.) will return 403 Unauthorized at the API level even if they are in
  the allowlist.

- X API v2 renamed "tweets" to "posts" in operationIds (2023+). If migrating
  from older docs, use getPostsById not getTweetById, etc.

- The OpenAPI spec is fetched fresh at every startup. If X changes operationIds,
  the allowlist must be updated.

- Port 8000 conflicts: if another process holds port 8000, startup fails with
  "[Errno 98] address already in use". Kill the conflicting process first.

- The .env file is read from server.py's directory (Path(__file__).parent / ".env").
  It must be in /root/workspace/xmcp/.env, not a parent directory.

---

## Files

```
/root/workspace/xmcp/
  server.py          -- main server (patched for Bearer Token support)
  .env               -- local config (NOT committed, contains token)
  env.example        -- template
  requirements.txt   -- Python deps
  .venv/             -- virtualenv
  test_grok_mcp.py   -- optional Grok test client
```

---

## Status as of 2026-04-23 21:40

Server: RUNNING
PID: 11203 (python server.py)
Endpoint: http://127.0.0.1:8000/mcp
Active tools: 20 (all read-only GET operations)
Auth: Bearer Token (read-only)
