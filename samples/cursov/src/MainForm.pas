unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, SynSQLite3, StdCtrls, ExtCtrls,
  ComCtrls, Grids, ShellAPI;

type
  TForm2 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Button5: TButton;
    Button6: TButton;
    ListBox3: TListBox;
    ListBox2: TListBox;
    Button4: TButton;
    Button2: TButton;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    Button3: TButton;
    Button1: TButton;
    Label1: TLabel;
    TabSheet2: TTabSheet;
    ListBox4: TListBox;
    Label4: TLabel;
    ListBox5: TListBox;
    Label5: TLabel;
    Label6: TLabel;
    ListBox6: TListBox;
    Button7: TButton;
    Button8: TButton;
    TabSheet3: TTabSheet;
    ListBox7: TListBox;
    Label7: TLabel;
    Label8: TLabel;
    ListBox8: TListBox;
    StringGrid1: TStringGrid;
    Button9: TButton;
    Button10: TButton;
    TabSheet4: TTabSheet;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button17: TButton;
    OpenDialog1: TOpenDialog;
    TabSheet5: TTabSheet;
    ListBox9: TListBox;
    Label9: TLabel;
    ListBox10: TListBox;
    Label10: TLabel;
    Button16: TButton;
    ListBox11: TListBox;
    Label11: TLabel;
    Button18: TButton;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    Button19: TButton;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Label12: TLabel;
    Label13: TLabel;
    Edit2: TEdit;
    Edit3: TEdit;
    Label14: TLabel;
    Edit4: TEdit;
    Label15: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure ListBox4Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure ListBox5Click(Sender: TObject);
    procedure ListBox7Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure ListBox9Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
  private
    procedure LoadTeachers;
    procedure LoadSubjects;
    procedure LoadGroups;
    procedure LoadLessons;
    procedure LoadReplaces;
    procedure SetGridNames;
    procedure LoadTimeTable(GroupId: Integer);
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  DB: TSQLDatabase;

implementation

uses ComObj;

{$R *.dfm}

// Загрузка преподавателей из базы
procedure TForm2.LoadTeachers;
var
  data: TSQLRequest;
  name: String;
begin
  ListBox1.Clear;
  ListBox6.Clear;
  ListBox9.Clear;
  data.Prepare(DB.DB, 'select TeacherId, FIO, email from Teachers');
  while data.Step = SQLITE_ROW do
  begin
    // если есть почта, рисуем собаку
    name := data.FieldString(1);
    if data.FieldString(2) <> '' then
      name := '@ ' + name
    else
      name := '     ' + name;

      // добавляем во все списки, где пишутся преподаватели
    ListBox1.AddItem(name, TObject(data.FieldInt(0)));
    ListBox6.AddItem(name, TObject(data.FieldInt(0)));
    ListBox9.AddItem(name, TObject(data.FieldInt(0)));
  end;
  data.Close;
end;

// Загрузка замен из базы
procedure TForm2.LoadReplaces;
var
  data: TSQLRequest;
begin
  ListBox11.Clear;

  data.Prepare(DB.DB, 'select TimeTableReplaceId, T1.FIO, T2.FIO from TimeTableReplace TTR inner join Teachers T1 on TTR.TeacherId = T1.TeacherId inner join Teachers T2 on TTR.ReplaceTeacherId = T2.TeacherId');
  while data.Step = SQLITE_ROW do
  begin
    ListBox11.AddItem(data.FieldString(1) + ' -> ' + data.FieldString(2), TObject(data.FieldInt(0)));
  end;
  data.Close;
end;

// Загрузка предметов из базы
procedure TForm2.LoadSubjects;
var
  data: TSQLRequest;
begin
  ListBox2.Clear;
  ListBox4.Clear;
  data.Prepare(DB.DB, 'select SubjectId, Name from Subjects');
  while data.Step = SQLITE_ROW do
  begin
    ListBox2.AddItem(data.FieldString(1), TObject(data.FieldInt(0)));
    ListBox4.AddItem(data.FieldString(1), TObject(data.FieldInt(0)));
  end;
  data.Close;
end;

procedure TForm2.ListBox4Click(Sender: TObject);
var
  Request: TSQLRequest;
