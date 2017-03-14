program demo06;

uses
  QuadEngine,
  Vec2f,
  Classes,
  Map in 'Map.pas',
  Explosion in 'Explosion.pas',
  GBuffer in 'GBuffer.pas',
  GBufferSprite in 'GBufferSprite.pas',
  Winapi.Windows,
  Vcl.Graphics;

type
  PParticle = ^TParticle;
  TParticle = record
    Pos: TVec3f;
    color: Cardinal;
    radius: Single;
  end;

var
  GBuffer: TGBuffer;
  Lighting: IQuadTexture;
  Pos: TVec2f;
  mList: TList;
  t: Double;
  keys: array[0..255] of Boolean;

procedure OnKeyDown(const AKey: Word; const APressedButtons: TPressedKeyButtons); stdcall;
begin
  keys[AKey]:= True;
end;

procedure OnKeyUp(const AKey: Word; const APressedButtons: TPressedKeyButtons); stdcall;
begin
  keys[AKey]:= False;

  if AKey = VK_SPACE then
  GBuffer.FCraters.Add(Pos);
end;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
var
  i, j: Integer;
  vec: PParticle;
  mVec: PParticle;
begin
  if keys[VK_UP] then Pos.Y := Pos.Y - 300 * delta;
  if keys[VK_DOWN] then Pos.Y := Pos.Y + 300 * delta;
  if keys[VK_LEFT] then Pos.X := Pos.X - 300 * delta;
  if keys[VK_RIGHT] then Pos.X := Pos.X + 300 * delta;

  if keys[ord('W')] then TGBuffer.QuadCamera.Translate(TVec2f.Create(0, -100*delta));
  if keys[ord('S')] then TGBuffer.QuadCamera.Translate(TVec2f.Create(0, 100*delta));
  if keys[ord('A')] then TGBuffer.QuadCamera.Translate(TVec2f.Create(-100*delta, 0));
  if keys[ord('D')] then TGBuffer.QuadCamera.Translate(TVec2f.Create(100*delta, 0));


  TGBuffer.QuadRender.BeginRender;
//  TGBuffer.QuadRender.Clear($0);
  TGBuffer.QuadRender.SetBlendMode(qbmSrcAlphaAdd);

  t := t + delta;
   {
  if t > 1.5 then
  begin
    t := 0;
    GetMem(Vec, sizeof(Tparticle));
    vec^.radius := random(250) / 1000 + 0.125;
    vec^.Pos := TVec3F.Create(random(1024) / 1024, -0.2 , 0.01);
    vec^.color := random($FFFFFF) + $FF000000;
    mList.Add(vec);
  end;      }

  TGBuffer.QuadRender.SetBlendMode(qbmNone);

  GBuffer.Draw;

//  GBuffer.DrawLight(tvec3f.Create(Pos.X / TGBuffer.GWidth, Pos.Y / TGBuffer.GHeight, 0.01), 0.3, $FF00AAFF);
//  TGBuffer.QuadRender.SetBlendMode(qbmAdd);
//  Lighting.DrawRotFrame(Pos, 0, 0.75, 1);

//  if random(5) = 1 then
  begin
    GBuffer.DrawLight(tvec3f.Create(Pos.X / TGBuffer.GWidth, Pos.Y / TGBuffer.GHeight, 0.01), 0.5, $FF00FF00);
    TGBuffer.QuadRender.SetBlendMode(qbmAdd);
    Lighting.DrawRotFrame(Pos, random(360), 0.5, random(16), $FF00FF00);
  end;

 // if random(5) = 1 then
  begin
    GBuffer.DrawLight(tvec3f.Create(700 / TGBuffer.GWidth, 300 / TGBuffer.GHeight, 0.01), 0.5, $FFFF0000);
    TGBuffer.QuadRender.SetBlendMode(qbmAdd);
    Lighting.DrawRotFrame(TVec2f.Create(700, 300), random(360), 0.5, random(16), $FFFF0000);
  end;

  for i := 0 to Level.Width - 1 do
    for j := 0 to Level.Height - 1 do
    case Level.Field[i, j] of
      mcNone: GBuffer.DrawLight(tvec3f.Create((i*64 + 32) / TGBuffer.GWidth, (j*64 + 32) / TGBuffer.GHeight, 0.05), 0.2, $33FFFFFF);
