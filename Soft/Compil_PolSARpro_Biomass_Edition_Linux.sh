#!/bin/sh
rm -rf bin
rm src/lib/PolSARproLib.o

echo "-----------------------"
echo "Copy Librairies"
mkdir bin
cp -R src/lib bin/lib/
cd bin/lib
rm *.c
rm *.h
echo "-----------------------"

cd ../../src/basis_change
make -f Makefile_basis_change.linux
rm *.o
cd ../bmp_process
make -f Makefile_bmp_process.linux
rm *.o
cd ../calculator
make -f Makefile_calculator.linux
rm *.o
cd ../calibration
make -f Makefile_calibration.linux
rm *.o
cd ../data_convert
make -f Makefile_data_convert.linux
rm *.o
cd ../data_import
make -f Makefile_data_import.linux
rm *.o
cd ../data_process_dual
make -f Makefile_data_process_dual.linux
rm *.o
cd ../data_process_mult
make -f Makefile_data_process_mult.linux
rm *.o
cd ../data_process_sngl
make -f Makefile_data_process_sngl.linux
rm *.o
cd ../speckle_filter
make -f Makefile_speckle_filter.linux
rm *.o
cd ../tools
make -f Makefile_tools.linux
rm *.o

echo "-----------------------"
cd ../PolSARap
echo "Compile PolSARap"
mkdir -p "../../bin/PolSARap"
g++ -I ../lib/alglib ../lib/alglib/ap.cpp ../lib/alglib/alglibinternal.cpp ../lib/alglib/linalg.cpp ../lib/alglib/alglibmisc.cpp ../lib/alglib/solvers.cpp ../lib/alglib/optimization.cpp PolSARap_Cryosphere_Decomposition.c -o ../../bin/PolSARap/PolSARap_Cryosphere_Decomposition.exe -lm -fopenmp -pthread
gcc -g -Wall ../lib/PolSARproLib.c PolSARap_Cryosphere_Inversion.c -o ../../bin/PolSARap/PolSARap_Cryosphere_Inversion.exe -lm -fopenmp -pthread
gcc -g -Wall ../lib/PolSARproLib.c PolSARap_Agriculture_Decomposition.c -o ../../bin/PolSARap/PolSARap_Agriculture_Decomposition.exe -lm -fopenmp -pthread
gcc -g -Wall ../lib/PolSARproLib.c PolSARap_Agriculture_Inversion_Dihedral.c -o ../../bin/PolSARap/PolSARap_Agriculture_Inversion_Dihedral.exe -lm -fopenmp -pthread
gcc -g -Wall ../lib/PolSARproLib.c PolSARap_Agriculture_Inversion_Surface.c -o ../../bin/PolSARap/PolSARap_Agriculture_Inversion_Surface.exe -lm -fopenmp -pthread
gcc -g -Wall ../lib/PolSARproLib.c PolSARap_Forest_Height_Estimation_Dual_Baseline.c -o ../../bin/PolSARap/PolSARap_Forest_Height_Estimation_Dual_Baseline.exe -lm -fopenmp -pthread
gcc -g -Wall ../lib/PolSARproLib.c PolSARap_Ocean.c -o ../../bin/PolSARap/PolSARap_Ocean.exe -lm -fopenmp -pthread
gcc -g -Wall ../lib/PolSARproLib.c PolSARap_Urban.c -o ../../bin/PolSARap/PolSARap_Urban.exe -lm -fopenmp -pthread

echo "-----------------------"
cd ../PolSARproSIM
echo "Compile PolSARproSIM"
mkdir -p "../../bin/PolSARproSIM"
gcc -o ../../bin/PolSARproSIM/PolSARproSim.exe PolSARproSim.c Allometrics.c Attenuation.c Branch.c c3Vector.c c33Matrix.c Complex.c Cone.c Crown.c Cylinder.c d3Vector.c d33Matrix.c Drawing.c Facet.c GraphicIMage.c GrgCyl.c Ground.c InfCyl.c JLkp.c Jnz.c Leaf.c LightingMaterials.c MonteCarlo.c Perspective.c Plane.c PolSARproSim_Direct_Ground.c PolSARproSim_Forest.c PolSARproSim_Procedures.c PolSARproSim_Progress.c PolSARproSim_Short_Vegi.c Ray.c RayCrownIntersection.c Realisation.c SarIMage.c Shuffling.c Sinc.c soilsurface.c Spheroid.c Tree.c YLkp.c -lm -fopenmp -pthread
gcc -o ../../bin/PolSARproSIM/PolSARproSim_ImgSize.exe PolSARproSim_ImgSize.c -lm -fopenmp -pthread
gcc -o ../../bin/PolSARproSIM/PolSARproSim_FE_Kz.exe ../lib/PolSARproLib.c PolSARproSim_FE_Kz.c -lm -fopenmp -pthread

