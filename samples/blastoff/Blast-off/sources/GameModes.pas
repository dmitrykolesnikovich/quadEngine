unit GameModes;

interface

uses
  Controls, Classes, PlayerHero, BaseSprite, Vec2f, GameRecord, QuadEngine,
  Windows, FlyStone, GlobalConst, MainMenu, BASS;

type
  PSpark = ^TSpark;
  TSpark = record
    X, Y: Single;
    dX, dY: Single;
    Color: Cardinal;
    CountDown: Double;
  end;

  TPieceState = record
    Size: Double;
    Visible: Boolean;
    dSize: Double;
  end;

  TCustomGameMode = class
  protected
    FQuad: IQuadRender;
  public
    constructor Create(AQuadRender: IQuadRender);
    procedure Draw(dt: Double); virtual;
    procedure OnKeyDown(Sender: TObject; var Key: Word); virtual;
    procedure OnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure OnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); virtual;
    procedure OnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); virtual;
    procedure OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); virtual;
    procedure Process(dt: Double); virtual; 
  end;

  TModeGame = class(TCustomGameMode)
  private
    RefreshGame: Boolean;
    SpriteEngine: TSpriteEngine;
    CreateMaxHeight: LongWord;
    TimeCreateStone: Double;
    OldCamera: TVec2f;
  public

    procedure Draw(dt: Double); override;
    procedure OnKeyDown(Sender: TObject; var Key: Word); override;
    procedure OnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure OnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure OnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); override;
    procedure Process(dt: Double); override;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

  end;

  TModeMainMenu = class(TCustomGameMode)
  private
    FMenu: TMenu;
    FmiStartGame: TTopMenuItem;
    FmiResumeGame: TTopMenuItem;
    FmiOptions: TTopMenuItem;
    FmiHelp: TTopMenuItem;
    FmiExitGame: TTopMenuItem;

    FmsiPlayerColor: TSubMenuSelectionItem;
    FmsiMotionBlur: TSubMenuBooleanItem;
    FmsiGlow: TSubMenuBooleanItem;
    FmsiShowFPS: TSubMenuBooleanItem;
    FmsiMaximize: TSubMenuBooleanItem;
    FmsiMusicVolume: TSubMenuIntegerItem;
    FmsiResetHighScores: TSubMenuItem;

    procedure StartNewGame;
    procedure ResumeGame;
    procedure ExitGame;
    procedure ResetHighScores;
    procedure ShowHelp;
  public
    procedure SetMusicVolume(AIsNext: Boolean);
    procedure SetMaximized(AIsNext: Boolean);
    procedure SetPlayerColor(AIsNext: Boolean);
    procedure Draw(dt: Double); override;
    procedure OnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure Process(dt: Double); override;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

  TModeIntro = class(TCustomGameMode)
  private
    Sparks: TList;
    Zbl: array[0..15, 0..11] of TPieceState;
    igdc: array[0..15, 0..11] of TPieceState;
    FTime: Single;
    IntroState: Byte;
    LogoColor: Double;
  public
    procedure Draw(dt: Double); override;
    procedure OnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure Process(dt: Double); override;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

  TModeHelp = class(TCustomGameMode)
  public
    procedure Draw(dt: Double); override;
    procedure OnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); override;
  end;

  TGameModesManager = class
  private
    FActiveMode: TCustomGameMode;
  public
    FModeGame: TModeGame;
    FModeMenu: TModeMainMenu;
    FModeIntro: TModeIntro;
    FModeHelp: TModeHelp;

    procedure Draw(dt: Double);
    procedure OnKeyDown(Sender: TObject; var Key: Word);
    procedure OnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); 
    procedure Process(dt: Double);
    procedure SetActiveMode(AGameMode: TCustomGameMode);
  end;

var
  GameModesManager: TGameModesManager;

implementation

uses
  Resources, iSettings, Direct3D9, SysUtils, Main_Form;

{ TGameModesManager }

