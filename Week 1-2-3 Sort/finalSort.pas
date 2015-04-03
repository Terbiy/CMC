Program datesSort;

const
  MinInt = -MaxInt - 1;
  // Размер массива
  N = 100;

type
  // Quick Sort
  // Массив
  stringArray = array[0..N] of String;
  // Стек для подмассивов
  pStack = ^St;
  St = record
    start: Integer;
    finish: Integer;
    next: pStack;
  end;
  // Merge Sort
  pQu = ^Qu;
  Qu = record
    date: String;
    next: pQu;
  end;
  // Тип для функции charsValues
  NumOrNot = (num, notnum);

var
  // Массив
  dates: stringArray;
  // Очередь
  head, pointer: pQu;
  arrayLen, numOfComparisons, numOfShifts: Integer;

///////////////////////
// РАБОТА С МАССИВОМ //
///////////////////////

procedure printArray(var arr: stringArray; len: Integer);
  var i: Integer;
begin
  for i := 1 To len Do begin
    writeln(i, '. ', arr[i]);
  end
end;

procedure printPartOfArray(var arr: stringArray; start, finish: Integer);
  var i: Integer;
begin
  for i := start To finish Do begin
    writeln(i, '. ', arr[i]);
  end
end;

procedure clearArray(var arr: stringArray; len: Integer);
  var i: Integer;
begin
  for i := 0 to len do
  begin
    arr[i] := '';
  end;
end;
//////////////////////////////////////////////
// ФУНКЦИИ И ПРОЦЕДУРЫ ДЛЯ РАБОТЫ СО СТЕКОМ //
//////////////////////////////////////////////
procedure stackPush(var s: pStack; start, finish: Integer);
  var x: pStack;
begin
  new(x);
  x^.start := start;
  x^.finish := finish;

  if s = nil Then
    s := x
  else begin
    x^.next := s;
    s := x
  end
end;

procedure stackPop(var s: pStack);
  var x: pStack;
begin
  x := s^.next;
  dispose(s);
  s := x;
end;

function stackIsEmpty(var s: pStack): Boolean;
begin
  stackIsEmpty := FALSE;
  if (s = nil) then
    stackIsEmpty := TRUE
end;

function stackLen(s: pStack): Integer;
  var len: Integer;
begin
  len := 1;
  if stackIsEmpty(s) then
    stackLen := 0
  else begin
    while s^.next <> nil do begin
      len := len + 1;
      s := s^.next
    end;
    stackLen := len;
  end;
end;

///////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ РАБОТЫ С ОЧЕРЕДЬЮ //
///////////////////////////////////////////////

function qIsEmpty(var q: pQu): Boolean;
begin
  qIsEmpty := FALSE;
  if q = nil then
    qIsEmpty := TRUE;
end;

// Функция измерения длины очереди не сбивает указатель.
// Предполагается, что в функцию передаётся указатель на начало.
function qLen(head: pQu): Integer;
  var i: Integer;
begin
  qLen := 0;
  if not(qIsEmpty(head)) then begin
    i := 1;
    while head^.next <> nil do begin
      head := head^.next;
      inc(i);
    end;
    qLen := i 
  end
end;

// Функция добавления элемента в очередь. Сбивает значение указателя.
procedure qPush(var p: pQu; date: String);
  var x: pQu;
begin
  new(x);
  x^.date := date;
  x^.next := nil;

  if qIsEmpty(p) Then
    p := x
  else begin
    While p^.next <> nil Do
      p := p^.next;

    p^.next := x;
    p := x;
  end
end;

procedure qShift(var head: pQu; date: String);
  var x: pQu;
begin
  new(x);
  x^.date := date;
  x^.next := nil;

  if qIsEmpty(head) Then
    head := x
  else begin
    x^.next := head;
    head := x
  end
end;

// Процедура удаления последнего элемента из очереди.
procedure qPop(head: pQu; var p: pQu);
begin
  if not(qIsEmpty(p)) AND not(qIsEmpty(head^.next)) then begin
    while p^.next <> nil do
      p := p^.next;
    while head^.next <> p do
      head := head^.next;
    dispose(p);
    p := head
  end else writeln('На вход в процедуру удаления последнего элемента подана некорректная очередь.')
