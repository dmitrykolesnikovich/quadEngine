unit BaseSprite;

interface

uses
  Windows, Classes, QuadEngine, GlobalConst, Vec2f, iCamera;

type
  TTypeSprite = (tpNone, tpArrow, tpStone, tpHero, tpBullet, tpBonus);

  TSpriteEngine = class;
  TFloor = class;

  TBaseSprite = class
  protected
    Fdt: Double;
    FOldPos, FPos, FVec: TVec2f;
    FAngle, FScale: Double;
    FDeltaAngle: Double;
    FZIndex: Integer;
    FIsNeedToKill: Boolean;
    FType: TTypeSprite;
    FFrame, FFrameCount, FFrameSpeed: Double;
    FFramesLooped: Boolean;
    FRadius: Double;
    FQuad: IQuadRender;
    FSpriteEngine: TSpriteEngine;
    function GetPosCam: TVec2f;
  public
    constructor Create(AQuadRender: IQuadRender; ASpriteEngine: TSpriteEngine); virtual;
    destructor Destroy; override;

    procedure Draw; virtual; abstract;
    procedure UpdatePosition(dt: Double); virtual;
    procedure Process(dt: Double); virtual;

    function GetLengthVector: Double;
    function IsCollided(ASprite: TBaseSprite; var ColPoint: TVec2f): Boolean;

    property Pos: TVec2f read FPos write FPos;
    property PosX: Single write FPos.X;
    property PosY: Single write FPos.Y;
    property Radius: Double read FRadius;
    property OldPos: TVec2f read FOldPos write FOldPos;
    property PosCam: TVec2f read GetPosCam;
    property Vector: TVec2f read FVec write FVec;
    property IsNeedToKill: boolean read FIsNeedToKill;
    property GetType: TTypeSprite read FType;
    property ZIndex: Integer read FZIndex;
    property Angle: Double read FAngle write FAngle;
  end;

  TSpriteEngine = class
  private
    FList: TList;
    function GetListItem(Index: Integer): TBaseSprite;
  public
    PauseGame: Boolean;
    Camera: TCamera;
    Floor: TFloor;
    constructor Create;
    destructor Destroy; override;

    procedure Add(ASprite: TBaseSprite);
    procedure Delete(ASprite: TBaseSprite);
    procedure Clear;
    procedure Process(dt: Double);
    Procedure Draw(AZIndex: Integer);
    function GetCountList: Integer;

    property List[Index: Integer]: TBaseSprite read GetListItem;
  end;

  TFloor = class
  private
    FSpriteEngine: TSpriteEngine;
    FHeight: Double;
    FSpeed: Double;
  public
    constructor Create(ASpriteEngine: TSpriteEngine);
    procedure Refresh;
    function GetDeadHeight: Double;

    procedure UpdatePosition(dt: Double);
    procedure Draw;

    property Height: Double read FHeight write FHeight;
    property Speed: Double read FSpeed write FSpeed;
  end;

implementation

uses
  Math, Collision_2d, Main_Form, iSettings, PlayerHero, Resources;

{ TBaseSprite }

constructor TBaseSprite.Create(AQuadRender: IQuadRender; ASpriteEngine: TSpriteEngine);
begin
  FQuad := AQuadRender;
  FIsNeedToKill := False;
  FZIndex := 0;
  FFramesLooped := True;
  FSpriteEngine := ASpriteEngine;
end;

destructor TBaseSprite.Destroy;
begin
  inherited;
end;

function TBaseSprite.GetLengthVector: Double;
begin
  Result := FPos.Distance(FOldPos);
end;

function TBaseSprite.GetPosCam: TVec2f;
begin
  Result := FPos - FSpriteEngine.Camera.Pos;
end;

function TBaseSprite.IsCollided(ASprite: TBaseSprite; var ColPoint: TVec2f): Boolean;
var
  TickCount: Integer;
  Step: Double;
  LengthRadiusRatioBullet, LengthRadiusRatioStone: Double;
  i: Integer;
  BulletVectorLength, StoneVectorLength: Double;
  PositionCollidedBullet, PositionCollidedStone: TVec2f;   {TODO: переименовать это говнище}
