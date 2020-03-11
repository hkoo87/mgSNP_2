#!/usr/bin/python

import os, sys, getopt


infile=''
outfile=''


def checkwindow(col9,col10):
   
	ALLEL_FREQ1 = 0.20
	ALLEL_FREQ2 = 5.0
	LOW_COV = 4

	data_col9 =  col9.split(':')
	data_col10 =  col10.split(':')
	

        list2_col9 = data_col9[1].split(',')
        list2_col10 = data_col10[1].split(',')


	sum_list2_col9 = 0
	sum_list2_col10 = 0
	if data_col9[1] == '.':
		sum_list2_col9 = 0
	else:
		sum_list2_col9 = sum(map(int,list2_col9)) 

        if data_col10[1] == '.':
                sum_list2_col10 = 0
        else:
		sum_list2_col10 = sum(map(int,list2_col10))

	min_depth = 0
	if sum_list2_col9 <= sum_list2_col10:
		min_depth = sum_list2_col9
	else:
		min_depth = sum_list2_col10
	
        if data_col9[0] == '.' or data_col10[0] == '.' or min_depth <= LOW_COV:
                return "LOW_COV:DEP-" + str(min_depth)

	elif int(data_col9[0]) > 1 or int(data_col10[0]) > 1:
        	return "SKIP_MULTIALLELE:DEP-" + str(min_depth)

	elif int(data_col9[0]) == 1 or int(data_col10[0]) == 1:
 
		try:
			div_col9 = float(list2_col9[0]) /float(list2_col9[1])
		except ZeroDivisionError:
			div_col9 = 0
		
                try:
                        div_col10 = float(list2_col10[0]) /float(list2_col10[1])
                except ZeroDivisionError:
                        div_col10 = 0

		if (div_col9 <= ALLEL_FREQ1 or div_col9 >= ALLEL_FREQ2) and (div_col10 <= ALLEL_FREQ1 or div_col10 >= ALLEL_FREQ2):
			if int(data_col9[0]) == 1 and int(data_col10[0]) == 1:
				return "SKIP_SAME_SNP:DEP-" + str(min_depth)	
			elif int(data_col9[0]) == 0 and int(data_col10[0]) == 1:
				return "DIFFERENT_SNP_01:DEP-" + str(min_depth)
			else:
				return "DIFFERENT_SNP_10:DEP-" + str(min_depth)
		else:
			return "SKIP_HighAlleleFreq:DEP-" + str(min_depth)

	elif int(data_col9[0]) == 0 and int(data_col10[0]) == 0:
		return "SKIP_NO_SNP:DEP-" + str(min_depth)

	else:
		return "ERROR:UNEXPECTED OPTION:DEP-" + str(min_depth)



myopts, args = getopt.getopt(sys.argv[1:],"i:o:")

for o, a in myopts:
    if o == '-i':
        infile=a
    elif o == '-o':
        outfile=a
    else:
        print("Usage: %s -i input -o output" % sys.argv[0])


INFILE = ''
OUTFILE = ''
if os.path.isfile(infile):
	try:
		INFILE  = open(infile, "r")
       		print "\nINFO: Reading input file " + infile
	except IOError:
		print 'ERROR: Cannot open file ', + infile 
		sys.exit()
else:
	print "ERROR: Input file " + infile + " not found"
	sys.exit()

try:
	OUTFILE  = open(outfile, "w")
	print "INFO: Opened  output file " + outfile + " for writing"
except IOError:
	print 'ERROR: Cannot open file ', + outfile
	sys.exit()



count_TOTAL = 0
count_OTHER = 0
count_SKIP_MULTIALLELE = 0
count_SKIP_SAME_SNP = 0
count_DIFFERENT_SNP_01 = 0
count_DIFFERENT_SNP_10 = 0
count_SKIP_HighAlleleFreq = 0
count_SKIP_NO_SNP = 0
count_LOW_COV = 0

print "INFO: Analysing data, please wait..."

for line in INFILE:
	if not line.startswith('#'):
		line = line.rstrip('\r\n|\n')  
		info = line.split()
	
		try:
			col9 = info[9]
		except IndexError:
			print 'ERROR: SNP data for first sample not found. Terminating program ...'
			OUTFILE.close()
			os.remove(outfile)
			sys.exit()

                try:
                        col10 = info[10]
                except IndexError:
                        print 'ERROR: SNP data for second sample not found. Terminating program ...'
                        OUTFILE.close()
                        os.remove(outfile)
                        sys.exit()		
		
		result = checkwindow(col9, col10)
		OUTFILE.write(line + "\t" + result + "\n")

		result = result.split(':')[0]

		if result == 'SKIP_NO_SNP':
			count_SKIP_NO_SNP += 1
		elif result == 'SKIP_HighAlleleFreq':
			count_SKIP_HighAlleleFreq += 1
		elif result == 'DIFFERENT_SNP_01':
			count_DIFFERENT_SNP_01 += 1
                elif result == 'DIFFERENT_SNP_10':
                        count_DIFFERENT_SNP_10 += 1
		elif result == 'SKIP_SAME_SNP':
			count_SKIP_SAME_SNP += 1
		elif result == 'SKIP_MULTIALLELE':
			count_SKIP_MULTIALLELE += 1
                elif result == 'LOW_COV':
                        count_LOW_COV += 1
		else:
			count_OTHER += 1

		count_TOTAL += 1


	else:
		OUTFILE.write(line)


print "INFO: Output written in file named " + outfile
print "\nINFO: -------------------STATS----------------------"
print "INFO: Total-sites\t", count_TOTAL
print "INFO: Ignored low coverage sites\t", count_LOW_COV 
print "INFO: Ignored Multiallelic sites\t",count_SKIP_MULTIALLELE
print "INFO: Ignored HighAllele frequency SNPs", count_SKIP_HighAlleleFreq
print "INFO: No SNPs observed\t", count_SKIP_NO_SNP
print "INFO: Same SNPs observed\t", count_SKIP_SAME_SNP
print "INFO: Different SNPs observed as 0 1\t", count_DIFFERENT_SNP_01
print "INFO: Different SNPs observed as 1 0\t", count_DIFFERENT_SNP_10
print "INFO: -------------------STATS----------------------\n"
print "INFO: Program finished sucessfully ...\n" 
OUTFILE.close()
INFILE.close()








