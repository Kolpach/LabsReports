import string
def compare_words(a, b):
    sovpad = 0
    for i in range(0, min(len(a), len(b))):
        if (a[len(a) - i-1] == b[len(b) - i-1]):
            sovpad += 1
        else:
            break
    return sovpad
a = str(input())
a_list = a.split(' ')
sovpad = 0
for i in range(0, len(a_list)):
    for j in range(i + 1, len(a_list)):
        if (compare_words(a_list[i], a_list[j]) > sovpad):
            sovpad = compare_words(a_list[i], a_list[j])
            a = a_list[i]
            b = a_list[j]
print(a, b)