end;

procedure qUnshift(var head: pQu);
  var x: pQu;
begin
  if not(qIsEmpty(head)) then begin
    x := head^.next;
    dispose(head);
    head := x
  end
end;

procedure qValueExchange(var el1, el2: pQu);
  var buf: String;
begin
  if not(qIsEmpty(el1)) AND not(qIsEmpty(el2)) then begin
    buf := el1^.date;
    el1^.date := el2^.date;
    el2^.date := buf
  end;
end;

function qLinkToPrev(head, p: pQu): pQu;
begin
  if not(qIsEmpty(p)) AND not(qIsEmpty(head^.next)) then begin
    while head^.next <> p do
      head := head^.next;
    qLinkToPrev := head;
  end
end;

function qLinkToPos(head: pQu; pos: Integer): pQu;
  var i: Integer;
begin
  if not(qIsEmpty(head)) AND (qLen(head) >= pos) then begin
    for i := (pos - 1) downto 1 do
      head := head^.next;
    qLinkToPos := head;
  end;
end;

procedure qPrintOut(head: pQu);
  var i: Integer;
begin
  if not(qIsEmpty(head)) then begin
    i := 0;

    While head <> nil do begin
      inc(i);
      writeln(i, '. ', head^.date);
      head := head^.next;
    end;
  end else writeln('Empty queue input.')
end;

procedure qDelete(var head, p: pQu);
begin
  while head <> nil do begin
    p := head;
    head := head^.next;
    dispose(p);
  end;
end;

/////////////////////////////////////////////////////////////////////////////////////
// ФУНКЦИИ И ПРОЦЕДУРЫ ДЛЯ ОБРАБОТКИ ВХОДЯЩЕГО ФАЙЛА, ЗАПОЛНЕНИЯ МАССИВА И ОЧЕРЕДИ //
/////////////////////////////////////////////////////////////////////////////////////

// Функция charsValues проверяет, являются ли, начиная с номера start и
// продолжительностью numOfC символы в строке line цифрами или не цифрами (в
// зависимости от параметра cType).
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
  
  b := charsValues(line, num, i, 2) AND charsValues(line, notnum, i, 1) AND charsValues(line, num, i, 2) AND charsValues(line, notnum, i, 1) AND charsValues(line, num, i, len - 6);

  correctDate := b;
end;

// Вспомогательная процедура для осуществления проверки и передачи обработанных дат.
function correctLine(var line: String): String;
  var len: Integer;
begin
  len := Length(line);

  // Функция для проверки соответствия даты формату.
  If correctDate(line, len) Then begin
    line[3] := '.';
    line[6] := '.';
  End;

  correctLine := line;
End;

// Функция для чтения, обработки и передачи дат в массив.
procedure readCheckFillArray(var f: text; var arr: stringArray; var arrayLen: Integer);
  var line: String;
      i: Integer;
begin

  i := 1;

  Repeat
    readln(f, line);

    arr[i] := correctLine(line);
    inc(i)
  Until eof(f);

  arrayLen := i - 1;
end;

procedure readCheckFillQueue(var f: text; var head, p: pQu);
  var line: String;
      i: Integer;
begin
  readln(f, line);
  qShift(head, correctLine(line));
  p := head;

  While not eof(f) do begin
    readln(f, line);

    qPush(p, correctLine(line));
  end;
end;

////////////////////////////////////////
// ДОПОЛНИТЕЛЬНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ //
////////////////////////////////////////

// Перевод численного значения раздельных дат в строковый.
function makeStringDate(day, month, year: Integer): String;
  var sDay,sMonth,sYear: String;
begin
  str(day, sDay);
  str(month, sMonth);
  str(year, sYear);

  makeStringDate := concat(sDay, '.', sMonth, '.', sYear);
end;

procedure fileToArray(fileDest: String; var arr: stringArray; var arrayLen: Integer);
  var unrefinedFile: text;
begin
  assign(unrefinedFile, fileDest);
  reset(unrefinedFile);

  readCheckFillArray(unrefinedFile, dates, arrayLen);

  close(unrefinedFile);
end;

