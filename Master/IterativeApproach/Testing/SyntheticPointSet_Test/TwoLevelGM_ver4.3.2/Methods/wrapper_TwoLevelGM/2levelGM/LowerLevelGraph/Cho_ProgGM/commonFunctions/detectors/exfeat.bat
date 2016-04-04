@echo off
.\extract_features_32bit.exe -haraff -harThres 10000 -i %1\%1.png -o1 %1\%1.haraff
.\mser.exe -t 2 -es 1 -ms 30 -mm 10 -i %1\%1.png -o %1\%1.mser