procedure TGameModesManager.Draw(dt: Double);
begin
  if FActiveMode <> nil then
    FActiveMode.Draw(dt);
end;

procedure TGameModesManager.OnKeyDown(Sender: TObject; var Key: Word);
begin
  if FActiveMode <> nil then
    FActiveMode.OnKeyDown(Sender, Key);
end;

procedure TGameModesManager.OnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FActiveMode <> nil then
    FActiveMode.OnKeyUp(Sender, Key, Shift);
end;

procedure TGameModesManager.OnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if FActiveMode <> nil then
    FActiveMode.OnMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TGameModesManager.OnMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if FActiveMode <> nil then
    FActiveMode.OnMouseMove(Sender, Shift, X, Y);
end;

procedure TGameModesManager.OnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if FActiveMode <> nil then
    FActiveMode.OnMouseUp(Sender, Button, Shift, X, Y);
end;

procedure TGameModesManager.Process(dt: Double);
begin
  if FActiveMode <> nil then
    FActiveMode.Process(dt);

  if BASS_ChannelBytes2Seconds(Audio.MusicIntro, BASS_ChannelGetPosition(Audio.MusicIntro)) > 40  then
  begin
    BASS_StreamPlay(Audio.MusicCycle, False, BASS_SAMPLE_LOOP);
    BASS_StreamFree(Audio.MusicIntro);
  end;
end;

procedure TGameModesManager.SetActiveMode(AGameMode: TCustomGameMode);
begin
  FActiveMode := AGameMode;
end;

{ TModeGame }

procedure TModeGame.AfterConstruction;
begin
  inherited;

  RefreshGame := True;

  SpriteEngine := TSpriteEngine.Create;
  SpriteEngine.PauseGame := True;
end;

procedure TModeGame.BeforeDestruction;
begin
  inherited;
  if Assigned(SpriteEngine) then
    SpriteEngine.Free;
end;

procedure TModeGame.Draw(dt: Double);
var
  i, j: Integer;
  LightPos : array [0..2] of Single;
  Color: Cardinal;
