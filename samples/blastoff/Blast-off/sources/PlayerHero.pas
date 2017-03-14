unit PlayerHero;

interface 

uses
  QuadEngine, BaseSprite, Vec2f, Classes, Direct3D9;

type
  TPlayerHero = class(TBaseSprite)
  const
    SpeedMove: TVec2i = (X: 250; Y: 0);
    SpeedUp: TVec2i = (X: 0; Y: 300);
    StartUp: TVec2i = (X: 0; Y: 500);
    BoomUp: Double = 1200;
    TimeRecharge: Double = 0.2;
    Radius: Double = 16;
  private
    FKey: array[0..3] of Boolean;
    FRecharge: Double;
    FJetFuel: Double;
    FGameTime: Double;
    FMaxHeight: Cardinal;
    FHealth: Byte;
    FSparks: TList;

    FNitroAlpha: Integer;

    function  GetKey(Index: Integer): Boolean;
    procedure SetKey(Index: Integer; Value: Boolean);
    function GetGameTime: Double;
    function GetHeight: Integer;
  public
    constructor Create(AQuadRender: IQuadRender; ASpriteEngine: TSpriteEngine); override;
    destructor Destroy; override;

    procedure Draw; override;
    procedure UpdatePosition(dt: Double); override;
    procedure Process(dt: Double); override;

    function GetIsLiving: boolean;
    procedure Death;

    procedure RefreshFuel;
    procedure AddHealth;

    property IsNeedToKill: boolean read FIsNeedToKill write FIsNeedToKill;

    property KeyMouse: Boolean Index 0 read GetKey write SetKey;
    property KeyLeft : Boolean Index 1 read GetKey write SetKey;
    property KeySpace: Boolean Index 2 read GetKey write SetKey;
    property KeyRight: Boolean Index 3 read GetKey write SetKey;
    property GameTime: Double read GetGameTime;
    property Height: Integer read GetHeight;
    property MaxHeight: Cardinal read FMaxHeight;
    property Health: Byte read FHealth write FHealth;

  end;
var
  PlayHero: TPlayerHero;

implementation

uses GlobalConst, Bullets, Main_Form, SysUtils, Resources, iSettings,
  GameRecord, Math, FlyStone;

{ TPlayerHero }
procedure TPlayerHero.Death;
begin
  Inc(GRecord.Deaths);
  FHealth := 0;
  GlobalRecord.Add(GRecord);
  GlobalRecord.SaveToFile('Record');
  SessionRecord.Add(GRecord);
  MaxRecord.Replace(GRecord);
  MaxRecord.SaveToFile('MaxRecord');

  Audio.PlaySound(Audio.Sound_Boom);
end;

function TPlayerHero.GetIsLiving: boolean;
begin
  Result := FHealth > 0;
end;

constructor TPlayerHero.Create(AQuadRender: IQuadRender; ASpriteEngine: TSpriteEngine);
var
  i: Byte;
begin
  inherited;

  FType := tpHero;
  FZIndex := 4;

  for I := 0 to 3 do
    FKey[i] := False;

  FJetFuel := 100;
  FPos.X := 0;
  FPos.Y := 0;
  FRecharge := 0;

  FGameTime := 0;
  FMaxHeight := 0;

  FNitroAlpha := 0;

  FRadius := 24;
  FHealth := 1;

  FSparks:= TList.Create;
end;

destructor TPlayerHero.Destroy;
begin
  FSparks.Clear;
  FSparks.Free;  
  inherited;
end;

procedure TPlayerHero.Draw;
begin
  inherited;
  if not GetIsLiving then
    Exit;

  FQuad.SetBlendMode(qbmNone);
  Quad.RenderToTexture(True, Textures.Hero, 2, True);
  Textures.RenderTarget.Draw(-PosCam.X + 64, -PosCam.Y + 64, $FFFFFFFF);
  Quad.RenderToTexture(False, Textures.Hero);

  FQuad.SetBlendMode(qbmSrcAlpha);
  Shaders.Ball.SetShaderState(True);
  Textures.Hero.DrawRot(PosCam.X, PosCam.Y, 0.0, 0.75, $FFFFFFFF);
  Shaders.Ball.SetShaderState(False);

  FQuad.SetBlendMode(qbmSrcAlphaAdd);
  Textures.HeroGlow.DrawRot(PosCam.X, PosCam.Y, 0.0, 0.75, Settings.PlayerColor - $FF000000 + trunc(FJetFuel*2.55) shl 24);
         {
  if PlayHero.Health > 1 then
  begin
    FQuad.SetBlendMode(qbmSrcAlpha);
    for i := 0 to Health - 2 do
      Textures.HeroShield.DrawRot(PosCam.X, PosCam.Y, Random(360), 0.85 + i * 0.1, $FFFFFFFF);
  end;  }

  FQuad.SetBlendMode(qbmAdd);
  Textures.CrossHair.DrawRot(MouseX, MouseY, 0.0, 1.0, $FFFFFFFF);
  FQuad.SetBlendMode(qbmSrcAlpha);

  if KeySpace and (FNitroAlpha > 0) then
    Textures.Jetfire.DrawRot(PosCam.X, PosCam.Y, 0, 1, D3DCOLOR_ARGB(FNitroAlpha, 255, 255, 255));

  if KeyLeft then
    Textures.Jetfire.DrawRot(PosCam.X+13, PosCam.Y, 270, 0.5, D3DCOLOR_ARGB(127, 255, 255, 255));
  if KeyRight then
    Textures.Jetfire.DrawRot(PosCam.X-13, PosCam.Y, 90, 0.5, D3DCOLOR_ARGB(127, 255, 255, 255));
