# A hub in WSL with KiCad on Windows

On a Windows PC the hub can run headless in WSL2 (Ubuntu 22.04) and be used
from the Windows browser, with KiCad installed only on Windows. The scripts are
in `scripts/wsl/`.

## Setup

The build lives in a clone inside WSL, `/root/src/Backplane`. Bend 2.0.36 and clang 19 are set up by
`/root/bp-tools/env.sh`:

```sh
. /root/bp-tools/env.sh
cd /root/src/Backplane && scripts/build.sh   # dist/backplane-serve + dist/web
```

Agent CLIs (Claude Code at `~/.local/bin/claude`) are installed and signed in
inside WSL, as on any Linux machine.

## Running it

`scripts/wsl/Backplane.cmd` starts the hub in WSL and opens
`http://127.0.0.1:3787/`. Copy it to the desktop; `DISTRO` and `HUB` at its top
name the distribution and the clone's `hub.sh`.

`scripts/wsl/hub.sh start|stop|status` does the work inside WSL. `start` is a
no-op while a hub holds `<home>/hub.lock`; otherwise it starts
`dist/backplane-serve` detached with `setsid` (the hub's `--headless` alone
stays attached, so the calling `wsl.exe` would never return), with:

- `--no-tailscale`, port `BACKPLANE_PORT` (3787), home `BACKPLANE_HOME`
  (`~/.backplane-bend`), binary `BACKPLANE_BIN`;
- `BACKPLANE_NO_UPDATE=1`, so the self-updater never replaces a local build
  with a release;
- `BACKPLANE_KICAD_CLI` set to `scripts/wsl/kicad-cli`.

Its log is `<home>/headless.log`.

## KiCad on Windows

`scripts/wsl/kicad-cli` runs Windows' `kicad-cli.exe`
(`BACKPLANE_WIN_KICAD_CLI`, else the first `/mnt/*/Program*/KiCad/*/bin/`).
Every argument that starts with `/`, and the value of a `--opt=/path`, goes
through `wslpath -w`; everything else passes untouched. Carriage returns are
stripped from both output streams and the exit status is the exe's. The hub
sees it as stock KiCad.

Works: ERC and DRC (the Checks page), exports (gerbers, drill, PDF, SVG,
positions, GLB), BOMs and releases. The board,
schematic and 3D viewers parse files themselves and need no KiCad.

Does not work: editing over IPC (`kicad_ipc`) and Open in KiCad. Both need the
Backplane build of KiCad, which is Linux-only.

## Security

The hub must stay on `127.0.0.1`. WSL forwards localhost to Windows, so the
browser reaches it there. Never start it with `--host 0.0.0.0`: that exposes
the hub, and the agents it runs with your accounts, to the network.