begin
  Button7.Enabled := False;
  ListBox5.Clear;

  if ListBox4.ItemIndex < 0 then
    Exit;

  Request.Prepare(DB.DB, 'select T.FIO, T.TeacherID from Lessons L inner join Teachers T on L.TeacherId = T.TeacherId where SubjectId = ?1');
  Request.Bind(1, Integer(ListBox4.Items.Objects[ListBox4.ItemIndex]));
  while Request.Step = SQLITE_ROW do
  begin
    ListBox5.AddItem(Request.FieldString(0), TObject(Request.FieldInt(1)));
  end;
  Request.Close;

  Button7.Enabled := True;
end;

procedure TForm2.ListBox5Click(Sender: TObject);
begin
  Button8.Enabled := False;

  if ListBox5.ItemIndex < 0 then
    Exit;

  Button8.Enabled := True;
end;

procedure TForm2.ListBox7Click(Sender: TObject);
begin
  LoadTimeTable(Integer(ListBox7.Items.Objects[ListBox7.ItemIndex]));
end;

// Загружаем группы из базы
procedure TForm2.LoadGroups;
var
  data: TSQLRequest;
begin
  ListBox3.Clear;
  ListBox7.Clear;
  data.Prepare(DB.DB, 'select GroupId, Name from Groups');
  while data.Step = SQLITE_ROW do
  begin
    ListBox3.AddItem(data.FieldString(1), TObject(data.FieldInt(0)));
    ListBox7.AddItem(data.FieldString(1), TObject(data.FieldInt(0)));
  end;
  data.Close;
end;

// загружаем предметы из базы
procedure TForm2.LoadLessons;
var
  data: TSQLRequest;
begin
  ListBox8.Clear;
  data.Prepare(DB.DB, 'select S.Name, T.FIO, L.LessonId from Lessons L inner join Subjects S on L.SubjectId = S.SubjectId inner join Teachers T on L.TeacherId = T.TeacherId');
  while data.Step = SQLITE_ROW do
  begin
    ListBox8.AddItem(data.FieldString(0) + ' - ' + data.FieldString(1), TObject(data.FieldInt(2)));
  end;
  data.Close;
end;

// добавление занятия группе
procedure TForm2.Button10Click(Sender: TObject);
var
  Request: TSQLRequest;
begin
  if (ListBox8.ItemIndex < 0) or (ListBox7.ItemIndex < 0) then
    Exit;

  Request.Prepare(DB.DB, 'insert or replace into TimeTable(DayOfWeek, EvenDay, LessonNumber, LessonId, GroupId) values(?1, ?2, ?3, ?4, ?5)');

  Request.Bind(1, (StringGrid1.Row + 1) div 2); // день недели
  Request.Bind(2, (StringGrid1.Row + 1) mod 2); // четность дня
  Request.Bind(3, StringGrid1.Col);         // номер урока
  Request.Bind(4, Integer(ListBox8.Items.Objects[ListBox8.ItemIndex])); // код урока
  Request.Bind(5, Integer(ListBox7.Items.Objects[ListBox7.ItemIndex]));             // код группы
  Request.Execute;
  Request.Close;

  // формируем расписание
  LoadTimeTable(Integer(ListBox7.Items.Objects[ListBox7.ItemIndex]));
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  Request: TSQLRequest;
begin
  if ListBox1.ItemIndex < 0 then
    Exit;

// удаляем выбранного преподавателя
  Request.Prepare(DB.DB, 'delete from Teachers where TeacherId = ?1');
  Request.Bind(1, Integer(ListBox1.Items.Objects[ListBox1.ItemIndex]));
  Request.Execute;
  Request.Close;

// и все его предметы  
  Request.Prepare(DB.DB, 'delete from Lessons where TeacherId = ?1');
  Request.Bind(1, Integer(ListBox1.Items.Objects[ListBox1.ItemIndex]));
  Request.Execute;
  Request.Close;

  LoadTeachers;
  LoadLessons;  
end;

// удаляем выбранный предмет из базы
procedure TForm2.Button2Click(Sender: TObject);
var
  Request: TSQLRequest;
