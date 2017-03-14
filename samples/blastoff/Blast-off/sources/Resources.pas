unit Resources;

interface

uses
  Windows, QuadEngine, Direct3D9, Bass;

type
  TFonts = class
  private
    const PATH = 'data\fonts\';
  public
    Console: IQuadFont;
    procedure LoadFonts(AQuadRender: IQuadRender);
    destructor destroy; override;
  end;

  TTextures = class
  private
    const PATH = 'data\gfx\';
  public
    RenderTarget: IQuadTexture;
    RenderTarget2: IQuadTexture;

    SimpleStone: IQuadTexture;
    Pipes: IQuadTexture;
    PipesGlow: IQuadTexture;
    CrossHair: IQuadTexture;
    Bullet: IQuadTexture;
    BulletGlow: IQuadTexture;
    Arrows, ArrowsGlow: IQuadTexture;
    Hero: IQuadTexture;
    HeroGlow: IQuadTexture;
    HeroShield: IQuadTexture;
    Bonuses: IQuadTexture;
    Explosion: IQuadTexture;
    Explosion_ring: IQuadTexture;
    Beam: IQuadTexture;
    Jetfire: IQuadTexture;
    Manual: IQuadTexture;

    // intro resources
    QuadLogo: IQuadTexture;
    igdcLogo: IQuadTexture;
    Logo1, ZblLogo: IQuadTexture;
    procedure LoadTextures(AQuadRender: IQuadRender);
    procedure ClearIntroResources;
    destructor destroy; override;
  end;

  TShaders = class
  private
    const PATH = 'data\shaders\';
  public
    NormalSpecular: IQuadShader;
    MotionBlur: IQuadShader;
    Ball: IQuadShader;
    HorizontalBlur: IQuadShader;
    VerticalBlur: IQuadShader;
    BurnShader: IQuadShader;
    procedure LoadShaders(AQuadRender: IQuadRender);
    destructor destroy; override;
  end;

  TAudio = class
  private
    const PATH = 'data\audio\';
    const SOUND_SHOT = 0;
  public
    MusicIntro: HSTREAM;
    MusicCycle: HSTREAM;
    Sound_Shots, Sound_Boom: HSAMPLE;
    Sound_Bonus_Shield: HSAMPLE;
    Sound_Bonus_KillAll: HSAMPLE;
    Sound_Bonus_Nitro: HSAMPLE;
    Sound_Bonus_Shots: HSAMPLE;
    procedure PlaySound(ASound: HSAMPLE);
    procedure Initialize(AHandle: THandle);
    procedure Finalize;
    destructor destroy; override;
  end;

var
  Fonts: TFonts;
  Textures: TTextures;
  Shaders: TShaders;
  Audio: TAudio;

implementation

uses
  iSettings;

{ TFont }
destructor TFonts.destroy;
begin
  Console := nil;
  inherited;
end;

procedure TFonts.LoadFonts(AQuadRender: IQuadRender);
begin
  Console := AQuadRender.CreateAndLoadFont(PATH + 'console.png', PATH + 'console.qef');
  Console.SetIsSmartColoring(True);
end;

{ TTextures }

procedure TTextures.ClearIntroResources;
begin
  QuadLogo := nil;
  igdcLogo := nil;
  Logo1 := nil;
  ZblLogo := nil;

  RenderTarget2 := nil;
end;

destructor TTextures.destroy;
begin
  SimpleStone := nil;
  Pipes := nil;
  PipesGlow := nil;
  CrossHair := nil;
  Bullet := nil;
  Arrows := nil;
  ArrowsGlow := nil;
  Hero := nil;
  HeroGlow := nil;
  HeroShield := nil;
  Bonuses := nil;
  BulletGlow := nil;
  Explosion := nil;
  Explosion_ring := nil;
  Beam := nil;
  Jetfire := nil;
  Manual := nil;

  RenderTarget := nil;
  inherited;
end;