//      mcBoxEmpty: GBuffer.DrawLight(tvec3f.Create((i*64 + 32) / TGBuffer.GWidth, (j*64 + 32) / TGBuffer.GHeight, 0.11), 0.1, $FFFF9922);
{      mcWall    : begin
                  GBuffer.DrawLight(tvec3f.Create((i*64) / TGBuffer.GWidth, (j*64) / TGBuffer.GHeight, 0.01), 0.1, $D0FFFFFF + random($20) shl 24);
                  GBuffer.DrawLight(tvec3f.Create((i*64 + 64) / TGBuffer.GWidth, (j*64) / TGBuffer.GHeight, 0.01), 0.1, $D0FFFFFF + random($20) shl 24);
                  GBuffer.DrawLight(tvec3f.Create((i*64) / TGBuffer.GWidth, (j*64 + 64) / TGBuffer.GHeight, 0.01), 0.1, $D0FFFFFF + random($20) shl 24);
                  GBuffer.DrawLight(tvec3f.Create((i*64 + 64) / TGBuffer.GWidth, (j*64 + 64) / TGBuffer.GHeight, 0.01), 0.1, $D0FFFFFF + random($20) shl 24);
                  end;}
    end;

  for i := 0 to mList.Count - 1 do
    begin
      mVec := mList.Items[i];

      mVec^.Pos.Y := mVec^.Pos.Y + delta / 8;

      GBuffer.DrawLight(mVec^.Pos, mVec^.radius, mVec^.color);
    end;

  TGBuffer.QuadRender.SetBlendMode(qbmNone);
  GBuffer.GBuf.DiffuseMap.DrawMap(TVec2f.Zero, TVec2f.Create(160, 120), TVec2f.Zero, TVec2f.Create(1, 1));
  GBuffer.GBuf.NormalMap.DrawMap(TVec2f.Create(160, 0), TVec2f.Create(320, 120), TVec2f.Zero, TVec2f.Create(1, 1));
  GBuffer.GBuf.SpecularMap.DrawMap(TVec2f.Create(320, 0), TVec2f.Create(480, 120), TVec2f.Zero, TVec2f.Create(1, 1));
  GBuffer.GBuf.HeightMap.DrawMap(TVec2f.Create(480, 0), TVec2f.Create(640, 120), TVec2f.Zero, TVec2f.Create(1, 1));

  TGBuffer.QuadRender.EndRender;
end;

begin
  Randomize;

  TGBuffer.QuadDevice := CreateQuadDevice;

  TGBuffer.QuadDevice.CreateWindow(TGBuffer.QuadWindow);
  TGBuffer.QuadWindow.SetCaption('Quad-engine window demo');
  TGBuffer.QuadWindow.SetSize(TGBuffer.GWidth, TGBuffer.GHeight);
  TGBuffer.QuadWindow.SetPosition(100, 100);
  TGBuffer.QuadWindow.SetOnKeyDown(OnKeyDown);
  TGBuffer.QuadWindow.SetOnKeyUp(OnKeyUp);

  TGBuffer.QuadDevice.CreateRender(TGBuffer.QuadRender);
  TGBuffer.QuadRender.Initialize(TGBuffer.QuadWindow.GetHandle, TGBuffer.GWidth, TGBuffer.GHeight, False, qsm20);

  GBuffer := TGBuffer.Create;

  TGBuffer.QuadDevice.CreateAndLoadTexture(0, 'data\lighting.jpg', Lighting, 128, 128);
  Pos := TVec2f.Create(400, 400);

  TGBuffer.QuadRender.SetAutoCalculateTBN(True);

  TGBuffer.QuadDevice.CreateTimerEx(TGBuffer.QuadTimer, OnTimer, 16, True);

  mList := TList.Create;

  Level := TMap.Create;
  Level.LoadFromFile('Levels\1.bmp');

  TGBuffer.QuadDevice.CreateCamera(TGBuffer.QuadCamera);

  TGBuffer.QuadWindow.Start;
end.
