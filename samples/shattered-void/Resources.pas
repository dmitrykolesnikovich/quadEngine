unit Resources;

interface

uses
  QuadEngine, bass;

type
  TTextures = class
  private
    const PATH = 'gfx\';
    const PATH_EXPLOSION = 'gfx\Explosion\';
  public
    QuadLogo: IQuadTexture;

    l1Layer4: IQuadTexture;
    l1Layer42: IQuadTexture;
    l1Layer3: IQuadTexture;
    l1Layer2: array[1..7] of IQuadTexture;
    l1Layer1: array[1..3] of IQuadTexture;
    l1Dust: IQuadTexture;
    l1Star: IQuadTexture;
    l1Star_mask: IQuadTexture;

    Hero: IQuadTexture;
    HeroFlame: IQuadTexture;
    HealthBar: IQuadTexture;

    Shot1: IQuadTexture;

    rt: IQuadTexture;
    rt2: IQuadTexture;
    postprocess: IQuadTexture;

    leftbar: IQuadTexture;

    // menu
    StarField: IQuadTexture;
    galaxy: IQuadTexture;
    galaxycore: IQuadTexture;
    Menu_rt,
    Menu_rt2,
    Menu_rt3: IQuadTexture;

    // Explosion
    expDebris,
    expFlame,
    expFlash,
    expRoundSpark,
    expShockwave,
    expSmoke,
    expSmokeTrail,
    expSpark: IQuadTexture;

    // enemy
    enemy_ball: IQuadTexture;
    enemy_ball_glow: IQuadTexture;
    procedure Load(ADevice: IQuadDevice; ARender: IQuadRender);
    destructor Destroy;
  end;

  TShaders = class
  private
    const PATH = 'shaders\';
  public
    GodRays: IQuadShader;
    HighPass: IQuadShader;

    // menu
    Blur1,
    Blur2,
    GalaxyDistort: IQuadShader;

    // enemy
    dudv: IQuadShader;
    procedure Load(ADevice: IQuadDevice);
    destructor Destroy;
  end;

  TFonts = class
  private
    const PATH = 'fonts\';
  public
    Console        : IQuadFont;
    procedure Load(ADevice: IQuadDevice);
    destructor Destroy;
  end;

  TSounds = class
  private
    const PATH = 'sounds\';
  public
    Explosions: array [0..3] of HSAMPLE;
    Shots: array [0..3] of HSAMPLE;
    Hits: array [0..3] of HSAMPLE;
    MenuExecute: HSAMPLE;
    MenuHover: HSAMPLE;
    procedure Load(ADevice: IQuadDevice);
    destructor Destroy;
  end;

var
  Fonts: TFonts;
  Textures: TTextures;
  Sounds: TSounds;
  Shaders: TShaders;

implementation

{ TTextures }

uses
  SysUtils, defs;

destructor TTextures.Destroy;
begin
  StarField := nil;
  galaxy := nil;
  galaxycore := nil;

  expDebris := nil;
  expFlame := nil;
  expFlash := nil;
  expRoundSpark := nil;
  expShockwave := nil;
  expSmoke := nil;
  expSmokeTrail := nil;
  expSpark := nil;

  enemy_ball := nil;
end;

procedure TTextures.Load(ADevice: IQuadDevice; ARender: IQuadRender);
var
  i: Integer;
begin
  ADevice.CreateAndLoadTexture(0, PATH + 'quad_logo.png', QuadLogo);

  ADevice.CreateTexture(l1Star);
  l1Star.LoadFromFile(0, PATH + 'star.jpg');
  ADevice.CreateTexture(l1Star_mask);
  l1Star_mask.LoadFromFile(0, PATH + 'star_mask.jpg');

  // Location2

  ADevice.CreateTexture(l1Layer4);
  l1Layer4.LoadFromFile(0, PATH + 'location01\background.jpg');
  ADevice.CreateTexture(l1Layer42);
  l1Layer42.LoadFromFile(0, PATH + 'location01\background2.jpg');
  ADevice.CreateTexture(l1Layer3);
  l1Layer3.LoadFromFile(0, PATH + 'location01\truss.png');

  for i := 1 to 7 do
  begin
    ADevice.CreateTexture(l1Layer2[i]);
 //   l1Layer2[i].LoadFromFile(0, PAnsiChar(AnsiString(PATH + 'location01\back_element' + IntToStr(i)  + '.png')));
   l1Layer2[i].LoadFromFile(0, PWideChar(PATH + 'location01\asteroid_back2.png'));
  end;

  for i := 1 to 3 do
  begin
    ADevice.CreateTexture(l1Layer1[i]);
