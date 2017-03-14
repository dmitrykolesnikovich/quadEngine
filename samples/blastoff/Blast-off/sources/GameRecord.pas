unit GameRecord;

interface

uses
  QuadEngine, SysUtils, Math;

type
  TGameRecord = class
  private
    FTime: Double;
    function GetAccuracy: Cardinal;
    function GetMaxSpeed: Double;
    function GetTimeM: String;
    procedure DrawText(XPos: Double; var YPos: Double; AText: String; AColor: Cardinal = $FFFFFFFF);
  public
    Deaths,
    MaxHeight,
    Shots,
    Hits,
    Kills,
    Accuracy: Cardinal;
    MaxSpeed: Double;
    FuelBurned: Double;
    MaxTime: Double;
    constructor Create;
    destructor Destroy; override;
    procedure Refresh;
    procedure DrawTitles(XPos: Integer; AQuad: IQuadRender; ADelta:Double);
    procedure Draw(XPos: Integer; AQuad: IQuadRender; Text: String = ''; AColor: Cardinal = $FFFFFFFF);
    procedure LoadFromFile(Section: String);
    procedure SaveToFile(Section: String);
    procedure Add(Rec: TGameRecord);
    procedure Replace(Rec: TGameRecord);
    procedure RefreshAccuracy;
  end;

var
  GRecord, SessionRecord, GlobalRecord, MaxRecord: TGameRecord;

implementation

uses
  Resources, IniFiles, iSettings;

function Animate(A, B, Time: Double): Double;
begin
  Result := (B - A) * (Time * Time * (3 - 2 * Time)) + A;
end;

{ TGameRecord }

procedure TGameRecord.Replace(Rec: TGameRecord);
begin
  if Hits <= Rec.Hits then
  begin
    if Rec.Hits = Hits then
      Shots := Min(Shots, Rec.Shots)
    else
      Shots := Rec.Shots;
    Hits := Rec.Hits;
    Accuracy := GetAccuracy;
  end;

  Deaths := Max(Deaths, Rec.Deaths);
  MaxSpeed := Max(MaxSpeed, Rec.MaxSpeed);
  Kills := Max(Kills, Rec.Kills);
  FuelBurned := Max(FuelBurned, Rec.FuelBurned);
  MaxTime := Max(MaxTime, Rec.MaxTime);
  MaxHeight := Max(MaxHeight, Rec.MaxHeight);
end;

procedure TGameRecord.Add(Rec: TGameRecord);
begin
  Inc(Deaths, Rec.Deaths);

  MaxSpeed := Max(MaxSpeed, Rec.MaxSpeed);

  Inc(Shots, Rec.Shots);
  Inc(Hits, Rec.Hits);
  Accuracy := GetAccuracy;
  Inc(Kills, Rec.Kills);

  MaxHeight := Max(MaxHeight, Rec.MaxHeight);

  FuelBurned := FuelBurned + Rec.FuelBurned;
  MaxTime := MaxTime + Rec.MaxTime;
end;

procedure TGameRecord.DrawText(XPos: Double; var YPos: Double; AText: String; AColor: Cardinal = $FFFFFFFF);
begin
  if AText <> '' then
    Fonts.Console.TextOutAligned(XPos, Ypos, 0.5, PAnsiChar(AnsiString(AText)), AColor, qfaRight);
  YPos := Ypos + Fonts.Console.TextHeight(' ', 0.5);
end;

constructor TGameRecord.Create;
begin
  Refresh;
end;

destructor TGameRecord.Destroy;
begin
  inherited;
end;

procedure TGameRecord.Draw(XPos: Integer; AQuad: IQuadRender; Text: String = ''; AColor: Cardinal = $FFFFFFFF);
var
  YPos: Double;
begin
  Ypos := 276;

  DrawText(XPos, YPos, Text, AColor);
  DrawText(XPos, YPos, '');
  DrawText(XPos, YPos, IntToStr(Kills), AColor);
  DrawText(XPos, YPos, IntToStr(Deaths), AColor);
  DrawText(XPos, YPos, '');
  DrawText(XPos, YPos, IntToStr(Shots), AColor);
  DrawText(XPos, YPos, IntToStr(Hits), AColor);
  DrawText(XPos, YPos, FormatFloat('0', Accuracy), AColor);
  DrawText(XPos, YPos, '');
  DrawText(XPos, YPos, IntToStr(MaxHeight), AColor);
  DrawText(XPos, YPos, FormatFloat('0.0', GetMaxSpeed), AColor);
  DrawText(XPos, YPos, FormatFloat('0', FuelBurned), AColor);
  DrawText(XPos, YPos, '');
  DrawText(XPos, YPos, GetTimeM, AColor);
end;

procedure TGameRecord.DrawTitles(XPos: Integer; AQuad: IQuadRender; ADelta:Double);
var
  YPos: Double;
  TextColor: Cardinal;