echo "-----------------------"
cd ../PolSARproSIMgr
echo "Compile PolSARproSIMgr"
mkdir -p "../../bin/PolSARproSIMgr"
gcc -o ../../bin/PolSARproSIMgr/PolSARproSim_gr.exe PolSARproSim.c Allometrics.c Attenuation.c Branch.c c3Vector.c c33Matrix.c Complex.c Cone.c Crown.c Cylinder.c d3Vector.c d33Matrix.c Drawing.c Facet.c GraphicIMage.c GrgCyl.c Ground.c InfCyl.c JLkp.c Jnz.c Leaf.c LightingMaterials.c MonteCarlo.c Perspective.c Plane.c PolSARproSim_Direct_Ground.c PolSARproSim_Forest.c PolSARproSim_Procedures.c PolSARproSim_Progress.c PolSARproSim_Short_Vegi.c Ray.c RayCrownIntersection.c Realisation.c SarIMage.c Shuffling.c Sinc.c soilsurface.c Spheroid.c Tree.c YLkp.c -lm -fopenmp -pthread
gcc -o ../../bin/PolSARproSIMgr/PolSARproSimGR_ImgSize.exe PolSARproSimGR_ImgSize.c -lm -fopenmp -pthread
gcc -o ../../bin/PolSARproSIMgr/PolSARproSim_FE_Kz.exe ../lib/PolSARproLib.c PolSARproSim_FE_Kz.c -lm -fopenmp -pthread

echo "-----------------------"
cd ../PolSARproSIMsv
echo "Compile PolSARproSIMsv"
mkdir -p "../../bin/PolSARproSIMsv"
gcc -o ../../bin/PolSARproSIMsv/PolSARproSim_sv.exe PolSARproSim.c Allometrics.c Attenuation.c Branch.c c3Vector.c c33Matrix.c Complex.c Cone.c Crown.c Cylinder.c d3Vector.c d33Matrix.c Drawing.c Facet.c GraphicIMage.c GrgCyl.c Ground.c InfCyl.c JLkp.c Jnz.c Leaf.c LightingMaterials.c MonteCarlo.c Perspective.c Plane.c PolSARproSim_Direct_Ground.c PolSARproSim_Forest.c PolSARproSim_Procedures.c PolSARproSim_Progress.c PolSARproSim_Short_Vegi.c Ray.c RayCrownIntersection.c Realisation.c SarIMage.c Shuffling.c Sinc.c soilsurface.c Spheroid.c Tree.c YLkp.c -lm -fopenmp -pthread
gcc -o ../../bin/PolSARproSIMsv/PolSARproSimSV_ImgSize.exe PolSARproSimSV_ImgSize.c -lm -fopenmp -pthread
gcc -o ../../bin/PolSARproSIMsv/PolSARproSim_FE_Kz.exe ../lib/PolSARproLib.c PolSARproSim_FE_Kz.c -lm -fopenmp -pthread

echo "-----------------------"
cd ../SVM
echo "Compile SVM"
mkdir -p "../../bin/SVM"
g++ -Wall -g -Wconversion -O3 -c svm.cpp
g++ -Wall -g -Wconversion -O3 svm-predict.c svm.o -o ../../bin/SVM/svm_predict_polsarpro.exe -lm -fopenmp -pthread
g++ -Wall -g -Wconversion -O3 svm-train.c svm.o -o ../../bin/SVM/svm_train_polsarpro.exe -lm -fopenmp -pthread
g++ -Wall -g -Wconversion -O3 svm-scale.c svm.o -o ../../bin/SVM/svm_scale_polsarpro.exe -lm -fopenmp -pthread
gcc -g ../lib/PolSARproLib.c svm_classifier.c -o ../../bin/SVM/svm_classifier.exe -lm -fopenmp -pthread
gcc -g ../lib/PolSARproLib.c write_best_cv_results.c -o ../../bin/SVM/write_best_cv_results.exe -lm -fopenmp -pthread
gcc -g ../lib/PolSARproLib.c grid_polsarpro.c -o ../../bin/SVM/grid_polsarpro.exe -lm -fopenmp -pthread
gcc -g ../lib/PolSARproLib.c svm_confusion_matrix.c -o ../../bin/SVM/svm_confusion_matrix.exe -lm -fopenmp -pthread

echo "-----------------------"
cd ../map_algebra_psp/linux/map_algebra
echo "Compile Map_Algebra_PSP"
make -f Makefile_map_algebra_psp.linux
rm *.o
cp ../../../../bin/map_algebra/linux/map_algebra_psp.exe ../../../../bin/map_algebra/linux/map_algebra_gimp.exe

echo "-----------------------"
cd ../../../map_algebra_satim/linux/map_algebra
echo "Compile Map_Algebra_SATIM"
make -f Makefile_map_algebra_satim.linux
rm *.o

echo "-----------------------"
echo "End of PolSARpro Compilation"
echo "-----------------------"
