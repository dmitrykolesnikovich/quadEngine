unit gmLocation01;

interface

uses
  Windows, MainMenu, Classes, QuadEngine, BaseGameMode, Xinput, fxExplosion,
  Bullets;

type
  TAsteroid = record
    X, Y: Single;
    Angle: Single;
    AngleVec: Single;
    XVec, YVec: Single;
    Index: Byte;
    Scale: Single;
  end;

  TgmLocation1_1 = class(TCustomGameMode)
    FTime: Double;
  public
    procedure Process(ADelta: Double); override;
    procedure Draw; override;
  end;

  TgmLocation1_2 = class(TCustomGameMode)
    FTime: Double;
  public
    procedure Process(ADelta: Double); override;
    procedure Draw; override;
  end;

  TgmLocation01 = class(TCustomGameModeGame)
  private
    FDeltaTime: Double;
    FAsteroids: array[0..15] of TAsteroid;
    FAsteroids2: array[0..5] of TAsteroid;
  public
    procedure Initialize; override;
    procedure Finalize; override;
    procedure Process(ADelta: Double); override;
    procedure Draw; override;
    procedure OnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); override;
  end;

implementation

uses
  Resources, Enemies, defs;

{ TgmMainMenu }

procedure TgmLocation01.Draw;
var
  i: Integer;
begin
  FQuadRender.RenderToTexture(True, Textures.rt);
  FQuadRender.SetBlendMode(qbmNone);
//  Textures.l1Layer4.Draw(-FTime * 2.5, 0, $FF222222);
 // FQuadRender.SetBlendMode(qbmAdd);
  FQuadRender.Rectangle(0, 0, ScreenWidth, ScreenHeight, $FF0C0818);

  FQuadRender.SetBlendMode(qbmSrcAlphaAdd);
  Textures.l1Star_mask.DrawRot(-FTime*2.5 + ScreenWidth, ScreenHeight / 2, -FTime, 5.9, $FF111111);
  Textures.l1Star.DrawRot(-FTime*2.5 + ScreenWidth, ScreenHeight / 2, -FTime*2.5, 0.9, $FF444422);
  Textures.l1Star.DrawRot(-FTime*2.5 + ScreenWidth, ScreenHeight / 2, FTime*7, 1.1, $FF442244);

  FQuadRender.SetBlendMode(qbmSrcAlpha);
  Textures.l1Dust.DrawRot(-FTime * 10 + ScreenWidth * 2.5, 300, 43, 2.0, $FF000000);
  Textures.l1Layer3.DrawRot(-FTime * 10 + ScreenWidth * 1.3, ScreenHeight/2, 30, 1.0, $EE000000);
  Textures.l1Layer3.DrawRot(-FTime * 10 + ScreenWidth * 2, ScreenHeight/2, -12, 0.9, $EE000000);

  Textures.l1Layer3.DrawRot(-FTime * 10 + ScreenWidth * 3.1, ScreenHeight/2, -12, 0.9, $EE000000);
  Textures.l1Layer3.DrawRot(-FTime * 10 + ScreenWidth * 3.2, ScreenHeight/2, 22, 1.0, $EE000000);
  Textures.l1Layer3.DrawRot(-FTime * 10 + ScreenWidth * 3.3, ScreenHeight/2, 9, 0.9, $EE000000);

  for i := 0 to 15 do
  begin
    Textures.l1Layer2[FAsteroids[i].Index].DrawRot(FAsteroids[i].X, FAsteroids[i].Y, FAsteroids[i].Angle, FAsteroids[i].Scale, $CC000000);
  end;

  for i := 0 to 5 do
  begin
    Textures.l1Layer1[FAsteroids2[i].Index].DrawRot(FAsteroids2[i].X, FAsteroids2[i].Y, FAsteroids2[i].Angle, FAsteroids2[i].Scale, $FF000000);
  end;
  //  gm.Draw;

    //Textures.l1Layer2[1].DrawRot(550, 600, 54, 4.0, $FF000000);

  Players[0].DrawBackground;