begin
  FQuad.SetBlendMode(qbmSrcAlpha);

  FQuad.RenderToTexture(True, Textures.RenderTarget);

  for i := Round(-SpriteEngine.Camera.Pos.Y) div 512 - 1 to Round(-SpriteEngine.Camera.Pos.Y) div 512 + 2 do
  for j := Round(-SpriteEngine.Camera.Pos.X) div 512 - 2 to Round(-SpriteEngine.Camera.Pos.X) div 512 + 2 do
  begin
    LightPos[0] := PlayHero.PosCam.X - 1024/2;
    LightPos[1] := PlayHero.PosCam.Y - 768/2;
    LightPos[2] := 1.0;                            
    FQuad.GetD3DDevice.SetVertexShaderConstantF(4, @Lightpos, 3);

    FQuad.SetBlendMode(qbmNone);
    Shaders.NormalSpecular.SetShaderState(True);
    Textures.Pipes.Draw(-j * 512 - SpriteEngine.Camera.Pos.X, -i * 512 - SpriteEngine.Camera.Pos.Y, $FFFFFFFF);
    Shaders.NormalSpecular.SetShaderState(False);

    if Settings.IsGlowEnabled then
    begin
      FQuad.SetBlendMode(qbmSrcAlphaAdd);
      Textures.PipesGlow.Draw(-j * 512 - SpriteEngine.Camera.Pos.X, -i * 512 - SpriteEngine.Camera.Pos.Y, D3DCOLOR_ARGB($FF-Random($1A), $5C, $82, $97));
    end;
  end;

  SpriteEngine.Draw(ZINDEX_BACKGROUND);
  SpriteEngine.Draw(ZINDEX_BULLETS);
  SpriteEngine.Floor.Draw;

  // рисуется второй раз, чтобы отражаться в шаре
  FQuad.SetBlendMode(qbmAdd);
  Textures.CrossHair.DrawRot(MouseX, MouseY, 0.0, 1.0, $FFFFFFFF);

  if PlayHero.Health > 1 then
  begin
    FQuad.SetBlendMode(qbmSrcAlphaAdd);
    for i := 0 to PlayHero.Health - 2 do
      Textures.HeroShield.DrawRot(PlayHero.PosCam.X, PlayHero.PosCam.Y, Random(360), 0.85 + i * 0.1, Settings.PlayerColor);
  end;

  FQuad.RenderToTexture(False, Textures.RenderTarget);

  LightPos[0] := (SpriteEngine.Camera.Pos.X - OldCamera.X)/10000;
  LightPos[1] := (SpriteEngine.Camera.Pos.Y - OldCamera.Y)/10000;

  if Settings.IsMotionBlurEnabled then
  begin
    Shaders.MotionBlur.BindVariableToPS(0, @LightPos, 2);
    Shaders.MotionBlur.SetShaderState(True);
  end;
  FQuad.SetBlendMode(qbmNone);
  Textures.RenderTarget.Draw(0, 0, $FFFFFFFF);

  if Settings.IsMotionBlurEnabled then
    Shaders.MotionBlur.SetShaderState(False);

  OldCamera := SpriteEngine.Camera.Pos;

  FQuad.SetBlendMode(qbmSrcAlpha);
  FQuad.Rectangle(0, 0, 124, 768,  $FF000000, $00000000, $F0000000, $00000000);
  FQuad.Rectangle(900, 0, 1024, 768,  $00000000, $FF000000, $00000000, $FF000000);

  for i := Trunc(-SpriteEngine.Camera.Pos.Y) div 200 to Trunc(-SpriteEngine.Camera.Pos.Y) div 200 + 5 do
    Fonts.Console.TextOutAligned(1019, - SpriteEngine.Camera.Pos.Y - i*200 +600, 0.5, PAnsiChar(AnsiString(IntToStr(i-3))), $FF88FFFF, qfaRight);

  if PlayHero.GetIsLiving then
    Fonts.Console.TextOutAligned(512, 0, 1.0, PAnsiChar(AnsiString(IntToStr(PlayHero.MaxHeight) + 'Km')), $FFFFFFFF, qfaCenter);

  if PlayHero.GetIsLiving and (PlayHero.Height > MaxHeight) then
  begin
    MaxHeightTimer := 1.5;
    Inc(MaxHeight, 50);
  end;

  if MaxHeightTimer > 0 then
  begin
    Fonts.Console.SetKerning((1.5 - MaxHeightTimer)*10);
    Color := $FF88FFFF;
    if MaxHeightTimer < 0.5 then
      Color := Trunc(MaxHeightTimer * 500) shl 24 + $88FFFF;
    Fonts.Console.TextOutAligned(512, 300, 1.0 + (1.5 - MaxHeightTimer)/1.5, PAnsiChar(AnsiString('Reached ' + IntToStr(MaxHeight - 50) + 'Km')), Color, qfaCenter);
    Fonts.Console.SetKerning(0);
    MaxHeightTimer := MaxHeightTimer - dt;
  end;

  SpriteEngine.Draw(ZINDEX_STONE);
  SpriteEngine.Draw(ZINDEX_HERO);

  FQuad.SetBlendMode(qbmSrcAlpha);

  if not PlayHero.GetIsLiving then
  begin
    GRecord.DrawTitles(300, FQuad, dt);
    GRecord.Draw(450, FQuad, 'Round');
    MaxRecord.Draw(600, FQuad, 'Best', $FFFF8888);
    SessionRecord.Draw(750, FQuad, 'Session', $FFFFFF88);
    GlobalRecord.Draw(900, FQuad, 'Global', $FF88FF88);
  end;
end;

procedure TModeGame.OnKeyDown(Sender: TObject; var Key: Word);
begin
  case Key of
    27:
      begin
        GameModesManager.SetActiveMode(GameModesManager.FModeMenu);
      end;
    32:
      if not PlayHero.GetIsLiving then
        RefreshGame := True;
    87, 38: PlayHero.KeySpace := True;
    65, 37: PlayHero.KeyLeft := True;
    68, 39: PlayHero.KeyRight := True;
  end;
