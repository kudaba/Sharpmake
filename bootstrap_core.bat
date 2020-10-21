@echo off

:: Clear previous run status
COLOR

:: set batch file directory as current
pushd "%~dp0"

set SHARPMAKE_EXECUTABLE=tmp\bin\debug\sharpmake.application\Sharpmake.Application.exe

call CompileSharpmake_core.bat Sharpmake.Application/Sharpmake.Application_Core.csproj Debug
if %errorlevel% NEQ 0 goto error

set SHARPMAKE_MAIN="Sharpmake.Main.sharpmake.cs"
if not "%~1" == "" (
    set SHARPMAKE_MAIN="%~1"
)

set SM_CMD=%SHARPMAKE_EXECUTABLE% /sources('%SHARPMAKE_MAIN%') /verbose
echo %SM_CMD%
%SM_CMD%
if %errorlevel% NEQ 0 goto error

goto success

@REM -----------------------------------------------------------------------
:success
COLOR 2F
echo Bootstrap succeeded^!
timeout /t 5
exit /b 0

@REM -----------------------------------------------------------------------
:error
COLOR 4F
echo Bootstrap failed^!
pause
set ERROR_CODE=1
goto end

@REM -----------------------------------------------------------------------
:end
:: restore caller current directory
popd
exit /b %ERROR_CODE%
