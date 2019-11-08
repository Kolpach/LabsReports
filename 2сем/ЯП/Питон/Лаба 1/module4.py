def chet( a ):
    if (int(a) % 2 == 0):
        return True
    return False
def ne_chet( a ):
    if (int(a) % 2 != 0):
        return True
    return False
print("Введите число: ")
number = int(input())
countOfChet = 0
countOfNeChet = 0
while (number!=0):
    b = number % 10
    if(b != 0): 
        countOfChet = countOfChet + int(chet(b))
        countOfNeChet = countOfNeChet + int(ne_chet(b))
    number = number // 10
print("Количество чётных: ", countOfChet, "\nКоличество нечётных: ", countOfNeChet)