end;

procedure TModeGame.OnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    87, 32, 38: PlayHero.KeySpace := False;
    65, 37: PlayHero.KeyLeft := False;
    68, 39: PlayHero.KeyRight := False;
  end;
end;

procedure TModeGame.OnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  PlayHero.KeyMouse := Button = mbLeft;
end;

procedure TModeGame.OnMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

end;

procedure TModeGame.OnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  PlayHero.KeyMouse := not (Button = mbLeft);
end;

procedure TModeGame.Process(dt: Double);
var
  Vec, Pos: TVec2f;
begin
  if RefreshGame then
  begin
    RefreshGame := False;
    SpriteEngine.Clear;
    PlayHero := TPlayerHero.Create(FQuad, SpriteEngine);
    SpriteEngine.Add(PlayHero);
    SpriteEngine.PauseGame := True;
    SpriteEngine.Camera.Pos := TVec2f.Create(-Settings.WindowWidth / 2, -600);
    SpriteEngine.Floor.Refresh;
    CreateMaxHeight := 0;
    GRecord.Refresh;
    TimeCreateStone := 0.1;
  end;

  if not SpriteEngine.PauseGame then
  begin
    if PlayHero.GetIsLiving then
      SpriteEngine.Floor.UpdatePosition(dt);
    if PlayHero.MaxHeight div 4 > CreateMaxHeight div 4 then
    begin
      CreateMaxHeight := PlayHero.MaxHeight;
      SpriteEngine.Add(THangPlatform.Create(FQuad, SpriteEngine));
    end;

    TimeCreateStone := TimeCreateStone - dt;

    if TimeCreateStone <= 0 then
    begin
      Pos.Create(Random(Settings.WindowWidth * 2) + SpriteEngine.Camera.Pos.X - Settings.WindowWidth, Settings.WindowHeight + SpriteEngine.Camera.Pos.Y + 50);
      if Pos.X < PlayHero.Pos.X then
        Vec.Create(Random(100), -Random(70)-400)
      else
        Vec.Create(-Random(100), -Random(70)-400);
      if PlayHero.Vector.Y < 0 then
        Vec := Vec + PlayHero.Vector;
      SpriteEngine.Add(TFlyPlatform.Create(FQuad, SpriteEngine, Pos, Vec));
      TimeCreateStone := (Random(400) + 50) / 1000;
    end;
  end;
  SpriteEngine.Process(dt);
end;

{ TCustomGameMode }

constructor TCustomGameMode.Create(AQuadRender: IQuadRender);
begin
  FQuad := AQuadRender;
end;

procedure TCustomGameMode.Draw(dt: Double);
begin

end;

procedure TCustomGameMode.OnKeyDown(Sender: TObject; var Key: Word);
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

procedure TCustomGameMode.Process(dt: Double);
begin

end;

{ TModeMainMenu }