begin
  if ListBox2.ItemIndex < 0 then
    Exit;

  Request.Prepare(DB.DB, 'delete from Subjects where SubjectId = ?1');
  Request.Bind(1, Integer(ListBox2.Items.Objects[ListBox2.ItemIndex]));
  Request.Execute;
  Request.Close;

  LoadSubjects;
end;

// добавление нового преподавателя
procedure TForm2.Button3Click(Sender: TObject);
var
  new: UTF8String;
  Request: TSQLRequest;
begin
  new := UTF8Encode(InputBox('Введите имя нового преподавателя', '', ''));

  Request.Prepare(DB.DB, 'insert or replace into Teachers(FIO) values(?1)');
  Request.Bind(1, new);
  Request.Execute;
  Request.Close;

  LoadTeachers;
end;

// добавить новый предмет
procedure TForm2.Button4Click(Sender: TObject);
var
  new: UTF8String;
  Request: TSQLRequest;
begin
  new := UTF8Encode(InputBox('Введите название нового предмета', '', ''));

  Request.Prepare(DB.DB, 'insert or replace into Subjects(Name) values(?1)');
  Request.Bind(1, new);
  Request.Execute;
  Request.Close;

  LoadSubjects;
end;

// добавить новую группу
procedure TForm2.Button5Click(Sender: TObject);
var
  new: UTF8String;
  Request: TSQLRequest;
begin
  new := UTF8Encode(InputBox('Введите название новой группы', '', ''));

  Request.Prepare(DB.DB, 'insert or replace into Groups(Name) values(?1)');
  Request.Bind(1, new);
  Request.Execute;
  Request.Close;

  LoadGroups;
end;

// удалить выбранную группу
procedure TForm2.Button6Click(Sender: TObject);
var
  Request: TSQLRequest;
begin
  if ListBox3.ItemIndex < 0 then
    Exit;

  Request.Prepare(DB.DB, 'delete from Groups where GroupId = ?1');
  Request.Bind(1, Integer(ListBox3.Items.Objects[ListBox3.ItemIndex]));
  Request.Execute;
  Request.Close;

  LoadGroups;
end;

// связать предмет с выбранным преподавателем
procedure TForm2.Button7Click(Sender: TObject);
var
  Request: TSQLRequest;
begin
  if (ListBox4.ItemIndex < 0) or (ListBox6.ItemIndex < 0) then
    Exit;

  Request.Prepare(DB.DB, 'insert or replace into Lessons(TeacherId, SubjectId) values(?1, ?2)');
  Request.Bind(1, Integer(ListBox6.Items.Objects[ListBox6.ItemIndex]));
  Request.Bind(2, Integer(ListBox4.Items.Objects[ListBox4.ItemIndex]));
  Request.Execute;
  Request.Close;

  ListBox4.OnClick(nil);
end;

// отвязать предмет от выбранного преподавателя
procedure TForm2.Button8Click(Sender: TObject);
var
  Request: TSQLRequest;
begin
  if (ListBox4.ItemIndex < 0) or (ListBox5.ItemIndex < 0) then
    Exit;

  Request.Prepare(DB.DB, 'delete from Lessons where TeacherId = ?1 and SubjectId = ?2');
  Request.Bind(1, Integer(ListBox5.Items.Objects[ListBox5.ItemIndex]));
  Request.Bind(2, Integer(ListBox4.Items.Objects[ListBox4.ItemIndex]));
  Request.Execute;
  Request.Close;

  ListBox4Click(nil);
end;

// убираем из расписания группы предмет
procedure TForm2.Button9Click(Sender: TObject);
var
  Request: TSQLRequest;
begin
  if (ListBox7.ItemIndex < 0) then
    Exit;

  Request.Prepare(DB.DB, 'delete from TimeTable where DayOfWeek = ?1 and EvenDay = ?2 and LessonNumber = ?3 and GroupId = ?4');

  Request.Bind(1, (StringGrid1.Row + 1) div 2);  // день недели
  Request.Bind(2, (StringGrid1.Row + 1) mod 2);                // четность дня
  Request.Bind(3, StringGrid1.Col);// номер урока
  Request.Bind(4, Integer(ListBox7.Items.Objects[ListBox7.ItemIndex])); // код группы

  Request.Execute;
  Request.Close;

  LoadTimeTable(Integer(ListBox7.Items.Objects[ListBox7.ItemIndex]));
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
// закрываем базу, больше не нужна
  DB.Free;
