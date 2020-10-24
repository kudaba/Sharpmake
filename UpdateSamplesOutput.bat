@echo off

:: Clear previous run status
COLOR

:: First compile sharpmake to insure we are trying to deploy using an executable corresponding to the code.
call CompileSharpmake.bat Sharpmake.sln Debug "Any CPU"
if %errorlevel% NEQ 0 goto error

set SHARPMAKE_EXECUTABLE=%~dp0tmp\bin\Debug\sharpmake.application\Sharpmake.Application.exe
if not exist %SHARPMAKE_EXECUTABLE% set SHARPMAKE_EXECUTABLE=%~dp0tmp\bin\Release\sharpmake.application\Sharpmake.Application.exe
if not exist %SHARPMAKE_EXECUTABLE% echo Cannot find sharpmake executable in %~dp0tmp\bin & pause & goto error

echo Using executable %SHARPMAKE_EXECUTABLE%

:: main
set ERRORLEVEL_BACKUP=0

:: Source file is .sh so line endings are lf instead of crlf
for /f "tokens=*" %%i in (UpdateSamplesOutputSource.sh) do (
    for /f "tokens=1,2,3,4 delims=;" %%a in ("%%i") do (
        call :UpdateRef %%a  %%b %%c reference %%d
        if not "%ERRORLEVEL_BACKUP%" == "0" goto error
    )
)

@COLOR 2F
echo References update succeeded!
timeout /t 5
goto end

:: function Update the reference folder that's used for regression tests
:: params:  testScopedCurrentDirectory,
::          folderPath,
::          mainFile,
::          outputDirectory
::          remapRootPath
:UpdateRef
:: backup current directory
pushd %CD%
:: set testScopedCurrentDirectory as current
cd /d %~dp0%~1

echo Updating references of %2...
rd /s /q "%~2\%~4"
call %SHARPMAKE_EXECUTABLE% /sources(@'%~2\%~3') /outputdir(@'%~2\%~4') /remaproot(@'%~5') /verbose
set ERRORLEVEL_BACKUP=%errorlevel%
:: restore caller current directory
popd
goto :end

:end
exit /b 0

:error
@COLOR 4F
pause
exit /b 1
