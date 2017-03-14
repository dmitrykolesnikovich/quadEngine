unit mSettings;

interface

uses
  Windows, Classes, SysUtils, IniFiles;

type
  TSettings = class
  private
    const SECTIONGRAPHICS = 'Graphics';
    const SECTIONAUDIO = 'Audio';
    const SECTIONGAME = 'Game';
  public
  const
    FILENAME = 'Settings.ini';  
    WindowWidth = 1024;
    WindowHeight = 768;
  var
    MusicVolume: Integer;
    ApplicationPath: string;
    HPVisible: Boolean;
    UnitSpeed: Integer;
    procedure Initialize;
    procedure Finalize;
  end;

var
  Settings: TSettings;

implementation

{ TSettings }

procedure TSettings.Finalize;
var
  ini: TIniFile;
begin
  ApplicationPath := ExtractFilePath(ParamStr(0));

  ini := TIniFile.Create(ApplicationPath + FILENAME);
  try
    //ini.WriteBool(SECTIONGAME, 'HPVisible', HPVisible);
    ini.WriteInteger(SECTIONGAME, 'UnitSpeed', UnitSpeed);
  finally
    ini.Free;
  end;
end;

procedure TSettings.Initialize;
var
  ini: TIniFile;
begin
  ApplicationPath := ExtractFilePath(ParamStr(0));

  ini := TIniFile.Create(ApplicationPath + FILENAME);
  try
    HPVisible := ini.ReadBool(SECTIONGAME, 'HPVisible', True);
    UnitSpeed := ini.ReadInteger(SECTIONGAME, 'UnitSpeed', 1);
    if UnitSpeed > 3 then
      UnitSpeed := 3
    else
      if UnitSpeed < 1 then
      UnitSpeed := 1

  finally
    ini.Free;
  end;
end;

initialization
  Settings := TSettings.Create;
  Settings.Initialize;

finalization
  Settings.Finalize;
  Settings.Free;

end.