end;

// заполнение заголовков таблицы расписания
procedure TForm2.SetGridNames;
begin
  StringGrid1.Cells[1, 0] := '1 пара';
  StringGrid1.Cells[2, 0] := '2 пара';
  StringGrid1.Cells[3, 0] := '3 пара';
  StringGrid1.Cells[4, 0] := '4 пара';
  StringGrid1.Cells[5, 0] := '5 пара';

  StringGrid1.Cells[0, 1] := 'Пон. чёт';
  StringGrid1.Cells[0, 2] := 'Пон. нечёт';
  StringGrid1.Cells[0, 3] := 'Вт. чёт';
  StringGrid1.Cells[0, 4] := 'Вт. нечёт';
  StringGrid1.Cells[0, 5] := 'Ср. чёт';
  StringGrid1.Cells[0, 6] := 'Ср. нечёт';
  StringGrid1.Cells[0, 7] := 'Чет. чёт';
  StringGrid1.Cells[0, 8] := 'Чет. нечёт';
  StringGrid1.Cells[0, 9] := 'Пт. чёт';
  StringGrid1.Cells[0, 10] := 'Пт. нечёт';
  StringGrid1.Cells[0, 11] := 'Субб. чёт';
  StringGrid1.Cells[0, 12] := 'Субб. нечёт';
end;

// запуск приложения
procedure TForm2.FormCreate(Sender: TObject);
begin
// открываем базу
  DB := TSQLDatabase.Create('base.sqlite');

  // загружаем все данные
  LoadTeachers;
  LoadSubjects;
  LoadGroups;
  LoadLessons;
  LoadReplaces;

  SetGridNames;
end;

// загружаем расписание
procedure TForm2.LoadTimeTable(GroupId: Integer);
var
  Request: TSQLRequest;
  i, j: Integer;
begin
// сначала всё очищаем
  for i := 1 to 5 do
  for j := 1 to 12 do
  begin
    StringGrid1.Cells[i, j] := '';
    StringGrid1.Objects[i, j] := nil;
  end;

  // если ничего не выбрано, выходим
  if (ListBox7.ItemIndex < 0) then
    Exit;

    // берем из базы расписание для нужной группы
  Request.Prepare(DB.DB, 'select S.Name, T.FIO, TT.TimeTableId, TT.DayOfWeek, TT.EvenDay, TT.LessonNumber, TT.LessonId ' +
                         'from TimeTable TT inner join ' +
                         'Lessons L on TT.LessonId = L.LessonId inner join ' +
                         'Subjects S on L.SubjectId = S.SubjectId inner join ' +
                         'Teachers T on L.TeacherId = T.TeacherId ' +
                         'where TT.GroupId = ?1');

  Request.Bind(1, GroupId);
  while Request.Step = SQLITE_ROW do
  begin
    StringGrid1.Cells[Request.FieldInt(5), Request.FieldInt(3) * 2 - 1 + Request.FieldInt(4)] := Request.FieldString(0) + ' - ' + Request.FieldString(1);
    StringGrid1.Objects[Request.FieldInt(5), Request.FieldInt(3) * 2 - 1 + Request.FieldInt(4)] := TObject(Request.FieldInt(6));
  end;
  Request.Close;

  ListBox4.OnClick(nil);
  LoadTeachers;
end;

// генерируем расписания
// самое важное тут
procedure TForm2.Button11Click(Sender: TObject);
// константы для экселя
const
  xlDiagonalDown = 5;
  xlDiagonalUp = 6;
  xlEdgeBottom = 9;
  xlEdgeLeft = 7;
  xlEdgeRight = 10;
  xlEdgeTop = 8;
  xlInsideHorizontal = 12;
  xlInsideVertical = 11;
  xlNone = -4142;
  xlContinuous = 1;
  xlThin = 2;
  xlContext = -5002;
  xlCenter = -4108;
  xlBottom = -4107;
  xlWorkbookDefault = 51;
var
  Xl, Xlw: Variant;
  i, j: Integer;
  Teachers: TSQLRequest;
  Lessons: TSQLRequest;
  Filename: String;
