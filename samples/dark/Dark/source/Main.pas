unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, QuadEngine, mSettings, Direct3D9, Resources, GameMode, Inputs;

const
  PATH = 'Data\';

type
  TGameWin = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    FQuadRender: IQuadRender;
    FQuadDevice: IQuadDevice;
    FQuadTimer: IQuadTimer;

    FGameMode: TGameMode;
    FLastMsg: Integer;
    procedure WndProc(var Message: TMessage); override;
  public
    procedure Process(const dt: Double);
    procedure Draw(const dt: Double);
  end;

var
  GameWin: TGameWin;

implementation

{$R *.dfm}

procedure OnTimer(out dt: Double); stdcall;
begin
  GameWin.Process(dt);
  GameWin.Draw(dt);
  Input.Clear;
end;

{ TGameWin }

procedure TGameWin.FormCreate(Sender: TObject);
begin

  Randomize;
  // Cursor := crNone;
  ClientWidth := Settings.WindowWidth;
  ClientHeight := Settings.WindowHeight;

  FQuadDevice := CreateQuadDevice;
  FQuadDevice.CreateRender(FQuadRender);
  FQuadRender.Initialize(Handle, ClientWidth, ClientHeight,
    Settings.fullscreen);
  FQuadDevice.CreateTimer(FQuadTimer);

  FQuadTimer.SetInterval(16);
  FQuadTimer.SetCallBack(@OnTimer);

  Fonts.LoadFonts(FQuadDevice);
  Textures.LoadTextures(FQuadDevice, FQuadRender);
  Shaders.LoadShaders(FQuadDevice);

  FGameMode := TGameMode.Create(FQuadRender);

  FQuadTimer.SetState(True);
end;

procedure TGameWin.FormDestroy(Sender: TObject);
begin
  FQuadTimer := nil;
  FGameMode.Free;
  FGameMode := nil;
  FQuadRender := nil;
  FQuadDevice := nil;
end;

procedure TGameWin.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // Input.SetKeyDown(Key);
end;

procedure TGameWin.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // Input.SetKeyUp(Key);
end;

procedure TGameWin.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Input.SetMouseDown(Button);
  // FHeroShader.LoadPixelShader('Data\Shaders\ps_temp.bin');
end;

procedure TGameWin.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Input.SetMouseUp(Button);
end;

procedure TGameWin.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  // FGameMode.OnMouseWheel(Shift, WheelDelta, Handled);
end;

procedure TGameWin.Process(const dt: Double);
begin
  if Assigned(FGameMode) then
    FGameMode.Process(dt);
end;

procedure TGameWin.WndProc(var Message: TMessage);
begin
  if not(Message.Msg = FLastMsg) then
  begin
    Input.SetMsg(Message);
    FLastMsg := Message.Msg;
  end;
  inherited WndProc(Message);
end;

procedure TGameWin.Draw(const dt: Double);
begin
  FQuadRender.BeginRender;
  Caption := 'FPS: ' + FormatFloat('##.00', FQuadTimer.GetFPS)
    + ' CPU: ' + FormatFloat('0.00', FQuadTimer.GetCPUload);
  // FQuadRender.Rectangle(0, 0, ClientWidth, ClientHeight, $FF000000);

  if Assigned(FGameMode) then
    FGameMode.Draw(dt);

  FQuadRender.EndRender;
end;

end.
