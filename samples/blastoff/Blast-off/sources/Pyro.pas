unit Pyro;

interface

uses
  BaseSprite, QuadEngine, PlayerHero, Vec2f;

type
  TExplosion = class(TBaseSprite)

  public
    constructor Create(AQuadRender: IQuadRender; ABaseSprite: TBaseSprite; ASpriteEngine: TSpriteEngine; CameraJutter: Double = 0.0; CameraJutterForce: Integer = 20);

    procedure Draw; override;
    procedure Process(dt: Double); override;
  end;

  TSmallExplosion = class(TBaseSprite)
    constructor Create(AQuadRender: IQuadRender; APosition, AVector: TVec2f; ASpriteEngine: TSpriteEngine);

    procedure Draw; override;
    procedure Process(dt: Double); override;
  end;

implementation

uses
  Resources, GlobalConst, iSettings;

{ TExplosion }

constructor TExplosion.Create(AQuadRender: IQuadRender; ABaseSprite: TBaseSprite; ASpriteEngine: TSpriteEngine; CameraJutter: Double; CameraJutterForce: Integer);
begin
  inherited Create(AQuadRender, ASpriteEngine);
  ASpriteEngine.Camera.Jutter(CameraJutter, CameraJutterForce);

  FFrameCount := 12;
  FFrameSpeed := 20 + Random(10);
  FFrame := 0;
  FFramesLooped := False;

  if ABaseSprite <> nil then
  begin
    FVec := ABaseSprite.Vector;
    FPos := ABaseSprite.Pos;
  end
  else
  begin
    FVec := PlayHero.Vector;
    FPos.Create(Random(Settings.WindowWidth) + FSpriteEngine.Camera.Pos.X, Random(Settings.WindowHeight) + FSpriteEngine.Camera.Pos.Y);
  end;

  FZIndex := GlobalConst.ZINDEX_BULLETS;
  Audio.PlaySound(Audio.Sound_Boom);
end;

procedure TExplosion.Draw;
begin
  inherited;
  FQuad.SetBlendMode(qbmAdd);

  Textures.Explosion.DrawRot(PosCam.X, PosCam.Y, FAngle, 1.0, $FFFFFFFF, Trunc(FFrame));
  FQuad.SetBlendMode(qbmSrcAlphaAdd);
  Textures.Explosion_ring.DrawRot(PosCam.X, PosCam.Y, FAngle, FFrame / 12, $FFFFFFFF - Trunc(FFrame*20) shl 24);
end;

procedure TExplosion.Process(dt: Double);
begin
  inherited;
  if FFrame > FFrameCount then
   FIsNeedToKill := True;
end;

{ TSmallExplosion }

constructor TSmallExplosion.Create(AQuadRender: IQuadRender;
  APosition, AVector: TVec2f; ASpriteEngine: TSpriteEngine);
begin
  inherited Create(AQuadRender, ASpriteEngine);

  FFrameCount := 12;
  FFrameSpeed := 20 + Random(10);
  FFrame := 0;
  FFramesLooped := False;

  FVec := AVector;
  FPos := APosition;

  FZIndex := GlobalConst.ZINDEX_HERO;
end;

procedure TSmallExplosion.Draw;
begin
  inherited;
  FQuad.SetBlendMode(qbmAdd);

  Textures.Explosion.DrawRot(PosCam.X, PosCam.Y, FAngle, 0.5, $FFFFFFFF, Trunc(FFrame));
  FQuad.SetBlendMode(qbmSrcAlphaAdd);
  Textures.Explosion_ring.DrawRot(PosCam.X, PosCam.Y, FAngle, FFrame / 24, $FFFFFFFF - Trunc(FFrame*20) shl 24);
end;

procedure TSmallExplosion.Process(dt: Double);
begin
  inherited;
  if FFrame > FFrameCount then
   FIsNeedToKill := True;
end;

end.
