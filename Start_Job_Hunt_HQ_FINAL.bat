@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo.
echo ========================================
echo        Job Hunt HQ - Launcher
echo ========================================
echo.
echo Folder:
echo %~dp0
echo.

REM Find the actual HTML file in THIS folder.
set "HTMLFILE="
for %%F in ("%~dp0*.html") do (
    if not defined HTMLFILE set "HTMLFILE=%%~nxF"
)

if not defined HTMLFILE (
    echo ERROR: No .html file was found in this folder.
    echo.
    echo Make sure the Job Hunt HQ HTML file is beside this BAT.
    echo.
    pause
    exit /b 1
)

echo Found HTML:
echo %HTMLFILE%
echo.

REM Use a fixed local port.
set "PORT=8765"
set "URL=http://127.0.0.1:%PORT%/%HTMLFILE%"

echo Starting local web server...
echo.

REM Start Python with the BAT's folder as the explicit server directory.
where py.exe >nul 2>&1
if %errorlevel%==0 (
    start "Job Hunt HQ Server" cmd /c "cd /d ""%~dp0"" && py -m http.server %PORT% --bind 127.0.0.1"
    goto WAIT
)

where python.exe >nul 2>&1
if %errorlevel%==0 (
    start "Job Hunt HQ Server" cmd /c "cd /d ""%~dp0"" && python -m http.server %PORT% --bind 127.0.0.1"
    goto WAIT
)

echo ERROR: Python was not found.
pause
exit /b 1

:WAIT
echo Waiting for the page to become available...

set /a N=0
:CHECK
set /a N+=1

powershell.exe -NoProfile -Command "try { $r=Invoke-WebRequest -UseBasicParsing -Uri '%URL%' -TimeoutSec 2; if($r.StatusCode -eq 200){exit 0}else{exit 1} } catch { exit 1 }" >nul 2>&1

if %errorlevel%==0 goto READY
if %N% GEQ 20 goto FAIL

timeout /t 1 /nobreak >nul
goto CHECK

:READY
echo.
echo ========================================
echo SERVER READY
echo ========================================
echo.
echo Opening:
echo %URL%
echo.

start "" "%URL%"

echo Job Hunt HQ is now running.
echo You may minimize this window.
echo.
echo Close the "Job Hunt HQ Server" window when finished.
echo.
pause
exit /b 0

:FAIL
echo.
echo ========================================
echo COULD NOT OPEN JOB HUNT HQ
echo ========================================
echo.
echo The server started, but this page did not respond:
echo %URL%
echo.
echo IMPORTANT: The BAT found this HTML file:
echo %HTMLFILE%
echo.
echo If you see a Python server window, leave it open and send me
echo a screenshot of that window.
echo.
pause
exit /b 1
