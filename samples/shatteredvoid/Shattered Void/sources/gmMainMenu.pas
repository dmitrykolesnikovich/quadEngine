unit gmMainMenu;

interface

uses
  Windows, Messages, MainMenu, Classes, QuadEngine, BaseGameMode, defs, XInput,
  fxExplosion, bass;

type
  TgmMainMenu = class(TCustomGameMode)
  private
    angle: Double;
    zoom: Double;
    FAnimatedTime: Double;
    FDeltaTime: Double;
    FTime: Double;
    FMenu: TMenu;
    FMenuPlay: TTopMenuItem;
    FMenuPlayNew: TSubMenuItem;
    FMenuPlayResume: TSubMenuItem;
    FMenuOptions: TTopMenuItem;
    FMenuOptionsGamePad: TSubMenuSelectionItem;
    FMenuOptionsFFB: TSubMenuBooleanItem;
    FMenuOptionsVolume: TSubMenuIntegerItem;
    FMenuProfile: TTopMenuItem;
    FMenuProfileAchievements: TSubMenuItem;
    FMenuProfileStatistics: TSubMenuItem;
    FMenuCredits: TTopMenuItem;
    FMenuExit: TTopMenuItem;
    procedure OnExitClick;
    procedure OnNewGame;
    procedure OnResume;
    procedure OnSetVolume(AIsNext: Boolean);
  public
    procedure Initialize; override;
    procedure Finalize; override;
    procedure Process(ADelta: Double); override;
    procedure Draw; override;
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); override;
  end;

implementation

uses
  Resources, SysUtils, MainForm;

{ TgmMainMenu }

procedure TgmMainMenu.Draw;
var
  alpha : Byte;
  i : Integer;
  AColor: Cardinal;
begin
  inherited;
  // background
  FQuadRender.RenderToTexture(true, Textures.Menu_rt);

  FQuadRender.Clear(0);
  FQuadRender.SetBlendMode(qbmSrcAlphaAdd);
 { Textures.galaxy.DrawRot(ScreenWidth/2, ScreenHeight, angle, 1.0*zoom, $FFCC88FF);
  Textures.galaxy.DrawRot(ScreenWidth/2, ScreenHeight, angle*1.1, 1.0*zoom, $33CC8800);
  Textures.galaxy.DrawRot(ScreenWidth/2, ScreenHeight, angle*1.5, 0.75*zoom, $66BB88FF);
  Textures.galaxy.DrawRot(ScreenWidth/2, ScreenHeight, angle*2, 0.35*zoom, $22AA88FF);     }

  // menu
  FQuadRender.SetBlendMode(qbmSrcAlpha);
  FMenu.Draw(FDeltaTime);

  FQuadRender.SetBlendMode(qbmSrcAlpha);
  FQuadRender.RectangleEx(0, 93, ScreenWidth, 123, $88000000, $88000000, $882288CC, $882288CC);
  FQuadRender.RectangleEx(0, 170, ScreenWidth, 180, $882288CC, $882288CC, $88000000, $88000000);
  Fonts.Console.TextOut(ScreenWidth/3+2, 80+2, 1.5, PWideChar('Shattered Void'), $FF2288CC, qfaCenter);
  Fonts.Console.TextOut(ScreenWidth/3, 80, 1.5, PWideChar('Shattered Void'), $FF000000, qfaCenter);

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



  FQuadRender.Clear(0);
  Shaders.GalaxyDistort.SetShaderState(true);
  Textures.Menu_rt.DrawMap(0, 0, ScreenWidth, ScreenHeight, 0.1, 0.15, 0.95, 1.0, $88888888);
  FQuadRender.SetBlendMode(qbmAdd);
  Textures.Menu_rt2.DrawMap(0, 0, ScreenWidth, ScreenHeight, 0.1, 0.15, 0.95, 1.0, $88888888);
  Shaders.GalaxyDistort.SetShaderState(false);



 // qr.SetBlendMode(qbmSrcAlphaAdd);
//  Textures.galaxycore.DrawRot(ScreenWidth/2 + 90, ScreenHeight + 9 - 50*zoom, 0, 1.5*zoom, $FFFFCC88);

  FQuadRender.SetBlendMode(qbmSrcAlpha);
  Textures.galaxy.DrawRot(ScreenWidth/2, ScreenHeight/2, angle, 1.0, $22CC88FF);
  FQuadRender.SetBlendMode(qbmAdd);
  Textures.StarField.DrawRot(ScreenWidth/2, ScreenHeight/2, 0, 1.25, $FFFFFFFF);
  Textures.StarField.DrawRot(ScreenWidth/2, ScreenHeight/2, angle, 1.5, $FFFFFFFF);
  Textures.StarField.DrawRot(ScreenWidth/2 - 64, ScreenHeight/2 + 64, angle*2, 2.5, $FFFFFFFF);

  // paused
  if gmGame1.IsInitialized then
  begin
    AColor := $FF000000 + Trunc(Animate($00, $FF, FAnimatedTime)) shl 16 + Trunc(Animate($00, $FF, FAnimatedTime)) shl 8 + Trunc(Animate($00, $FF, FAnimatedTime));
    FQuadRender.SetBlendMode(qbmSrcAlpha);
    Textures.postprocess.DrawRot(ScreenWidth - ScreenWidth/8, ScreenHeight - ScreenHeight/8, 0, 1/4, $CCFFFFFF);

    FQuadRender.SetBlendMode(qbmSrcAlphaAdd);
    Fonts.Console.TextOut(ScreenWidth - ScreenWidth/8, ScreenHeight - ScreenHeight/8 - Fonts.Console.TextHeight(' ', 1.0) / 2, 1.0, 'Paused', AColor, qfaCenter);
  end;


