:: Set different cmake variables
call set_cmake_vars

:: Patch the CMakeLists
copy /Y %RECIPE_DIR%\CMakeLists.txt.in %SRC_DIR%\CMakeLists.txt

for %%B in (Debug Release) DO (
      md build_%%B
      pushd build_%%B

      :: Configure.
      cmake -G "Ninja" ^
            -D CMAKE_BUILD_TYPE=%%B ^
            -D CMAKE_PREFIX_PATH=%CMAKE_PREFIX_PATH% ^
            -D CMAKE_INSTALL_PREFIX:PATH=%CMAKE_INSTALL_PREFIX_ALT% ^
            -D CMAKE_DEBUG_POSTFIX=d ^
            -D ZLIB_TARGET_NAME_PREFIX=alt- ^
            %SRC_DIR%
      if errorlevel 1 exit 1

      :: Build.
      cmake --build . --target install --config %%B
      if errorlevel 1 exit 1

      :: Test.
      ctest
      if errorlevel 1 exit 1

      popd
)

:: Copy FindZLIB.cmake resource file to Library\cmake
call copy_find_module ZLIB

:: Copy dlls to Library/bin so they can be found on the path
copy /Y "%LIBRARY_PREFIX%\alt\bin\*zlib*.dll" "%LIBRARY_BIN%"

