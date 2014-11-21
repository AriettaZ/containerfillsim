########################################################################
#This python script will create bounding box for a CFP job
#It is based on LOG-surfaceCheck created from surfaceCheck
#
#Author: Summer Wang @ Ohio Supercomputer Center
#Email: xwang@osc.edu
#Date: 09/10/2013
########################################################################

#import numpy
#import string
import re

outputFile = 'newfile'

inputFile = open('LOG-surfaceCheck', 'r')

#lineList = inputFile.readlines()
#startLine = lineList[25]

for line in inputFile:
	li=line.strip()
	if li.startswith('Bounding Box'):
		name, number =li.split(':', 1)
		number = re.sub('[()]',  '', number)
#		print number
		numberList = number.split(' ')
		minX = float(numberList[1])
		minY = float(numberList[2])
		minZ = float(numberList[3])
		maxX = float(numberList[4])
		maxY = float(numberList[5])
		maxZ = float(numberList[6])
		dx = (maxX-minX)/2.0
		dy = (maxY-minY)/2.0
		dz = (maxZ-minZ)/2.0
		minX = minX - dx
		minY = minY - dy
		minZ = minZ - dz
		maxX = maxX + dx
		maxY = maxY + dy
		maxZ = maxZ + dz

ofile = open(outputFile, 'w')
ofile.write('vertices' + '\n')
ofile.write('(' + '\n')
ofile.write('   ('+ str(minX) + ' ' + str(minY) + ' ' + str(minZ) + ')' + '\n')
ofile.write('   ('+ str(maxX) + ' ' + str(minY) + ' ' + str(minZ) + ')' + '\n')
ofile.write('   ('+ str(maxX) + ' ' + str(maxY) + ' ' + str(minZ) + ')' + '\n')
ofile.write('   ('+ str(minX) + ' ' + str(maxY) + ' ' + str(minZ) + ')' + '\n')
ofile.write('   ('+ str(minX) + ' ' + str(minY) + ' ' + str(maxZ) + ')' + '\n')
ofile.write('   ('+ str(maxX) + ' ' + str(minY) + ' ' + str(maxZ) + ')' + '\n')
ofile.write('   ('+ str(maxX) + ' ' + str(maxY) + ' ' + str(maxZ) + ')' + '\n')
ofile.write('   ('+ str(minX) + ' ' + str(maxY) + ' ' + str(maxZ) + ')' + '\n')
ofile.write(');' + '\n')
ofile.close()

