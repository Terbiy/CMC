#include <stdio.h>
#define N 100

int binarySearch(unsigned int arrLen, int sortedArr[], int searchNum)
{
    unsigned int first = 0;
    unsigned int last = arrLen;

    if (arrLen == 0) {
      printf("� ���ᨢ� �� ᮤ�ন��� ����⮢.");
      return -1;
    } else if (sortedArr[0] > searchNum) {
      printf("����訢���� ����� ����� 祬 �������쭮� ���祭�� � ���ᨢ�.");
      return -1;
    } else if (sortedArr[arrLen - 1] < searchNum) {
      printf("����訢���� ����� ����� 祬 ���ᨬ��쭮� ���祭�� � ���ᨢ�.");
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
      printf("����訢���� ����� ��室���� �� ����樨 %d.", last);
      return last;
    } else {
      printf("������� � ���ᨢ� ���������.");
      return -1;
    }
}


int main()
{
  int numbers[N], num, i, j, temp, searchNum, position;
 
  printf("���砫� ������㥬 ���ᨢ ����⮢.\n");
  printf("��᫮ ����⮢ ���ᨢ�: ");
  scanf("%d", &num);
 
  printf("������ %d �ᥫ\n", num);
 
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
 
  printf("���ᨢ �����஢���� � ���浪� �����⠭��:\n");
 
  for ( i = 0 ; i < num ; i++ ) {
    printf("%d", numbers[i]);
    (i == num - 1) ? printf("\n") : printf(", ");
  }

  printf("������ �᪮��� �᫮: ");
  scanf("%d", &searchNum);
  position = binarySearch(5, numbers, searchNum);

  return 0;
}