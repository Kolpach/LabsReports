import random
randomNumber=random.randint(0, 100)
userNumber = int(input("Type integer number\n"))
if(randomNumber > userNumber):
    print("Usernumber is LESS than randomnumber: ", randomNumber)
elif(randomNumber < userNumber):
    print("Usernumber is HIGHER than randomnumber: ", randomNumber)
else:
    print("Usernumber is equivalent to randomnumber: ", randomNumber)