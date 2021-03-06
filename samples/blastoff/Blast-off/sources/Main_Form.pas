unit Main_Form;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, QuadEngine, Vec2f, Direct3D9, GameModes;

{TODO: ������� �������� � ��������}

type
  TForm2 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
  private

  public
    procedure RefClipCursor;
    { Public declarations }
  end;

var
  Form2: TForm2;
  Quad: IQuadRender;
  Timer: IQuadTimer;

implementation

uses
  FlyStone, BaseSprite, GlobalConst, PlayerHero, Resources, iSettings,
  GameRecord;

{$R *.dfm}

procedure TForm2.RefClipCursor;
var
  ClipRect: TRect;
begin
  ClipRect.Left   := Left + GetSystemMetrics (SM_CXFRAME);
  ClipRect.Right  := ClipRect.Left + ClientWidth;
  ClipRect.Top    := Top + GetSystemMetrics (SM_CYCAPTION) + GetSystemMetrics (SM_CYFRAME);
  ClipRect.Bottom := ClipRect.Top + ClientHeight;
  ClipCursor (@ClipRect);
end;

procedure OnTimer(var delta: Double);
begin
  GameModesManager.Process(delta);

  Quad.BeginRender;

  GameModesManager.Draw(delta);

  if Settings.IsShowFPS then
  begin
    Quad.SetBlendMode(qbmSrcAlpha);
    Fonts.Console.TextOut(5, 5, 0.5, PAnsiChar(AnsiString('FPS: ^$R'+FormatFloat('##.00', Timer.GetFPS)+#13+
      '^$!CPU: ^$R'+FormatFloat('0.00', Timer.GetCPUload))), $FFFFFFFF);
  end;

  Quad.EndRender;
end;

procedure TForm2.FormActivate(Sender: TObject);
begin
  RefClipCursor;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  Randomize;

  ClientWidth := Settings.WindowWidth;
  ClientHeight := Settings.WindowHeight;

  Cursor := crNone;

  Quad := CreateQR;
  Quad.InitializeFromIni(Handle, PAnsiChar(Ansistring(Settings.ApplicationPath + Settings.FILENAME)));

  Timer := Quad.CreateTimer;
  Timer.SetInterval(16);
  Timer.SetCallBack(@OnTimer);

//  StartGame;
  Fonts.LoadFonts(Quad);
  Textures.LoadTextures(Quad);
  Shaders.LoadShaders(Quad);
  Audio.Initialize(Handle);

  GameModesManager.FModeGame := TModeGame.Create(Quad);
  GameModesManager.FModeMenu := TModeMainMenu.Create(Quad);
  GameModesManager.FModeIntro := TModeIntro.Create(Quad);
  GameModesManager.FModeHelp := TModeHelp.Create(Quad);
  GameModesManager.SetActiveMode(GameModesManager.FModeIntro);

  GameModesManager.FModeMenu.SetMusicVolume(True);
  GameModesManager.FModeMenu.SetMaximized(True);
  GameModesManager.FModeMenu.SetPlayerColor(True);

  Timer.SetState(True);
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  Quad := nil;
end;

procedure TForm2.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  GameModesManager.OnKeyDown(Sender, Key);
end;

procedure TForm2.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  GameModesManager.OnKeyUp(Sender, Key, Shift);
end;

procedure TForm2.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  GameModesManager.OnMouseDown(Sender, Button, Shift, Trunc(X / ClientWidth * Settings.WindowWidth), Trunc(Y / ClientHeight * Settings.WindowHeight));
end;

procedure TForm2.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  MouseX := Trunc(X / ClientWidth * Settings.WindowWidth);
  MouseY := Trunc(Y / ClientHeight * Settings.WindowHeight);

  GameModesManager.OnMouseMove(Sender, Shift,  Trunc(X / ClientWidth * Settings.WindowWidth), Trunc(Y / ClientHeight * Settings.WindowHeight));
end;

procedure TForm2.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  GameModesManager.OnMouseUp(Sender, Button, Shift,  Trunc(X / ClientWidth * Settings.WindowWidth), Trunc(Y / ClientHeight * Settings.WindowHeight));
end;

end.
