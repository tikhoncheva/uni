disp('compile all the mex files...');

%cd commonFunctions
directory = { 'commonFunctions', 'kdtree', 'BruteSearch120909' };
ext = { 'cpp', 'c', 'cc' };

for j=1:length(directory)
    cd(directory{j}); 
    for i=1:length(ext)

        listOfFiles = dir( [ '*.' ext{i} ]);

        for j=1:length(listOfFiles)
            disp([ 'mex ' listOfFiles(j).name ]);
            eval([ 'mex ' listOfFiles(j).name ]);
        end

    end

    cd ..
end