@echo off

if "%~1"=="/?" (
    type "%~dp0omni-help.md"
    exit /b 0
)


set omni=%userprofile%\.omni\
if not exist %omni% mkdir %omni%
if not defined alias_list set alias_list=%omni%.env

:: Open alias list in editor when no argument is provided
if ""=="%~1" (
    nvim %alias_list%
    exit /b 0
)

:: Initialize variables based on positional arguments
set destination_arg=%~1
set option=%2
set option_extras=%3

set temp_dest=%temp%\dest.temp

:: Isolate Locals
setlocal EnableDelayedExpansion
call :loadenvs
if defined dest_%destination_arg% echo !dest_%destination_arg%! > %temp_dest%
endlocal
:: Isolate 

if exist %temp_dest% set /p destination=<%temp_dest% & del %temp_dest%

if not defined destination (
    echo _%~n1=%~1>>%alias_list%
    nvim %alias_list%
    exit /b 0
)

mkdir %destination% 2>nul
pushd %destination%


if /i "%option%"=="-e" (
    start .
    popd
    goto :EOF
)

if /i "%option%"=="-n" (
    nvim . 
    popd
    goto :EOF
)

if /i "%option%"=="-c" (
    cd | clip
    popd
    goto :EOF
)

if /i "%option%"=="/" (
  goto :searchContent
)

if /i "%option%"=="\" (
  goto :searchFile
)

if /i "%option%"=="-f" (
    nvim "%option_extras%"
    goto :EOF
)

if /i "%ComSpec% /c" == "%CMDCMDLINE:~0,30%" (
    start "" cmd /k
)

goto :EOF

:searchContent
set rgCmd=rg %option_extras%
set fzfCmd=fzf --bind "enter:become(nvim {}),ctrl-e:become(start {})"
%rgCmd% | %fzfCmd%
goto :EOF

:searchFile
set esCmd=es -p -path "%cd%" %option_extras%
set fzfCmd=fzf --bind "enter:become(nvim {}),ctrl-e:become(start explorer {})"
%esCmd% | %fzfCmd%
goto :EOF


:: Loadenv function
:loadenvs
for /f "tokens=1,2 delims==" %%a in ('findstr "=" %alias_list%') do (
    set "dest_%%a=%%b"
)
goto :EOF

:backAndOut
popd
:goto :EOF
