del ..\lib\PolSARproLib.o
mingw32-make -f Makefile_basis_change.win
del *.o
cd ..\..\src\bmp_process
Makefile_bmp_process_all.bat
