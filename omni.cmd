@echo off

if "%~1"=="/?" (
    type "%~dp0omni-help.md"
    exit /b 0
)
set destination_arg=%~1
set option=%2
set option_extras=%3
if not defined option set option=.cmd

set temp_dest=%temp%\dest.temp
if not defined directories_env set directories_env=%userprofile%\.noir\directories.env
:: Isolate Locals
setlocal EnableDelayedExpansion
call :loadenvs
if defined dest_%destination_arg% echo !dest_%destination_arg%! > %temp_dest%
endlocal
:: Isolate 
if exist %temp_dest% set /p destination=<%temp_dest% & del %temp_dest%
if not defined destination (
  echo _%~n1=%~1>>%directories_env%
  nvim %directories_env%
  exit /b 0
)

mkdir %destination% 2>nul
pushd %destination%


if /i "%option:~0,2%"=="-s" (
    start . & goto :EOF
)

if /i "%option:~0,2%"=="-n" (
    nvim . 
    popd
    goto :EOF
)

if /i "%option%"=="/" (
  goto :searchContent
)

if /i "%option%"=="\" (
  goto :searchFile
)

if not "%option:~0,1%"=="." (
    nvim "%option%"
    popd
    goto :EOF
)

if /i "%ComSpec%" neq %CMDCMDLINE% (
    start "" cmd /k
)

goto :EOF

:searchContent
set rgCmd=rg %option_extras%
set fzfCmd=fzf --bind "enter:become(nvim {}),ctrl-e:become(start {})"
%rgCmd% | %fzfCmd%
goto :EOF

:searchFile
set esCmd=es -p -parent-path %destination% %option_extras%
set fzfCmd=fzf --bind "enter:become(nvim {}),ctrl-e:become(start explorer {})"
%esCmd% | %fzfCmd%
goto :EOF


:: Loadenv function
:loadenvs
for /f "tokens=1,2 delims==" %%a in ('findstr "=" %directories_env%') do (
    set "dest_%%a=%%b"
)
goto :EOF