procedure TModeMainMenu.AfterConstruction;
begin
  inherited;
  FMenu := TMenu.Create(FQuad);

  FmiStartGame := FMenu.AddItem;
  FmiStartGame.Caption := 'New Game';
  FmiStartGame.OnEnter := StartNewGame;

  FmiResumeGame := FMenu.AddItem;
  FmiResumeGame.Caption := 'Resume';
  FmiResumeGame.OnEnter := ResumeGame;

  FmiOptions := FMenu.AddItem;
  FmiOptions.Caption := 'Options';

  FmsiPlayerColor := FmiOptions.AddSubMenuSelectionItem;
  FmsiPlayerColor.Caption := 'Player Color';
  FmsiPlayerColor.Items.Add('^$WWhite^$!');
  FmsiPlayerColor.Items.Add('^$RRed^$!');
  FmsiPlayerColor.Items.Add('^$BBlue^$!');
  FmsiPlayerColor.Items.Add('^$LLime^$!');
  FmsiPlayerColor.Items.Add('^$YYellow^$!');
  FmsiPlayerColor.Items.Add('^$AAqua^$!');
  FmsiPlayerColor.Items.Add('^$PPink^$!');
  FmsiPlayerColor.LinkWithVar(@Settings.PlayerColorIndex);
  FmsiPlayerColor.OnChange := SetPlayerColor;

  FmiOptions.AddSubMenuItem.Caption := '-';

  FmsiMotionBlur := FmiOptions.AddSubMenuBooleanItem;
  FmsiMotionBlur.Caption := 'Motion Blur';
  FmsiMotionBlur.LinkWithVar(@Settings.IsMotionBlurEnabled);

  FmsiGlow := FmiOptions.AddSubMenuBooleanItem;
  FmsiGlow.Caption := 'Glow';
  FmsiGlow.LinkWithVar(@Settings.IsGlowEnabled);

  FmsiShowFPS := FmiOptions.AddSubMenuBooleanItem;
  FmsiShowFPS.Caption := 'Show FPS/CPU load';
  FmsiShowFPS.LinkWithVar(@Settings.IsShowFPS);

  FmsiMaximize := FmiOptions.AddSubMenuBooleanItem;
  FmsiMaximize.Caption := 'Maximize window';
  FmsiMaximize.LinkWithVar(@Settings.IsMaximize);
  FmsiMaximize.OnChange := SetMaximized;

  FmiOptions.AddSubMenuItem.Caption := '-';

  FmsiMusicVolume := FmiOptions.AddSubMenuIntegerItem;
  FmsiMusicVolume.Caption := 'SFX Volume';
  FmsiMusicVolume.LinkWithVar(@Settings.MusicVolume);
  FmsiMusicVolume.MaxValue := 10;
  FmsiMusicVolume.MinValue := 0;
  FmsiMusicVolume.OnChange := SetMusicVolume;

  FmiOptions.AddSubMenuItem.Caption := '-';

  FmsiResetHighScores := FmiOptions.AddSubMenuItem;
  FmsiResetHighScores.Caption := 'Reset highscores';
  FmsiResetHighScores.OnEnter := ResetHighScores;

  FmiHelp := FMenu.AddItem;
  FmiHelp.Caption := 'Help';
  FmiHelp.OnEnter := ShowHelp;

  FmiExitGame := FMenu.AddItem;
  FmiExitGame.Caption := 'Exit';
  FmiExitGame.OnEnter := ExitGame;
end;

procedure TModeMainMenu.BeforeDestruction;
begin
  inherited;

end;

procedure TModeMainMenu.Draw(dt: Double);
begin
  FQuad.SetBlendMode(qbmNone);
  FQuad.Rectangle(0, 0, Settings.WindowWidth, Settings.WindowHeight, $FF000000);
  FQuad.Rectangle(0, 200, Settings.WindowWidth, Settings.WindowHeight, $FF222222);
  FQuad.SetBlendMode(qbmSrcAlpha);
  Fonts.Console.TextOutAligned(Settings.WindowWidth/2, 75, 1.5, 'BLAST-OFF', $FFFFFFFF, qfaCenter);
  FMenu.Draw(dt);
  Fonts.Console.TextOutAligned(Settings.WindowWidth/2, 740, 0.5, 'Copyright Darthman & ZblCoder, Moscow 2012. For IGDC #77.', $FFFFFFFF, qfaCenter);
end;

procedure TModeMainMenu.ExitGame;
begin
  Form2.Close;
end;

procedure TModeMainMenu.OnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FMenu.KeyPress(Key);
end;

procedure TModeMainMenu.Process(dt: Double);
begin

end;


