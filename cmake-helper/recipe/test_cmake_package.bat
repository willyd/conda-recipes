@echo off
@setlocal EnableDelayedExpansion
:: A batch script that can test if CMake packages are correctly installed
:: Join all the passed packages
for %%p in (%*) do (
    set PKGS=!PKGS!'%%p',
)

:: Generate a CMakeLists template and render it
if NOT DEFINED TEMP (
    echo ERROR: Temp directory not defined
)

set _TEST_DIR=%TEMP%\test_cmake_package
if EXIST "%_TEST_DIR%" (
    rmdir /S /Q "%_TEST_DIR%"
)

mkdir "%_TEST_DIR%"
pushd "%_TEST_DIR%"
set _CMAKELISTS=cmake_minimum_required(VERSION 3.0) ^

project(test) ^

{%% for package in packages %%} ^

find_package({{ package }} REQUIRED) ^

{%% endfor %%}

echo !_CMAKELISTS! > CMakeLists.txt.template

:: Render a CMakeLists with the appropriate find_package
python -c "from jinja2 import Template; t = Template(open('CMakeLists.txt.template', 'r').read()); f = open('CMakeLists.txt', 'w'); f.write(t.render(packages=[!PKGS!]))"
:: The cmake_variables
call set_cmake_vars.bat
:: Call cmake
if EXIST build (
    rmdir /S /Q build
)
mkdir build
pushd build
cmake -G Ninja ^
      -D CMAKE_PREFIX_PATH=%CMAKE_PREFIX_PATH% ^
      -D CMAKE_MODULE_PATH=%CMAKE_MODULE_PATH% ^
      ..\
popd
popd

if ERRORLEVEL 1 (
    echo ERROR: Something is wrong with one of the provided CMake packages.
    exit /b 1
)

@endlocal