;                   䠩�: ex1.asm
;�뢮� �ᥫ �������� / �����������
Include io.asm ; ������祭�� ���譥�� 䠩�� io.asm
;������祭� ����樨 �����-�뢮��

S Segment stack; �⥪ 128 ����
  db 128 dup (?)
S Ends

D Segment
  res db '�⮣:$'
  wrong db '�訡�� �� �����.$'
  sameInt db '����� � ��砫� � ���� ��ப� ᮢ������.$'
  char db 128 dup (?)
  null db '0'
  fInt db ?
  sInt db ?
D Ends

Cd Segment ;������� ����
   Assume ss:S, ds: D, cs:Cd
start:
;============================
; ������� ���������

  ; ��אַ� 㪠����� �� ��砫� ॣ���� ������
  ; ��� �⮣� 㪠����� �뢮����� ��� ����
  mov ax, D
  mov ds, ax

  mov bx, 0

; ���� ��ப�
;    mov bx, 0
;    mov cx, 5
;rC:
;    inch char[bx]
;    inc bx
;    loop rC

cI:
  ; ���� ��ப�
  inch char[bx]
  cmp char[bx], '.'
  je lE
  inc bx
  cmp bx, 10
  je nI
  jne cI

lE:
  ; �뢮� ��ப�
  lea dx, res
  outstr dx
  newline
  mov char[bx], '$'
  lea dx, char
  outstr dx

  ; ��।������ ������ ᢮��⢠ ��ப�
  ; ��ப� ��稭����� ��ன � �����稢�����
  ; ��ன, ���� ��㣮�.
  mov al, char
  sub al, null
  cmp al, 0
  jg gZF
  jmp exit ; ������ ����� 0
gZF:
  cmp al, 9
  jl fTrue
  jmp exit

  ; ���� ᨬ��� �������� ��ன,
  ; �஢��塞 ��᫥���� ᨬ���.
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
  ; �ࠢ������ ������� ��� �祩�� ����� �����.
  cmp fInt, al
  je sameInts

  ; �뢮� �����饭�� � ⮬, �� ���� ᮢ������.
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
  newline ; ��ॢ�� ���⪨
;============================
   finish; �맮� ��楤��� �����襭�� �ணࠬ��
Cd Ends
   End start
