@echo off
@setlocal EnableDelayedExpansion

set MSVC_PRODUCT_VERS=(90, 100, 110, 120, 140)
if "%1" == "" (
    echo "No MSVC version prodived. Valid values are: %MSVC_PRODUCT_VERS%"
    goto :error
    )

for %%v in %MSVC_PRODUCT_VERS% do (
    if "%1" == "%%v" (
        set MSVC_PRODUCT_VER=%%v
        )
    if "%1" == "v%%v" (
        set MSVC_PRODUCT_VER=%%v
        )
)

if not defined MSVC_PRODUCT_VER (
    echo "Invalid MSVC version prodived %1. Valid values are: %MSVC_PRODUCT_VERS%"
    goto :error
    )
echo Using MSVC version %MSVC_PRODUCT_VER%
set VCVARSALL=!VS%MSVC_PRODUCT_VER%COMNTOOLS!..\..\VC\vcvarsall.bat
if not exist "%VCVARSALL%" (
    echo File "%VCVARSALL%" does not exist
    goto :error
    )

@endlocal & set VCVARSALL=%VCVARSALL%& set /a MSVC_PRODUCT_VER=%MSVC_PRODUCT_VER%/10
goto :end

:error
set ERRORLEVEL=1

:end

