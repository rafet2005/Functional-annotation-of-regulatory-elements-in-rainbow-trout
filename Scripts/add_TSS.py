fileName = input("Enter file name: ")

myFile = open (fileName , 'r')
outputFile = open ("Gene_TSS", 'w')

for line in myFile:
#	outputFile.write(line)
	tmp =line.split('\t')
	if tmp[6] == '-':
		print(f"{tmp[0]}\t{int(tmp[4])-1}\t{tmp[4]}\tTSS" , file= outputFile)
		print(f"{tmp[0]}\t{int(tmp[4])-1-2000}\t{int(tmp[4])+2000}\tTSS2Kb" , file= outputFile)
		print(f"{tmp[0]}\t{int(tmp[3])-1}\t{tmp[3]}\tTES" , file= outputFile)
	else:
		print(f"{tmp[0]}\t{tmp[3]}\t{int(tmp[3])+1}\tTSS" , file= outputFile)
		print(f"{tmp[0]}\t{int(tmp[3])-2000}\t{int(tmp[3])+1+2000}\tTSS2Kb" , file= outputFile)
		print(f"{tmp[0]}\t{int(tmp[4])-1}\t{tmp[4]}\tTES" , file= outputFile)

myFile.close()
outputFile.close()