end;

function TPlayerHero.GetHeight: Integer;
begin
  Result := Trunc(-Self.FPos.Y) div 200;
end;

function TPlayerHero.GetGameTime: Double;
begin
  Result := FGameTime / 10;
end;

function TPlayerHero.GetKey(Index: Integer): Boolean;
begin
  Result := FKey[Index];
end;

procedure TPlayerHero.SetKey(Index: Integer; Value: Boolean);
begin
  FKey[Index] := Value;
end;

procedure TPlayerHero.UpdatePosition(dt: Double);
begin
  if FSpriteEngine.PauseGame then
    Exit;

  inherited;
  if FPos.Y > FSpriteEngine.Floor.Height then
  begin
    if GetIsLiving then
      Death;
    FPos.Y := FSpriteEngine.Floor.Height;
  end;

  if GetIsLiving then
  begin
    FVec := FVec + Grav * dt;
    if (GRecord.MaxSpeed < -FVec.Y) and (FVec.Y < 0) then
      GRecord.MaxSpeed := -FVec.Y;

    GRecord.MaxTime := GRecord.MaxTime + dt;
  end
    else
      FVec := FVec * 0.995;

  if FPos.X < (FSpriteEngine.Camera.Pos.X + Settings.WindowWidth * 0.25) then
    FSpriteEngine.Camera.PosX := FPos.X - Settings.WindowWidth * 0.25
  else
    if FPos.X > (FSpriteEngine.Camera.Pos.X + Settings.WindowWidth * 0.75) then
      FSpriteEngine.Camera.PosX := FPos.X - Settings.WindowWidth * 0.75;

  if (FPos.Y < (FSpriteEngine.Camera.Pos.Y + Settings.WindowHeight * 0.25)) then
    FSpriteEngine.Camera.PosY := FPos.Y - Settings.WindowHeight * 0.25
  else
    if (FPos.Y > (FSpriteEngine.Camera.Pos.Y + Settings.WindowHeight * 0.5)) and (FVec.Y > 0) then
      FSpriteEngine.Camera.PosY := FPos.Y - Settings.WindowHeight * 0.5;
end;

procedure TPlayerHero.Process(dt: Double);
var
  i, j: Integer;
  Vec, Pos: TVec2f;
begin
  inherited;
  if not GetIsLiving then
    Exit;

  if FSpriteEngine.PauseGame then
  begin

    if KeyMouse or KeySpace then
    begin
      Fvec := -StartUp;
      FSpriteEngine.PauseGame := False;
      FRecharge := 0.2;
      FGameTime := 0;


      Pos.Create(PlayHero.Pos.X, Settings.WindowHeight + FSpriteEngine.Camera.Pos.Y + 50);
      Vec.Create(0, -660);
      FSpriteEngine.Add(TFlyPlatform.Create(FQuad, FSpriteEngine, Pos, Vec));
    end

  end
  else
    begin
      if FMaxHeight < Height then begin
        FMaxHeight := Height;
        GRecord.MaxHeight := FMaxHeight;
      end;

      FGameTime := FGameTime + dt;
           
      if KeyLeft then
        FVec := FVec - SpeedMove * dt;

      if KeyRight then
        FVec := FVec + SpeedMove * dt;

   if KeySpace and (FJetFuel > (100 * dt)) then
      begin
        FJetFuel := Max(FJetFuel - 100 * dt, 0);
        FNitroAlpha := Min(FNitroAlpha + 25, 255);
        FVec := FVec - SpeedUp * dt;
        GRecord.FuelBurned := GRecord.FuelBurned + 100 * dt;
      end
      else
        begin
          FJetFuel := Min(FJetFuel + 10 * dt, 100);
          FNitroAlpha := Max(FNitroAlpha - 75, 50);
        end;

      if (FRecharge <= 0) and KeyMouse then
      begin
        FSpriteEngine.Add(TBaseBullets.Create(FQuad, FSpriteEngine, Self));
        Audio.PlaySound(Audio.Sound_Shots);
        FRecharge := TimeRecharge;
        Inc(GRecord.Shots);
        GRecord.RefreshAccuracy;
      end
      else
        if FRecharge > 0 then
          FRecharge := FRecharge - dt;
    end;
end;

procedure TPlayerHero.RefreshFuel;
begin
  FJetFuel := 100;
end;

procedure TPlayerHero.AddHealth;
begin
  if FHealth < 6 then
    Inc(FHealth);
end;

end.
