import random
import string
stroke = ''
position = random.randint(0,5)
for x in range(0,6):#генерация одной строки
    if(x != position):
        stroke += "".join(random.choice(string.digits))
    else:
        stroke += '3'
print(stroke)