procedure fileToQueue(fileDest: String; var head, p: pQu);
  var unrefinedFile: text;
begin
  assign(unrefinedFile, fileDest);
  reset(unrefinedFile);

  readCheckFillQueue(unrefinedFile, head, p);

  close(unrefinedFile);
end;

///////////////////////////////////////////////
// ПРОЦЕДУРЫ СОРТИРОВКИ И ВСПОМОГАТЕЛЬНЫЕ ИМ //
///////////////////////////////////////////////

// Функция сравнения дат. Определяет, позже ли первая дата, чем вторая.
function dateIsLater(m, n: String): Boolean;
  var dayM, dayN, monthM, monthN, yearM, yearN, lenM, lenN, err: Integer;
begin
  inc(numOfComparisons);

  lenM := Length(m);
  lenN := Length(n);

  val(copy(m, 1, 2), dayM, err);
  val(copy(m, 4, 2), monthM, err);
  val(copy(m, 7, lenM - 7 + 1), yearM, err);

  val(copy(n, 1, 2), dayN, err);
  val(copy(n, 4, 2), monthN, err);
  val(copy(n, 7, lenN - 7 + 1), yearN, err);

  dateIsLater := ((yearM > yearN) OR
                 ((yearM = yearN) AND (monthM > monthN)) OR
                 ((yearM = yearN) AND (monthM = monthN) AND (dayM > dayN)));
end;

// Процедура обмена значениями внутри массива.
procedure valueExchange(var arr: stringArray; el1, el2: Integer);
  var buf: String;
begin
  inc(numOfShifts);

  buf := arr[el1];
  arr[el1] := arr[el2];
  arr[el2] := buf;
end;
procedure valueTransfer(var arr: stringArray; el1, el2: Integer);
begin
  inc(numOfShifts);
  arr[el1] := arr[el2];
end;

procedure qValueTransfer(var el1, el2: pQu);
begin
  if not(qIsEmpty(el1)) AND not(qIsEmpty(el2)) then begin
    inc(numOfShifts);
    el1^.date := el2^.date;
  end
end;

// Быстрая сортировка
procedure quickSortArray(var arr: stringArray; len: Integer);
  var l, r, i, j: Integer;
      K: String;
      subArrays: pStack;
begin
  // Подготовка массива
  arr[0] := makeStringDate(MinInt,MinInt,MinInt);
  arr[len + 1] := makeStringDate(MaxInt,MaxInt,MaxInt);

  // Подготовка переменных подсчёта действий.
  numOfComparisons := 0;
  numOfShifts := 0;

  // Q1
  // Так как я игнорирую добавление метода простых ставок при завершении
  // сортировки, то и не выполняю здесь проверку.
  l := 1;
  r := len;

  Repeat
    // writeln('Размер стека: ', stackLen(subArrays));

    // Q8
    if not(stackIsEmpty(subArrays)) then begin
      l := subArrays^.start;
      r := subArrays^.finish;

      stackPop(subArrays);
    end;


    While (r - l) > 0 do begin
      // Q2
      i := l;
      j := r + 1;
      K := arr[l];

      While (i < j) do begin
        // Q3
        Repeat
          inc(i);
        Until dateIsLater(arr[i], K) OR (i >= j);

        // Q4
        Repeat
          dec(j);
        Until dateIsLater(K, arr[j]) OR (j <= i);

        // Q6
        if (i < j) then
          valueExchange(arr, i, j);
      end;

      // Q5
      if dateIsLater(K, arr[j]) then
        valueExchange(arr, l, j);

      // Q7
      if ((r - j) >= (j - l)) then begin
        stackPush(subArrays, j, r);
        r := j - 1
      end else begin
        stackPush(subArrays, l, j - 1);
        l := j + 1
      end;

    end;
  Until (stackIsEmpty(subArrays));
  // Завершение обработки массива.
  arr[0] := '';
  arr[len + 1] := '';
end;


procedure mergeSortQueue(var head, p: pQu);
  var s, d, f, counter: Integer;
      i, j, k, l, buf: pQu;
