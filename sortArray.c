#include <stdio.h>
#define N 100
 
int main()
{
  int numbers[N], num, i, j, temp;
 
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

  return 0;
}