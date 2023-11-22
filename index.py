def print_elements_above_both_diagonals(matrix):
    rows = len(matrix)
    cols = len(matrix[0])

    print("Элементы выше главной и побочной диагонали:")
    for i in range(rows):
        for j in range(cols):
            if j > i and j < (cols - i - 1):
                print(matrix[i][j], end=" ")
            else:
                print(" ", end=" ")
        print()

# Пример матрицы
matrix = [
    [1, 2, 3, 4, 5],
    [6, 7, 8, 8, 1],
    [9, 10, 11, 12, 1],
    [13, 14, 15, 16, 1],
    [13, 14, 15, 16, 1],
]

# Вывести элементы выше главной и побочной диагонали
print_elements_above_both_diagonals(matrix)