begin
  Result := False;

  BulletVectorLength := ASprite.GetLengthVector;
  StoneVectorLength := GetLengthVector;


  if not Collision.VsLine(Pos + Vector * 0.25, OldPos - Vector * 0.25,
    ASprite.Pos + ASprite.Vector * 0.25, ASprite.OldPos - ASprite.Vector * 0.25, PositionCollidedBullet) and
    (Pos.Distance(ASprite.Pos) > (FRadius + ASprite.Radius)) and
    (OldPos.Distance(ASprite.OldPos) > (FRadius + ASprite.Radius)) then
      Exit;

  LengthRadiusRatioBullet := BulletVectorLength / ASprite.Radius;
  LengthRadiusRatioStone := StoneVectorLength / FRadius;

  if LengthRadiusRatioBullet > LengthRadiusRatioStone then
    TickCount := Ceil(LengthRadiusRatioBullet)
  else
    TickCount := Ceil(LengthRadiusRatioStone);

  if TickCount = 0 then
    TickCount := 1;

  i := 0;
  repeat
    PositionCollidedBullet := ASprite.OldPos + ASprite.Vector * Fdt * i / TickCount;
    PositionCollidedStone := OldPos + Vector * Fdt * i / TickCount;
    Result := PositionCollidedBullet.Distance(PositionCollidedStone) < (ASprite.Radius + FRadius);
    Inc(i);
  until Result or (i = TickCount);

  if Result then
    if ASprite.Radius < FRadius then
      ColPoint := PositionCollidedBullet.Lerp(PositionCollidedStone, ASprite.Radius / FRadius)
    else
      ColPoint := PositionCollidedStone.Lerp(PositionCollidedBullet, FRadius / ASprite.Radius);
end;

procedure TBaseSprite.Process(dt: Double);
begin
  FFrame := FFrame + FFrameSpeed * dt;
  if FFramesLooped and (FFrame >= FFrameCount) then
    FFrame := FFrame - FFrameCount;
end;

procedure TBaseSprite.UpdatePosition(dt: Double);
begin
  Fdt := dt;
  FOldPos := FPos;

  FPos := FPos + FVec * Fdt;
end;

{ TSpriteEngine }

procedure TSpriteEngine.Clear;
var
  i: Integer;
begin
  if FList.Count = 0 then
    Exit;

  for i := FList.Count - 1 downto 0 do
  begin
    List[i].Free;
    FList.Delete(i);
  end;
end;

constructor TSpriteEngine.Create;
begin
  FList := TList.Create;
  Camera := TCamera.Create;
  Floor := TFloor.Create(Self);
  Camera.Pos := TVec2f.Create(0, 0);
end;

destructor TSpriteEngine.Destroy;
begin
  Camera.Free;
  FList.Free;
  Floor.Free;
  inherited;
end;

procedure TSpriteEngine.Add(ASprite: TBaseSprite);
begin
  FList.Add(ASprite);
end;

procedure TSpriteEngine.Delete(ASprite: TBaseSprite);
var
  Index: Integer;
begin
  Index := FList.IndexOf(ASprite);
  if Index <> -1 then
    FList.Delete(Index);
end;

procedure TSpriteEngine.Draw(AZIndex: Integer);
var
  i: Integer;
begin
  if FList.Count = 0 then
    Exit;

  for i := 0 to FList.Count - 1 do
    if (i < FList.Count) and (AZIndex = List[i].ZIndex) then
        List[i].Draw;
end;

function TSpriteEngine.GetCountList: Integer;
begin
  Result := FList.Count;
end;

function TSpriteEngine.GetListItem(Index: Integer): TBaseSprite;
begin
  Result := TBaseSprite(FList.Items[Index]);
end;

procedure TSpriteEngine.Process(dt: Double);
var
  i: Integer;
begin
  Camera.Process(dt);

  if FList.Count = 0 then
    Exit;

  for i :=  0 to FList.Count - 1 do
    List[i].UpdatePosition(dt);

  for i := FList.Count - 1 downto 0 do
    if i < FList.Count then
      if List[i].IsNeedToKill then
      begin
        List[i].Free;
        FList.Delete(i);
      end
      else
      List[i].Process(dt);
end;

{ TFloor }

constructor Tfloor.Create;
begin
  FSpriteEngine := ASpriteEngine;
  Refresh;
end;

function TFloor.GetDeadHeight: Double;
begin
  Result := FHeight + 1000;
end;

procedure TFloor.Draw;
var
  i: Integer;
begin
  Quad.SetBlendMode(qbmSrcAlpha);
  Quad.Rectangle(0, FHeight-FSpriteEngine.Camera.Pos.Y+PlayHero.Radius+16, Settings.WindowWidth, FHeight+1000-FSpriteEngine.Camera.Pos.Y, $AA000000);
  
  Quad.SetBlendMode(qbmSrcAlphaAdd);
  for i := 0 to Settings.WindowWidth div 16 - 1 do
    Textures.Beam.DrawRot(16 * i, FHeight-FSpriteEngine.Camera.Pos.Y+PlayHero.Radius+16, 0.0, 1, $FFFF9933, Random(8));
end;

procedure Tfloor.Refresh;
begin
  FHeight := 0.0;
  FSpeed := 0.0;
end;

procedure TFloor.UpdatePosition(dt: Double);
begin
  FSpeed := dt * 200;
  FHeight := FHeight - FSpeed;
  if PlayHero.Pos.Y + 2000 < FHeight then
    FHeight  := PlayHero.Pos.Y + 2000;
end;

end.
