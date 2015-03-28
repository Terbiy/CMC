Program datesSort;

const
  MinInt = -MaxInt - 1;
  // Размер массива
  N = 100;

type
  // Массив
  stringArray = array[0..N] of String;
  // Тип для функции charsValues
  NumOrNot = (num, notnum);
  // Стек для подмассивов
  pStack = ^st;
  st = record
    start: Integer;
    finish: Integer;
    next: pStack;
  end;

var
  // Массив
  dates: stringArray;
  // Длина массива
  arrayLen, numOfComparisons, numOfShifts: Integer;

///////////////////////////////////////////////////////////////////////////
// ФУНКЦИИ И ПРОЦЕДУРЫ ДЛЯ ОБРАБОТКИ ВХОДЯЩЕГО ФАЙЛА, ЗАПОЛНЕНИЯ МАССИВА //
///////////////////////////////////////////////////////////////////////////

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
procedure checkFill(var line: String; var arr: stringArray; var i: Integer);
  var len, err: Integer;
begin
  len := Length(line);

  // Функция для проверки соответствия даты формату.
  If correctDate(line, len) Then begin
    line[3] := '.';
    line[6] := '.';

    arr[i] := line;

    inc(i);
  End
End;

// Функция для чтения, обработки и передачи дат.
procedure readCheckFill(var f: text; var arr: stringArray; var arrayLen: Integer);
  var line: String;
      i: Integer;
begin

  i := 1;

  Repeat
    readln(f, line);

    // Проверка и расшифровка строки, добавление записи в качестве значения элемента очереди.
    checkFill(line, arr, i);
  Until eof(f);

  arrayLen := i - 1;
end;

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

procedure fileToArray(fileDest: String; var arr: stringArray; var arrayLen: Integer);
  var unrefinedFile: text;
begin
  assign(unrefinedFile, fileDest);
  reset(unrefinedFile);

  readCheckFill(unrefinedFile, dates, arrayLen);

  close(unrefinedFile);
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

//////////////////////////
// ПРОЦЕДУРЫ СОРТИРОВКИ //
//////////////////////////

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

procedure valueExchange(var arr: stringArray; el1, el2: Integer);
  var buf: String;
begin
  inc(numOfShifts);

  buf := arr[el1];
  arr[el1] := arr[el2];
  arr[el2] := buf;
end;

// QuickSort
procedure quicksort(var arr: stringArray; len: Integer);
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
end;

//////////////////////////////////
// Печать статистики сортировок //
//////////////////////////////////
procedure sortCountAndPrint(fileDest: String);
begin
  fileToArray(fileDest, dates, arrayLen);
  quicksort(dates, arrayLen);
  write(numOfComparisons:6);
  clearArray(dates, N);
end;

procedure printLine(num: Integer);
  var nOS1, nOS2, nOS3, nOS4, nOS5, avNOC, avNOS: Integer;
      sNum: String;
begin
  avNOC := 0;
  avNOS := 0;

  write('| ');
  write(num:2, ' | сравнения  |');
    str(num, sNum);
    sortCountAndPrint(concat('dates\datesUp_', sNum,'.txt'));
    avNOC := avNOC + numOfComparisons;
    nOS1 := numOfShifts;
    sortCountAndPrint(concat('dates\datesDown_', sNum,'.txt'));
    avNOC := avNOC + numOfComparisons;
    nOS2 := numOfShifts;
    sortCountAndPrint(concat('dates\datesCross_', sNum,'.txt'));
    avNOC := avNOC + numOfComparisons;
    nOS3 := numOfShifts;
    sortCountAndPrint(concat('dates\randomDates1_', sNum,'.txt'));
    avNOC := avNOC + numOfComparisons;
    nOS4 := numOfShifts;
    sortCountAndPrint(concat('dates\randomDates2_', sNum,'.txt'));
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

procedure printStatistics(var dates: stringArray; var arrayLen: Integer);
begin

  writeln('┌-------------------------------------------------------------┐');
  writeln('| n  |  параметр  |    номер последовательности    | среднее  |');
  writeln('|    |            |     1     2     3     4     5  | значение |');
  writeln('|----|------------|--------------------------------|----------|');
  printLine(10);
  writeln('|----|------------|--------------------------------|----------|');
  printLine(20);
  writeln('|----|------------|--------------------------------|----------|');
  printLine(30);
  writeln('|----|------------|--------------------------------|----------|');
  printLine(40);
  writeln('|----|------------|--------------------------------|----------|');
  printLine(50);
  writeln('└-------------------------------------------------------------┘')
end;

begin

  printStatistics(dates, arrayLen);
  // writeln('Итоговый массив: ');
  // printArray(dates, arrayLen);



  // writeln(numOfComparisons);
  // writeln(numOfShifts);
end.