begin
  // Подготовка переменных подсчёта действий.
  numOfComparisons := 0;
  numOfShifts := 0;
  // Подготовка дополнительного пространства в очереди.
  For counter := 1 to qLen(head) do
    qPush(p, '');

  // N1
  s := 0; //Из области памяти (R_1,...,R_N) в (R_N+1,...,R_2N)

  Repeat
    // N2

    if (s = 0) then begin
      i := qLinkToPos(head, 1);
      j := qLinkToPos(head, qLen(head) div 2);
      k := qLinkToPos(head, (qLen(head) div 2) + 1);
      l := qLinkToPos(head, qLen(head));
    end else if (s = 1) then begin
      k := qLinkToPos(head, 1);
      l := qLinkToPos(head, qLen(head) div 2);
      i := qLinkToPos(head, (qLen(head) div 2) + 1);
      j := qLinkToPos(head, qLen(head));
    end;

    d := 1;
    f := 1;

    // N3
    While (i <> j) do begin

      if not(dateIsLater(i^.date, j^.date)) then begin
        qValueTransfer(k, i);
        
        if d = 1 then
          k := k^.next
        else k := qLinkToPrev(head, k);

        // N5
        i := i^.next;

        if dateIsLater(qLinkToPrev(head, i)^.date, i^.date) then begin
          Repeat
            // N6
            qValueTransfer(k, j);
            
            if d = 1 then
              k := k^.next
            else k := qLinkToPrev(head, k);

            // N7
            j := qLinkToPrev(head, j);
          Until dateIsLater(j^.next^.date, j^.date);
        end else continue;
      end else begin
        // N8
        qValueTransfer(k, j);
        
        if d = 1 then
          k := k^.next
        else k := qLinkToPrev(head, k);

        // N9
        j := qLinkToPrev(head, j);

        if dateIsLater(j^.next^.date, j^.date) then begin
          Repeat
            // N10
            qValueTransfer(k, i);
            
            if d = 1 then
              k := k^.next
            else k := qLinkToPrev(head, k);
          
            // N11
            i := i^.next
          Until dateIsLater(qLinkToPrev(head, i)^.date, i^.date);
        end else continue;
      end;
      
      // N12
      f := 0;
      d := -d;
      // Обмен значениями переменных без буферной переменной.
      buf := k;
      k := l;
      l := buf;
    end;

    qValueTransfer(k, i);

    // N13
    if f = 0 then begin
      s := 1 - s;
    end;
  Until f <> 0;

  if s = 0 then
    for counter := 1 to (qLen(head) div 2) do begin
      i := qLinkToPos(head, counter);
      j := qLinkToPos(head, (qLen(head) div 2) + counter);
      qValueTransfer(i, j);
    end;
end;

//////////////////////////////////
// Печать статистики сортировок //
//////////////////////////////////
procedure sortCountAndPrintQuick(fileDest: String);
begin
  fileToArray(fileDest, dates, arrayLen);
  quickSortArray(dates, arrayLen);
  write(numOfComparisons:6);
  clearArray(dates, N);
end;

procedure sortCountAndPrintMerge(fileDest: String);
begin
  fileToQueue(fileDest, head, pointer);
  mergeSortQueue(head, pointer);
  write(numOfComparisons:6);
  qDelete(head, pointer);
end;

procedure printLineQuick(num: Integer);
  var nOS1, nOS2, nOS3, nOS4, nOS5, avNOC, avNOS: Integer;
      sNum: String;
begin
  avNOC := 0;
  avNOS := 0;

  write('| ');
  write(num:2, ' | сравнения  |');
    str(num, sNum);
    sortCountAndPrintQuick(concat('dates\datesUp_', sNum,'.txt'));
    avNOC := avNOC + numOfComparisons;
    nOS1 := numOfShifts;
    sortCountAndPrintQuick(concat('dates\datesDown_', sNum,'.txt'));
    avNOC := avNOC + numOfComparisons;
    nOS2 := numOfShifts;
    sortCountAndPrintQuick(concat('dates\datesCross_', sNum,'.txt'));
    avNOC := avNOC + numOfComparisons;
    nOS3 := numOfShifts;
    sortCountAndPrintQuick(concat('dates\randomDates1_', sNum,'.txt'));
    avNOC := avNOC + numOfComparisons;
    nOS4 := numOfShifts;
    sortCountAndPrintQuick(concat('dates\randomDates2_', sNum,'.txt'));
    avNOC := avNOC + numOfComparisons;
    nOS5 := numOfShifts;
    
    avNOC := avNOC div 5;
    avNOS := (nOS1 + nOS2 + nOS3 + nOS4 + nOS5) div 5;
    
    write('  | ');
    writeln(avNOC:6, '   |');

    write('|    |перемещения |');
    write(nOS1:6);
    write(nOS2:6);
    write(nOS3:6);
    write(nOS4:6);
    write(nOS5:6);
    write('  | ');
    writeln(avNOS:6, '   |');