// qr.SetBlendMode(qbmSrcAlphaMul);
//  Textures.l1Dust.DrawRot(600, 300, 43, 1.0, $FF00FF00);

  FQuadRender.RenderToTexture(False, Textures.rt);



  FQuadRender.RenderToTexture(True, Textures.postprocess);
  FQuadRender.SetBlendMode(qbmNone);
  Textures.l1Layer4.Draw(-Ftime * 2.5, 0, $FFFFFFFF);
  FQuadRender.SetBlendMode(qbmAdd);

  FQuadRender.SetBlendMode(qbmSrcAlpha);
  Textures.l1Layer3.DrawRot(-FTime * 10 + ScreenWidth * 1.3, ScreenHeight/2, 30, 1.0, $FF222222);
  Textures.l1Layer3.DrawRot(-FTime * 10 + ScreenWidth * 2, ScreenHeight/2, -12, 0.9, $FF222222);

  Textures.l1Layer3.DrawRot(-FTime * 10 + ScreenWidth * 3.1, ScreenHeight/2, -12, 0.9, $FF222222);
  Textures.l1Layer3.DrawRot(-FTime * 10 + ScreenWidth * 3.2, ScreenHeight/2, 22, 1.0, $FF222222);
  Textures.l1Layer3.DrawRot(-FTime * 10 + ScreenWidth * 3.3, ScreenHeight/2, 9, 0.9, $FF222222);


  FQuadRender.SetBlendMode(qbmSrcAlpha);
  for i := 0 to 15 do
  begin
    Textures.l1Layer2[FAsteroids[i].Index].DrawRot(FAsteroids[i].X, FAsteroids[i].Y, FAsteroids[i].Angle, FAsteroids[i].Scale, $FF444444);
  end;

  Textures.l1Dust.DrawRot(-FTime * 10 + ScreenWidth * 2.5, 300, 43, 2.0, $FF664422);

  FQuadRender.SetBlendMode(qbmSrcAlphaAdd);
  Textures.l1Star.DrawRot(-FTime*2.5 + ScreenWidth, ScreenHeight / 2, -FTime*2.5, 0.9, $FF444422);
  Textures.l1Star.DrawRot(-FTime*2.5 + ScreenWidth, ScreenHeight / 2, FTime*7, 1.1, $FF442244);

 // gm.Draw;

  BulletManager.Draw;
  Players[0].Draw;

  Explosionmanager.Draw;

  EnemyManager.DrawLayer(0);



  FQuadRender.SetBlendMode(qbmSrcAlpha);
  for i := 0 to 5 do
  begin
    Textures.l1Layer1[FAsteroids2[i].Index].DrawRot(FAsteroids2[i].X, FAsteroids2[i].Y, FAsteroids2[i].Angle, FAsteroids2[i].Scale, $FF444444);
  end;

  FQuadRender.SetBlendMode(qbmAdd);
  Shaders.GodRays.SetShaderState(True);
  Textures.rt.DrawMap(0, 0, ScreenWidth, ScreenHeight, 0, 0, 1, 1);
  Shaders.GodRays.SetShaderState(False);

  FQuadRender.SetBlendMode(qbmSrcAlpha);


  FQuadRender.RenderToTexture(False, Textures.postprocess);
  Textures.postprocess.Draw(0, 0);

  FQuadRender.Rectangle(0, ScreenHeight - 10, (FTime * 2.5), ScreenHeight, $FFFFFFFF);

  inherited;
end;

procedure TgmLocation01.Finalize;
begin
  inherited;
end;

procedure TgmLocation01.Initialize;
var
  i: Integer;
begin
  inherited;

  for i := 0 to 15 do
  begin
    FAsteroids[i].Scale := Random(100)/400 + 0.25;
    FAsteroids[i].X := Random(ScreenWidth);
    FAsteroids[i].Y := Random(ScreenHeight);
    FAsteroids[i].Angle := Random(360);
    FAsteroids[i].AngleVec := Random(100)/10 - 5;
    FAsteroids[i].XVec := (-Random(6000)/300 - 10) * FAsteroids[i].Scale;
    FAsteroids[i].YVec := Random(30)/50 -0.1;
    FAsteroids[i].Index := Random(7) + 1;
  end;

  for i := 0 to 5 do
  begin
    FAsteroids2[i].Scale := Random(150)/100 + 2.0;
    FAsteroids2[i].X := Random(ScreenWidth);
    FAsteroids2[i].Y := Random(ScreenHeight);
    FAsteroids2[i].Angle := Random(360);
    FAsteroids2[i].AngleVec := Random(100)/10 - 5;
    FAsteroids2[i].XVec := (-Random(3000)/300 - 15) * FAsteroids2[i].Scale;
    FAsteroids2[i].YVec := Random(30)/50 -0.1;
    FAsteroids2[i].Index := Random(3) + 1;
  end;

  FTime := 0;
  FDeltaTime := 0;
