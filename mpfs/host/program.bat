@echo off
REM ============================================================================
REM  program.bat -- one-click launcher for FlashPro Express to program the
REM  Discovery Kit (MPFS095T) with the delivered job (sar_top_095t.job).
REM  No Libero needed. See docs/PROGRAM_THE_BOARD.md.
REM
REM  Put sar_top_095t.job in the SAME folder as this script (or edit JOB below).
REM ============================================================================
setlocal
set "JOB=%~dp0sar_top_095t.job"

REM ---- locate FlashPro Express (edit FPEXPRESS if your install path differs) ----
set "FPEXPRESS="
for %%P in (
  "C:\Microchip\Program_Debug_v2025.1\Program_Debug_Tool\bin64\FPExpress.exe"
  "C:\Microchip\Program_Debug_v2024.1\Program_Debug_Tool\bin64\FPExpress.exe"
  "C:\Microchip\FlashPro_Express\bin64\FPExpress.exe"
  "C:\Microchip\Libero_SoC_2025.2\Libero_SoC\Designer\bin64\FPExpress.exe"
) do if exist %%~P set "FPEXPRESS=%%~P"

if "%FPEXPRESS%"=="" (
  echo.
  echo  [!] FlashPro Express was not found automatically.
  echo      Install it from Microchip's free "Programming and Debug" tools, then set the
  echo      FPEXPRESS path near the top of this script and re-run.
  echo.
  pause
  exit /b 1
)

if not exist "%JOB%" (
  echo.
  echo  [!] Job file not found:  %JOB%
  echo      Place sar_top_095t.job next to this script.
  echo.
  pause
  exit /b 1
)

echo.
echo  Found FlashPro Express: %FPEXPRESS%
echo  Job:                    %JOB%
echo.
echo  Launching FlashPro Express. In the window that opens:
echo     1. Project -^> Import (or "Open Job Project") -^> select the job above.
echo     2. Confirm the programmer + MPFS095T target are detected.
echo     3. Click RUN.  Wait for  PROGRAM PASSED  (green).
echo     4. Power-cycle the board.
echo.
start "" "%FPEXPRESS%"
endlocal
