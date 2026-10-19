@echo off
setlocal
set "DISTRO=Ubuntu"
set "HUB=/root/src/Backplane/scripts/wsl/hub.sh"
set "URL=http://127.0.0.1:3787/"

wsl.exe -d %DISTRO% -e bash -lc "%HUB% start"
if errorlevel 1 (
  echo Backplane hub did not start.
  pause
  exit /b 1
)
start "" "%URL%"
