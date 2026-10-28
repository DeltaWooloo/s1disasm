@ECHO OFF

REM // This file has been gutted and replaced with the Lua build script.
REM // It has been kept around for ease-of-use for Windows users.
"build_tools/Lua/lua.exe" build.lua || pause REM // Pause on Lua parse failure so that the user can read the error message.

REM // Convenience batch script to build the ROM and open it in the default emulator if compilation succeeds.
REM // Requires ".bin" files to be associated with an emulator.

if /i "%~1" == "-r" goto :Run
if /i "%~1" == "--run" goto :Run
exit

:Run
if exist s1built.bin (
    start "" s1built.bin
)
