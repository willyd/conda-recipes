@echo off

:: Set the module folder
call %RECIPE_DIR%\set_cmake_vars.bat

:: Copy the generic find module there
if NOT EXIST "%CMAKE_MODULE_DIR%" (mkdir "%CMAKE_MODULE_DIR%")
copy /Y "%RECIPE_DIR%\GenericFindModuleConfig.cmake" "%CMAKE_MODULE_DIR%\GenericFindModuleConfig.cmake"

:: Copy the needed batch scripts
copy /Y %RECIPE_DIR%\set_cmake_vars.bat %SCRIPTS%
copy /Y %RECIPE_DIR%\unset_cmake_vars.bat %SCRIPTS%
copy /Y %RECIPE_DIR%\test_cmake_package.bat %SCRIPTS%
copy /Y %RECIPE_DIR%\copy_find_module.bat %SCRIPTS%