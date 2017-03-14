unit Bullets;

interface

uses
  QuadEngine, BaseSprite;

type
  TBaseBullets = class(TBaseSprite)
  private
    FParent: TBaseSprite;
  public
    constructor Create(AQuadRender: IQuadRender; ASpriteEngine: TSpriteEngine; AParent: TBaseSprite);
    destructor Destroy; override;

    procedure Draw; override;
    procedure Process(dt: Double); override;
  end;

implementation

uses GlobalConst, PlayerHero, FlyStone, SysUtils, Main_Form, Collision_2d, Resources, Vec2f,
  GameRecord;

{ TPlayerHero }

constructor TBaseBullets.Create(AQuadRender: IQuadRender; ASpriteEngine: TSpriteEngine; AParent: TBaseSprite);
begin
  inherited Create(AQuadRender, ASpriteEngine);
  FParent := AParent;
  FType := tpBullet;
  FZIndex := 5;
  FRadius := 4;

  if Assigned(FParent) and (FParent.GetType = tpHero) then begin
    FPos := AParent.Pos;
    FAngle := AngleFromPoints(MouseX, MouseY, PosCam.X, PosCam.Y) / 180 * pi;
    FVec.Create(1500 * Cos(FAngle), 1500 * Sin(FAngle));
    FVec := FVec + AParent.Vector;
    FOldPos := FPos;
  end;

end;

destructor TBaseBullets.Destroy;
begin

  inherited;
end;

procedure TBaseBullets.Draw;
begin
  inherited;
  FQuad.SetBlendMode(qbmSrcColorAdd);
  Textures.BulletGlow.DrawRot(PosCam.X, PosCam.Y, FAngle*180/Pi - 90, 0.75, $FFFFFFFF);
  FQuad.SetBlendMode(qbmAdd);
  Textures.Bullet.DrawRot(PosCam.X, PosCam.Y, FAngle*180/Pi - 90, 0.75, $FFFF8866);
end;

procedure TBaseBullets.Process(dt: Double);
var
  i: Integer;
  v: TVec2f;
  Angle, Dis: Double;
begin
  inherited;

  if FPos.Distance(PlayHero.Pos) > 1000 then begin
    FIsNeedToKill := True;
    Exit;
  end;

    for i := 0 to FSpriteEngine.GetCountList - 1 do
      if ((FSpriteEngine.List[i].GetType = tpStone) or (FSpriteEngine.List[i].GetType = tpBonus)) and IsCollided(FSpriteEngine.List[i], v) then
      begin
        FIsNeedToKill := True;
        TBasePlatform(FSpriteEngine.List[i]).Boom(Self);
        Audio.PlaySound(Audio.Sound_Boom);

        if Assigned(FParent) and (FParent.GetType = tpHero) and (FSpriteEngine.List[i].GetType = tpStone) then
        begin
          Inc(GRecord.Hits);
          GRecord.RefreshAccuracy;
          Dis := PlayHero.Pos.Distance(v);

          if Dis < 192 then
          begin
            Angle := mMath.GetAngle(PlayHero.Pos, v) / 180 * pi;
            Dis := (192 - Dis) / 192;

            PlayHero.Vector := TVec2f.Create(PlayHero.Vector.X + PlayHero.BoomUp * Cos(Angle) * Dis,
              PlayHero.Vector.Y + PlayHero.BoomUp * Sin(Angle) * Dis);
          end;
        end;
        Break;
      end;
end;

end.
