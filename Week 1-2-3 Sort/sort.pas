Program datesSort;
uses crt;

// ����⠭� ��� ����ன ���஢��.
const
  M = 1;
  MinInt = - MaxInt - 1;

type
  // ��।� ��� �࠭���� ���祭�� ���.
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
  // �室��� 䠩� � 䠩� � �����஢���묨 ��⠬�.
  unrefinedFile, datesFile: text;
  // ��।�
  dates, pointer: pQu;
  // �������
  numOfComparisons, numOfShifts: Integer;

///////////////////////////////////////////////
// ������� � ��������� ��� ������ � �������� //
///////////////////////////////////////////////

procedure push(var q, p: pQu; var d: dateYMD);
  var x, y: pQu;
begin
  // �㭪�� ࠡ�⠥� � 㪠��⥫��, �� �� � ��砫�� ��।�. �᫨ ��।��� �
  // �㭪�� ��砫�, � � १��� 㪠��⥫� ᬥ����� �� �����.
  new(x);
  x^.date := d;
  x^.next := nil;
  x^.prev := nil;

  if q = nil Then
    q := x
  else begin
    if p = nil then p := q;
    
    While p^.next <> nil Do
      p := p^.next;

    p^.next := x;
    x^.prev := p;
    p := x;
  end
end;

procedure shift(var q: pQu; var d: dateYMD);
  var x, y: pQu;
begin
  new(x);
  x^.date := d;
  x^.next := nil;
  x^.prev := nil;

  if q = nil Then q := x
  else begin
    While q^.prev <> nil do q := q^.prev;

    q^.prev := x;
    x^.next := q;
    q := x
  end
end;

procedure exchange(var el1, el2: pQu);
  var buf: pQu;
begin
  // �஢�ઠ, �� ���� � �� �� �� ����� � �㭪�� � ����⢥
  // ��ࠬ��� �����.
  // ��� �� ��楤�� ���� �� �����筮 ��ꥬ����, ⠪ ��� �� �����
  // �����⢫���� �� �।���������, �� ������

  // ������ �㭪�� ॠ����� ��������� ᠬ�� �������� ���ᨢ� �, ���
  // ᫥��⢨� ����� ���浪��� ����� ����⮢, �� ����� ᬮ����
  // 㪠��⥫�.
  if (el1 <> el2) then begin
    if (el1^.next = el2) OR (el2^.next = el1) Then Begin
      if el2^.next = el1 then
        exchange(el2, el1)
      else begin
        // ��� �ᥤ��� ����⮢.
        el1^.next := el2^.next;
        el2^.prev := el1^.prev;
        el1^.prev := el2;
        el2^.next := el1;
        el2^.prev^.next := el2;
        el1^.next^.prev := el1
      end
    end else begin
      // ��� �� �ᥤ��� ����⮢.
      if (el1^.next = nil) then
        exchange(el2, el1)
      else begin
        new(buf);
        // ���࠭���� �痢� ��ࢮ�� �����.
        buf^.next := el1^.next;
        buf^.prev := el1^.prev;

        // ��७�� ��ࢮ�� ����� �� ���� ��ண�.
        el1^.prev := el2^.prev;
        el1^.next := el2^.next;
        el2^.prev^.next := el1;
        if (el2^.next <> nil) then
          el2^.next^.prev := el1;

        // ��७�� ��ண� ����� �� ���� ��ࢮ��.
        el2^.next := buf^.next;
        el2^.prev := buf^.prev;
        buf^.next^.prev := el2;
        if (buf^.prev <> nil) then
          buf^.prev^.next := el2;

        // ���⪠ ����� � ���㫥��� ��뫪� ���୮� ��६�����.
        dispose(buf);
        buf := nil;
      end
    end
  end
end;

// �㭪�� valueExchange �� ������� ���冷� ����⮢ � ��।�, ��
// �ந������ ��७�� ���祭�� ����� ��࠭�묨 ����⠬�.
procedure valueExchange(el1, el2: pQu);
  var buf: dateYMD;
begin
  // ��।�� ��ࠬ��� �� ���祭�� �ந�室��, ⠪ ��� ��� ����室�����
  // �������� ���祭�� ��।����� 㪠��⥫��.
  buf.day := el1^.date.day;
  buf.month := el1^.date.month;
  buf.year := el1^.date.year;

  el1^.date.day := el2^.date.day;
  el1^.date.month := el2^.date.month;
  el1^.date.year := el2^.date.year;

  el2^.date.day := buf.day;
  el2^.date.month := buf.month;
  el2^.date.year := buf.year;

end;

// ���᭥��� ����� ��।�.
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

function qPartLen(start, finish: pQu): Integer;
  var len: Integer;
      b: Boolean;
begin
  // �㭪�� �����뢠�� �᫮ ����⮢, �� ������ ��⮨� ���ࢠ�.
  len := 1;

  While (start <> finish) do begin
    inc(len);

    if (start^.next = nil) then begin
      if (start <> finish) then len := 0;
    end else start := start^.next;
  end;

  qPartLen := len
end;

procedure printOut(q: pQu);
  var i: Integer;
begin
  if (q <> nil) then begin
    i := 1;
    while q^.prev <> nil do
      q := q^.prev;

    Repeat
      writeln(i, '. ', q^.date.day, '.', q^.date.month, '.', q^.date.year);
      q := q^.next;
      inc(i)
    Until q = nil;
  end else writeln('Empty queue input.')
end;

///////////////////////////////////////////////////////
// ������� � ��������� ��� ��������� ��������� ����� //
///////////////////////////////////////////////////////

