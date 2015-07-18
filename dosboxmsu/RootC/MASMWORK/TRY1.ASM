;                   файл: ex1.asm
;Вывод чисел знаковых / беззнаковых
Include io.asm ; Подключение внешнего файла io.asm
;подключены операции ввода-вывода

S Segment stack; стек 128 байт
  db 128 dup (?)
S Ends

D Segment
  res db 'Итог:$'
  char db 100 dup (?)
  cifra db '0'
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
  ; Вывод текста
  lea dx, res
  outstr dx
  newline
  mov char[bx], '$'
  lea dx, char
  outstr dx

  ; Определение наличия свойства текста
  ; Текст начинается цифрой и заканчивается
  ; цифрой, причём другой.
  mov al, char
  sub al, cifra
  cmp al, 0
  jg gZ
  jmp exit ; Разница меньше 0
gZ:
  cmp al, 9
  jl gotIt
  jmp exit

gotIt:


  jmp exit
nI:
  mov char, 'N'
  mov bx, 1
  mov char[bx], '$'
  lea dx, char
  outstr dx

exit:
  newline ; перевод каретки
;============================
   finish; вызов процедуры завершения программы
Cd Ends
   End start
