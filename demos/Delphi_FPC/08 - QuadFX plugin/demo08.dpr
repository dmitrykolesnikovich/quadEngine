program demo08;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  QuadEngine, QuadFX, Vec2f, System.SysUtils, Math;

const
  WIN_SIZE: TVec2i = (X: 1024; Y: 768);
  RENDER_SIZE: TVec2i = (X: 1024; Y: 768);

var
  QuadDevice: IQuadDevice;
  QuadWindow: IQuadWindow;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;
  QuadInput: IQuadInput;

  Background: IQuadTexture;

  QuadFXManager: IQuadFXManager;
  QuadFXLayer: IQuadFXLayer;
  QuadFXEffectParams: IQuadFXEffectParams;
  QuadFXEffectParams2: IQuadFXEffectParams;

  QuadFXAtlas: IQuadFXAtlas;

  Effect: IQuadFXEffect;

procedure DrawBackground;
var
  X, Y: Integer;
begin
  QuadRender.SetBlendMode(qbmNone);
  for Y := 0 to RENDER_SIZE.Y div 65 do
    for X := 0 to RENDER_SIZE.X div 65 do
      Background.Draw(TVec2f.Create(X * 65, Y * 65));
end;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
var
  i: Integer;
  MousePosition: TVec2f;
begin
  QuadInput.Update;

  QuadInput.GetMousePosition(MousePosition);

  if QuadInput.IsMouseClick(mbLeft) then
    QuadFXLayer.CreateEffect(QuadFXEffectParams, MousePosition, 0, 1.5);

  if QuadInput.IsMouseClick(mbRight) then
    QuadFXLayer.CreateEffect(QuadFXEffectParams2, MousePosition, DegToRad(45), 1);

  QuadFXLayer.Update(delta);

  QuadWindow.SetCaption(PWideChar(Format('%f %f %d', [QuadTimer.GetCPUload, QuadTimer.GetFPS, QuadFXLayer.GetParticleCount])));

  QuadRender.BeginRender;
  QuadRender.Clear($FFCCCCCC);
  DrawBackground;
  QuadFXLayer.Draw;

  QuadRender.EndRender;
end;

procedure OnClose; stdcall;
begin
  QuadTimer.SetState(False);
  sleep(500);

  Background := nil;

  QuadFXEffectParams := nil;
  QuadFXEffectParams2 := nil;
  QuadFXAtlas := nil;
  QuadFXLayer := nil;
  QuadFXManager := nil;

  QuadTimer := nil;
  QuadRender := nil;
  QuadWindow := nil;
  QuadDevice := nil;
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  Randomize;
  QuadDevice := CreateQuadDevice;
  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('QuadEngine - Demo08 - QuadFX plugin');
  QuadWindow.SetSize(WIN_SIZE.X, WIN_SIZE.Y);
  QuadWindow.CreateInput(QuadInput);
  QuadWindow.SetOnClose(OnClose);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, RENDER_SIZE.X, RENDER_SIZE.Y, False);

  QuadDevice.CreateAndLoadTexture(0, 'data\Background.png', Background);

  QuadFXManager := CreateQuadFXManager(QuadDevice);

  QuadFXManager.CreateLayer(QuadFXLayer);
  QuadFXLayer.SetGravitation(TVec2f.Create(10, 10));

  QuadFXManager.CreateEffectParams(QuadFXEffectParams);
  QuadFXEffectParams.LoadFromFile('Effect1', 'data\QuadFX_Effect.json');

  QuadFXManager.CreateEffectParams(QuadFXEffectParams2);
  QuadFXEffectParams2.LoadFromFile('Effect2', 'data\QuadFX_Effect.json');

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);

  QuadWindow.Start;
end.