begin
// если нужно отправлять, проверяем есть ли пароль
  if CheckBox1.Checked and (Edit4.Text = '') then
  begin
    ShowMessage('Для отправки по почте необходимо ввести пароль');
    exit;
  end;

  i := 1;


  StaticText1.Caption := '';
  StaticText2.Caption := '';
  Cursor := crHourGlass;

  // грузим учителей из базы
  Teachers.Prepare(DB.DB, 'select TeacherId, FIO, email from Teachers');

  // для каждого учителя запускаем эксель
  while Teachers.Step = SQLITE_ROW do
  begin
    StaticText1.Caption := Teachers.FieldString(1);
    StaticText2.Caption := 'Запуск Excel';

    Xl := CreateOleObject('Excel.Application');
    Xlw := Xl.Workbooks.Add;
    Xl.Visible := False;
    Xl.Columns[1].ColumnWidth := 45;

    StaticText2.Caption := 'Генерация таблицы';

    // и заполняем его данными

    Xl.Cells[i, 1] := 'Преподаватель ' + Teachers.FieldString(1);
    Xl.Cells[i, 1].Font.Bold := True;
    Xl.cells[i + 1, 1] := '"1" пара-8.30-10.00';
    Xl.cells[i + 2, 1] := '"3" пара-12.20-13.50';
    Xl.cells[i + 3, 1] := '"4" пара-14.00-15.30';
    Xl.cells[i + 4, 1] := '"5" пара-15.40-17.10';
    Xl.cells[i + 5, 1] := 'Зав.учебной частью';
    Xl.cells[i + 6, 1] := 'Попова Любовь Юрьевна';
    Xl.cells[i + 7, 1] := 'рабочий тел:(499) 610-37-53';
    Xl.cells[i + 8, 1] := '                  (925)800-12-26';

    Xl.cells[i, 5] := '2014/2015 учебный год';
    Xl.Cells[i, 5].Font.Bold := True;

          //  рисуем красивые рамочки, табличку
          //
          //  все эти красивости делались в экселе через запись макроса
          //  потом макрос просто копировался в делфи

    Xl.Range[Xl.Cells[i+1, 2], Xl.Cells[i+13, 8]].Select;

    Xl.Selection.Borders[xlDiagonalDown].LineStyle := xlNone;
    Xl.Selection.Borders[xlDiagonalUp].LineStyle := xlNone;
    Xl.Selection.Borders[xlEdgeLeft].LineStyle := xlNone;
    Xl.Selection.Borders[xlEdgeTop].LineStyle := xlNone;

    Xl.Selection.Borders[xlEdgeBottom].LineStyle := xlContinuous;
    Xl.Selection.Borders[xlEdgeBottom].Weight := xlThin;

    Xl.Selection.Borders[xlEdgeRight].LineStyle := xlNone;
    Xl.Selection.Borders[xlInsideVertical].LineStyle := xlNone;
    Xl.Selection.Borders[xlInsideHorizontal].LineStyle := xlNone;
    Xl.Selection.Borders[xlDiagonalDown].LineStyle := xlNone;
    Xl.Selection.Borders[xlDiagonalUp].LineStyle := xlNone;

    Xl.Selection.Borders[xlEdgeLeft].LineStyle := xlContinuous;
    Xl.Selection.Borders[xlEdgeLeft].Weight := xlThin;

    Xl.Selection.Borders[xlEdgeTop].LineStyle := xlContinuous;
    Xl.Selection.Borders[xlEdgeTop].Weight := xlThin;

    Xl.Selection.Borders[xlEdgeBottom].LineStyle := xlContinuous;
    Xl.Selection.Borders[xlEdgeBottom].Weight := xlThin;

    Xl.Selection.Borders[xlEdgeRight].LineStyle := xlContinuous;
    Xl.Selection.Borders[xlEdgeRight].Weight := xlThin;

    Xl.Selection.Borders[xlInsideVertical].LineStyle := xlContinuous;
    Xl.Selection.Borders[xlInsideVertical].Weight := xlThin;

    Xl.Selection.Borders[xlInsideHorizontal].LineStyle := xlContinuous;
    Xl.Selection.Borders[xlInsideHorizontal].Weight := xlThin;

    // продолжаем делать красивую таблицу
    for j := 0 to 5 do
    begin
      Xl.Range[Xl.Cells[i+j*2 + 2, 2], Xl.Cells[i+j*2+3, 2]].Select;
      Xl.Selection.HorizontalAlignment := xlCenter;
      Xl.Selection.VerticalAlignment := xlBottom;
      Xl.Selection.WrapText := False;
      Xl.Selection.Orientation := 0;
      Xl.Selection.AddIndent := False;
      Xl.Selection.IndentLevel := 0;
      Xl.Selection.ShrinkToFit := False;
      Xl.Selection.ReadingOrder := xlContext;
      Xl.Selection.MergeCells := False;
      Xl.Selection.Merge;

      Xl.Cells[i+j*2+2, 3] := 'числ';
      Xl.Cells[i+j*2+2+1, 3] := 'знам';
    end;

    // дни недели
    Xl.Cells[i+2, 2] := 'Понедельник';
    Xl.Cells[i+4, 2] := 'Вторник';
    Xl.Cells[i+6, 2] := 'Среда';
    Xl.Cells[i+8, 2] := 'Четверг';
    Xl.Cells[i+10, 2] := 'Пятница';
    Xl.Cells[i+12, 2] := 'Суббота';

    Xl.Cells[i+1, 4] := '"1"';
    Xl.Cells[i+1, 5] := '"2"';
    Xl.Cells[i+1, 6] := '"3"';
    Xl.Cells[i+1, 7] := '"4"';
    Xl.Cells[i+1, 8] := '"5"';

    StaticText2.Caption := 'Заполнение расписания';

    // заполняем расписание
    // Берем расписание для преподавателя с учетом замены.
    // Если заменен, значит ничего не выбираем, если не заменен, расписание того, кого заменили
    
    Lessons.Prepare(DB.DB, 'select G.Name, TT.DayOfWeek, TT.EvenDay, TT.LessonNumber ' +
                            'from TimeTable TT inner join ' +
                            'Lessons L on TT.LessonId = L.LessonId inner join ' +
                            'Groups G on G.GroupId = TT.GroupId inner join ' +
                            'TimeTableReplace TTR on TTR.TeacherId = L.TeacherId ' +
                            'where (ifnull(TTR.ReplaceTeacherId, L.TeacherId) = ?1 ' +
                            'and not exists (select 1 from TimeTableReplace where TeacherId = ?1))');
    Lessons.Bind(1, Teachers.FieldInt(0));
    while Lessons.Step = SQLITE_ROW do
    begin
      Xl.Cells[i + integer(Lessons.FieldInt(1)) * 2 - 1 + integer(Lessons.FieldInt(2)) + 1, integer(Lessons.FieldInt(3)) + 3] := Lessons.FieldString(0);
    end;

    Lessons.Close;

    StaticText2.Caption := 'Сохранение файла';


    // сохраняем файл
    Filename := ExtractFilePath(ParamStr(0)) + 'rasp\' + Teachers.FieldString(1) + '.xls';
    if FileExists(Filename) then
      DeleteFile(Filename);
    Xl.Application.Workbooks[1].SaveAs(Filename, xlWorkbookDefault);
    Xl.Application.Quit;
    Xl := Null;

    // и если нужно, отправляем по почте
    if CheckBox1.Checked and (Teachers.FieldString(2) <> '') then
      ShellExecute(Self.Handle, 'open', 'mailsend.exe',
        pansichar('-to ' + Teachers.FieldString(2) + ' -from ' + Edit1.Text + ' -ssl -port ' + Edit2.Text + ' -auth -smtp ' + Edit3.Text +
        ' -user ' + Edit1.Text + ' -pass "' + Edit4.Text + '" -sub "Расписание" +cc +bc -v -M "Расписание в приложении" -attach "' + Filename + ',application/vnd.ms-excel"'), nil, 1);
  end;
  Teachers.Close;
  Cursor := crArrow;

  StaticText1.Caption := 'Все расписания созданы';
  StaticText2.Caption := 'Завершено';