// �㭪�� charsValues �஢����, ����� ��, ��稭�� � ����� start �
// �த����⥫쭮���� numOfC ᨬ���� � ��ப� line ��ࠬ� ��� �� ��ࠬ� (�
// ����ᨬ��� �� ��ࠬ��� cType).
function charsValues(var line: String; cType: NumOrNot; var start: Integer; numOfC: Integer): Boolean;
  var zero, nine: Char;
      i: Integer;
      b: Boolean;
begin
  zero := '0';
  nine := '9';
  b := TRUE;

  If (cType = num) Then
    // �ࠢ������ � �।���� �᫮���� ���������.
    For i := start To start + numOfC - 1 Do
      b := b AND ((line[i] >= zero) AND (line[i] <= nine))
  Else
    // �ࠢ������ �� �।����� �᫮���� ���������.
    For i := start To start + numOfC - 1 Do
      b := b AND ((line[i] < zero) or (line[i] > nine));
  start := i + 1;
  charsValues := b;
end;

// �㭪�� correctDate ��।����, ����ᠭ� �� ��।����� ��ப� � �ଠ� ����.
// TRUE, �᫨ ��. FALSE, �᫨ ���.
function correctDate(var line: String; len: Integer): Boolean;
  var i: Integer;
      b: Boolean;
begin
  i := 1;
  
  b := charsValues(line, num, i, 2) AND charsValues(line, notnum, i, 1) AND charsValues(line, num, i, 2) AND charsValues(line, notnum, i, 1) AND charsValues(line, num, i, len - 6);

  correctDate := b;
end;

// �ᯮ����⥫쭠� ��楤�� ��� �����⢫���� �஢�ન � ��।�� ��ࠡ�⠭��� ���.
procedure checkFill(var testFile: text; var line: String; var q, p: pQu);
  var len, err: Integer;
      date: dateYMD;
begin
  len := Length(line);

  // �㭪�� ��� �஢�ન ᮮ⢥��⢨� ���� �ଠ��.
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

// �㭪�� ��� �⥭��, ��ࠡ�⪨ � ��।�� ���.
procedure readCheckFill(var f: text; var q, p: pQu);
  var line: String;
      testFile: text;
begin
  assign(testFile, 'testFile.txt');
  rewrite(testFile);

  Repeat
    readln(f, line);

    // �஢�ઠ � ����஢�� ��ப�, ���������� ����� � ����⢥ ���祭�� ����� ��।�.
    checkFill(testFile, line, q, p);
  Until eof(f);
  close(testFile);
end;

//////////////////////////
// ��������� ���������� //
//////////////////////////

// �㭪�� �ࠢ�����
// ��᫥���� ��६����� numOfComparisons ������� ��� ������� �᫠ �ࠢ�����,
// �믮������� �� �६� ࠡ��� �����⬠.
// arg1 � arg2 �।�⠢���� ᮡ�� �ࠢ������� ���祭��
function dateIsLater(var numOfComparisons: Integer; var arg1, arg2: dateYMD): Boolean;
begin
  inc(numOfComparisons);
  dateIsLater := ((arg1.year > arg2.year) OR
                 ((arg1.year = arg2.year) AND (arg1.month > arg2.month)) OR
                 ((arg1.year = arg2.year) AND (arg1.month = arg2.month) AND (arg1.day > arg2.day)));
end;

procedure countAndValueExchange(var numOfShifts: Integer; el1, el2: pQu);
begin
  inc(numOfShifts);
  valueExchange(el1, el2);
end;

// ������ ����ன ���஢�� �� ����� "�����⢮ �ணࠬ��஢����"
// �����줠 ����, ��।������ ��� ���஢�� �������᪮� ��������.
procedure quickSort(var q, p: pQu);
  var N, l, r, i, j: pQu;
      temp, buf, K: dateYMD;
begin
  // �����⮢�� ����㯨�襩 ��।� � ��ࠡ�⪥ �����⬮�.
  // ���������� �����⢥����� ���� ᫥��.
  temp.day := MinInt;
  temp.month := MinInt;
  temp.year := MinInt;
  shift(q, temp);
  // ���������� �����⢥����� ���� �ࠢ�.
  temp.day := MaxInt;
  temp.month := MaxInt;
  temp.year := MaxInt;
  push(q, p, temp);

  // Q1
  l := q^.next; // l := 1;
  r := p^.prev; // l := N;

  // Q2
  i := l;
  j := r^.next;
  K := l^.date;

  // Q5
  While (j <> i) (*OR (j^.next <> i)*) do begin
    // Q3
    Repeat
      i := i^.next;
    Until dateIsLater(numOfComparisons, i^.date, K) OR (i = j) OR (i^.prev = j);
    Writeln(i^.date.year);

    // Q4
    Repeat
      j := j^.prev;
    Until j = i (*dateIsLater(numOfComparisons, K, j^.date) OR (j = i) OR (j^.next = i)*);
    Writeln(j^.date.year);
    
    // Q6
    // if (j <> i) OR (j^.next <> i) then
      countAndValueExchange(numOfShifts, i, j);
  end;
end;

begin
  clrscr;

  assign(unrefinedFile, 'dates.txt');
  reset(unrefinedFile);

  readCheckFill(unrefinedFile, dates, pointer);

  close(unrefinedFile);

  printOut(dates);
  quickSort(dates, pointer);
  printOut(dates);
  writeln();
  writeln(numOfComparisons);
  writeln(numOfShifts);
  readln()

End.