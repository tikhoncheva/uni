import sys 


with open('exp_out_file') as infile, open('process.csv', 'w') as outfile:
    copy = False
#    for line in open(filein):
    for line in infile:
       # line = line.strip()
        if line.strip() == "Permutations:":
            copy = True
        elif line.strip() == "Experiment parameters:":
            copy = False
        elif copy:
            outfile.write(line)
        
        
 
outfile.close()
