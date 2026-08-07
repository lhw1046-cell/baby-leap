@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

git --version >nul 2>&1
if errorlevel 1 (
  echo  [오류] Git 이 설치되어 있지 않습니다.
  echo  git-scm.com 에서 설치한 뒤 setup.bat 을 먼저 실행하세요.
  pause
  exit /b 1
)

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  if exist "%~dp0baby-leap\.git" (
    cd /d "%~dp0baby-leap"
  ) else (
    echo  [오류] 저장소를 찾을 수 없습니다.
    echo  같은 폴더의 setup.bat 을 먼저 실행하세요.
    pause
    exit /b 1
  )
)

echo.
echo  ============================================
echo   자동 반영 감시 중
echo  ============================================
echo.
echo  폴더: %CD%
echo  파일을 저장하면 30초 안에 자동으로 올라갑니다.
echo  중지하려면 이 창을 닫으세요.
echo.

:loop
timeout /t 30 /nobreak >nul

git status --porcelain > "%TEMP%\bl_status.txt" 2>nul
for %%A in ("%TEMP%\bl_status.txt") do set "SIZE=%%~zA"
if "!SIZE!"=="0" goto loop

echo  [%time:~0,8%] 변경 감지 - 올리는 중...
git add -A >nul 2>&1
git commit -m "auto %date:~0,10% %time:~0,5%" >nul 2>&1
git push >nul 2>&1
if errorlevel 1 (
  echo  [%time:~0,8%] 실패 - publish.bat 을 직접 실행해 원인을 확인하세요.
) else (
  echo  [%time:~0,8%] 반영 완료
)
goto loop
