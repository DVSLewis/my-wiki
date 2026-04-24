# xmcp — OAuth1 PIN (Out-of-Band) Flow

## Status
Added 2026-04-24. Applies to /root/workspace/xmcp/server.py.

---

## Problem

The original OAuth1 implementation in xmcp assumed an interactive desktop
environment. It called `webbrowser.open()` and spun up a local HTTP server
on port 8976 to capture the redirect callback from X.

On a headless server (e.g. Zo running as a daemon, a Docker container, or
an SSH session), both of these steps fail silently or block forever:

- No browser is available to open.
- X cannot reach the local HTTP server for the callback redirect.

---

## Solution: oauth_callback='oob'

The OAuth1 spec defines an "out-of-band" (oob) callback mode.  When a client
sends `oauth_callback=oob` in the request-token step, X:

1. Issues the request token normally.
2. After the user authorizes at the authorization URL, instead of redirecting
   to a callback URL, X displays a short numeric PIN on the page.
3. The client uses that PIN as the `oauth_verifier` when exchanging for an
   access token.

This requires no local HTTP server and no browser on the host machine.  The
operator visits the authorization URL on any device (phone, laptop, etc.) and
pastes the PIN back to the server via stdin.

---

## Env Var

```
X_OAUTH_OOB=1
```

Accepted truthy values: `1`, `true`, `yes`, `on` (case-insensitive).
Default (unset or `0`): browser-redirect flow (original behavior, unchanged).

---

## Code Structure After Patch

```
run_oauth1_flow()                   <-- dispatcher (checks X_OAUTH_OOB)
  |
  +-- _run_oauth1_pin_flow()        <-- NEW: oob/PIN path
  |       OAuth1Session(callback_uri="oob")
  |       prints authorization URL to stdout
  |       reads PIN from stdin via input()
  |       exchanges PIN for access token
  |
  +-- _run_oauth1_browser_flow()    <-- REFACTORED: original logic, unchanged
          OAuth1Session(callback_uri="http://host:port/path")
          webbrowser.open(...)
          _wait_for_callback(...)   <-- local HTTP server, still present
```

---

## Developer Portal Requirement

The X app must be configured for PIN-based or oob auth:

- In the X Developer Portal, under "User Authentication Settings", set the
  Callback / Redirect URI to `oob` (literally the string "oob"), OR leave it
  blank for PIN-based apps.
- If the portal has a real HTTPS callback URL set and the code sends `oob`,
  X will return a 401 / oauth_callback_not_confirmed error.

---

## Usage: First-Time Setup on a Headless Server

1. Set env vars in your .env or shell:

   ```
   X_OAUTH_CONSUMER_KEY=<your-consumer-key>
   X_OAUTH_CONSUMER_SECRET=<your-consumer-secret>
   X_OAUTH_OOB=1
   X_OAUTH_PRINT_TOKENS=1    # optional: prints tokens to stdout after auth
   ```

2. Start xmcp normally. It will block at the PIN prompt:

   ```
   === OAuth1 PIN Authorization ===
   Open this URL in any browser and authorize the app:
     https://api.twitter.com/oauth/authorize?oauth_token=...

   Enter the PIN shown by X after authorization: _
   ```

3. Open the URL on any device, authorize, copy the PIN, paste it into the
   terminal. xmcp will exchange the PIN for access tokens and continue startup.

4. (Optional) To skip the flow on subsequent starts, capture the tokens from
   step 1 and set them directly:

   ```
   X_OAUTH_ACCESS_TOKEN=<access-token>
   X_OAUTH_ACCESS_TOKEN_SECRET=<access-secret>
   ```

   With both of these set, the OAuth1 flow is bypassed entirely at startup.

---

## Env Var Reference (OAuth1)

| Variable                  | Default           | Description                              |
|---------------------------|-------------------|------------------------------------------|
| X_OAUTH_CONSUMER_KEY      | (required)        | App consumer key                         |
| X_OAUTH_CONSUMER_SECRET   | (required)        | App consumer secret                      |
| X_OAUTH_OOB               | 0                 | Set to 1 to use PIN/oob flow             |
| X_OAUTH_ACCESS_TOKEN      | (empty)           | Pre-supplied access token (skips flow)   |
| X_OAUTH_PRINT_TOKENS      | 0                 | Print access tokens to stdout after auth |
| X_OAUTH_PRINT_AUTH_HEADER | 0                 | Print signed Authorization header        |
| X_OAUTH_CALLBACK_HOST     | 127.0.0.1         | Browser-flow only: callback host         |
| X_OAUTH_CALLBACK_PORT     | 8976              | Browser-flow only: callback port         |
| X_OAUTH_CALLBACK_PATH     | /oauth/callback   | Browser-flow only: callback path         |
| X_OAUTH_CALLBACK_TIMEOUT  | 300               | Browser-flow only: timeout (seconds)     |

---

## Cross-References

- wiki/agent-build-order.md — Zo agent context; this flow enables Zo to
  authenticate on first deploy without a desktop environment.
- /root/workspace/xmcp/server.py — patched source, functions:
    _run_oauth1_pin_flow, _run_oauth1_browser_flow, run_oauth1_flow
- X OAuth1 docs: https://developer.twitter.com/en/docs/authentication/oauth-1-0a/pin-based-oauth
