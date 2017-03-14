unit FlyStone;

interface

uses
  QuadEngine, BaseSprite, Bullets, Vec2f, Direct3D9;

type
  TBasePlatform = class(TBaseSprite)
  public
    procedure Boom(ABullet: TBaseSprite); virtual;
    procedure Kill; virtual; abstract;
    function CollBullet(ABullet: TBaseBullets; dt: Double): Boolean; virtual; abstract;
  end;

  TBasePlatformRect = class(TBasePlatform)
  protected
    FSize, FGoVector: TVec2f;
  public
    function CollBullet(ABullet: TBaseBullets; dt: Double): Boolean; override;
  end;

  TFlyPlatform = class(TBasePlatform)
  protected
    FHealth: Integer;
    FBonus: Boolean;
  public
    constructor Create(AQuadRender: IQuadRender; ASpriteEngine: TSpriteEngine; APos,  AVec: TVec2f);

    procedure Draw; override;
    procedure UpdatePosition(dt: Double); override;
    procedure Process(dt: Double); override;
    procedure Boom(ABullet: TBaseSprite); override;
    procedure Kill; override;
  end;

  THangPlatform = class(TBasePlatformRect)
  private
    FCreationTime: Double;
    FDirection: byte;
  public
    constructor Create(AQuadRender: IQuadRender; ASpriteEngine: TSpriteEngine); override;

    procedure Draw; override;
    procedure Process(dt: Double); override;
  end;

  { Bonus }

  TBaseBonus = class(TBasePlatform)
    constructor Create(AQuadRender: IQuadRender; ABasePlatform: TBaseSprite; ASpriteEngine: TSpriteEngine);
    procedure UpdatePosition(dt: Double); override;
    procedure Process(dt: Double); override;
    procedure Boom(ABullet: TBaseSprite); override;
  end;

  TBonusRefreshFuel = class(TBaseBonus)
  public
    procedure Draw; override;
    procedure Boom(ABullet: TBaseSprite); override;
  end;
  TBonusShiels = class(TBaseBonus)
  public
    procedure Draw; override;
    procedure Boom(ABullet: TBaseSprite); override;
  end;
  TBonusKillAll = class(TBaseBonus)
  public
    procedure Draw; override;
    procedure Boom(ABullet: TBaseSprite); override;
  end;
  TBonusShots = class(TBaseBonus)
  public
    procedure Draw; override;
    procedure Boom(ABullet: TBaseSprite); override;
  end;


implementation

uses GlobalConst, PlayerHero, Main_Form, SysUtils, Resources, Collision_2d, iSettings, Math,
  GameRecord, Pyro;

{ TBasePlatform }

procedure TBasePlatform.Boom;
begin

end;

{ TBasePlatformRect }

function TBasePlatformRect.CollBullet(ABullet: TBaseBullets; dt: Double): Boolean;
begin
  Result := (ABullet.PosCam.X >= FPos.X - FSize.X / 2) and
    (ABullet.PosCam.X < FPos.X + FSize.X / 2) and
    (ABullet.PosCam.Y >= FPos.Y - FSize.Y / 2) and
    (ABullet.PosCam.Y < FPos.Y + FSize.Y / 2);
end;

{ TFlyStone }

procedure TFlyPlatform.Kill;
begin
  FIsNeedToKill := True;
  FSpriteEngine.Add(TExplosion.Create(FQuad, Self, FSpriteEngine, 0.1, 10));
end;

procedure TFlyPlatform.Boom(ABullet: TBaseSprite);
begin
  Dec(FHealth);

  if FHealth = 0 then
  begin
    Inc(GRecord.Kills);
    Kill;

//      FSpriteEngine.Add(TBonusShots.Create(FQuad, Self, FSpriteEngine));
    if FBonus then
      case Random(100) of
        0..59:
          FSpriteEngine.Add(TBonusRefreshFuel.Create(FQuad, Self, FSpriteEngine));
        60..79:
          FSpriteEngine.Add(TBonusShiels.Create(FQuad, Self, FSpriteEngine));
        80..89:
          FSpriteEngine.Add(TBonusShots.Create(FQuad, Self, FSpriteEngine));
        90..99:
          FSpriteEngine.Add(TBonusKillAll.Create(FQuad, Self, FSpriteEngine));
      end;
  end;

  if Assigned(ABullet) and (FHealth > 0) then
  begin
    FVec := FVec + (ABullet.Vector - PlayHero.Vector) * 0.1;
    FSpriteEngine.Add(TSmallExplosion.Create(FQuad, ABullet.Pos, Vector, FSpriteEngine));
  end;
end;

