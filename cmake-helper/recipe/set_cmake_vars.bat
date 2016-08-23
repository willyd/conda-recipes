@echo off

if DEFINED LIBRARY_PREFIX (
    :: Default to LIBRARY_PREFIX when building packages
    set CMAKE_LIBRARY_PREFIX=%LIBRARY_PREFIX%
)

if NOT DEFINED CMAKE_LIBRARY_PREFIX (
    if DEFINED CONDA_PREFIX (
        :: LIBRARY_PREFIX is not defined but CMAKE_LIBRARY_PREFIX is when not in the root env
        set CMAKE_LIBRARY_PREFIX=%CONDA_PREFIX%\Library
    ) else (
        :: Maybe in root when check for python exe
        where python 1>&2 2> nul
        if NOT ERRORLEVEL 1 (
            for /F "tokens=* USEBACKQ" %%F in (`python -c "import sys; import os; print(os.path.join(sys.prefix, 'Library'))"`) DO (
                set var=%%F
            )
            set CMAKE_LIBRARY_PREFIX=%var%
        )
    )
)

:: We could not find the library prefix
if NOT DEFINED CMAKE_LIBRARY_PREFIX (
    echo "Could not find library prefix please set the LIBRARY_PREFIX env variable."
    exit /b 1
)

:: Folder where we should store the Find*.cmake modules
set CMAKE_MODULE_DIR=%CMAKE_LIBRARY_PREFIX%\cmake\modules
:: Make the variables cmake friendly, i.e. Unix style
set CMAKE_MODULE_PATH=%CMAKE_MODULE_DIR:\=/%
set CMAKE_INSTALL_PREFIX=%CMAKE_LIBRARY_PREFIX:\=/%
set CMAKE_INSTALL_PREFIX_ALT=%CMAKE_INSTALL_PREFIX%/alt
set CMAKE_PREFIX_PATH=%CMAKE_LIBRARY_PREFIX:\=/%
:: Make the alt folder first on the prefix path so that it is search first
set CMAKE_PREFIX_PATH=%CMAKE_PREFIX_PATH%/alt;%CMAKE_PREFIX_PATH%
:: Set the default install prefix