end;

procedure TForm2.Button12Click(Sender: TObject);
var
  Request: TSQLRequest;
begin
  if MessageDlg('Удалить все записи в разделе "преподаватели"?', mtConfirmation, mbYesNoCancel, 0) <> mrYes then
    Exit;

// удаляем всех преподователей
  Request.Prepare(DB.DB, 'delete from Teachers');
  Request.Execute;
  Request.Close;

// удаляем все предметы
  Request.Prepare(DB.DB, 'delete from Lessons');
  Request.Execute;
  Request.Close;

// перезагружаем данные  
  LoadTeachers;
  LoadLessons;  
end;

// удаляем все предметы из базы
procedure TForm2.Button13Click(Sender: TObject);
var
  Request: TSQLRequest;
begin
  if MessageDlg('Удалить все записи в разделе "предметы"?', mtConfirmation, mbYesNoCancel, 0) <> mrYes then
    Exit;

  Request.Prepare(DB.DB, 'delete from Subjects');
  Request.Execute;
  Request.Close;

  LoadSubjects;
end;

// удалить все группы
procedure TForm2.Button14Click(Sender: TObject);
var
  Request: TSQLRequest;
begin
  if MessageDlg('Удалить все записи в разделе "группы"?', mtConfirmation, mbYesNoCancel, 0) <> mrYes then
    Exit;

  Request.Prepare(DB.DB, 'delete from Groups');
  Request.Execute;
  Request.Close;

  LoadGroups;