procedure TTextures.LoadTextures(AQuadRender: IQuadRender);
begin
  SimpleStone := AQuadRender.CreateAndLoadTexture(0, PATH + 'stone.png');
  SimpleStone.LoadFromFile(1,  PATH + 'stone_n.png');
  SimpleStone.LoadFromFile(2,  PATH + 'stone_s.png');

  Pipes := AQuadRender.CreateAndLoadTexture(0, PATH + 'pk02_pipes01_C.jpg');
  Pipes.LoadFromFile(1, PATH + 'pk02_pipes01_N.jpg');
  Pipes.LoadFromFile(2, PATH + 'pk02_pipes01_S.jpg');

  PipesGlow := AQuadRender.CreateAndLoadTexture(0, PATH + 'pk02_pipes01_I.jpg');

  CrossHair := AQuadRender.CreateAndLoadTexture(0, PATH + 'crosshair.png');

  Bullet := AQuadRender.CreateAndLoadTexture(0, PATH + 'bullet.png');
  BulletGlow := AQuadRender.CreateAndLoadTexture(0, PATH + 'bulletglow.png');

  Arrows := AQuadRender.CreateAndLoadTexture(0, PATH + 'arrowsglow.png', 96, 192);
  ArrowsGlow := AQuadRender.CreateAndLoadTexture(0, PATH + 'arrows.png');

  Hero := AQuadRender.CreateAndLoadTexture(0, PATH + 'player.png');
  Hero.LoadFromFile(1, PATH + 'player_dudv.png');
  AQuadRender.CreateRenderTexture(128, 128, Hero, 2);

  HeroGlow := AQuadRender.CreateAndLoadTexture(0, PATH + 'playerglow.png');

  HeroShield := AQuadRender.CreateAndLoadTexture(0, PATH + 'player_shield.png');
  Bonuses := AQuadRender.CreateAndLoadTexture(0, PATH + 'bonuses.png', 64, 64);

  Explosion := AQuadRender.CreateAndLoadTexture(0, PATH + 'explosion.jpg', 120, 120);
  Explosion_ring := AQuadRender.CreateAndLoadTexture(0, PATH + 'Explosion_ring.jpg');

  Beam := AQuadRender.CreateAndLoadTexture(0, PATH + 'beam.png', 16, 16);

  Jetfire := AQuadRender.CreateAndLoadTexture(0, PATH + 'jetfire.png');

  Manual := AQuadRender.CreateAndLoadTexture(0, PATH + 'manual.jpg');

  AQuadRender.CreateRenderTexture(Settings.WindowWidth, Settings.WindowHeight, RenderTarget, 0);
  AQuadRender.CreateRenderTexture(512, 512, RenderTarget2, 0);

  // intro resources
  Logo1 := AQuadRender.CreateTexture;
  Logo1.LoadFromFile(0, PATH + 'quad_logo.jpg');
  Logo1.LoadFromFile(1, PATH + 'noise1.jpg');
  Logo1.LoadFromFile(2, PATH + 'Zbl_Logo.jpg');

  ZblLogo := AQuadRender.CreateAndLoadTexture(0, PATH + 'Zbl_Logo.jpg', 64, 64);
  QuadLogo := AQuadRender.CreateAndLoadTexture(0, PATH + 'quad_logo.jpg');
  igdcLogo := AQuadRender.CreateAndLoadTexture(0, PATH + 'igdc_logo.jpg', 64, 64);


end;

{ TShaders }

destructor TShaders.destroy;
begin
  NormalSpecular := nil;
  MotionBlur := nil;
  Ball := nil;
  HorizontalBlur := nil;
  VerticalBlur := nil;
  BurnShader := nil;
  inherited;
end;

procedure TShaders.LoadShaders(AQuadRender: IQuadRender);
var
  Matrix: TD3DMatrix;
begin
  AQuadRender.GetD3DDevice.GetTransform(D3DTS_PROJECTION, Matrix);

  NormalSpecular := AQuadRender.CreateShader;
  NormalSpecular.LoadComplexShader(PATH + 'vs_normalspecular.bin', PATH + 'ps_normalspecular.bin');
  NormalSpecular.SetShaderState(True);
  AQuadRender.GetD3DDevice.SetVertexShaderConstantF(0, @Matrix, 4);
  NormalSpecular.SetShaderState(False);

  MotionBlur := AQuadRender.CreateShader;
  MotionBlur.LoadPixelShader(PATH + 'Motion.bin');

  Ball := AQuadRender.CreateShader;
  Ball.LoadPixelShader(PATH + 'Ball.bin');

  HorizontalBlur := AQuadRender.CreateShader;
  HorizontalBlur.LoadPixelShader(PATH + 'bl2.bin');

  VerticalBlur := AQuadRender.CreateShader;
  VerticalBlur.LoadPixelShader(PATH + 'bl3.bin');

  BurnShader := AQuadRender.CreateShader;
  BurnShader.LoadPixelShader(PATH + 'Burn.bin');
end;

{ TAudio }

destructor TAudio.destroy;
begin

  inherited;
end;

procedure TAudio.Finalize;
begin
 BASS_Stop;
end;

procedure TAudio.Initialize(AHandle: THandle);
begin
  if BASS_GetVersion <> DWORD(MAKELONG(2, 0)) then
    Exit;

  BASS_Init(1, 44100, 0, AHandle, nil);
  BASS_Start;

  MusicIntro := BASS_StreamCreateFile(False, PAnsiChar(AnsiString(PATH + 'Intro.ogg')), 0, 0, 0);
  MusicCycle := BASS_StreamCreateFile(False, PAnsiChar(AnsiString(PATH + 'Cycle.ogg')), 0, 0, 0);

  Sound_Shots := BASS_SampleLoad(False, PAnsiChar(AnsiString(PATH + 'shot.ogg')), 0, 0, 32, 0);
  Sound_Boom := BASS_SampleLoad(False, PAnsiChar(AnsiString(PATH + 'boom.ogg')), 0, 0, 32, 0);
  Sound_Bonus_Shield := BASS_SampleLoad(False, PAnsiChar(AnsiString(PATH + 'bonusshield.ogg')), 0, 0, 32, 0);
  Sound_Bonus_KillAll := BASS_SampleLoad(False, PAnsiChar(AnsiString(PATH + 'bonuskillall.ogg')), 0, 0, 32, 0);
  Sound_Bonus_Shots := BASS_SampleLoad(False, PAnsiChar(AnsiString(PATH + 'bonusshots.ogg')), 0, 0, 32, 0);
  Sound_Bonus_Nitro := BASS_SampleLoad(False, PAnsiChar(AnsiString(PATH + 'bonusnitro.ogg')), 0, 0, 32, 0);

  BASS_StreamPlay(MusicIntro, False, 0);
end;

procedure TAudio.PlaySound(ASound: HSAMPLE);
begin
  BASS_SamplePlay(ASound);
end;

initialization
  Fonts := TFonts.Create;
  Textures := TTextures.Create;
  Shaders := TShaders.Create;
  Audio := TAudio.Create;

finalization
  Fonts.Free;
  Textures.Free;
  Shaders.Free;
  Audio.Free;

end.
