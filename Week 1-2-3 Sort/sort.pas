Program datesSort;
uses crt;
// Поддерживаемые форматы дат:
// ЧЧ.ММ.ГГГГ
// ЧЧ.ММ.ГГ

// Константа для быстрой сортировки.
const
  M = 1;

type
  // Очередь для хранения значений дат.
  dateYMD = record
    year: Integer;
    month: Integer;
    day: Integer;
  end;
  pQu = ^Qu;
  Qu = record
    date : dateYMD;
    next : pQu;
    prev: pQu;
  end;
  NumOrNot = (num, notnum);

var
  // Входной файл и файл с отсортрованными датами.
  unrefinedFile, datesFile: text;
  // Очередь
  dates, pointer: pQu;
  // Подсчёт
  numOfComparisons, numOfShifts: Integer;

///////////////////////////////////////////////
// ФУНКЦИИ И ПРОЦЕДУРЫ ДЛЯ РАБОТЫ С ОЧЕРЕДЬЮ //
///////////////////////////////////////////////

procedure push(var q, p: pQu; var d: dateYMD);
  var x, y: pQu;
begin
  // q - начало очереди.
  y := q;
  
  new(x);
  x^.date := d;
  x^.next := nil;
  x^.prev := nil;

  if q = nil Then
    q := x
  else begin
    While y^.next <> nil Do
      y := y^.next;

    y^.next := x;
    x^.prev := y;
    // Указатель на конец очереди.
    p := x;
  end
end;

procedure exchange(var el1, el2: pQu);
  var buf: pQu;
begin
  new(buf);
  // Сохранение связей первого элемента.
  buf^.next := el1^.next;
  buf^.prev := el1^.prev;

  if (el1^.next = el2) OR (el2^.next = el1) Then Begin
    if el2^.next = el1 then
      exchange(el2, el1)
    else begin
      // Для соседних элементов.
      el1^.next := el2^.next;
      el2^.prev := el1^.prev;
      el1^.prev := el2;
      el2^.next := el1;
      el2^.prev^.next := el2;
      el1^.next^.prev := el1
    end
  end else begin
    // Для не соседних элементов.
    // Перенос первого элемента на место второго.
    el1^.next := el2^.next;
    el1^.prev := el2^.prev;
    el2^.prev^.next := el1;
    el2^.next^.prev := el1;

    // Перенос второго элемента на место первого.
    el2^.next := buf^.next;
    el2^.prev := buf^.prev;
    buf^.prev^.next := el2;
    buf^.next^.prev := el2
  end;
end;

// Выяснение длины очереди.
function qLen(var q: pQu): Integer;
  var len: Integer;
      x: pQu;
begin
  x := q;

  if x = nil then
    qLen := 0
  else begin
    len := 1;
    While x^.next <> nil Do begin
      len := len + 1;
      x := x^.next;
    end;
    qLen := len
  end
end;

///////////////////////////////////////////////////////
// ФУНКЦИИ И ПРОЦЕДУРЫ ДЛЯ ОБРАБОТКИ ВХОДЯЩЕГО ФАЙЛА //
///////////////////////////////////////////////////////

// Функция charsValues проверяет, являются ли, начиная с номера start и продолжительностью numOfC
// символы в строке line цифрами или не цифрами (в зависимости от параметра cType).
function charsValues(var line: String; cType: NumOrNot; var start: Integer; numOfC: Integer): Boolean;
  var zero, nine: Char;
      i: Integer;
      b: Boolean;
begin
  zero := '0';
  nine := '9';
  b := TRUE;

  If (cType = num) Then
    // Сравниваем в пределах числового диапазона.
    For i := start To start + numOfC - 1 Do
      b := b AND ((line[i] >= zero) AND (line[i] <= nine))
  Else
    // Сравниваем за пределами числового диапазона.
    For i := start To start + numOfC - 1 Do
      b := b AND ((line[i] < zero) or (line[i] > nine));
  start := i + 1;
  charsValues := b;
end;