begin
  FTime := FTime + ADelta;
  if FTime > 1.5 then
    FTime := FTime - 1.5;

  AQuad.Rectangle(XPos-210, 180, Settings.WindowWidth - XPos + 210, 652, $CC000000);

  Fonts.Console.TextOutAligned(Settings.WindowWidth/2, 75, 1.5, 'BLAST-OFF', $FFFFFFFF, qfaCenter);

  Fonts.Console.TextOutAligned(Settings.WindowWidth/2, 200, 1.0, 'Game statistics', $FFFFFFFF, qfaCenter);

  Ypos := 276;

  DrawText(XPos, YPos, '');
  DrawText(XPos, YPos, '');
  DrawText(XPos, YPos, 'Kills', $FF88FFFF);
  DrawText(XPos, YPos, 'Deaths', $FF88FFFF);
  DrawText(XPos, YPos, '');
  DrawText(XPos, YPos, 'Shots fired', $FF88FFFF);
  DrawText(XPos, YPos, 'Direct hits', $FF88FFFF);
  DrawText(XPos, YPos, 'Accuracy (%)', $FF88FFFF);
  DrawText(XPos, YPos, '');
  DrawText(XPos, YPos, 'Max height (Km)', $FF88FFFF);
  DrawText(XPos, YPos, 'Max speed (Km/s)', $FF88FFFF);
  DrawText(XPos, YPos, 'Fuel burned (Units)', $FF88FFFF);
  DrawText(XPos, YPos, '');
  DrawText(XPos, YPos, 'Time spent in game', $FF88FFFF);

  TextColor := Trunc(Animate($00, $FF, FTime)) shl 24 + $FFFFFF;
  Fonts.Console.TextOutAligned(Settings.WindowWidth/2, 650, 1.0, 'Press SPACE BAR to restart', TextColor, qfaCenter);
end;

procedure TGameRecord.RefreshAccuracy;
begin
  Accuracy := GetAccuracy;
end;

function TGameRecord.GetAccuracy: Cardinal;
begin
  if Shots > 0 then
    Result := Trunc(Hits / Shots * 100)
  else
    Result := 0;
end;

function TGameRecord.GetMaxSpeed: Double;
begin
  Result := MaxSpeed / 200;
end;

function TGameRecord.GetTimeM: String;
begin
  Result := FormatDateTime('h:mm:ss', MaxTime/60/60/24);
end;

procedure TGameRecord.LoadFromFile(Section: String);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(Settings.ApplicationPath + 'Record.ini');
  try
    Deaths := ini.ReadInteger(Section, 'Deaths', 0);
    MaxHeight := ini.ReadInteger(Section, 'MaxHeight', 0);
    Shots := ini.ReadInteger(Section, 'ShotsFired', 0);
    Hits := ini.ReadInteger(Section, 'Hits', 0);
    Kills := ini.ReadInteger(Section, 'Kills', 0);
    MaxSpeed := ini.ReadFloat(Section, 'MaxSpeed', 0.0);
    FuelBurned := ini.ReadFloat(Section, 'FuelBurned', 0.0);
    MaxTime := ini.ReadFloat(Section, 'TimeSpent', 0.0);
    Accuracy := ini.ReadInteger(Section, 'Accuracy', 0);
  finally
    ini.Free;
  end;
end;

procedure TGameRecord.SaveToFile(Section: String);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(Settings.ApplicationPath + 'Record.ini');
  try
    ini.WriteInteger(Section, 'Deaths', Deaths);
    ini.WriteInteger(Section, 'MaxHeight', MaxHeight);
    ini.WriteInteger(Section, 'ShotsFired', Shots);
    ini.WriteInteger(Section, 'Hits', Hits);
    ini.WriteInteger(Section, 'Kills', Kills);
    ini.WriteFloat(Section, 'MaxSpeed', MaxSpeed);
    ini.WriteFloat(Section, 'FuelBurned', FuelBurned);
    ini.WriteFloat(Section, 'TimeSpent', MaxTime);
    ini.WriteInteger(Section, 'TimeSpent', Accuracy);
  finally
    ini.Free;
  end;
end;

procedure TGameRecord.Refresh;
begin
  Deaths := 0;
  MaxHeight := 0;
  Shots := 0;
  Hits := 0;
  Kills := 0;
  MaxSpeed := 0.0;
  FuelBurned := 0.0;
  MaxTime := 0.0;
end;

initialization
  GRecord := TGameRecord.Create;
  SessionRecord := TGameRecord.Create;
  GlobalRecord := TGameRecord.Create;
  GlobalRecord.LoadFromFile('Record');
  MaxRecord := TGameRecord.Create;
  MaxRecord.LoadFromFile('MaxRecord');

finalization
  GRecord.Free;
  SessionRecord.Free;
  GlobalRecord.Free;

end.
