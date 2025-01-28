echo "assinar executavel"

SignTool sign /f mycert.pfx /p bnhg80 c:\energy\PROJ_CR.exe
SignTool sign /f mycert.pfx /p bnhg80 c:\energy\CR_RELATORIOS.exe

pause
