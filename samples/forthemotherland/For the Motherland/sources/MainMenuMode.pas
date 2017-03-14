unit MainMenuMode;

interface

uses
  QuadEngine, Classes, Controls, CustomGameMode, Graphics, Dialogs, SysUtils, Resources,
  mSettings, Windows, Cursor, Collision, MainMenu, Vec2f, bass;

type
  TMainMenuMode = class(TCustomGameMode)
  private
    FMainMenu: TMenu;
    FMouse: TVec2f;
  public
    MMResumeGame: TTopMenuItem;
    MMStartGame: TTopMenuItem;
    MMOptions: TTopMenuItem;
    MMHelp: TTopMenuItem;
    MMExitGame: TTopMenuItem;

    FlvlEn: Boolean;
    FlvlMenu: TMenu;
    MMlvl1: TTopMenuItem;
    MMlvl2: TTopMenuItem;
    MMlvl3: TTopMenuItem;
    MMlvl4: TTopMenuItem;
    MMlvl5: TTopMenuItem;
    MMlvl6: TTopMenuItem;

    Fon: Integer;

    procedure OnCreate; override;
    procedure OnDestroy; override;
    procedure OnKeyDown(Key: Word; Shift: TShiftState); override;
    procedure OnKeyUp(Key: Word; Shift: TShiftState); override;
    procedure OnMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure OnMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure OnMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Draw; override;
    procedure SetMusicVolume(AIsNext: Boolean);
    procedure CongigClick;
    procedure Exit;
    procedure SetFon(num: Integer);
    procedure NewGame;
  end;

implementation

uses Main;

{ TMainMenuMode }

procedure TMainMenuMode.Draw;
begin
   case Fon of
    0: begin
      Textures.MenuBG.Draw(0, 0, $FFFFFFFF);
      Textures.logo.Draw(0, 768-128, $FFFFFFFF);
    end;
    1: begin
      Textures.MenuBG.Draw(0, 0, $FFFFFFFF);
      Fonts.F30.TextOutAligned(512+1, 70+1, 1, PAnsiChar(AnsiString('������')), $FF000000, qfaCenter);
      Fonts.F30.TextOutAligned(512, 70, 1, PAnsiChar(AnsiString('������')), $FF000000, qfaCenter);
    end;
    2: begin
      Textures.Defeat.Draw(0, 0, $FFFFFFFF);
      Fonts.F30.TextOutAligned(512+1, 70+1, 1, PAnsiChar(AnsiString('���������')), $FF000000, qfaCenter);
      Fonts.F30.TextOutAligned(512, 70, 1, PAnsiChar(AnsiString('���������')), $FF000000, qfaCenter);
    end;
  end;

  FMainMenu.Draw(1);
  if FlvlEn then
    FlvlMenu.Draw(1);
end;

procedure TMainMenuMode.Exit;
begin
  GameWin.Exit;
end;

procedure TMainMenuMode.NewGame;
begin
  FlvlEn := not FlvlEn;
end;

procedure TMainMenuMode.CongigClick;
begin
  //
end;

procedure TMainMenuMode.OnCreate;
begin
  FlvlEn := False;
  Fon := 0;
  FMainMenu := TMenu.Create(FQuad, Fonts.F30);
  FMainMenu.Left := 100;
  FMainMenu.Top := 100;

  MMStartGame:= FMainMenu.AddItem;
  MMStartGame.Caption := '����� ����';
  MMStartGame.OnEnter := NewGame;
  MMResumeGame:= FMainMenu.AddItem;
  MMResumeGame.Caption := '����������';
  MMResumeGame.Enabled:= false;
  MMOptions:= FMainMenu.AddItem;
  MMOptions.Caption := '���������';
  MMOptions.Enabled:= false;
  MMHelp:= FMainMenu.AddItem;
  MMHelp.Caption := '������';
  MMHelp.Enabled := false;

  MMExitGame := FMainMenu.AddItem;
  MMExitGame.Caption := '�����';
  // MMExitGame.OnEnter := Exit;

  FlvlMenu := TMenu.Create(FQuad, Fonts.F30);
  FlvlMenu.Left := 370;
  FlvlMenu.Top := 100;


  MMlvl1 := FlvlMenu.AddItem;
  MMlvl1.Caption := '������� 1';
  MMlvl2 := FlvlMenu.AddItem;
  MMlvl2.Caption := '������� 2';
  MMlvl3 := FlvlMenu.AddItem;
  MMlvl3.Caption := '������� 3';
 { MMlvl4 := FlvlMenu.AddItem;
  MMlvl4.Caption := '������� 4';
  MMlvl5 := FlvlMenu.AddItem;
  MMlvl5.Caption := '������� 5';
  MMlvl6 := FlvlMenu.AddItem;
  MMlvl6.Caption := '������� 6'; }


 // FMainMenu.SelectedItem:= MMStartGame;
end;

procedure TMainMenuMode.SetFon(num: Integer);
begin
  Fon := num;
end;

procedure TMainMenuMode.SetMusicVolume(AIsNext: Boolean);
begin
  BASS_SetVolume(Settings.MusicVolume * 10);
end;

procedure TMainMenuMode.OnDestroy;
begin
  FMainMenu.Free;
  FlvlMenu.Free;
end;

procedure TMainMenuMode.OnKeyDown(Key: Word; Shift: TShiftState);
begin
end;

procedure TMainMenuMode.OnKeyUp(Key: Word; Shift: TShiftState);
begin

end;

procedure TMainMenuMode.OnMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FMainMenu.ItemMouseClick(X, Y);
  if FlvlEn then
    FlvlMenu.ItemMouseClick(X, Y);
end;

procedure TMainMenuMode.OnMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  FMainMenu.ItemMouseHover(X, Y);
  FMouse := TVec2f.Create(X, Y);


  if FlvlEn then
    FlvlMenu.ItemMouseHover(X, Y);

end;

procedure TMainMenuMode.OnMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

end.
