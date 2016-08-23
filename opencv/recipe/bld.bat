call set_cmake_vars

:: Patch the cmake list to have relocatable packages and allow building with Ninja
copy /Y "%RECIPE_DIR%\CMakeListsPatch.txt" "%SRC_DIR%\CMakeLists.txt"

:: Clone the 3rdparty to by-pass firewall limitations
:: Make sure we don't clone with the autocrlf option on.
git clone https://github.com/opencv/opencv_3rdparty.git -c core.autocrlf=false
pushd opencv_3rdparty
git checkout ffmpeg/master_20150703
popd

:: Set the opencv ffmpeg url for firewall reasons
:: Make sure there is a / at the end!
set OPENCV_FFMPEG_URL=file:///%SRC_DIR%/opencv_3rdparty/ffmpeg/
set OPENCV_FFMPEG_URL=%OPENCV_FFMPEG_URL:\=/%

if "%CONDA_CUDA_VERSION%" == "" (
  echo Building without CUDA
  set WITH_CUDA=0
) else (
echo Building with CUDA
  set WITH_CUDA=1
)

for %%B in (Debug Release) DO (
      md build_%%B
      pushd build_%%B

      :: Configure.
      cmake -G "Ninja" ^
            -D CMAKE_BUILD_TYPE=%%B                                        ^
            -D BUILD_SHARED_LIBS=ON                                        ^
            -D BUILD_TESTS=0                                               ^
            -D BUILD_DOCS=0                                                ^
            -D BUILD_PERF_TESTS=0                                          ^
            -D BUILD_PACKAGE=0                                             ^
            -D BUILD_WITH_STATIC_CRT=OFF                                   ^
            -D BUILD_ZLIB=0                                                ^
            -D BUILD_TIFF=1                                                ^
            -D BUILD_PNG=1                                                 ^
            -D BUILD_OPENEXR=1                                             ^
            -D BUILD_JASPER=1                                              ^
            -D BUILD_JPEG=1                                                ^
            -D PYTHON_EXECUTABLE="%PYTHON%"                                ^
            -D PYTHON_INCLUDE_PATH="%PREFIX%\include"                      ^
            -D PYTHON_LIBRARY="%PREFIX%\libs\python%CONDA_PY%.lib"         ^
            -D PYTHON_PACKAGES_PATH="%SP_DIR%"                             ^
            -D WITH_EIGEN=0                                                ^
            -D WITH_CUDA=%WITH_CUDA%                                       ^
            -D CUDA_ARCH_BIN="3.0 3.5 3.7 5.0 5.2"                         ^
		-D CUDA_ARCH_PTX="3.0"                                         ^
            -D WITH_OPENNI=0                                               ^
            -D WITH_FFMPEG=1                                               ^
            -D OPENCV_FFMPEG_URL=%OPENCV_FFMPEG_URL%                       ^
            -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX%                  ^
            -D CMAKE_PREFIX_PATH=%CMAKE_PREFIX_PATH%                       ^
            -D CMAKE_MODULE_PATH=%CMAKE_MODULE_PATH%                       ^
            %SRC_DIR%
      if errorlevel 1 exit 1

      :: Build.
      cmake --build . --target install --config %%B
      if errorlevel 1 exit 1

      popd
)

set OPENCV_ARCH=x86
if %ARCH% EQU 64 (
    set OPENCV_ARCH=x64
)

:: Copy FindOpenCV.cmake resource file to Library\cmake
call copy_find_module OpenCV

:: Copy the opencv libs to the bin folder so that they are found on the path
:: Potentially use post-link script to make a hard link instead of copying.
copy "%LIBRARY_PREFIX%\%OPENCV_ARCH%\vc%VS_MAJOR%\bin\*.dll" "%LIBRARY_BIN%"