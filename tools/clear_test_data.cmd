@echo off
rem Double-click launcher for clear_test_data.ps1.
rem Pass the family id as the first argument to skip the prompt:
rem   clear_test_data.cmd <familyId>
setlocal
pushd "%~dp0.."
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0clear_test_data.ps1" %*
set "RC=%ERRORLEVEL%"
popd
if "%~1"=="" pause
exit /b %RC%
