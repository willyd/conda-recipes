call set_cmake_vars

for %%B in (Debug Release) DO (
      md build_%%B
      pushd build_%%B

      :: Configure.
      cmake -G "Ninja" ^
            -D BUILD_SHARED_LIBS=ON ^
            -D CMAKE_BUILD_TYPE=%%B ^
            -D CMAKE_PREFIX_PATH=%CMAKE_PREFIX_PATH% ^
            -D CMAKE_MODULE_PATH=%CMAKE_MODULE_PATH% ^
            -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
            -D GFLAGS_BUILD_gflags_nothreads_LIB=OFF ^
            -D CMAKE_DEBUG_POSTFIX=d ^
            %SRC_DIR%
      if errorlevel 1 exit 1

      :: Build.
      cmake --build . --target install --config %%B
      if errorlevel 1 exit 1

      popd
)

:: Copy FindGFlags.cmake resource file to Library\cmake
call copy_find_module GFlags

:: Copy dll to bin folder so that it is on the path
copy /Y "%LIBRARY_LIB%\gflags*.dll" "%LIBRARY_BIN%"




