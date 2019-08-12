echo "SVM"

IF NOT EXIST "..\..\bin\SVM" mkdir "..\..\bin\SVM"

g++ -Wall -g -Wconversion -O3 -c svm.cpp
g++ -Wall -g -Wconversion -O3 svm-predict.c svm.o -o ..\..\bin\SVM\svm_predict_polsarpro.exe -lm -static -lcomdlg32 -lole32 -fopenmp
g++ -Wall -g -Wconversion -O3 svm-train.c svm.o -o ..\..\bin\SVM\svm_train_polsarpro.exe -lm -static -lcomdlg32 -lole32 -fopenmp
g++ -Wall -g -Wconversion -O3 svm-scale.c svm.o -o ..\..\bin\SVM\svm_scale_polsarpro.exe -lm -static -lcomdlg32 -lole32 -fopenmp
gcc -g ..\lib\PolSARproLib.c svm_classifier.c -o ..\..\bin\SVM\svm_classifier.exe -lm -static -lcomdlg32 -lole32 -fopenmp
gcc -g ..\lib\PolSARproLib.c write_best_cv_results.c -o ..\..\bin\SVM\write_best_cv_results.exe -lm -static -lcomdlg32 -lole32 -fopenmp
gcc -g ..\lib\PolSARproLib.c grid_polsarpro.c -o ..\..\bin\SVM\grid_polsarpro.exe -lm -static -lcomdlg32 -lole32 -fopenmp
gcc -g ..\lib\PolSARproLib.c svm_confusion_matrix.c -o ..\..\bin\SVM\svm_confusion_matrix.exe -lm -static -lcomdlg32 -lole32 -fopenmp

del *.o
