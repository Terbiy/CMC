#include <stdio.h>
#define N 100

int binarySearch(unsigned int arrLen, int sortedArr[], int searchNum)
{
    unsigned int first = 0;
    unsigned int last = arrLen;

    if (arrLen == 0) {
      printf("В массиве не содержится элементов.");
      return -1;
    } else if (sortedArr[0] > searchNum) {
      printf("Запрашиваемый элемент меньше чем минимальное значение в массиве.");
      return -1;
    } else if (sortedArr[arrLen - 1] < searchNum) {
      printf("Запрашиваемый элемент больше чем максимальное значение в массиве.");
      return -1;
    }

    while (first < last) {
      unsigned int mid = first + (last - first) / 2;

      if (searchNum <= sortedArr[mid])
        last = mid;
      else
        first = mid + 1;
    }

    if (sortedArr[last] == searchNum) {
      printf("Запрашиваемый элемент находится на позиции %d.", last);
      return last;
    } else {
      printf("Элемент в массиве отсутствует.");
      return -1;
    }
}


int main()
{
  int numbers[N], num, i, j, temp, searchNum, position;
 
  printf("Сначала отсортируем массив элементов.\n");
  printf("Число элементов массива: ");
  scanf("%d", &num);
 
  printf("Введите %d чисел\n", num);
 
  for (i = 0; i < num; i++)
    scanf("%d", &numbers[i]);
 
  for (i = 0 ; i < ( num - 1 ); i++)
  {
    for (j = 0 ; j < num - i - 1; j++)
    {
      if (numbers[j] > numbers[j+1])
      {
        temp       = numbers[j];
        numbers[j]   = numbers[j+1];
        numbers[j+1] = temp;
      }
    }
  }
 
  printf("Массив отсортированный в порядке возрастания:\n");
 
  for ( i = 0 ; i < num ; i++ ) {
    printf("%d", numbers[i]);
    (i == num - 1) ? printf("\n") : printf(", ");
  }

  printf("Введите искомое число: ");
  scanf("%d", &searchNum);
  position = binarySearch(5, numbers, searchNum);

  return 0;
}