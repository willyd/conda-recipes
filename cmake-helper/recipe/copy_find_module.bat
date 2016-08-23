@echo off
:: Create the cmake module directory if it does not exist
if NOT EXIST "%CMAKE_MODULE_DIR%" ( md "%CMAKE_MODULE_DIR%" )
:: Copy the package Find module to CMAKE_MODULE_DIR
copy /Y "%RECIPE_DIR%\Find%1.cmake" "%CMAKE_MODULE_DIR%" || exit 1