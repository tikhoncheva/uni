addPathOpenGM('/export/home/etikhonc/Documents/Tools/opengm-master/', ... % openGMSourceDir 
              '/export/home/etikhonc/Documents/Tools/opengm-master/');  % openGMBuildDir

disp('creating empty model');
gm = openGMModel;
disp('printing model info');
opengm('modelinfo', 'm', gm);
disp('adding variables');
gm.addVariables([2,1,3,5,2,2]);
disp('printing model info again');
opengm('modelinfo', 'm', gm);
disp('clearing all');
clear all;
%exit;