end;

// загрузка групп из экселя
procedure TForm2.Button15Click(Sender: TObject);
var
  Xl, XLw: Variant;
  i: Integer;
  Request: TSQLRequest;
  new: UTF8String;
begin
  if OpenDialog1.Execute then
  begin
    Xl := CreateOleObject('Excel.Application');
    Xl.Visible := True;
    Xlw := Xl.Workbooks.Open(OpenDialog1.FileName);
    Xl.Application.EnableEvents := True;

    i := 1;
    while Xl.cells[i, 1].Value <> '' do
    begin
      new := UTF8Encode(Xl.cells[i, 1].Value);

      Request.Prepare(DB.DB, 'insert or replace into Groups(Name) values(?1)');
      Request.Bind(1, new);
      Request.Execute;
      Request.Close;
      inc(i);
    end;

    if Xl.Visible then
      Xl.Visible:=false;
    Xl.Quit;
    Xl := Unassigned;

    LoadGroups;
  end;
end;

// Импорт преподавателей из экселя
procedure TForm2.Button17Click(Sender: TObject);
var
  Xl, XLw: Variant;
  i, j: Integer;
  Request: TSQLRequest;
  new: UTF8String;
  TeacherId, SubjectId: Integer;
begin
  if OpenDialog1.Execute then
  begin
    Xl := CreateOleObject('Excel.Application');
    Xl.Visible := True;
    Xlw := Xl.Workbooks.Open(OpenDialog1.FileName);
    Xl.Application.EnableEvents := True;

    i := 1;
    while Xl.cells[i, 1].Value <> '' do
    begin
      new := UTF8Encode(Xl.cells[i, 1].Value);

      Request.Prepare(DB.DB, 'insert or replace into Teachers(FIO) values(?1)');
      Request.Bind(1, new);
      Request.Execute;
      Request.Close;

      Request.Prepare(DB.DB, 'select TeacherId from Teachers where FIO=?1');
      Request.Bind(1, new);
      while Request.Step = SQLITE_ROW do
        TeacherId := Request.FieldInt(0);
      Request.Close;

      j := 2;
      while Xl.cells[i, j].Value <> '' do
      begin
        new := UTF8Encode(Xl.cells[i, j].Value);

        Request.Prepare(DB.DB, 'insert or replace into Subjects(Name) values(?1)');
        Request.Bind(1, new);
        Request.Execute;
        Request.Close;

        Request.Prepare(DB.DB, 'select SubjectId from Subjects where Name=?1');
        Request.Bind(1, new);
        while Request.Step = SQLITE_ROW do
          SubjectId := Request.FieldInt(0);
        Request.Close;


        Request.Prepare(DB.DB, 'insert or replace into Lessons(TeacherId, SubjectId) values(?1,?2)');
        Request.Bind(1, TeacherId);
        Request.Bind(2, SubjectId);
        Request.Execute;
        Request.Close;

        inc(j);
      end;
      inc(i);
    end;

    if Xl.Visible then
      Xl.Visible:=false;
    Xl.Quit;
    Xl := Unassigned;

    LoadTeachers;
    LoadSubjects;
    LoadLessons;    
  end;