end;

procedure TgmMainMenu.Finalize;
begin
  FMenu.Free;

  inherited;
end;

procedure TgmMainMenu.Initialize;
begin
  inherited;

  FMenu := TMenu.Create(FQuadRender);

  FMenuPlay := FMenu.AddItem;
  FMenuPlay.Caption := 'Play';

  FMenuPlayNew := FMenuPlay.AddSubMenuItem;
  FMenuPlayNew.Caption := 'Start new game';
  FMenuPlayNew.OnEnter := OnNewGame;

  FMenuPlayResume := FMenuPlay.AddSubMenuItem;
  FMenuPlayResume.Caption := 'Resume';
  FMenuPlayResume.OnEnter := OnResume;

  FMenuOptions := FMenu.AddItem;
  FMenuOptions.Caption := 'Options';

  FMenuOptionsGamePad := FMenuOptions.AddSubMenuSelectionItem;
  FMenuOptionsGamePad.Caption := 'Controls';
  FMenuOptionsGamePad.Items.Add('Keyboard');
  if IsGamepadAvailable then
    FMenuOptionsGamePad.Items.Add('GamePad');
  FMenuOptionsGamePad.LinkWithVar(@IsGamepadUsed);

  if IsGamepadAvailable then
  begin
    FMenuOptionsFFB := FMenuOptions.AddSubMenuBooleanItem;
    FMenuOptionsFFB.Caption := 'GamePad Feedback';
    FMenuOptionsFFB.LinkWithVar(@IsForceFeedBack);
  end;

  FMenuOptionsVolume := FMenuOptions.AddSubMenuIntegerItem;
  FMenuOptionsVolume.Caption := 'Volume';
  FMenuOptionsVolume.MaxValue := 10;
  FMenuOptionsVolume.MinValue := 0;
  FMenuOptionsVolume.Value := 10;
  FMenuOptionsVolume.OnChange := OnSetVolume;


  FMenuProfile := FMenu.AddItem;
  FMenuProfile.Caption := 'Profile';

  FMenuProfileStatistics := FMenuProfile.AddSubMenuItem;
  FMenuProfileStatistics.Caption := 'Statistics';
  FMenuProfileAchievements := FMenuProfile.AddSubMenuItem;
  FMenuProfileAchievements.Caption := 'Achievements';

  FMenuCredits := FMenu.AddItem;
  FMenuCredits.Caption := 'Credits';

  FMenuExit := FMenu.AddItem;
  FMenuExit.Caption := 'Exit';
  FMenuExit.OnEnter := OnExitClick;
end;

procedure TgmMainMenu.OnExitClick;
begin
  SendMessage(Form1.Handle, WM_CLOSE, 0, 0);
  BASS_SamplePlay(Sounds.MenuExecute);
end;

procedure TgmMainMenu.OnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  FMenu.KeyPress(Key);

  if (Key = VK_LEFT) or (Key = VK_RIGHT) or (Key = VK_UP) or (Key = VK_DOWN) then
    BASS_SamplePlay(Sounds.MenuHover);

  if (key = VK_ESCAPE) and (gmGame1.IsInitialized) then
    gm := gmGame;
end;

procedure TgmMainMenu.OnNewGame;
begin
  gmGame := gmS1_1;
  gmGame.Initialize;
  gm := gmGame;
  BASS_SamplePlay(Sounds.MenuExecute);
end;

procedure TgmMainMenu.OnResume;
begin
  if not gmGame.IsInitialized then
    gmGame.Initialize;
  gm := gmGame;
  BASS_SamplePlay(Sounds.MenuExecute);
end;

procedure TgmMainMenu.Process(ADelta: Double);
var
  XInputState: TXInputKeystroke;
  Hres: Cardinal;
  Key: Word;
begin
  inherited;
  FDeltaTime := ADelta;
  FTime := FTime + ADelta;

  angle := angle + ADelta;
  if angle < 50 then
    zoom := angle / 50
  else
    zoom := 1.0;

  FAnimatedTime := FAnimatedTime + ADelta;
  if FAnimatedTime > 1.5 then
    FAnimatedTime := FAnimatedTime - 1.5;

  if IsGamepadAvailable then
  begin
    while XInputGetKeystroke(0, 0, XInputState) <> 4306 {ERROR_EMPTY} do
    begin
      if XInputState.Flags = XINPUT_KEYSTROKE_KEYDOWN then
      case XInputState.VirtualKey of
        VK_PAD_DPAD_RIGHT, VK_PAD_LTHUMB_RIGHT : Key := VK_RIGHT;
        VK_PAD_DPAD_LEFT, VK_PAD_LTHUMB_LEFT : Key := VK_LEFT;
        VK_PAD_DPAD_UP, VK_PAD_LTHUMB_UP : Key := VK_UP;
        VK_PAD_DPAD_DOWN, VK_PAD_LTHUMB_DOWN : Key := VK_DOWN;
        VK_PAD_A : Key := VK_RETURN;
        VK_PAD_BACK, VK_PAD_START : Key := VK_ESCAPE;
      end;
    end;
    OnKeyDown(Self, Key, []);
  end;
end;

procedure TgmMainMenu.OnSetVolume(AIsNext: Boolean);
begin
  BASS_SetVolume(FMenuOptionsVolume.Value * 10);
end;

end.
