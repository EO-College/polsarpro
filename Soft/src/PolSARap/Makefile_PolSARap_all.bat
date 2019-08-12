echo "PolSARap"

IF NOT EXIST "..\..\bin\PolSARap" mkdir "..\..\bin\PolSARap"

g++ -I ..\lib\alglib ..\lib\alglib\ap.cpp ..\lib\alglib\alglibinternal.cpp ..\lib\alglib\linalg.cpp ..\lib\alglib\alglibmisc.cpp ..\lib\alglib\solvers.cpp ..\lib\alglib\optimization.cpp PolSARap_Cryosphere_Decomposition.c -o ..\..\bin\PolSARap\PolSARap_Cryosphere_Decomposition.exe -lm -static -lcomdlg32 -lole32 -fopenmp
gcc -g -Wall ..\lib\PolSARproLib.c PolSARap_Cryosphere_Inversion.c -o ..\..\bin\PolSARap\PolSARap_Cryosphere_Inversion.exe -lm -static -lcomdlg32 -lole32 -fopenmp
gcc -g -Wall ..\lib\PolSARproLib.c PolSARap_Agriculture_Decomposition.c -o ..\..\bin\PolSARap\PolSARap_Agriculture_Decomposition.exe -lm -static -lcomdlg32 -lole32 -fopenmp
gcc -g -Wall ..\lib\PolSARproLib.c PolSARap_Agriculture_Inversion_Dihedral.c -o ..\..\bin\PolSARap\PolSARap_Agriculture_Inversion_Dihedral.exe -lm -static -lcomdlg32 -lole32 -fopenmp
gcc -g -Wall ..\lib\PolSARproLib.c PolSARap_Agriculture_Inversion_Surface.c -o ..\..\bin\PolSARap\PolSARap_Agriculture_Inversion_Surface.exe -lm -static -lcomdlg32 -lole32 -fopenmp
gcc -g -Wall ..\lib\PolSARproLib.c PolSARap_Forest_Height_Estimation_Dual_Baseline.c -o ..\..\bin\PolSARap\PolSARap_Forest_Height_Estimation_Dual_Baseline.exe -lm -static -lcomdlg32 -lole32 -fopenmp
gcc -g -Wall ..\lib\PolSARproLib.c PolSARap_Ocean.c -o ..\..\bin\PolSARap\PolSARap_Ocean.exe -lm -static -lcomdlg32 -lole32 -fopenmp
gcc -g -Wall ..\lib\PolSARproLib.c PolSARap_Urban.c -o ..\..\bin\PolSARap\PolSARap_Urban.exe -lm -static -lcomdlg32 -lole32 -fopenmp
del *.o
cd ..\..\src\PolSARproSIM
Makefile_PolSARproSIM_all.bat