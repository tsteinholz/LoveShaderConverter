@echo off
echo Welcome to Love Shader Converter,
echo this file needs to be executed from the same directory as the EXE.
echo
set /p file="Please enter the shader file:"
LoveShaderConverter.exe %file%
pause
