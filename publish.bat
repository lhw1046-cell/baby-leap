@echo off
setlocal
cd /d "%~dp0"

echo.
echo  ============================================
echo   baby-leap 배포
echo  ============================================
echo.

git --version >nul 2>&1
if errorlevel 1 (
  echo  [오류] Git 이 설치되어 있지 않습니다.
  echo.
  echo  git-scm.com 에서 Git for Windows 를 설치하세요.
  echo  설치 옵션은 전부 기본값으로 두면 됩니다.
  echo.
  pause
  exit /b 1
)

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  if exist "%~dp0baby-leap\.git" (
    cd /d "%~dp0baby-leap"
  ) else (
    echo  [오류] 저장소를 찾을 수 없습니다.
    echo  같은 폴더의 setup.bat 을 먼저 한 번 실행하세요.
    echo.
    pause
    exit /b 1
  )
)

rem ---------- 최초 1회: 커밋 작성자 정보 ----------
set "GEMAIL="
for /f "delims=" %%i in ('git config user.email 2^>nul') do set "GEMAIL=%%i"
if not "%GEMAIL%"=="" goto :identity_ok

echo  [최초 1회 설정]
echo  커밋 기록에 남길 이름과 이메일이 필요합니다.
echo.
set "GNAME="
set "GMAIL="
set /p "GNAME=  이름 (예: HyeonWoo Lee): "
echo.
echo  이메일은 공개 저장소 기록에 남습니다.
echo  그냥 엔터를 치면 깃허브가 주는 비공개 주소를 씁니다.
set /p "GMAIL=  이메일 (엔터 = 비공개 주소): "

if "%GNAME%"=="" set "GNAME=lhw1046-cell"
if "%GMAIL%"=="" set "GMAIL=lhw1046-cell@users.noreply.github.com"

git config --global user.name "%GNAME%"
git config --global user.email "%GMAIL%"

echo.
echo  설정했습니다. 다음부터는 묻지 않습니다.
echo    이름   : %GNAME%
echo    이메일 : %GMAIL%
echo.

:identity_ok

git add -A

git diff --cached --quiet
if not errorlevel 1 (
  echo  변경된 내용이 없습니다.
  echo.
  pause
  exit /b 0
)

echo  [변경된 파일]
git diff --cached --name-status
echo.

set "MSG=%~1"
if "%MSG%"=="" set /p "MSG=  커밋 메시지 (그냥 엔터 = 자동): "
if "%MSG%"=="" set "MSG=update %date:~0,10% %time:~0,5%"

echo.
git commit -m "%MSG%"
if errorlevel 1 goto :fail

git push
if errorlevel 1 goto :fail

echo.
echo  ============================================
echo   완료. 1~2분 뒤 반영됩니다.
echo   https://lhw1046-cell.github.io/baby-leap/
echo  ============================================
echo.
pause
exit /b 0

:fail
echo.
echo  [실패] 위 메시지를 확인하세요.
echo  처음 실행이라면 깃허브 로그인 창이 떴을 수 있습니다.
echo.
pause
exit /b 1