procedure TModeMainMenu.SetMaximized(AIsNext: Boolean);
begin
  if Settings.IsMaximize then
  begin
    Form2.Height := GetSystemMetrics(SM_CYSCREEN);
    Form2.ClientWidth := Form2.ClientHeight div 3 * 4;
    Form2.Left := (GetSystemMetrics(SM_CXSCREEN) - Form2.Width) div 2;
    Form2.Top := 0;
  end
  else
  begin
    Form2.ClientHeight := Settings.WindowHeight;
    Form2.ClientWidth := Settings.WindowWidth;
    Form2.Left := (GetSystemMetrics(SM_CXSCREEN) - Form2.Width) div 2;
    Form2.Top := (GetSystemMetrics(SM_CYSCREEN) - Form2.Height) div 2;
  end;
  Form2.RefClipCursor;
end;

procedure TModeMainMenu.SetMusicVolume(AIsNext: Boolean);
begin
  BASS_SetVolume(Settings.MusicVolume * 10);
end;

procedure TModeMainMenu.SetPlayerColor;
begin
  case Settings.PlayerColorIndex of
    0 : Settings.PlayerColor := $FFFFFFFF;
    1 : Settings.PlayerColor := $FFFF0000;
    2 : Settings.PlayerColor := $FF0000FF;
    3 : Settings.PlayerColor := $FF00FF00;
    4 : Settings.PlayerColor := $FFFFFF00;
    5 : Settings.PlayerColor := $FF88FFFF;
    6 : Settings.PlayerColor := $FFFF00FF;
  end;
end;

procedure TModeMainMenu.ShowHelp;
begin
  GameModesManager.SetActiveMode(GameModesManager.FModeHelp);
end;

procedure TModeMainMenu.ResetHighScores;
begin
  GRecord.Refresh;
  SessionRecord.Refresh;
  GlobalRecord.Refresh;
  MaxRecord.Refresh;

  if FileExists(Settings.ApplicationPath + 'Record.ini') then
    DeleteFile(Settings.ApplicationPath + 'Record.ini');
end;

procedure TModeMainMenu.ResumeGame;
begin
  GameModesManager.SetActiveMode(GameModesManager.FModeGame);
end;

procedure TModeMainMenu.StartNewGame;
begin
  GameModesManager.SetActiveMode(GameModesManager.FModeGame);
  GameModesManager.FModeGame.RefreshGame := True;
end;

{ TModeIntro }

procedure TModeIntro.AfterConstruction;
var
  i, j: Integer;
begin
  inherited;

  Shaders.BurnShader.BindVariableToPS(0, @FTime, 1);

  Sparks := TList.Create;

  for i := 0 to 15 do
  for j := 0 to 11 do
  begin
    Zbl[i, j].Visible := True;
    Zbl[i, j].Size := 1.0;

    igdc[i, j].Visible := False;
    igdc[i, j].Size := random(200) / 100;
  end;

  IntroState := 0;
end;

procedure TModeIntro.BeforeDestruction;
begin
  inherited;

end;

procedure TModeIntro.Draw(dt: Double);
var
  Spark: PSpark;
  i, j: Integer;
