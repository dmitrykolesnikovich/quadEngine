unit gmLocation02;

interface

uses
  Windows, MainMenu, Classes, QuadEngine, BaseGameMode, Xinput, fxExplosion,
  Bullets;

type
  TgmLocation2_1 = class(TCustomGameMode)
    FTime: Double;
  public
    procedure Process(ADelta: Double); override;
    procedure Draw; override;
  end;

  TgmLocation02 = class(TCustomGameModeGame)
  private
    FDeltaTime: Double;
    angle: Double;
    zoom: Double;
    FAnimatedTime: Double;
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

procedure TgmLocation02.Draw;
var
  i: Integer;
begin
  // background
  FQuadRender.RenderToTexture(True, Textures.Menu_rt);

  FQuadRender.Clear(0);
  FQuadRender.SetBlendMode(qbmSrcAlphaAdd);
  Textures.galaxy.DrawRot(ScreenWidth - FTime*3, ScreenHeight/2, angle, 1.0*zoom, $FFCC88FF);
  Textures.galaxy.DrawRot(ScreenWidth - FTime*3, ScreenHeight/2, angle*1.1, 1.0*zoom, $33CC8800);
  Textures.galaxy.DrawRot(ScreenWidth - FTime*3, ScreenHeight/2, angle*1.5, 0.75*zoom, $66BB88FF);
  Textures.galaxy.DrawRot(ScreenWidth - FTime*3, ScreenHeight/2, angle*2, 0.35*zoom, $22AA88FF);
  FQuadRender.RenderToTexture(false, Textures.Menu_rt);

  FQuadRender.SetBlendMode(qbmNone);

  FQuadRender.RenderToTexture(true, Textures.Menu_rt2);
  Shaders.Blur1.SetShaderState(True);
  Textures.Menu_rt.Draw(0, 0, $FFFFFFFF);
  Shaders.Blur1.SetShaderState(False);
  FQuadRender.RenderToTexture(false, Textures.Menu_rt2);

  FQuadRender.RenderToTexture(true, Textures.Menu_rt2);
  Shaders.Blur2.SetShaderState(True);
  Textures.Menu_rt2.DrawMap(0, 0, ScreenWidth, ScreenHeight, 0, 0, 1, 1, $FFFFFFFF);
  Shaders.Blur2.SetShaderState(False);
  FQuadRender.RenderToTexture(false, Textures.Menu_rt2);


FQuadRender.RenderToTexture(True, Textures.postprocess);


  FQuadRender.Clear(0);
  Shaders.GalaxyDistort.SetShaderState(true);
  Textures.Menu_rt.DrawMap(0, 0, ScreenWidth, ScreenHeight, 0.1, 0.15, 0.95, 1.0, $88888888);
  FQuadRender.SetBlendMode(qbmAdd);
  Textures.Menu_rt2.DrawMap(0, 0, ScreenWidth, ScreenHeight, 0.1, 0.15, 0.95, 1.0, $88888888);
  Shaders.GalaxyDistort.SetShaderState(false);



  qr.SetBlendMode(qbmSrcAlphaAdd);
  Textures.galaxycore.DrawRot(ScreenWidth - FTime*3 + 90, ScreenHeight/2 + 9 - 50*zoom, 0, 1.5*zoom, $FFFFCC88);

  FQuadRender.SetBlendMode(qbmAdd);
  Textures.StarField.DrawRot(ScreenWidth/2, ScreenHeight/2, 0, 1.25, $FFFFFFFF);
  Textures.StarField.DrawRot(ScreenWidth/2, ScreenHeight/2, angle, 1.5, $FFFFFFFF);
  Textures.StarField.DrawRot(ScreenWidth/2 - 64, ScreenHeight/2 + 64, angle*2, 2.5, $FFFFFFFF);

  FQuadRender.SetBlendMode(qbmSrcAlpha);
  BulletManager.Draw;
  Players[0].Draw;

  Explosionmanager.Draw;

  EnemyManager.DrawLayer(0);

  FQuadRender.RenderToTexture(False, Textures.postprocess);

  FQuadRender.SetBlendMode(qbmNone);
  Textures.postprocess.Draw(0, 0);

  FQuadRender.Rectangle(0, ScreenHeight - 10, (FTime * 2.5), ScreenHeight, $FFFFFFFF);

  inherited;
end;

procedure TgmLocation02.Finalize;
begin
  inherited;
end;

procedure TgmLocation02.Initialize;
var
  i: Integer;
begin
  inherited;

  FTime := 0;
  FDeltaTime := 0;
  angle := 40;
end;

procedure TgmLocation02.OnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;

end;

procedure TgmLocation02.OnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
end;

procedure TgmLocation02.Process(ADelta: Double);
var
  i: Integer;
begin
  inherited;
  FDeltaTime := ADelta;
  FTime := FTime + ADelta;

  angle := angle + ADelta;
  if angle < 50 then
    zoom := angle / 50
  else
    zoom := 1.0;

  LightPos.x := 1 - (FTime * 2.5) / ScreenWidth;
end;

{ TgmLocation1_1 }


procedure TgmLocation2_1.Draw;
begin
  inherited;

  FQuadRender.Clear(0);
  FQuadRender.SetBlendMode(qbmSrcAlpha);
  Fonts.Console.TextOut(ScreenWidth/2+2, ScreenHeight/2+2, 1, 'Stage 2-1', $FFCCCCCC, qfaCenter);
  Fonts.Console.TextOut(ScreenWidth/2, ScreenHeight/2, 1, 'Stage 2-1', $FF000000, qfaCenter);
end;

procedure TgmLocation2_1.Process(ADelta: Double);
begin
  inherited;

  FTime := FTime + ADelta;
  if FTime > 2 then
  begin
    EnemyManager.LoadEnemyWaves('Waves\l2_1.txt');
    gmGame2.Initialize;
    gmGame := gmGame2;
    gm := gmGame;
    FTime := 0;
  end;
end;

end.
