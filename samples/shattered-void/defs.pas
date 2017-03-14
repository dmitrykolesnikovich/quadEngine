unit defs;

interface

uses
  QuadEngine, vec2f, Player, BaseGameMode, bass, gmLocation01, gmLocation02;

const
  ScreenWidth = 1280;
  ScreenHeight = 720;

var
  Device: IQuadDevice;
  qr: IQuadRender;
  qt: IQuadTimer;

  Players : array [0..0] of TPlayer;

  LightPos: TVector;

  IsGamepadUsed: Integer = 1;
  IsGamepadAvailable: Boolean = False;
  IsForceFeedBack: Boolean = True;


  gmGame: TCustomGameMode;
  gmGame1: TgmLocation01;
  gmGame2: TgmLocation02;
  gmS1_1, gmS1_2, gmS2_1, gmMenu, gm: TCustomGameMode;

  GameMusic: HMUSIC;

implementation

end.