begin

  if IntroState = 0 then
  begin
    FQuad.Clear(0);

    if Timer.GetWholeTime > 2 then
    begin
      Inc(IntroState);
      Exit;
    end;
  end;


  if IntroState = 1 then
  begin
    FQuad.SetBlendMode(qbmNone);
    Textures.QuadLogo.Draw(0, 0, $FF000000 + trunc(LogoColor) shl 16 + trunc(LogoColor) shl 8 + trunc(LogoColor));

    LogoColor := LogoColor + dt * 128;

    if LogoColor > 255 then
    begin
      Inc(IntroState);
      LogoColor := 0;      
      Exit;
    end;
  end;


  if IntroState = 2 then
  begin
    for i := Sparks.Count - 1 downto 0 do
    begin
      Spark := PSpark(Sparks[i]);
      Spark.CountDown := Spark.CountDown - dt;
      Spark.X := Spark.X + dt * Spark.dX;
      Spark.Y := Spark.Y + dt * Spark.dY;
      if Spark.CountDown < 0 then
      begin
        Sparks.Delete(i);
        Dispose(Spark);
      end;
    end;

                
    FQuad.Clear(0);

    FQuad.SetBlendMode(qbmNone);
    Shaders.BurnShader.SetShaderState(True);
    Textures.Logo1.DrawRot(512, 384, 0.0, 1.0, $FFFFFFFF);
    Shaders.BurnShader.SetShaderState(False);

    FQuad.SetBlendMode(qbmSrcAlphaAdd);
      for i := 0 to Sparks.Count - 1 do
      begin
        Spark := PSpark(Sparks[i]);
        FQuad.Rectangle(Spark.X - Spark.CountDown*5, Spark.Y - Spark.CountDown*5, Spark.X + Spark.CountDown*5, Spark.Y + Spark.CountDown*5, Spark.Color);
      end;       

    FTime := FTime + dt / 5;

    if (FTime > 0.2) and (FTime < 0.70) then
      for i := 0 to 3 do
      begin
        New(Spark);
        Spark.X := random(1024);
        Spark.Y := random(768);
        Spark.dX := Random(60) - 30;
        Spark.dY := -90 - Random(90);
        Spark.CountDown := 1.0 - Random(1000)/1000;
        Spark.Color := $FFFF8822;
        Sparks.Add(Spark);
      end;

    if FTime > 1.0 then
    begin
      Inc(IntroState);
      FTime := 0;
      Exit;
    end;
  end;


  if IntroState = 3 then
  begin
    FQuad.RenderToTexture(True, Textures.RenderTarget);
    FQuad.Clear(0);

    for j := 0 to 11 do
      for i := 0 to 15 do
        Textures.ZblLogo.DrawRot(i*64 + 32, j*64 + 32, 0, zbl[i, j].Size, $FFFFFFFF, i+j*16);

    FQuad.SetBlendMode(qbmSrcAlphaMul);
    for i := 1 to 768 div 4 do
      FQuad.Rectangle(0, i*4, 1024, i*4 + 2, trunc(LogoColor / 1.5) shl 24 + $FFFFFF);

    FQuad.RenderToTexture(False, Textures.RenderTarget);

    FQuad.SetBlendMode(qbmNone);
    FQuad.RenderToTexture(True, Textures.RenderTarget2);
    Shaders.HorizontalBlur.SetShaderState(True);
    Textures.RenderTarget.Draw(0, 0, $FFFFFFFF);
    Shaders.HorizontalBlur.SetShaderState(False);
    FQuad.RenderToTexture(False, Textures.RenderTarget2);

    FQuad.RenderToTexture(True, Textures.RenderTarget2);
    shaders.VerticalBlur.SetShaderState(True);
    Textures.RenderTarget2.DrawMap(0, 0, 1024, 768, 0, 0, 1, 1, $FFFFFFFF);
    Shaders.VerticalBlur.SetShaderState(False);
    FQuad.RenderToTexture(False, Textures.RenderTarget2);

    Textures.RenderTarget.Draw(0, 0, $FFFFFFFF);
    FQuad.SetBlendMode(qbmAdd);
    Textures.RenderTarget2.DrawMap(0, 0, 1024, 768, 0, 0, 1, 1, trunc(LogoColor) shl 24 + trunc(LogoColor) shl 16 + trunc(LogoColor) shl 8 + trunc(LogoColor));
    Textures.RenderTarget2.DrawMap(0, 0, 1024, 768, 0, 0, 1, 1, trunc(LogoColor) shl 24 + trunc(LogoColor) shl 16 + trunc(LogoColor) shl 8 + trunc(LogoColor));

    FTime := FTime + dt / 5;

    LogoColor := LogoColor + dt * 64;

    if LogoColor > 255 then
    begin
      Inc(IntroState);
      LogoColor := 0;
      FTime := 0;
      Exit;
    end;
  end;


  if IntroState = 4 then
  begin
    FQuad.RenderToTexture(True, Textures.RenderTarget);
    FQuad.Clear(0);

    for j := 0 to 11 do
    for i := 0 to 15 do
    begin
      Zbl[i, j].Size := Zbl[i, j].Size + Zbl[i, j].dSize * dt;

      FQuad.SetBlendMode(qbmAdd);

      if zbl[i, j].Visible then
      begin
        if random(50) <> 1 then

        Textures.ZblLogo.DrawRot(i*64 + 32, j*64 + 32, 0, zbl[i, j].Size, $FFFFFFFF, i+j*16)
       else
          zbl[i, j].Size := random(200) / 100;

        if random(100) = 1 then
          zbl[i, j].Visible := False;
      end;


      if random(100) = 1 then
        if not igdc[i, j].Visible then
          igdc[i, j].Visible := True
        else
          igdc[i, j].Size := 1.0;

      if igdc[i, j].Visible then
      begin
        if random(50) <> 1 then
          Textures.igdcLogo.DrawRot(i*64 + 32, j*64 + 32, 0, igdc[i, j].Size, $FFFFFFFF, i+j*16)
      end;
    end;

    FQuad.SetBlendMode(qbmSrcAlphaMul);
    for i := 1 to 768 div 4 do
    FQuad.Rectangle(0, i*4, 1024, i*4 + 2, $AAFFFFFF);

    FQuad.RenderToTexture(False, Textures.RenderTarget);

    FQuad.SetBlendMode(qbmNone);
    FQuad.RenderToTexture(True, Textures.RenderTarget2);
    Shaders.HorizontalBlur.SetShaderState(True);
    Textures.RenderTarget.Draw(0, 0, $FFFFFFFF);
    Shaders.HorizontalBlur.SetShaderState(False);
    FQuad.RenderToTexture(False, Textures.RenderTarget2);

    FQuad.RenderToTexture(True, Textures.RenderTarget2);
    Shaders.VerticalBlur.SetShaderState(True);
    Textures.RenderTarget2.DrawMap(0, 0, 1024, 768, 0, 0, 1, 1, $FFFFFFFF);
    Shaders.VerticalBlur.SetShaderState(False);
    FQuad.RenderToTexture(False, Textures.RenderTarget2);

    Textures.RenderTarget.Draw(0, 0, $FFFFFFFF);
    FQuad.SetBlendMode(qbmAdd);
    Textures.RenderTarget2.DrawMap(0, 0, 1024, 768, 0, 0, 1, 1, $FFFFFFFF);
    Textures.RenderTarget2.DrawMap(0, 0, 1024, 768, 0, 0, 1, 1, $FFFFFFFF);

    if FTime > 1.5 then
    begin
      FQuad.SetBlendMode(qbmSrcAlphaMul);
      FQuad.Rectangle(0, 0, 1024, 768, Trunc(LogoColor) shl 24 + $FFFFFF);

      LogoColor := LogoColor + dt * 64;

      if LogoColor > 255 then
        Inc(IntroState);
    end;


    FTime := FTime + dt / 5;
  end;

  if IntroState = 5 then
  begin
    Textures.ClearIntroResources;
    GameModesManager.SetActiveMode(GameModesManager.FModeMenu);
  end;
end;

procedure TModeIntro.OnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;

  if Key in [VK_ESCAPE, VK_SPACE] then
    GameModesManager.SetActiveMode(GameModesManager.FModeMenu);
end;

procedure TModeIntro.Process(dt: Double);
begin
  inherited;

end;

{ TModeHelp }

procedure TModeHelp.Draw(dt: Double);
begin
  inherited;
  FQuad.SetBlendMode(qbmNone);
  Textures.Manual.Draw(0, 0, $FFFFFFFF);
end;

procedure TModeHelp.OnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  GameModesManager.SetActiveMode(GameModesManager.FModeMenu);
end;

initialization
  GameModesManager := TGameModesManager.Create;

finalization
  GameModesManager.Free;

end.
