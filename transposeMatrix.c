#include <stdio.h>
#define ROWS 2
#define COLS 5

void transposeMatrix(int initialMatrix[][COLS], int transposedMatrix[][ROWS], int rowsNum, int columnsNum)
{
  int i, j;

  for(i = 0; i < rowsNum; i++)
    for(j = 0; j < columnsNum; j++)
      transposedMatrix[j][i] = initialMatrix[i][j];
}

void printMatrix(int matrix[][ROWS], int rowsNum, int columnsNum)
{
  int i, j;

  for(i = 0; i < rowsNum; i++) {
    printf("|");
    
    for(j = 0; j < columnsNum; j++)
      printf("%3d%0s", matrix[i][j], (j != columnsNum - 1) ? "," : "");

    printf("|\n");
  }
}

void main()
{

  int matrix[ROWS][COLS] =
  {
    {0,1,2,3,4},
    {5,6,7,8,9}
  };
  int transposedMatrix[COLS][ROWS];

  transposeMatrix(matrix, transposedMatrix, ROWS, COLS);
  printMatrix(transposedMatrix, COLS, ROWS);

  return;
}