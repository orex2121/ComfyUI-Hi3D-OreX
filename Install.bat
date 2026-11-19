@echo off
setlocal EnableExtensions
chcp 65001 >nul
title ComfyUI-Hi3D-OreX dependency installer

set "NODE_DIR=%~dp0"
set "PYTHON=%NODE_DIR%..\..\..\python_embeded\python.exe"

echo ============================================================
echo   ComfyUI-Hi3D-OreX - Portable ComfyUI dependency installer
echo ============================================================
echo.

if not exist "%PYTHON%" (
    echo [ERROR] Portable ComfyUI Python was not found:
    echo         %PYTHON%
    echo.
    echo Place this node pack in ComfyUI\custom_nodes\ComfyUI-Hi3D-OreX
    goto :failed
)

echo [1/4] Checking the Portable ComfyUI Python and PyTorch...
"%PYTHON%" -c "import torch; print('Python/Torch:', torch.__version__, 'CUDA:', torch.version.cuda)"
if errorlevel 1 goto :failed

set "CUDA_FILE=%TEMP%\hi3d_orex_cuda_%RANDOM%_%RANDOM%.txt"
"%PYTHON%" -c "import torch; print('cu' + torch.version.cuda.replace('.', '') if torch.version.cuda else 'cpu')" > "%CUDA_FILE%"
if errorlevel 1 (
    del /q "%CUDA_FILE%" >nul 2>&1
    goto :failed
)
set /p "CUDA_TAG="<"%CUDA_FILE%"
del /q "%CUDA_FILE%" >nul 2>&1

if /I "%CUDA_TAG%"=="cu126" goto :cuda_supported
if /I "%CUDA_TAG%"=="cu128" goto :cuda_supported
if /I "%CUDA_TAG%"=="cu130" goto :cuda_supported
echo [ERROR] Unsupported PyTorch CUDA build: %CUDA_TAG%
echo         Supported builds: cu126, cu128, cu130.
goto :failed

:cuda_supported
echo [2/4] Installing the regular Python requirements without replacing dependencies...
"%PYTHON%" -m pip install --disable-pip-version-check --no-input --no-deps -r "%NODE_DIR%requirements.txt"
if errorlevel 1 goto :failed

echo [3/4] Installing sparse CUDA packages for %CUDA_TAG%...
"%PYTHON%" -m pip install --disable-pip-version-check --no-input --only-binary=:all: --extra-index-url https://ratharog.github.io/cumm-spconv/ "cumm-%CUDA_TAG%==0.9.1" "spconv-%CUDA_TAG%==2.4.1"
if errorlevel 1 goto :failed

echo [4/4] Verifying spconv without changing PyTorch...
"%PYTHON%" -c "import torch; import spconv.pytorch as spconv; import cumm; spconv.SubMConv3d(4, 8, 3); print('OK - Torch', torch.__version__, '- spconv is ready')"
if errorlevel 1 goto :failed

echo.
echo [SUCCESS] Dependencies are installed. Fully restart ComfyUI.
echo.
pause
exit /b 0

:failed
echo.
echo [FAILED] Installation was not completed. Read the error above.
echo         PyTorch was not intentionally installed or replaced by this script.
echo.
pause
exit /b 1