end;

procedure TForm2.ListBox9Click(Sender: TObject);
var
  data: TSQLRequest;
begin
  if ListBox9.ItemIndex < 0 then
    Exit;

    // заполняем преподавателей, которые могут заменить
    //  по хитрой схеме, отбраковывая всех, кто занят на любую из
    // нужных для замены пар. И убираем из списка того, кого  нужно мменять
  ListBox10.Clear;
  data.Prepare(DB.DB,
    'select TeacherId, FIO from Teachers ' +
    'where TeacherId not in( ' +
    'select T2.TeacherId ' +
    'from TimeTable TT inner join Lessons L on TT.LessonId = L.LessonId inner join Teachers T on L.TeacherId = T.TeacherId and T.TeacherId = ?1 ' +
    'inner join TimeTable TT2 on TT.DayOfWeek = TT2.DayOfWeek and TT.EvenDay = TT2.EvenDay and TT.LessonNumber = TT2.LessonNumber and TT.TimeTableId != TT2.TimeTableId ' +
    'inner join Lessons L2 on TT2.LessonId = L2.LessonId inner join Teachers T2 on L2.TeacherId = T2.TeacherId ' +
    'group by T2.TeacherId ' +
    'union all select ?1)'
  );
  data.Bind(1, Integer(ListBox9.Items.Objects[ListBox9.ItemIndex]));
  while data.Step = SQLITE_ROW do
  begin
    ListBox10.AddItem(data.FieldString(1), TObject(data.FieldInt(0)));
  end;
  data.Close;
end;

// добавляем замену
procedure TForm2.Button16Click(Sender: TObject);
var
  data: TSQLRequest;
begin
  if (ListBox9.ItemIndex < 0) or (ListBox10.ItemIndex < 0) then
    Exit;


  data.Prepare(DB.DB, 'insert or replace into TimeTableReplace(TeacherId, ReplaceTeacherId) values (?1, ?2)');
  data.Bind(1, Integer(ListBox9.Items.Objects[ListBox9.ItemIndex]));
  data.Bind(2, Integer(ListBox10.Items.Objects[ListBox10.ItemIndex]));
  data.Execute;
  data.Close;

  LoadReplaces;
end;

// убираем замену
procedure TForm2.Button18Click(Sender: TObject);
var
  data: TSQLRequest;
begin
  if (ListBox11.ItemIndex < 0) then
    Exit;

  data.Prepare(DB.DB, 'delete from TimeTableReplace where TimeTableReplaceId = ?1');
  data.Bind(1, Integer(ListBox11.Items.Objects[ListBox11.ItemIndex]));
  data.Execute;
  data.Close;

  LoadReplaces;
end;

// Загрузка емейлов из экселя
procedure TForm2.Button19Click(Sender: TObject);
var
  Xl, XLw: Variant;
  i: Integer;
  Request: TSQLRequest;
  email, name: UTF8String;
  TeacherId, SubjectId: Integer;
begin
  if OpenDialog1.Execute then
  begin
    Xl := CreateOleObject('Excel.Application');
    Xl.Visible := False;
    Xlw := Xl.Workbooks.Open(OpenDialog1.FileName);
    Xl.Application.EnableEvents := True;

    i := 1;
    while Xl.cells[i, 1].Value <> '' do
    begin
      email := UTF8Encode(Xl.cells[i, 1].Value);
      name := UTF8Encode(Xl.cells[i, 3].Value + ' ' + Xl.cells[i, 2].Value);

      Request.Prepare(DB.DB, 'update Teachers set email = ?1 where FIO = ?2');
      Request.Bind(1, email);
      Request.Bind(2, name);
      Request.Execute;
      Request.Close;

      inc(i);
    end;

    if Xl.Visible then
      Xl.Visible:=false;
    Xl.Quit;
    Xl := Unassigned;

    LoadTeachers;
    LoadSubjects;
    LoadLessons;    
  end;
end;

end.