//    l1Layer1[i].LoadFromFile(0, PAnsiChar(AnsiString(PATH + 'location01\rock' + IntToStr(i)  + '.png')));
    l1Layer1[i].LoadFromFile(0, PWideChar(PATH + 'location01\truss_back'  + IntToStr(i)  + '.png'));
  end;

  ADevice.CreateAndLoadTexture(0, PATH + 'location01\dust.png', l1Dust);

  ADevice.CreateAndLoadTexture(0, PATH + 'shot1.png', Shot1);


  ADevice.CreateTexture(Hero);
  Hero.LoadFromFile(0, PWideChar(PATH + 'Ships\player.png'), 128, 128);

  ADevice.CreateAndLoadTexture(0, PATH + 'Ships\player_engines.png', HeroFlame, 128, 128);

  ADevice.CreateAndLoadTexture(0, PATH + 'healthbar.png', HealthBar);
  ADevice.CreateAndLoadTexture(0, PATH + 'leftbar.png', leftbar);

  // general
  ADevice.CreateRenderTarget(ScreenWidth div 4, ScreenHeight div 4, rt, 0);
  ADevice.CreateRenderTarget(ScreenWidth div 4, ScreenHeight div 4, rt2, 0);
  ADevice.CreateRenderTarget(ScreenWidth, ScreenHeight, postprocess, 0);

  // menu
  ADevice.CreateAndLoadTexture(0, 'gfx\galaxystarfield.jpg', StarField);
  ADevice.CreateAndLoadTexture(0, 'gfx\galaxy.png', galaxy);
  ADevice.CreateAndLoadTexture(0, 'gfx\galaxycore.png', galaxycore);

  ADevice.CreateRenderTarget(ScreenWidth, ScreenHeight, Menu_rt, 0);
  ADevice.CreateRenderTarget(ScreenWidth div 8, ScreenHeight div 8, Menu_rt2, 0);
  ADevice.CreateRenderTarget(ScreenWidth, ScreenHeight, Menu_rt3, 0);

  // Explosion

  ADevice.CreateAndLoadTexture(0, PATH_EXPLOSION + 'debris.png', expDebris, 42, 42);
  ADevice.CreateAndLoadTexture(0, PATH_EXPLOSION + 'flame.png', expFlame, 128, 128);
  ADevice.CreateAndLoadTexture(0, PATH_EXPLOSION + 'flash.png', expFlash, 128, 128);
  ADevice.CreateAndLoadTexture(0, PATH_EXPLOSION + 'roundspark.png', expRoundSpark);
  ADevice.CreateAndLoadTexture(0, PATH_EXPLOSION + 'shockwave.png', expShockwave);
  ADevice.CreateAndLoadTexture(0, PATH_EXPLOSION + 'smoke.png', expSmoke, 32, 32);
  ADevice.CreateAndLoadTexture(0, PATH_EXPLOSION + 'smoketrail.png', expSmokeTrail, 256, 85);
  ADevice.CreateAndLoadTexture(0, PATH_EXPLOSION + 'spark.png', expSpark);

  // enemy
  ADevice.CreateAndLoadTexture(0, PATH + 'Ships\enemy_ball.png', enemy_ball);
  enemy_ball.LoadFromFile(1, PATH + 'Ships\enemy_ball_dudv.png');
  ADevice.CreateRenderTarget(128, 128, enemy_ball, 2);

  ADevice.CreateAndLoadTexture(0, PATH + 'Ships\enemy_ball_glow.png', enemy_ball_glow);
end;

{ TFonts }

destructor TFonts.Destroy;
begin
  Console := nil;

  inherited;
end;

procedure TFonts.Load(ADevice: IQuadDevice);
begin
  ADevice.CreateFont(Console);

  Console.LoadFromFile(PATH + 'Console.png', PATH + 'Console.qef');
  Console.SetIsSmartColoring(True);
end;

{ TShaders }

destructor TShaders.Destroy;
begin
  GodRays := nil;

  inherited;
end;

procedure TShaders.Load(ADevice: IQuadDevice);
begin
  ADevice.CreateShader(GodRays);
  GodRays.LoadPixelShader(PATH + 'VolLight.bin');

  ADevice.CreateShader(HighPass);
  HighPass.LoadPixelShader(PATH + 'highpass.bin');

  // menu
  ADevice.CreateShader(Blur1);
  Blur1.LoadPixelShader('shaders\bl2.bin');

  ADevice.CreateShader(Blur2);
  Blur2.LoadPixelShader('shaders\bl3.bin');

  ADevice.CreateShader(GalaxyDistort);
  GalaxyDistort.LoadPixelShader('shaders\galaxy_distort.bin');

  ADevice.CreateShader(dudv);
  dudv.LoadPixelShader('shaders\dudv.bin');
end;

{ TSounds }

destructor TSounds.Destroy;
begin

end;

procedure TSounds.Load(ADevice: IQuadDevice);
var
  i: Integer;
begin
  for i := 0 to 3 do
  begin
    Shots[i] := BASS_SampleLoad(False, PAnsiChar(AnsiString(PATH + 'Shot' + IntToStr(i+1) + '.ogg')), 0, 0, 32, 0);
    Explosions[i] := BASS_SampleLoad(False, PAnsiChar(AnsiString(PATH + 'Explosion' + IntToStr(i+1) + '.ogg')), 0, 0, 32, 0);
    Hits[i] := BASS_SampleLoad(False, PAnsiChar(AnsiString(PATH + 'Hit' + IntToStr(i+1) + '.ogg')), 0, 0, 32, 0);
  end;
  MenuExecute := BASS_SampleLoad(False, PAnsiChar(AnsiString(PATH + 'MenuExecute.ogg')), 0, 0, 32, 0);
  MenuHover := BASS_SampleLoad(False, PAnsiChar(AnsiString(PATH + 'MenuHover.ogg')), 0, 0, 32, 0);
end;

initialization
  Fonts := TFonts.Create;
  Textures := TTextures.Create;
  Shaders := TShaders.Create;
  Sounds := Tsounds.Create;

finalization
  Fonts.Free;
  Textures.Free;
  Sounds.Free;
  Shaders.Free;

end.
