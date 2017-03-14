unit Bullets;

interface

uses
  QuadEngine, Vec2F, Classes, XInput, windows, bass;

type
  TCustomBullet = class
  private
    FQuadRender: IQuadRender;
    FTime: Double;
    FPosition: TVec2f;
    FVector: TVec2f;
    FIsDead: Boolean;
  public
    constructor Create(AQuadRender: IQuadRender; X, Y: Double); virtual;

    procedure Draw; virtual; abstract;
    procedure Process(ADelta: Double); virtual;

    property Position: TVec2f read FPosition;
    property IsDead: Boolean read FIsDead;
  end;

  TSimpleBullet = class(TCustomBullet)
  const
    COOLDOWN = 0.1;
  public
    constructor Create(AQuadRender: IQuadRender; X, Y: Double); override;
    procedure Draw; override;
  end;

  TBulletManager = class
  private
    FIsLeft: Boolean;
    FQuadRender: IQuadRender;
    FBullets: TList;
    FCoolDown: Double;
    function GetBullet(index: integer): TCustomBullet;
    function GetBulletCount: Integer;
  public
    constructor Create(AQuadRender: IQuadRender);
    destructor Destroy; override;

    procedure RemoveBullet(index: Integer);
    procedure Clear;
    procedure AddBullet;
    procedure Draw;
    procedure Process(ADelta: Double);

    property Bullets[index: integer]: TCustomBullet read GetBullet;
    property BulletsCount: Integer read GetBulletCount;
  end;

var
  BulletManager: TBulletManager;

implementation

uses
  Resources, defs;

function Animate(A, B, Time: Double): Double;
begin
  Result := (B - A) * (Time * Time * (3 - 2 * Time)) + A;
end;

{ TCustomBullet }

constructor TCustomBullet.Create(AQuadRender: IQuadRender; X, Y: Double);
var
  i: Integer;
begin
  BASS_SamplePlay(Sounds.Shots[Random(4)]);

  FQuadRender := AQuadRender;

  FPosition := Tvec2F.Create(X, Y);

  FIsDead := false;
end;

procedure TCustomBullet.Process(ADelta: Double);
var
  i: Integer;
begin
  if FIsDead then
    Exit;

  if (FPosition.X - 128) > ScreenWidth then
    FIsDead := True;

  FTime := FTime + ADelta;
  FPosition := FPosition + FVector * ADelta;
end;

{ TBulletManager }

procedure TBulletManager.AddBullet;
var
  Bullet: TSimpleBullet;
  Y: Integer;
begin
  if FCoolDown < 0.1 then
   Exit;

  FCoolDown := 0;

  Y := Trunc(Players[0].Position.Y);

  if FIsLeft then
    Dec(Y, 24)
  else
    Inc(Y, 24);

  FIsLeft := not FIsLeft;

  Bullet := TSimpleBullet.Create(FQuadRender, Players[0].Position.X, Y);
  FBullets.Add(Bullet);

  inherited;
end;

procedure TBulletManager.Clear;
var
  i: Integer;
begin
  if FBullets.Count > 0 then
  for i := FBullets.Count -1 downto 0 do
    RemoveBullet(i);
end;

constructor TBulletManager.Create(AQuadRender: IQuadRender);
begin
  FQuadRender := AQuadRender;
  FBullets := TList.Create;
end;

destructor TBulletManager.Destroy;
begin
  Clear;
  FBullets.Free;
end;

procedure TBulletManager.Draw;
var
  i: Integer;
begin
  if FBullets.Count > 0 then
  for i := 0 to FBullets.Count - 1 do
    TCustomBullet(FBullets[i]).Draw;
end;

function TBulletManager.GetBullet(index: integer): TCustomBullet;
begin
  Result := TCustomBullet(FBullets[index]);
end;

function TBulletManager.GetBulletCount: Integer;
begin
  Result := FBullets.Count;
end;

procedure TBulletManager.Process(ADelta: Double);
var
  i: Integer;
  XInputVibration: TXInputVibration;
begin
  FCoolDown := FCoolDown + ADelta;

  if FBullets.Count > 0 then
  begin
    for i := 0 to FBullets.Count - 1 do
      TCustomBullet(FBullets[i]).Process(ADelta);

    for i := FBullets.Count - 1 downto 0 do
    if TCustomBullet(FBullets[i]).IsDead then
      RemoveBullet(i);
  end;
end;

procedure TBulletManager.RemoveBullet(index: Integer);
begin
  TCustomBullet(FBullets[index]).Free;
  FBullets.Delete(index);
end;

{ TSimpleBullet }

constructor TSimpleBullet.Create(AQuadRender: IQuadRender; X, Y: Double);
begin
  inherited;
  FVector := TVec2f.Create(1000, 0);
end;

procedure TSimpleBullet.Draw;
begin
  FQuadRender.SetBlendMode(qbmSrcAlphaAdd);

  Textures.Shot1.DrawRot(FPosition.X, FPosition.Y, 0, 1.0, $FFFFCC33);
end;

end.
