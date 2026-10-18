@echo off
setlocal
cd /d "%~dp0"

where node >nul 2>&1
if errorlevel 1 (
  echo Node.js is not installed or is not on PATH.
  echo Install Node.js, then run this launcher again.
  pause
  exit /b 1
)

if not exist "node_modules\express" (
  echo Installing SmartAttend dependencies...
  call npm install
  if errorlevel 1 (
    echo Dependency installation failed. Check the messages above.
    pause
    exit /b 1
  )
)

where curl.exe >nul 2>&1
if errorlevel 1 (
  echo curl.exe is required for the startup check but was not found.
  echo Install a current Windows version with curl.exe, or run npm start in this folder.
  pause
  exit /b 1
)

curl.exe --silent --fail --max-time 1 http://127.0.0.1:3002/api/departments >nul 2>&1
if not errorlevel 1 goto ready

start "SmartAttend Server" cmd /k npm start

for /L %%i in (1,1,20) do (
  curl.exe --silent --fail --max-time 1 http://127.0.0.1:3002/api/departments >nul 2>&1
  if not errorlevel 1 goto ready
  ping.exe -n 2 127.0.0.1 >nul
)

echo SmartAttend did not respond on port 3002.
echo Check the SmartAttend Server window for errors.
pause
exit /b 1

:ready
start "" "http://localhost:3002/"
