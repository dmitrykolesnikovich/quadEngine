unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, QuadEngine, defs, bass, player, MainMenu, BaseGameMode, gmMainmenu,
  Xinput, fxExplosion, Enemies, Bullets;

type
  TForm1 = class(TForm)
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

var
  Form1: TForm1;
  Time: Double;

implementation

uses
  Resources, gmLocation01, gmLocation02;

{$R *.dfm}

{ TForm1 }

procedure OnTimer(out delta : Double; Id: Cardinal); stdcall;
begin
  qr.BeginRender;

  gm.Process(delta);
  gm.Draw;

  qr.SetBlendMode(qbmSrcAlpha);
  Fonts.Console.SetKerning(0);
  Fonts.Console.TextOut(5, 5, 0.3, PChar('FPS: ^$R' + FormatFloat('00.00', qt.GetFPS) + #13 +
                                         '^$!CPU: ^$G' + FormatFloat('00.00', qt.GetCPUload)), $FFFFFFFF);

 // qr.SetBlendMode(qbmAdd);
 // Textures.QuadLogo.DrawRot(ScreenWidth - 350*0.25, ScreenHeight - 350*0.25, 0, 0.5);
  qr.EndRender;
end;

procedure TForm1.AfterConstruction;
var
  XInputCapabilities: TXInputCapabilities;
begin
  inherited;

  Self.Cursor := crNone;

  FillChar(XInputCapabilities, SizeOf(TXInputCapabilities), 0);

  if IsGamepadUsed = 1 then
  begin
    XInputEnable(True);
    IsGamepadAvailable := XInputGetCapabilities(0, XINPUT_FLAG_GAMEPAD, XInputCapabilities) = ERROR_SUCCESS;
    if not IsGamepadAvailable then
    begin
      IsGamepadUsed := 0;
      XInputEnable(False);
    end
  end;


  Device := CreateQuadDevice;

  Device.CreateRender(qr);
  qr.Initialize(Self.Handle, ScreenWidth, ScreenHeight, ParamCount > 0);

  Fonts.Load(Device);
  Shaders.Load(Device);
  Textures.Load(Device, qr);

  LightPos.x := 0.5;
  LightPos.y := 0.5;
  Shaders.GodRays.BindVariableToPS(0, @LightPos, 1);

  Randomize;

  Players[0] := Tplayer.Create;

  gmMenu := TgmMainMenu.Create(qr);
  gmMenu.Initialize;

  gmGame1 := TgmLocation01.Create(qr);
  gmGame2 := TgmLocation02.Create(qr);
  gmS1_1 := TgmLocation1_1.Create(qr);
  gmS1_2 := TgmLocation1_2.Create(qr);
  gmS2_1 := TgmLocation2_1.Create(qr);

  ExplosionManager := TExplosionManager.Create(qr);
  EnemyManager := TEnemyManager.Create(qr);
  BulletManager := TBulletManager.Create(qr);

  gm := gmMenu;


  // let's play some music
  if not (BASS_GetVersion <> DWORD(MAKELONG(2,0))) then
  begin
    BASS_Init(1, 44100, 0, Form1.Handle, nil);
    BASS_Start;
    GameMusic := BASS_StreamCreateFile(False, PAnsiChar('music/theme.ogg'), 0, 0, 0);
    BASS_StreamPlay(GameMusic, FALSE, BASS_SAMPLE_LOOP);
  end;

  Sounds.Load(Device);

  // and then let's rock!
  Device.CreateTimer(qt);
  qt.SetInterval(16);
  qt.SetCallBack(@OnTimer);
  qt.SetState(True);
end;

procedure TForm1.BeforeDestruction;
begin
  qt.SetState(False);
  Sleep(100);
  qt := nil;

  Players[0].free;

  gm := nil;

  gmMenu.Finalize;
  gmMenu.Free;

  gmGame1.Finalize;
  gmGame1.Free;

  gmGame2.Finalize;
  gmGame2.Free;

  gmS1_1.Free;
  gmS1_2.Free;
  gmS2_1.Free;

  ExplosionManager.Free;
  EnemyManager.Free;
  BulletManager.Free;

  qr := nil;
  Device := nil;

  inherited;
end;

procedure TForm1.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  NewHeight := Trunc(NewWidth / 4 * 3);
  Resize := True;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  gm.OnKeyDown(Self, Key, Shift);
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  gm.OnKeyUp(Self, Key, Shift);
end;

end.
