unit BaseGameMode;

interface

uses
  Classes, Windows, Controls, QuadEngine, XInput, fxExplosion, SysUtils, Bullets;

type
  TCustomGameMode = class
  private
    FIsInitialized: Boolean;
  protected
    FQuadRender: IQuadRender;
  public
    constructor Create(AQuadRender: IQuadRender);
    destructor Destroy; override;

    procedure Initialize; virtual;
    procedure Finalize; virtual;
    procedure Process(ADelta: Double); virtual; abstract;
    procedure Draw; virtual; abstract;
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure OnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure OnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); virtual;
    procedure OnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); virtual;
    procedure OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); virtual;
    property IsInitialized: Boolean read FIsInitialized write FIsInitialized;
  end;

  TCustomGameModeGame = class(TCustomGameMode)
  private
    FMoveLeft,
    FMoveRight,
    FMoveUp,
    FMoveDown,
    FFire: Word;
  protected
    FTime: Double;
  public
    procedure Draw; override;
    procedure Process(ADelta: Double); override;
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure OnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure Initialize; override;
  end;

implementation

uses
  defs, Enemies, Resources;

{ TCustomGameMode }

constructor TCustomGameMode.Create(AQuadRender: IQuadRender);
begin
  FQuadRender := AQuadRender;
  FIsInitialized := False;
end;

destructor TCustomGameMode.Destroy;
begin

  inherited;
end;

procedure TCustomGameMode.Finalize;
begin

end;

procedure TCustomGameMode.Initialize;
begin
  FIsInitialized := True;
end;

procedure TCustomGameMode.OnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TCustomGameMode.OnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TCustomGameMode.OnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TCustomGameMode.OnMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

end;

procedure TCustomGameMode.OnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

end;

{ TCustomGameModeGame }

procedure TCustomGameModeGame.Draw;
var
  i: Integer;
begin
  FQuadRender.SetBlendMode(qbmMul);
  Textures.leftbar.DrawMap(0, 0, 62, ScreenHeight, 0, 0, 0.95, 0.5);
  FQuadRender.SetBlendMode(qbmSrcAlpha);
  for i := 0 to Players[0].Health do
    Textures.HealthBar.Draw(8, ScreenHeight - i * 16, $FFFF4444 + i * 3 shl 8 + i * 3);

  Fonts.Console.TextOut(ScreenWidth/2+2, 0, 0.5, PWideChar('Score: ' + FormatFloat('00000000', Players[0].Score)), $FFCCCCCC, qfaCenter);
  Fonts.Console.TextOut(ScreenWidth/2, 0, 0.5, PWideChar('Score: ' + FormatFloat('00000000', Players[0].Score)), $FF000000, qfaCenter);
end;

procedure TCustomGameModeGame.Initialize;
begin
  inherited;
  Players[0].Initialize;
  ExplosionManager.Clear;
  EnemyManager.Clear;
  BulletManager.Clear;

  FMoveLeft := 0;
  FMoveRight := 0;
  FMoveUp := 0;
  FMoveDown := 0;
  FFire := 0;
end;

procedure TCustomGameModeGame.OnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  case Key of
    VK_DOWN: FMoveDown := MAXSHORT;
    VK_UP: FMoveUp := MAXSHORT;
    VK_LEFT: FMoveLeft := MAXSHORT;
    VK_RIGHT: FMoveRight := MAXSHORT;
    VK_ESCAPE: gm := gmMenu;
    VK_CONTROL: FFire := 128;
    VK_F1: qr.TakeScreenshot('test.bmp');
  end;
end;

procedure TCustomGameModeGame.OnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  case Key of
    VK_DOWN: FMoveDown := 0;
    VK_UP: FMoveUp := 0;
    VK_LEFT: FMoveLeft := 0;
    VK_RIGHT: FMoveRight := 0;
    VK_CONTROL: FFire := 0;
  end;
end;

procedure TCustomGameModeGame.Process(ADelta: Double);
var
  XInputState: TXInputState;
  XInputKeystroke: TXInputKeystroke;
begin
  inherited;

  if IsGamepadUsed = 1 then
  begin
    XInputGetState(0, XInputState);

    FMoveRight := 0;
    FMoveLeft := 0;
    FMoveUp := 0;
    FMoveDown := 0;

    if abs(XInputState.Gamepad.sThumbLX) > XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE then
    begin
      if XInputState.Gamepad.sThumbLX > 0 then
        FMoveRight := XInputState.Gamepad.sThumbLX - XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE
      else
        FMoveLeft := -XInputState.Gamepad.sThumbLX + XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE;
    end;

    if abs(XInputState.Gamepad.sThumbLY) > XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE then
    begin
      if XInputState.Gamepad.sThumbLY > 0 then
        FMoveUp := XInputState.Gamepad.sThumbLY - XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE
      else
        FMoveDown := -XInputState.Gamepad.sThumbLY + XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE;
    end;

    FFire := XInputState.Gamepad.bRightTrigger;

    while XInputGetKeystroke(0, 0, XInputKeystroke) <> 4306 {ERROR_EMPTY} do
    begin
      if XInputKeystroke.Flags = XINPUT_KEYSTROKE_KEYDOWN then
      case XInputKeystroke.VirtualKey of
         VK_PAD_START : gm := gmMenu;
      end;
    end;
  end;


  Players[0].SetVector(FMoveRight/MAXSHORT - FMoveLeft/MAXSHORT, FMoveDown/MAXSHORT - FMoveUp/MAXSHORT);
  Players[0].Process(ADelta);
  if (FFire >= 128) and (Players[0].Health > 0) then
    BulletManager.AddBullet;

  ExplosionManager.Process(ADelta);
  EnemyManager.Process(ADelta, FTime);
  BulletManager.Process(ADelta);

  EnemyManager.IWannaShootTheDog; // let the fun begin!
end;

end.
