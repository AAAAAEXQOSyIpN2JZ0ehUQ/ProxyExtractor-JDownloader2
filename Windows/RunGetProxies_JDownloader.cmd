@echo off
REM Nombre del script de PowerShell
set "scriptPath=GetProxies_JDownloader.ps1"

REM Nombre del directorio de trabajo
set "workingDirectory=Proxies"

REM Verifica si PowerShell está disponible
where powershell >nul 2>nul
if errorlevel 1 (
    echo PowerShell no está instalado. Asegúrate de que PowerShell esté disponible en tu sistema.
    pause
    exit /b 1
)

REM Verifica si el script de PowerShell existe
if not exist "%scriptPath%" (
    echo El archivo de script '%scriptPath%' no se encuentra. Asegúrate de que el archivo exista en el directorio actual.
    pause
    exit /b 1
)

REM Verifica si el directorio de trabajo existe, y si no, lo crea
if not exist "%workingDirectory%" (
    mkdir "%workingDirectory%"
)

REM Ejecuta el script de PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -File "%scriptPath%"

REM Pausa para ver los resultados
pause
