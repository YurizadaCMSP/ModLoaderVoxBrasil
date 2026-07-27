@echo off

echo ===============================================
echo          Mod Loader - VoxBrasil
echo        Compilação da Versão Pública
echo ===============================================
echo.
echo Você tem certeza de que deseja gerar uma versão FINAL?
echo.
echo Esta compilação NÃO será identificada nos logs
echo como uma versão de desenvolvimento.
echo.

choice /C SN /M "Deseja continuar"

if errorlevel 2 exit /b 1

:: Habilita compilação paralela no MSVC
set CL=/MP

:: Adiciona o pdbcopy ao PATH
set "PATH=%ProgramFiles(x86)%\Windows Kits\10\Debuggers\x86;%PATH%"

:: Inicia a geração da Release
premake5 --file=release.lua prepare --toolset=vs2022 --final-release

echo.
echo ===============================================
echo Processo concluído.
echo ===============================================
pause
