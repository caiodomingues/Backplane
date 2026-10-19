#!/usr/bin/env bash
# The Backplane hub in WSL, for a Windows desktop: hub.sh start|stop|status
set -u

here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/../.." && pwd)
bin=${BACKPLANE_BIN:-$repo/dist/backplane-serve}
home=${BACKPLANE_HOME:-$HOME/.backplane-bend}
port=${BACKPLANE_PORT:-3787}
url="http://127.0.0.1:$port/"

# hub.lock outlives the hub, and WSL reuses pids after every boot.
hub_pid() {
  local pid
  pid=$(cut -d' ' -f1 "$home/hub.lock" 2>/dev/null) || return 1
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null || return 1
  local exe
  exe=$(readlink "/proc/$pid/exe" 2>/dev/null) || return 1
  [ "${exe% (deleted)}" = "$(readlink -f "$bin")" ] && echo "$pid"
}

answers() { curl -s -m 2 -o /dev/null "http://127.0.0.1:$port/hello"; }

start() {
  local pid i
  if pid=$(hub_pid); then
    echo "hub already running (pid $pid) at $url"
    return 0
  fi
  [ -x "$bin" ] || { echo "no hub binary at $bin" >&2; return 1; }
  mkdir -p "$home"
  # --headless alone stays attached, so a one-shot wsl.exe never returns.
  BACKPLANE_NO_UPDATE=1 BACKPLANE_KICAD_CLI="$here/kicad-cli" \
    setsid -f nohup "$bin" --home "$home" --port "$port" --no-tailscale \
      --headless --foreground >>"$home/headless.log" 2>&1 </dev/null
  for i in $(seq 1 40); do
    if answers; then
      echo "hub running (pid $(hub_pid)) at $url"
      return 0
    fi
    sleep 0.5
  done
  echo "hub did not answer on $url within 20 s; see $home/headless.log" >&2
  return 1
}

stop() {
  local pid i
  pid=$(hub_pid) || { echo "hub not running"; return 0; }
  kill "$pid"
  for i in $(seq 1 40); do
    kill -0 "$pid" 2>/dev/null || { echo "hub stopped (pid $pid)"; return 0; }
    sleep 0.5
  done
  echo "hub (pid $pid) still running after 20 s" >&2
  return 1
}

status() {
  local pid
  if pid=$(hub_pid); then
    if answers; then echo "hub running (pid $pid) at $url"
    else echo "hub process $pid alive but $url does not answer"; return 1
    fi
  else
    echo "hub not running"
    return 3
  fi
}

case ${1:-} in
  start|stop|status) "$1" ;;
  *) echo "usage: $0 start|stop|status" >&2; exit 2 ;;
esac
