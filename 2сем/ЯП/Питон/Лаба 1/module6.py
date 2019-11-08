import math
def length_of_year(R, Speed):
     return int(2*R* math.pi /speed)
print("Введите радиус в 10^6: ")
radius = int(input())
print("Введите скорость в км/ч: ")
speed = int(input())
radius = radius * 10000
speed = speed * 36 * 23.93
print("Speed is: ", length_of_year(radius, speed))