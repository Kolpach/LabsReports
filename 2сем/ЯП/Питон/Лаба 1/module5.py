import random
import string
stringList = []
numberOfStrokes = 0
for j in range(100):
    stroke = ''
    for x in range(0,6):#генерация одной строки
        stroke += "".join(random.choice(string.ascii_lowercase))
    stringList.append( stroke )
    #print(stringList[j])
j,x = 0,0
for j in range(0, 100):
    for x in range(0,6):
        if(stringList[j][x] == 't'):
            print(stringList[j])
            numberOfStrokes += 1;
            break;
print(numberOfStrokes)