end;

procedure printLineMerge(num: Integer);
  var nOS1, nOS2, nOS3, nOS4, nOS5, avNOC, avNOS: Integer;
      sNum: String;
begin
  avNOC := 0;
  avNOS := 0;

  write('| ');
  write(num:2, ' | сравнения  |');
    str(num, sNum);
    sortCountAndPrintMerge(concat('dates\datesUp_', sNum,'.txt'));
    avNOC := avNOC + numOfComparisons;
    nOS1 := numOfShifts;
    sortCountAndPrintMerge(concat('dates\datesDown_', sNum,'.txt'));
    avNOC := avNOC + numOfComparisons;
    nOS2 := numOfShifts;
    sortCountAndPrintMerge(concat('dates\datesCross_', sNum,'.txt'));
    avNOC := avNOC + numOfComparisons;
    nOS3 := numOfShifts;
    sortCountAndPrintMerge(concat('dates\randomDates1_', sNum,'.txt'));
    avNOC := avNOC + numOfComparisons;
    nOS4 := numOfShifts;
    sortCountAndPrintMerge(concat('dates\randomDates2_', sNum,'.txt'));
    avNOC := avNOC + numOfComparisons;
    nOS5 := numOfShifts;
    
    avNOC := avNOC div 5;
    avNOS := (nOS1 + nOS2 + nOS3 + nOS4 + nOS5) div 5;
    
    write('  | ');
    writeln(avNOC:6, '   |');

    write('|    |перемещения |');
    write(nOS1:6);
    write(nOS2:6);
    write(nOS3:6);
    write(nOS4:6);
    write(nOS5:6);
    write('  | ');
    writeln(avNOS:6, '   |');
end;

procedure printStatisticsQS(var dates: stringArray; var arrayLen: Integer);
begin

  writeln('┌-------------------------------------------------------------┐');
  writeln('| n  |  параметр  |    номер последовательности    | среднее  |');
  writeln('|    |            |     1     2     3     4     5  | значение |');
  writeln('|----|------------|--------------------------------|----------|');
  printLineQuick(10);
  writeln('|----|------------|--------------------------------|----------|');
  printLineQuick(20);
  writeln('|----|------------|--------------------------------|----------|');
  printLineQuick(30);
  writeln('|----|------------|--------------------------------|----------|');
  printLineQuick(40);
  writeln('|----|------------|--------------------------------|----------|');
  printLineQuick(50);
  writeln('└-------------------------------------------------------------┘')
end;

procedure printStatisticsMS(var dates: stringArray; var arrayLen: Integer);
begin

  writeln('┌-------------------------------------------------------------┐');
  writeln('| n  |  параметр  |    номер последовательности    | среднее  |');
  writeln('|    |            |     1     2     3     4     5  | значение |');
  writeln('|----|------------|--------------------------------|----------|');
  printLineMerge(10);
  writeln('|----|------------|--------------------------------|----------|');
  printLineMerge(20);
  writeln('|----|------------|--------------------------------|----------|');
  printLineMerge(30);
  writeln('|----|------------|--------------------------------|----------|');
  printLineMerge(40);
  writeln('|----|------------|--------------------------------|----------|');
  printLineMerge(50);
  writeln('└-------------------------------------------------------------┘')
end;

begin

  Writeln('Быстрая сортировка');
  printStatisticsQS(dates, arrayLen);
  writeln;
  Writeln('Сортировка слиянием');
  printStatisticsMS(dates, arrayLen);
end.