#! /usr/bin/python

import os, sys, getopt, re

def getCIGARstats(tab5):
	readLength = 0
	clipLength = 0
	indelLength = 0
	tab5 = tab5.strip()
	match_all = re.findall( r"([0-9]*[MIDNSHP=X]*)", tab5, re.I)
	for item in match_all:
		if re.match('.*H|.*S',item):
			tmp_item = item.strip('HS')
			clipLength += int(tmp_item)
			readLength += int(tmp_item)
		elif re.match('.*M|.*=|.*X',item):
			tmp_item = item.strip('MX=')
			readLength += int(tmp_item)
		elif re.match('.*I|.*D',item):
			tmp_item = item.strip('ID')
 			indelLength += int(tmp_item)
		else:
			pass
	return readLength, clipLength, indelLength

def getMDstats(tab11):
	MD_tag = tab11.split(':')
	MD = MD_tag[2]
	matchLength = 0
	mismatchLength = 0
	deletionLength = 0

	match_all = re.findall( "(\^[A-Z]*)", MD, re.I)
	for item in match_all:
        	if item != '':
                	tmp_item = item.strip('^')
                	deletionLength += len(tmp_item)

	match_all = re.findall( "([A-Z]*)", MD, re.I)
	for item in match_all:
        	if item != '':
                	mismatchLength += len(item)

	match_all = re.findall( "([0-9]*)", MD, re.I)
	for item in match_all:
        	if item != '':
                	matchLength += int(item)

	mismatchLength = mismatchLength - deletionLength
	return matchLength, mismatchLength, deletionLength

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

MIN_ALIGN_LENGTH = 70
MIN_PERCENT_MATCH = 90

for line in INFILE:
        if not line.startswith('@'):
                line = line.rstrip('\r\n|\n')  
                tab = line.split()
		tab2 = tab[2]
                tab5 = tab[5]
                tab9 = tab[9]
		tab12 = tab[12]

		if tab2 == '*' or tab5 == '*':
			pass
		else:
			readLength, clipLength, indelLength = getCIGARstats(tab5)
			alignLength = readLength - clipLength

			matchLength, mismatchLength, deletionLength = getMDstats(tab12)
			percentMatch = 100 * (float(matchLength) / float(matchLength + mismatchLength))
			if alignLength > MIN_ALIGN_LENGTH and percentMatch >= MIN_PERCENT_MATCH:
				OUTFILE.write(line + "\n")


	else:
		OUTFILE.write(line)

print "INFO: Program completed. Output file  " + outfile + " generated.\n"
