@echo off

if "%~1"=="/?" (
    goto :help
)

set name=%~1
set fullname=%~2
set destination_arg=%~3
set option=%4
set option_extras=%5

set temp_dest=%temp%\dest.temp

:: Isolate Locals
setlocal EnableDelayedExpansion
if not defined directories_env set directories_env=%userprofile%\.noir\directories.env
call :loadenvs
if defined dest_%destination_arg% echo !dest_%destination_arg%! > %temp_dest%
endlocal
:: Isolate 

if exist %temp_dest% set /p destination=<%temp_dest% 
del %temp_dest% 
if not defined destination set destination=%destination_arg%

mkdir %destination% 2>nul
pushd %destination%
set "option=%~4"
if not defined option set option=.cmd

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

:: Because the Start Menu passes the complete file path,
:: while the command line just passes the file name.
if /i "%name%"=="%fullname%.cmd" (
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

:help
cls
echo =======================================================
echo         Omni Folder Navigation Utility Help
echo =======================================================
echo.
echo USAGE:
echo   omni ^<script^> ^<scriptBase^> ^<destination^> [option]
echo.
echo PARAMETERS:
echo   ^<script^>      : Full path of this script (e.g., %%~0).
echo   ^<scriptBase^>  : Base name of the script (e.g., %%~dpn0).
echo   ^<destination^> : Folder to navigate to. This folder will be created if it does not already exist.
echo   [option]        : Optional argument that determines the action.
echo   [option_extras] : Optional argument that complements an option.
echo.
echo OPTIONS:
echo   -s    : Open the destination folder in the default file explorer.
echo           NOTE: When using -s, the script leaves the current directory changed to the destination folder.
echo   -n    : Open the destination folder in Nvim.
echo           NOTE: When using -n, the script returns to the original directory after launching Nvim.
echo   -c    : Copy the current directory path to the clipboard.
echo           NOTE: When using -c, the current directory remains changed to the destination folder.
echo    / ^<text^>
echo         : Search for the text provided and allows the user to open the file in Nvim 
echo    \ ^<text^>
echo         : Search for the file name and path, allows opening it in Nvim or Explorer
echo   ^<filename^>
echo         : Open the specified file in Nvim (provided the file does not begin with a dot).
echo           NOTE: When opening a file, the script returns to the original directory after launching Nvim.
echo.
echo SPECIAL CASE:
echo   When launched from the Start Menu, the first parameter may equal the script
echo   base name with a .cmd extension. In this case, a new command prompt window is opened.
echo.
echo EXAMPLES:
echo   omni %%0 %%~dpn0 %%dest%% %%1
echo       - Change to the destination folder (%%dest%%).
echo   omni %%0 %%~dpn0 %%dest%% -s
echo       - Open the destination folder in the file explorer.
echo         (The current directory remains set to %%dest%%.)
echo   omni %%0 %%~dpn0 %%dest%% -n
echo       - Open the destination folder in Nvim.
echo         (The script then returns to the original directory.)
echo   omni %%0 %%~dpn0 %%dest%% -c
echo       - Copy the current directory path to the clipboard.
echo         (The current directory remains set to %%dest%%.)
echo   omni %%0 %%~dpn0 %%dest%% myfile.txt
echo       - Open "myfile.txt" in Nvim.
echo         (The script returns to the original directory after launching Nvim.)
pause >nul
goto :EOF

:: Loadenv function
:loadenvs
for /f "tokens=1,2 delims==" %%a in ('findstr "=" %directories_env%') do (
    set "dest_%%a=%%b"
)
goto :EOF
