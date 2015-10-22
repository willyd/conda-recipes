@echo off
@setlocal EnableDelayedExpansion
set MSVC_ARCH_64=amd64
set MSVC_ARCH_32=x86
set MSVC_ARCH=!MSVC_ARCH_%ARCH%!
set MSVC_VER=%1
if "%MSVC_VER%" == "" (
    set MSVC_VER=%CONDA_MSVC_VER%
    )
if "%MSVC_VER%" == "" (
rem  default to v120
    set MSVC_VER=v120
    )
@endlocal & set MSVC_ARCH=%MSVC_ARCH%& set MSVC_VER=%MSVC_VER%

call "%~dp0\msvc-select.bat" %MSVC_VER%
call "%VCVARSALL%" %MSVC_ARCH%
