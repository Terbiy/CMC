;                   файл: ex1.asm
;Вывод чисел знаковых / беззнаковых
Include io.asm ; Подключение внешнего файла io.asm
;подключены операции ввода-вывода

S Segment stack; стек 128 байт
  db 128 dup (?)
S Ends

D Segment
  res db 'Итог:$'
  wrong db 'Ошибка при вводе.$'
  sameInt db 'Цифры в начале и конце строки совпадают.$'
  char db 128 dup (?)
  null db '0'
  fInt db ?
  sInt db ?
D Ends

Cd Segment ;Сегмент кода
   Assume ss:S, ds: D, cs:Cd
start:
;============================
; КОМАНДЫ ПРОГРАММЫ

  ; Прямое указание на начало регистра данных
  ; Без этого указания выводится куча мусора
  mov ax, D
  mov ds, ax

  mov bx, 0

; Ввод строки
;    mov bx, 0
;    mov cx, 5
;rC:
;    inch char[bx]
;    inc bx
;    loop rC

cI:
  ; Ввод строки
  inch char[bx]
  cmp char[bx], '.'
  je lE
  inc bx
  cmp bx, 10
  je nI
  jne cI

lE:
  ; Вывод строки
  lea dx, res
  outstr dx
  newline
  mov char[bx], '$'
  lea dx, char
  outstr dx

  ; Определение наличия свойства строки
  ; Строка начинается цифрой и заканчивается
  ; цифрой, причём другой.
  mov al, char
  sub al, null
  cmp al, 0
  jg gZF
  jmp exit ; Разница меньше 0
gZF:
  cmp al, 9
  jl fTrue
  jmp exit

  ; Первый символ оказался цифрой,
  ; проверяем последний символ.
fTrue:
  mov fInt, al
  dec bx
  mov al, char[bx]
  sub al, null
  jg gZS
  jmp exit
gZS:
  cmp al, 9
  jl sTrue
  jmp exit

sTrue:
  mov sInt, al
  ; Сравнивать напрямую две ячейки памяти нельзя.
  cmp fInt, al
  je sameInts

  ; Вывод оповещения о том, что цифры совпадают.
sameInts:
  newline
  lea dx, sameInt
  outstr dx

  jmp exit
nI:
  newline
  lea dx, wrong
  outstr dx

exit:
  newline ; перевод каретки
;============================
   finish; вызов процедуры завершения программы
Cd Ends
   End start
