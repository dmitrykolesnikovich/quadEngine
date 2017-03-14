unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, ToolWin, StdCtrls, ExtCtrls, Menus;

Const
  MAP_W = 34;
  MAP_H = 25;

type
  TConfig = record
    WaterAngle: Word;
    WaterSpeed: Byte;
    SvetX, SvetY: Word;
  end;

  PUnit = ^TUnit;
  TUnit = record
    X, Y, UnitType, Player: Byte;
  end;

  PDelay = ^TDelay;
  TDelay = record
    X, Y, T: Byte;
  end;

  TMyPoint = record
    X, Y: Byte;
  end;

  TDelayList = record
    X, Y, T, Count: Byte;
  end;
  TDelayListUnits = record
    Points: array of TMyPoint;
  end;

  TForm2 = class(TForm)
    IL: TImageList;
    Panel1: TPanel;
    ToolBar: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    SD: TSaveDialog;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    OD: TOpenDialog;
    ToolButton11: TToolButton;
    UnitList: TComboBox;
    ToolButton12: TToolButton;
    PlayerList: TComboBox;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    StatusBar: TStatusBar;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    ToolButton20: TToolButton;
    Menu: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    PanelConfig: TPanel;
    Tree: TTreeView;
    GroupBox1: TGroupBox;
    MapName: TEdit;
    GroupBox2: TGroupBox;
    VectorWater: TTrackBar;
    VectorWaterImg: TImage;
    ToolButton21: TToolButton;
    ToolButton22: TToolButton;
    ToolButton23: TToolButton;
    DecorList: TComboBox;
    ToolButton24: TToolButton;
    ToolButton25: TToolButton;
    GroupBox3: TGroupBox;
    WaterSpeed: TTrackBar;
    procedure ToolButton6Click(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ToolButton10Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton19Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure VectorWaterChange(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure UnitListChange(Sender: TObject);
    procedure DecorListChange(Sender: TObject);
  private
    FDownL, FDownC, FDownR: Boolean;
    FMapGround: array[0..MAP_W-1, 0..MAP_H-1] of Byte;
    FBrush: Integer;
    FUnits: array of TUnit;
    FUnitsComp, FUnitsPlayer: Integer;
    FUnitToTree: Boolean;
    NodeSelected: TTreeNode;
    MouseX, MouseY: Integer;
    FDecorList: array[0..MAP_W-1, 0..MAP_H-1] of Integer;
    SvetX, SvetY: Integer;
    procedure DrawGrid;
    procedure DrawGround(X, Y, ABrush: Integer);
    procedure DrawDecor;
    procedure DrawSvet;
    procedure DrawDelay;
    procedure DrawUnit;
    procedure Save;
    procedure SaveGround(AFile: TFileStream);
    procedure SaveDelay(AFile: TFileStream);
    procedure SaveConfig(AFile: TFileStream);
    procedure SaveDecor(AFile: TFileStream);
    procedure Load;
    procedure LoadGround(AFile: TFileStream);
    procedure LoadDelay(AFile: TFileStream);
    procedure LoadConfig(AFile: TFileStream);
    procedure LoadDecor(AFile: TFileStream);
    procedure RefreshMap;
    procedure NewMap;
    procedure AddUnit(X, Y, UnitType, Player: Integer);
    procedure DelUnit(X, Y: Integer);
    function ExistsUser(X, Y: Integer): Boolean;
    procedure SaveUnits(AFile: TFileStream);
    procedure LoadUnits(AFile: TFileStream);
    procedure RefreshStatusBar;
    function MouseWin(X, Y: Integer): Boolean;
    function AddTree(X, Y, ABrush: Integer): TTreeNode;
    procedure DelTree(X, Y: Integer);
    procedure AddUnitDelay(X, Y: Integer);
    function GetUserList(X, Y: Integer): PUnit;
    function GetDelayExistsUnit(X, Y: Integer): Boolean;
    procedure RefreshVectorWater;
    procedure AddDecor(X, Y: Integer);
    procedure DelDecor(X, Y: Integer);
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.N3Click(Sender: TObject);
begin
  //
end;

procedure TForm2.AddDecor(X, Y: Integer);
var
  l: Integer;
begin
  if (X = 0) or (Y = 0) or (X = 33) or (Y = 24) or ExistsUser(X, Y) or (FMapGround[X, Y] = 5) or (FDecorList[X, Y] > -1) then
    Exit;
  FDecorList[X, Y] := DecorList.ItemIndex;
end;

procedure TForm2.DelDecor(X, Y: Integer);
begin
  if (X <= 0) or (Y <= 0) or (X >= 33) or (Y >= 24) or (FDecorList[X, Y] = -1) then
    Exit;
  FDecorList[X, Y] := -1;
end;

procedure TForm2.AddUnit(X, Y, UnitType, Player: Integer);
var
  l: Integer;
begin
  if (X = 0) or (Y = 0) or (X = 33) or (Y = 24) or ExistsUser(X, Y){ or ((FMapGround[X, Y] = 5) and (UnitType <> 0))} or (FDecorList[X, Y] > -1) then
    Exit;
  l := Length(FUnits);
  SetLength(FUnits, l + 1);
  FUnits[l].X := X;
  FUnits[l].Y := Y;
  FUnits[l].UnitType := UnitType;
  FUnits[l].Player := Player;
  case FUnits[l].Player of
    0: Inc(FUnitsPlayer);
    1: Inc(FUnitsComp);
  end;
end;

procedure TForm2.DelUnit(X, Y: Integer);
var
  i, l: Integer;
begin
  l := length(FUnits) - 1;
  for i := l downto 0 do
  begin
    if (FUnits[i].X = X) and (FUnits[i].Y = Y) then
    begin
      case FUnits[i].Player of
        0: Dec(FUnitsPlayer);
        1: Dec(FUnitsComp);
      end;
      if i <> l then
        FUnits[i] := FUnits[l];

      SetLength(FUnits, l);
      Exit;
    end;
  end;
end;

procedure TForm2.DrawGrid;
var
  i: Integer;
begin
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Color := $AAAAAA;
  for i := 1 to MAP_W-1 do
  begin
    Canvas.MoveTo(i*24, ToolBar.Height);
    Canvas.LineTo(i*24, ClientHeight);
  end;
  for i := 0 to MAP_H-1 do
  begin
    Canvas.MoveTo(0, i*24+22);
    Canvas.LineTo(816, i*24+22);
  end;
  Canvas.Pen.Color := $000000;
  Canvas.Brush.Style := bsClear;
  Canvas.Rectangle(24, 46, 794, 600);
  Canvas.Pen.Color := $FFFFFF;
  Canvas.Rectangle(23, 45, 793, 599);
end;

procedure TForm2.DrawGround(X, Y, ABrush: Integer);
begin
  FMapGround[X, Y] := ABrush;
  case ABrush of
    0: Canvas.Brush.Color := clHotLight;
    1: Canvas.Brush.Color := clHighlight;
    3: Canvas.Brush.Color := clOlive;
    4: Canvas.Brush.Color := clGreen;
    5: Canvas.Brush.Color := clFuchsia;
    6, 13: begin
      Canvas.Brush.Color := clYellow;
      FMapGround[X, Y] := 6;
    end;
    else
      Canvas.Brush.Color := clBtnFace;
  end;
 // if (ABrush = 5) then
 //   DelUnit(X, Y);
  Canvas.Pen.Style := psClear;
  Canvas.Brush.Style := bsSolid;
  Canvas.Rectangle(X * 24 + 1, Y * 24 + 23, X * 24 + 25, Y * 24 + 47);
  //Canvas.TextOut(X * 24 + 1, Y * 24 + 23, IntToStr(ABrush));
end;

procedure TForm2.DrawSvet;
begin
  Canvas.Font.Color := clRed;
  Canvas.TextOut(SvetX, SvetY, 'L');
end;

procedure TForm2.DrawDelay;
var
  Node, pNode: TTreeNode;
  Delay: PDelay;
  i, j: integer;
  iUnit: PUnit;
begin
  i := 1;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Color := $FF0000;
  Node := Tree.TopItem;
  while Assigned(Node) do
  begin
    Delay := PDelay(Node.Data);
    for j := 0 to Node.Count - 1 do
    begin
      iUnit := PUnit(Node.Item[j].Data);
      Canvas.MoveTo(Delay^.X * 24 + 12, Delay^.Y * 24 + 12 + ToolBar.Height);
      Canvas.LineTo(iUnit^.X * 24 + 12, iUnit^.Y * 24 + 12 + ToolBar.Height);
    end;

    Canvas.Font.Color := clBlack;
    Canvas.TextOut(Delay^.X * 24 + 2, Delay^.Y * 24 + 21, 'T' + IntToStr(i));
    Node := Node.GetNextSibling;
    Inc(i);
  end;
end;

procedure TForm2.DrawDecor;
var
  X, Y: Integer;
begin
  Canvas.Font.Color := clBlack;
  for Y := 0 to MAP_H-1 do
    for X := 0 to MAP_W-1 do
      if FDecorList[X, Y] > -1 then
        Canvas.TextOut(X * 24 + 2, Y * 24 + 33, 'D' + IntToStr(FDecorList[X, Y]));

end;

procedure TForm2.DrawUnit;
var
  i, Count: Integer;
begin
  Count := length(FUnits);
  for i := 0 to Count - 1 do
  begin
    case FUnits[i].Player of
      0: Canvas.Font.Color := clBlack;
      1: Canvas.Font.Color := clRed;
    end;
    Canvas.TextOut(FUnits[i].X * 24 + 2, FUnits[i].Y * 24 + 33, IntToStr(FUnits[i].UnitType+1));
  end;

  StatusBar.Panels.Items[0].Text := '�����: ' + IntToStr(FUnitsPlayer);
  StatusBar.Panels.Items[1].Text := '���������: ' + IntToStr(FUnitsComp);
end;

function TForm2.ExistsUser(X, Y: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to length(FUnits) - 1 do
    if (FUnits[i].X = X) and (FUnits[i].Y = Y) then
    begin
      Result := True;
      Exit;
    end;
end;

procedure TForm2.RefreshStatusBar;
var
  i: Integer;
begin
  FUnitsComp := 0;
  FUnitsPlayer := 0;
  for i := 0 to length(FUnits) - 1 do
    case FUnits[i].Player of
      0: Inc(FUnitsPlayer);
      1: Inc(FUnitsComp);
    end;
end;

procedure TForm2.RefreshVectorWater;
begin
  VectorWaterImg.Canvas.Rectangle(-1, -1, 33, 33);
  VectorWaterImg.Canvas.MoveTo(16, 16);
  VectorWaterImg.Canvas.LineTo(Round(16+16*Cos(VectorWater.Position/180*Pi)), Round(16+16*Sin(VectorWater.Position/180*Pi)));
end;

procedure TForm2.NewMap;
var
  X, Y: Integer;
begin
  for Y := 0 to MAP_H-1 do
    for X := 0 to MAP_W-1 do
    begin
      FMapGround[X, Y] := 2;
      FDecorList[X, Y] := -1;
    end;
  SetLength(FUnits, 0);

  RefreshMap;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  SD.InitialDir := ExtractFilePath(Application.Exename);
  OD.InitialDir := ExtractFilePath(Application.Exename);

 // if FileExists(ExtractFilePath(Application.Exename) + 'UnitList.txt') then
  //  UnitList.Items.LoadFromFile(ExtractFilePath(Application.Exename) + 'UnitList.txt');
  if UnitList.Items.Count > 0 then
    UnitList.ItemIndex := 0;

  FBrush := 0;
  FUnitsComp := 0;
  FUnitsPlayer := 0;
  NodeSelected := nil;
  FUnitToTree := False;
  NewMap;
end;

procedure TForm2.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if not MouseWin(X, Y) then
    Exit;

  case Button of
    mbLeft  :
    begin
      FDownL := True;

      if FUnitToTree then
        AddUnitDelay(X div 24, (Y - 22) div 24)
      else
        case FBrush of
          0..5, 13: DrawGround(X div 24, (Y - 22) div 24, FBrush);
          9: AddUnit(X div 24, (Y - 22) div 24, UnitList.ItemIndex, PlayerList.ItemIndex);
          10, 11: AddTree(X div 24, (Y - 22) div 24, FBrush);
          14: AddDecor(X div 24, (Y - 22) div 24);
          15: begin
            SvetX := X;
            SvetY := Y;
          end;
        end;
    end;
    mbRight :
    begin
      FDownR := True;
      case FBrush of
        0..5, 13: DrawGround(X div 24, (Y - 22) div 24, 2);
        9: DelUnit(X div 24, (Y - 22) div 24);
        10, 11: DelTree(X div 24, (Y - 22) div 24);
        14: DelDecor(X div 24, (Y - 22) div 24);
      end;
    end;
    mbMiddle: FDownC := True;
  end;

  RefreshMap;      
  FUnitToTree := False;
end;

procedure TForm2.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if not MouseWin(X, Y) then
  begin
    FDownL := False;
    FDownR := False;
    FDownC := False;
    Exit;
  end;
  MouseX := X;
  MouseY := Y;
  StatusBar.Panels.Items[2].Text := IntToStr(X div 24) + 'x' + IntToStr((Y - 22) div 24);

  if FDownL and ((FBrush < 6) or (FBrush > 11)) then
    DrawGround(X div 24, (Y - 22) div 24, FBrush)
  else
    if FDownR and ((FBrush < 6) or (FBrush > 11)) then
      DrawGround(X div 24, (Y - 22) div 24, 2);

end;

procedure TForm2.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not MouseWin(X, Y) then
    Exit;

  case Button of
    mbLeft  : FDownL := False;
    mbRight : FDownR := False;
    mbMiddle: FDownC := False;
  end;   
  RefreshMap;
end;

procedure TForm2.FormPaint(Sender: TObject);
begin
  RefreshMap;
end;

procedure TForm2.Load;
var
  AFile: TFileStream;
  Teg: AnsiString;
  Seek: Integer;
begin
  if not OD.Execute then
    Exit;
  SD.InitialDir := OD.FileName;

  AFile := TFileStream.Create(OD.FileName, fmOpenRead);
  try
    AFile.Seek(0, soBeginning);
    SetLength(Teg, 3);
    AFile.Read(Teg[1], 3);
    if AnsiCompareText(Teg, 'MAP') = 0 then
    begin

      while AFile.Position < AFile.Size do
      begin
        SetLength(Teg, 4);
        AFile.Read(Teg[1], 4);
        AFile.Read(Seek, SizeOf(Seek));
        if AnsiCompareText(Teg, 'GRND') = 0 then
          LoadGround(AFile)
        else
        if AnsiCompareText(Teg, 'UNIT') = 0 then
          LoadUnits(AFile)  
        else
        if AnsiCompareText(Teg, 'DELY') = 0 then
          LoadDelay(AFile) 
        else
        if AnsiCompareText(Teg, 'CONF') = 0 then
          LoadConfig(AFile)
        else
        if AnsiCompareText(Teg, 'DECR') = 0 then
          LoadDecor(AFile)
        else
          AFile.Seek(Seek, soCurrent);
      end;
    end
    else
      ShowMessage('���� �� �������� ������');
  finally
    AFile.Free;
  end;
  RefreshMap;
end;

procedure TForm2.RefreshMap;
Var
  X, Y: Integer;
begin
  for Y := 0 to MAP_H-1 do
    for X := 0 to MAP_W-1 do
      DrawGround(X, Y, FMapGround[X, Y]);

  DrawGrid;  
  DrawDelay;
  DrawUnit;
  DrawDecor;
  DrawSvet;
end;

procedure TForm2.ToolButton9Click(Sender: TObject);
begin
  Load;
end;

procedure TForm2.UnitListChange(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to componentcount - 1 do
    if (Components[i] is TToolButton) and ((Components[i] as TToolButton).Style = tbsCheck) then
      TToolButton(Components[i]).Down := False;

  ToolButton13.Down := True;
  FBrush := ToolButton13.ImageIndex;
end;

procedure TForm2.VectorWaterChange(Sender: TObject);
begin
  RefreshVectorWater;
end;

procedure TForm2.Save;
var
  AFile: TFileStream;
begin
  if not SD.Execute then
    Exit;
  OD.InitialDir := SD.FileName;

  AFile := TFileStream.Create(SD.FileName, fmCreate);
  try
    AFile.Write(AnsiString('MAP')[1], 3);
    SaveGround(AFile);
    SaveUnits(AFile);
    SaveDelay(AFile);
    SaveConfig(AFile);
    SaveDecor(AFile);
  finally
    AFile.Free;
  end;
  RefreshMap;
end;

procedure TForm2.SaveDecor(AFile: TFileStream);
var
  TotalSize, Size: Integer;
  X, Y, i: Integer;
  Decor: array of TDelay;
begin
  for Y := 0 to MAP_H-1 do
    for X := 0 to MAP_W-1 do
      if FDecorList[X, Y] >= 0 then
      begin
        i := length(Decor);
        SetLength(Decor, i+1);
        Decor[i].X := X;
        Decor[i].Y := Y;
        Decor[i].T := FDecorList[X, Y];
      end;
  i := Length(Decor);
  if i = 0 then
    Exit;
  AFile.Write(AnsiString('DECR')[1], 4);
  Size := SizeOf(TDelay) * i;
  TotalSize := Size + SizeOf(i);
  AFile.Write(TotalSize, SizeOf(TotalSize));
  AFile.Write(i, SizeOf(i));
  AFile.WriteBuffer(Decor[0], Size);
end;

procedure TForm2.SaveConfig(AFile: TFileStream);
var
  TotalSize: Integer;
  Size: Byte;
  Name: AnsiString;
  conf: TConfig;
begin
  AFile.Write(AnsiString('CONF')[1], 4);
  Name := MapName.Text;
  Size := length(Name);
  conf.SvetX := SvetX;
  conf.SvetY := SvetY;
  conf.WaterAngle := VectorWater.Position+90;
  conf.WaterSpeed := WaterSpeed.Position;
  TotalSize := SizeOf(conf) + SizeOf(Size) + Size;
  AFile.Write(TotalSize, SizeOf(TotalSize));
  AFile.Write(Size, SizeOf(Size));
  AFile.Write(Name[1], Size);
  AFile.Write(conf, SizeOf(conf));
end;

procedure TForm2.SaveUnits(AFile: TFileStream);
var
  TotalSize, Count, Size: Integer;
begin
  AFile.Write(AnsiString('UNIT')[1], 4);
  Count := Length(FUnits);
  Size := Count * SizeOf(FUnits);
  TotalSize := Size + SizeOf(TotalSize);
  AFile.Write(TotalSize, SizeOf(TotalSize));
  AFile.Write(Count, SizeOf(Count));
  AFile.WriteBuffer(FUnits[0], Size);
end;

procedure TForm2.LoadUnits(AFile: TFileStream);
var
  Count, Size: Integer;
begin
  AFile.Read(Count, SizeOf(Count));
  SetLength(FUnits, Count);
  Size := Count * SizeOf(FUnits);
  AFile.ReadBuffer(FUnits[0], Size);
  RefreshStatusBar;
end;

function TForm2.MouseWin(X, Y: Integer): Boolean;
begin
  Result := (X >= 0) and (Y >=0) and (X < ClientWidth) and (Y < ClientHeight);
end;

procedure TForm2.LoadDelay(AFile: TFileStream);
var
  Count, i, j, Size: Integer;
  Delay: TDelayList;
  Units: array of TMyPoint;
begin
  Tree.Items.Clear;
  AFile.Read(Count, SizeOf(Count));

  for i := 0 to Count - 1 do
  begin
    AFile.Read(Delay, SizeOf(Delay));
    NodeSelected := AddTree(Delay.X, Delay.Y, Delay.T+10);

    SetLength(Units, Delay.Count);

    Size := Delay.Count * SizeOf(TMyPoint);
    AFile.ReadBuffer(Units[0], Size);
    for j := 0 to Delay.Count - 1 do
       AddUnitDelay(Units[j].X, Units[j].Y);
  end;
end;

procedure TForm2.SaveDelay(AFile: TFileStream);
var
  Node: TTreeNode;
  Delay: PDelay;
  i, j, Count: integer;
  iUnit: PUnit;
  TotalSize, Size: Integer;
  List: array of TDelayList;
  DelayList1: TDelayList;
  Units: array of TDelayListUnits;
begin
  TotalSize := SizeOf(TotalSize);
  Count := 0;

  Node := Tree.TopItem;
  while Assigned(Node) do
  begin
    Delay := PDelay(Node.Data); 
    SetLength(List, Count+1);
    SetLength(Units, Count+1);
    List[Count].T := Delay^.T;
    List[Count].Count := Node.Count;
    List[Count].X := Delay^.X;  
    List[Count].Y := Delay^.Y;

    SetLength(Units[Count].Points, List[Count].Count);
    TotalSize := TotalSize + List[Count].Count*2 + 4;
    for i := 0 to List[Count].Count - 1 do
    begin
      iUnit := PUnit(Node.Item[i].Data);
      Units[Count].Points[i].X := iUnit.X;
      Units[Count].Points[i].Y := iUnit.Y;
    end;
    Node := Node.getNextSibling;
    Inc(Count);
  end;

  AFile.Write(AnsiString('DELY')[1], 4);
  AFile.Write(TotalSize, SizeOf(TotalSize));
  AFile.Write(Count, SizeOf(Count));

  for i := 0 to Count - 1 do
  begin
    DelayList1 := List[i];
    AFile.Write(DelayList1, SizeOf(DelayList1));
    Size := List[i].Count * SizeOf(TMyPoint);
    AFile.WriteBuffer(Units[i].Points[0], Size);
  end;     
end;

procedure TForm2.SaveGround(AFile: TFileStream);
var
  MapSizeW, MapSizeH: Byte;
  TotalSize: Integer;
begin
  AFile.Write(AnsiString('GRND')[1], 4);
  MapSizeW := 34;
  MapSizeH := 25;
  TotalSize := SizeOf(MapSizeW) + SizeOf(MapSizeH) + MapSizeW * MapSizeH;
  AFile.Write(TotalSize, SizeOf(TotalSize));
  TotalSize := MapSizeW * MapSizeH;
  AFile.Write(MapSizeW, SizeOf(MapSizeW));
  AFile.Write(MapSizeH, SizeOf(MapSizeH));
  AFile.WriteBuffer(FMapGround[0], TotalSize);
end;

procedure TForm2.LoadGround(AFile: TFileStream);
var
  MapSizeW, MapSizeH: Byte;
  TotalSize: Integer;
begin
  AFile.Read(MapSizeW, SizeOf(MapSizeW));
  AFile.Read(MapSizeH, SizeOf(MapSizeH));
  TotalSize := MapSizeW * MapSizeH;
  AFile.ReadBuffer(FMapGround[0], TotalSize);
end;

procedure TForm2.LoadConfig(AFile: TFileStream);
var
  TotalSize: Integer;
  Size: Byte;
  Name: AnsiString;
  conf: TConfig;
begin
  AFile.Read(Size, SizeOf(Size));
  SetLength(Name, Size);
  AFile.Read(Name[1], Size);
  MapName.Text := Name;
  AFile.Read(conf, SizeOf(conf));
  SvetX := conf.SvetX;
  SvetY := conf.SvetY;
  VectorWater.Position := conf.WaterAngle-90;
  WaterSpeed.Position := conf.WaterSpeed;
end;

procedure TForm2.LoadDecor(AFile: TFileStream);
var
  TotalSize, Size: Integer;
  i, Count: Integer;
  Decor: array of TDelay;
begin
  AFile.Read(Count, SizeOf(Count));
  SetLength(Decor, Count);
  Size := Count * SizeOf(TDelay);
  AFile.ReadBuffer(Decor[0], Size);
  for i := 0 to Count - 1 do
    FDecorList[Decor[i].X, Decor[i].Y] := Decor[i].T;
end;

procedure TForm2.ToolButton10Click(Sender: TObject);
begin
  Save;
end;

procedure TForm2.ToolButton6Click(Sender: TObject);
Var
  i: Integer;
begin
  for i := 0 to componentcount - 1 do
    if (Components[i] is TToolButton) and ((Sender as TToolButton).Style = tbsCheck) then
      TToolButton(Components[i]).Down := False;

  (Sender as TToolButton).Down := True;
  FBrush := (Sender as TToolButton).ImageIndex;
end;

procedure TForm2.ToolButton8Click(Sender: TObject);
begin
  if MessageDlg('������� ����� �����?', mtWarning, mbOKCancel, 0) = mrOK then
    NewMap;
end;

procedure TForm2.ToolButton19Click(Sender: TObject);
begin
  (Sender as TToolButton).Down := Width < 850;

  if (Sender as TToolButton).Down then
  begin
    Width := Width + 200;
    PanelConfig.Visible := True;
  end
  else   
  begin
    Width := Width - 200;
    PanelConfig.Visible := False;
  end;
  RefreshVectorWater;
end;

function TForm2.AddTree(X, Y, ABrush: Integer): TTreeNode;
var
  Count: Integer;
  NodeName: string;
  Delay: PDelay;
begin
  Result := nil;
  New(Delay);
  case ABrush of
    10:
    begin
      NodeName := '���������';
      Delay^.T := 0;
    end;
    11:
    begin
      NodeName := '������';
      Delay^.T := 1;
    end;
  end;
  Delay^.X := X;
  Delay^.Y := Y;
  Count := Tree.Items.Count;
  Result := Tree.Items.AddChildObject(nil, IntToStr(Count + 1) + '. ' + Chr(Y+64) + IntToStr(X) + ' (' + NodeName + ')', Delay);
end; 

procedure TForm2.AddUnitDelay(X, Y: Integer);
var
  NodeName: string;
  iUnit: PUnit;
  Delay: TDelay;
begin
  Delay := PDelay(NodeSelected.Data)^;
  if ((Delay.X = X) and (Delay.Y = Y)) {or GetDelayExistsUnit(X, Y) }then
    Exit;
  iUnit := GetUserList(X, Y);
  NodeName := UnitList.Items.Strings[iUnit^.UnitType];
  Tree.Items.AddChildObject(NodeSelected, Chr(Y+64) + IntToStr(X) + ' (' + NodeName + ')', iUnit);
  NodeSelected.Focused := True;
  NodeSelected.Expanded := true;
end;

procedure TForm2.DecorListChange(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to componentcount - 1 do
    if (Components[i] is TToolButton) and ((Sender as TToolButton).Style = tbsCheck) then
      TToolButton(Components[i]).Down := False;

  ToolButton22.Down := True;
  FBrush := ToolButton22.ImageIndex;
end;

procedure TForm2.DelTree(X, Y: Integer);
var
  Node, dNode: TTreeNode;
  Delay: PDelay;
begin
  Node := Tree.TopItem;
  while Assigned(Node) do
  begin
    Delay := PDelay(Node.Data);
    dNode := Node;    
    Node := Node.GetNext;
    if (Delay^.X = X) and (Delay^.Y = Y) then
    begin
      dNode.Delete;
      Dispose(Delay);
    end;
  end;
end;

procedure TForm2.N1Click(Sender: TObject);
var
  Node, dNode: TTreeNode;
  Delay: PDelay;
  i: integer;
begin
  if Tree.Items.Count = 0 then
  begin
    ShowMessage('������� ����� ��������');
    Exit;
  end;   
  if Length(FUnits) = 0 then
  begin
    ShowMessage('�� ����� ��� �� ������ �����!');
    Exit;
  end;

  NodeSelected := Tree.Selected;
  FUnitToTree := True;
end;

procedure TForm2.N2Click(Sender: TObject);
begin
  Tree.Selected.Delete;
  RefreshMap;
end;

function TForm2.GetUserList(X, Y: Integer): PUnit;
var
  i, Count: Integer;
begin
  Result := nil;
  Count := Length(FUnits);
  for i := 0 to Count do
    if (FUnits[i].X = X) and (FUnits[i].Y = Y) then
    begin
      Result := @FUnits[i];
      Exit;
    end;
end;

function TForm2.GetDelayExistsUnit(X, Y: Integer): Boolean;
var
  Node: TTreeNode;
  Delay: PDelay;
  j: integer;
  iUnit: PUnit;
begin
  Result := False;
  Node := Tree.TopItem;
  while Assigned(Node) do
  begin
    Delay := PDelay(Node.Data);
    for j := 0 to Node.Count - 1 do
    begin
      iUnit := PUnit(Node.Item[j].Data);
      if (iUnit^.X = X) and (iUnit^.Y = Y) then
      begin
        Result := True;
        Exit;
      end;
    end;
    Node := Node.GetNext;
  end;
end;

end.
