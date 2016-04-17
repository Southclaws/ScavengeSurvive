# This script reads all lines in water.dat and processes them into arrays containing their relevant values.
f = open("./water.dat", "r")
writeFile = open("./output.txt", "w")
lines = f.readlines()
writeFile.write("new Float:squares[][] = {}")
curlength = 4
for string in lines:
    coords = string.split("    ") #Split in four whitespaces
    if len(coords) == 4:
        min = coords[0].split(" ")
        max = coords[3].split(" ")
        writeFile.write("{" + min[0] + ", " + min[1] +  ", " + max[0] + ", " + max[1] + ", " + min[2] +  "},\n")
    else:
        if curlength == 4:
            writeFile.write("};\nnew Float:triangles[][] = {")
            curlength = 3
        min = coords[0].split(" ")
        mid = coords[1].split(" ")
        max = coords[2].split(" ")
        writeFile.write("{" + min[0] + ", " + min[1] +  ", " + mid[0] + ", " + mid[1] +  ", " + max[0] + ", " + max[1] + ", " + min[2] + "},\n")
writeFile.write("};")
f.close()
writeFile.close()
print "ho!"
