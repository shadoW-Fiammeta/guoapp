@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0.."
where python >nul 2>nul
if errorlevel 1 (
  echo 请先安装 Python 3.10 或更新版本，并加入 PATH。
  pause
  exit /b 1
)
python scripts\build_windows.py --all-sources %*
if errorlevel 1 (
  echo 构建未完成，请查看上面的错误和 README 的 Windows 构建说明。
  pause
  exit /b 1
)
echo 已生成电脑端压缩包，位置：dist\windows
explorer "%CD%\dist\windows"
pause