end;

procedure TgmLocation01.OnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;

end;

procedure TgmLocation01.OnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
end;

procedure TgmLocation01.Process(ADelta: Double);
var
  i: Integer;
begin
  inherited;
  FDeltaTime := ADelta;
  FTime := FTime + ADelta;

  if ((FTime ) > 185) and ((FTime*2.5) < (1240 / 2)) then
  begin
    gmGame := gmS1_2;
    gmGame.Initialize;
    gm := gmGame;
  end;

  if ((FTime) > 437) then
  begin
    gmGame := gmS2_1;
    gmGame.Initialize;
    gm := gmGame;
  end;

  for i := 0 to 15 do
  begin
    FAsteroids[i].X := FAsteroids[i].X + FAsteroids[i].XVec * FDeltaTime;
    if FAsteroids[i].X < -200 then
      FAsteroids[i].X := ScreenWidth + 200;
    FAsteroids[i].Y := FAsteroids[i].Y + FAsteroids[i].YVec * FDeltaTime;
    FAsteroids[i].Angle := FAsteroids[i].Angle + FAsteroids[i].AngleVec * FDeltaTime;
  end;


  for i := 0 to 5 do
  begin
    FAsteroids2[i].X := FAsteroids2[i].X + FAsteroids2[i].XVec * FDeltaTime;
    if FAsteroids2[i].X < -300 then
      FAsteroids2[i].X := ScreenWidth + 300;
    FAsteroids2[i].Y := FAsteroids2[i].Y + FAsteroids2[i].YVec * FDeltaTime;
    FAsteroids2[i].Angle := FAsteroids2[i].Angle + FAsteroids2[i].AngleVec * FDeltaTime;
  end;

  LightPos.x := 1 - (FTime * 2.5) / ScreenWidth;
end;

{ TgmLocation1_1 }

procedure TgmLocation1_1.Draw;
begin
  inherited;

  FQuadRender.Clear(0);
  FQuadRender.SetBlendMode(qbmSrcAlpha);
  Fonts.Console.TextOut(ScreenWidth/2+2, ScreenHeight/2+2, 1, 'Stage 1-1', $FFCCCCCC, qfaCenter);
  Fonts.Console.TextOut(ScreenWidth/2, ScreenHeight/2, 1, 'Stage 1-1', $FF000000, qfaCenter);
end;

procedure TgmLocation1_1.Process(ADelta: Double);
begin
  inherited;

  FTime := FTime + ADelta;
  if FTime > 2 then
  begin
    EnemyManager.LoadEnemyWaves('Waves\l1_1.txt');
    gmGame1.Initialize;
    gmGame := gmGame1;
    gm := gmGame;
    FTime := 0;
  end;
end;

{ TgmLocation1_2 }

procedure TgmLocation1_2.Draw;
begin
  inherited;

  FQuadRender.Clear(0);
  FQuadRender.SetBlendMode(qbmSrcAlpha);
  Fonts.Console.TextOut(ScreenWidth/2+2, ScreenHeight/2+2, 1, 'Stage 1-2', $FFCCCCCC, qfaCenter);
  Fonts.Console.TextOut(ScreenWidth/2, ScreenHeight/2, 1, 'Stage 1-2', $FF000000, qfaCenter);
end;

procedure TgmLocation1_2.Process(ADelta: Double);
begin
  inherited;
  inherited;

  FTime := FTime + ADelta;
  if FTime > 2 then
  begin
    EnemyManager.LoadEnemyWaves('Waves\l1_2.txt');
    gmGame := gmGame1;
    gmGame1.Initialize;
    gmGame1.FTime := 640/2.5;
    gm := gmGame;
    FTime := 0;
  end;
end;

end.
