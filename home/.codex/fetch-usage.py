#!/usr/bin/env python3
# Fetch Codex plan usage via the app-server and cache it in the same shape as claude-usage.json.
import json
import os
import subprocess
import sys
import tempfile

CACHE = os.path.expanduser("~/.cache/codex-usage.json")

proc = subprocess.Popen(["codex", "app-server"], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                        stderr=subprocess.DEVNULL, text=True)

def send(msg):
    proc.stdin.write(json.dumps(msg) + "\n")
    proc.stdin.flush()

def call(id_, method, params=None):
    send({"id": id_, "method": method, **({"params": params} if params else {})})
    for line in proc.stdout:
        msg = json.loads(line)
        if msg.get("id") == id_:
            return msg
    sys.exit(1)

try:
    call(1, "initialize", {"clientInfo": {"name": "tmux-usage", "version": "0.1"}})
    send({"method": "initialized"})
    res = call(2, "account/rateLimits/read")
    if "error" in res:  # access token expired: refresh it once and retry
        call(3, "account/read", {"refreshToken": True})
        res = call(4, "account/rateLimits/read")
finally:
    proc.kill()

limits = res.get("result", {}).get("rateLimits")
if not limits:
    sys.exit(1)

def window(w):
    return w and {"used_percentage": w["usedPercent"], "resets_at": w["resetsAt"]}

out = {"five_hour": window(limits.get("primary")), "seven_day": window(limits.get("secondary"))}
os.makedirs(os.path.dirname(CACHE), exist_ok=True)
fd, tmp = tempfile.mkstemp(dir=os.path.dirname(CACHE))
with os.fdopen(fd, "w") as f:
    json.dump(out, f)
os.replace(tmp, CACHE)