// Функция correctDate определяет, записана ли переданная строка в формате даты.
// TRUE, если да. FALSE, если нет.
function correctDate(var line: String; len: Integer): Boolean;
  var i: Integer;
      b: Boolean;
begin
  i := 1;
  b := FALSE;
  If (len = 8) Then
    b := charsValues(line, num, i, 2) AND charsValues(line, notnum, i, 1) AND charsValues(line, num, i, 2) AND charsValues(line, notnum, i, 1) AND charsValues(line, num, i, 2)
  else If (len = 10) Then
    b := charsValues(line, num, i, 2) AND charsValues(line, notnum, i, 1) AND charsValues(line, num, i, 2) AND charsValues(line, notnum, i, 1) AND charsValues(line, num, i, 4);
  correctDate := b;
end;

// Вспомогательная процедура для осуществления проверки и передачи обработанных дат.
procedure checkFill(var testFile: text; var line: String; var q, p: pQu);
  var len, err: Integer;
      date: dateYMD;
begin
  len := Length(line);

  If (len <= 10) Then
    // Функция для проверки соответствия даты формату.
    If correctDate(line, len) Then begin
      line[3] := '.';
      line[6] := '.';
      Writeln(testFile, line);

      val(copy(line, 7, len - 7 + 1), date.year, err);
      val(copy(line, 4, 2), date.month, err);
      val(copy(line, 1, 2), date.day, err);

      push(q, p, date);
    End
End;

// Функция для чтения, обработки и передачи дат.
procedure readCheckFill(var f: text; var q, p: pQu);
  var line: String;
      testFile: text;
begin
  assign(testFile, 'testFile.txt');
  rewrite(testFile);

  Repeat
    readln(f, line);

    // Проверка и расшифровка строки, добавление записи в качестве значения элемента очереди.
    checkFill(testFile, line, q, p);
  Until eof(f);
  close(testFile);
end;

//////////////////////////
// ПРОЦЕДУРЫ СОРТИРОВКИ //
//////////////////////////

// Функция сравнения
// Численная переменная numOfComparisons существует для подсчёта числа сравнений,
// выполненных во время работы алгоритма.
// arg1 и arg2 представляют собой сравниваемые значения
function dateComparison(var numOfComparisons: Integer; var arg1, arg2: dateYMD; bigger: Boolean): Boolean;
begin
  inc(numOfComparisons);
  dateComparison := bigger AND ((arg1.year > arg2.year) OR
                               ((arg1.year = arg2.year) AND (arg1.month > arg2.month)) OR
                               ((arg1.year = arg2.year) AND (arg1.month = arg2.month) AND (arg1.day > arg2.day)));
end;

// Алгоритм быстрой сортировки из книги "Искусство программирования"
// Дональда Кнута, переделанный для сортировки динамической структуры.
procedure quickSort(var q, p: pQu);
  var N, l, r, i, j, K: pQu;
      buf: dateYMD;
begin
  N := p;
  // Q1
  l := q;
  r := N;

  // Q2
  i := l;
  j := l;
  K := l;

  While not((i = j) OR (i^.prev = j)) Do begin
    // Q3
    Repeat
      i := i^.next;
    Until dateComparison(numOfComparisons, K^.date, i^.date, FALSE) OR
          (i = j) OR (i^.prev = j);

    // Q4
    Repeat
      j := j^.prev;
    Until dateComparison(numOfComparisons, K^.date, i^.date, TRUE) OR
          (j = i) OR (j^.next = i);

    // Q5
    if (i = j) OR (i^.prev = j) Then begin
      buf := l^.date;
      l^.date := j^.date;
      j^.date := buf;
    // Q6
    end else begin
      buf := i^.date;
      i^.date := j^.date;
      j^.date := buf;
    end;
  end;


end;

begin
  clrscr;

  assign(unrefinedFile, 'dates.txt');
  reset(unrefinedFile);

  readCheckFill(unrefinedFile, dates, pointer);

  close(unrefinedFile);

  Writeln('Год: ', pointer^.date.year, ', месяц: ', pointer^.date.month, ', день: ', pointer^.date.day, '.');
  Writeln();
  Writeln(qLen(dates));

  readln()

End.