constructor TFlyPlatform.Create(AQuadRender: IQuadRender; ASpriteEngine: TSpriteEngine; APos,  AVec: TVec2f);
begin
  inherited Create(AQuadRender, ASpriteEngine);
  FType := tpStone;
  FZIndex := ZINDEX_STONE;
  FRadius := 32;

  //FBonus := True;
  FBonus := Random(10) < 2;

  FHealth := Random(2)+1;

  FPos := APos;
  FVec := AVec;

  FDeltaAngle := Random(10000)/100;
end;

procedure TFlyPlatform.Draw;
var
  LightPos : array [0..2] of Single;
begin
  inherited;

  if (Self.PosCam.X < - FRadius * 2) or (Self.PosCam.X > Settings.WindowWidth + FRadius * 2) or
    (Self.PosCam.Y < - FRadius * 2) or (Self.PosCam.Y > Settings.WindowHeight + FRadius * 2) then
    Exit;

  FQuad.SetBlendMode(qbmSrcAlpha);

  LightPos[0] := PlayHero.PosCam.X - 1024/2;
  LightPos[1] := PlayHero.PosCam.Y - 768/2;
  LightPos[2] := 2.5;
  FQuad.GetD3DDevice.SetVertexShaderConstantF(4, @Lightpos, 3);

  Shaders.NormalSpecular.SetShaderState(True);
  if FHealth > 1 then
    Textures.SimpleStone.DrawRot(PosCam.X, PosCam.Y, FAngle, 1.0, $FFFF9933)
  else
    Textures.SimpleStone.DrawRot(PosCam.X, PosCam.Y, FAngle, 1.0, $FFFFFFFF);
  Shaders.NormalSpecular.SetShaderState(False);
end;

procedure TFlyPlatform.Process(dt: Double);
var
  v: TVec2f;
begin
  inherited;

  if FPos.Y > FSpriteEngine.Floor.GetDeadHeight then
    FIsNeedToKill := True;

  if PlayHero.GetIsLiving and IsCollided(PlayHero, v) then
  begin
    FIsNeedToKill := True;
    Boom(nil);
    PlayHero.Health := PlayHero.Health - 1;
    if PlayHero.Health = 0 then
      PlayHero.Death;
    FSpriteEngine.Add(TExplosion.Create(FQuad, Self, FSpriteEngine, 0.1, 10));
  end;

  FAngle := FAngle + FDeltaAngle * dt;
end;


procedure TFlyPlatform.UpdatePosition(dt: Double);
begin
  inherited;
  FVec := FVec + Grav * dt;
end;

{ THangPlatform }

constructor THangPlatform.Create(AQuadRender: IQuadRender; ASpriteEngine: TSpriteEngine);
begin
  inherited;
  FType := tpArrow;
  FZIndex := ZINDEX_BACKGROUND;
  FSize.X := 48;
  FSize.Y := 96;

  FFrame := Random(2);
  FFrameCount := 2;
  FFrameSpeed := 4;

  FCreationTime := 2.0;

  case Random(10) of
    0..4: FGoVector := TVec2f.Create(0, 50);
    5..6: FGoVector := TVec2f.Create(0, -10);
    else
      FGoVector := TVec2f.Create(0, 0);
  end;

  FDirection := Random(2);

  FPos.Create(Random(Settings.WindowWidth) + FSpriteEngine.Camera.Pos.X, 0);
  FVec.Create(0, 0);
end;

procedure THangPlatform.Process(dt: Double);
begin
  inherited;

  if (FPos.Y > FSpriteEngine.Floor.GetDeadHeight) and (FCreationTime <= 0.0) then
    FIsNeedToKill := True;

  if FCreationTime > 0 then
    FCreationTime := FCreationTime - dt;

  if Collision.RectVsCircle(Pos, Pos+FSize, PlayHero.Pos, PlayHero.Radius) then
    PlayHero.Vector := PlayHero.Vector - FGoVector;
end;

procedure THangPlatform.Draw;
begin
  inherited;

  if FCreationTime > 0 then
  begin
    FPos.Y := FSpriteEngine.Camera.Pos.Y - 64;
  end
  else
    if (Self.PosCam.X < - FSize.X * 2) or (Self.PosCam.X > Settings.WindowWidth + FSize.X * 2) or
      (Self.PosCam.Y < - FSize.Y * 2) or (Self.PosCam.Y > Settings.WindowHeight + FSize.Y * 2) then
      Exit;

  FQuad.SetBlendMode(qbmSrcAlpha);

  if FGoVector.Y > 0 then
  begin
    Textures.ArrowsGlow.Draw(PosCam.X, PosCam.Y, $FFFFFFFF);
    FQuad.SetBlendMode(qbmSrcAlphaAdd);                                                       //159, 234, 21
    Textures.Arrows.Draw(PosCam.X-FSize.X/2, PosCam.Y-FSize.Y/2, D3DCOLOR_ARGB($FF-Random($1A), 100, 234, 21), Trunc(FFrame));
  end
  else
    if FGoVector.Y < 0 then
    begin
      Textures.ArrowsGlow.DrawRot(PosCam.X+FSize.X/2, PosCam.Y+FSize.Y/2, 180, 1, $FFFFFFFF);
      FQuad.SetBlendMode(qbmSrcAlphaAdd);
      Textures.Arrows.DrawRot(PosCam.X+FSize.X/2, PosCam.Y+FSize.Y/2, 180, 1, D3DCOLOR_ARGB($FF-Random($1A), $FF, $11, 0), Trunc(FFrame));
    end
      else
      begin
        Textures.ArrowsGlow.DrawRot(PosCam.X+FSize.X/2, PosCam.Y+FSize.Y/2, FDirection * 180, 1, $FFFFFFFF);
        FQuad.SetBlendMode(qbmSrcAlphaAdd);
        Textures.Arrows.DrawRot(PosCam.X+FSize.X/2, PosCam.Y+FSize.Y/2, FDirection * 180, 1, D3DCOLOR_ARGB($FF-Random($1A), $FF, $FF, 0), Trunc(FFrame));
      end;
end;

{ TBaseBonus }

procedure TBaseBonus.Boom(ABullet: TBaseSprite);
begin
  inherited;
  FIsNeedToKill := True;
end;

constructor TBaseBonus.Create(AQuadRender: IQuadRender; ABasePlatform: TBaseSprite; ASpriteEngine: TSpriteEngine);
begin
  inherited Create(AQuadRender, ASpriteEngine);
  FVec := ABasePlatform.Vector;
  FPos := ABasePlatform.Pos;

  FType := tpBonus;
  FRadius := 32;
  FZIndex := GlobalConst.ZINDEX_STONE;
end;

procedure TBaseBonus.Process(dt: Double);
var
  v: TVec2f;
begin
  inherited;
  if PlayHero.GetIsLiving and IsCollided(PlayHero, v) then
    Boom(nil);
end;

procedure TBaseBonus.UpdatePosition(dt: Double);
begin
  inherited;
  FVec := FVec + Grav * dt;
end;

{ TBonusRefreshFuel }

procedure TBonusRefreshFuel.Boom(ABullet: TBaseSprite);
begin
  inherited;
  PlayHero.RefreshFuel;
  Audio.PlaySound(Audio.Sound_Bonus_Nitro);
end;

procedure TBonusRefreshFuel.Draw;
begin
  Textures.Bonuses.DrawRot(PosCam.X, PosCam.Y, 0.0, 0.75, $FFFFFFFF, 2);
end;

{ TBonusShiels }

procedure TBonusShiels.Boom(ABullet: TBaseSprite);
begin
  inherited;
  PlayHero.AddHealth;
  Audio.PlaySound(Audio.Sound_Bonus_Shield);
end;

procedure TBonusShiels.Draw;
begin
  Textures.Bonuses.DrawRot(PosCam.X, PosCam.Y, 0.0, 0.75, $FFFFFFFF, 0);
end;

{ TBonusKillAll }

procedure TBonusKillAll.Boom(ABullet: TBaseSprite);
var
  i: Integer;
begin
  inherited;
  Audio.PlaySound(Audio.Sound_Bonus_KillAll);

  for i := 0 to FSpriteEngine.GetCountList - 1 do
    if (FSpriteEngine.List[i].GetType = tpStone) then
      TBasePlatform(FSpriteEngine.List[i]).Kill;

  for i := 0 to 15 do
    FSpriteEngine.Add(TExplosion.Create(FQuad, nil, FSpriteEngine,  0.6));
end;

procedure TBonusKillAll.Draw;
begin
  Textures.Bonuses.DrawRot(PosCam.X, PosCam.Y, 0.0, 0.75, $FFFFFFFF, 1);
end;

{ TBonusShots }

procedure TBonusShots.Boom(ABullet: TBaseSprite);
const
  CountBullets = 12;
var
  i: Integer;
  Bullet: TBaseBullets;
begin
  inherited;
  Audio.PlaySound(Audio.Sound_Bonus_Shots);
  for i := 1 to 360 div CountBullets do
  begin
    Bullet := TBaseBullets.Create(FQuad, FSpriteEngine, nil);
    Bullet.Angle := (i*(360 / CountBullets)) / 180 * pi;
    Bullet.Pos := Self.Pos;
    Bullet.Vector.Create(1500 * Cos(Bullet.Angle), 1500 * Sin(Bullet.Angle));
    Bullet.Vector := Bullet.Vector + Vector;
    Bullet.OldPos := FPos;
    FSpriteEngine.Add(Bullet);
  end;
end;

procedure TBonusShots.Draw;
begin
  inherited;
  Textures.Bonuses.DrawRot(PosCam.X, PosCam.Y, 0.0, 0.75, $FFFFFFFF, 3);
end;

end.
