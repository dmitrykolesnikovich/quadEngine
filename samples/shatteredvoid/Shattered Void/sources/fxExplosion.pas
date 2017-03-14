unit fxExplosion;

interface

uses
  QuadEngine, Vec2F, Classes, XInput, windows, bass;

type
  TParticle = record
    Position: TVec2f;
    Vector: TVec2f;
    Angle: Double;
    Rotation: Double;
    Scale: Double;
    LiveTime: Double;
    Time: Double;
    Frame: byte;
  end;

  TExplosion = class
  private
    FQuadRender: IQuadRender;
    FTime: Double;
    FPosition: TVec2f;

    FFlames: array[0..4] of TParticle;
    FSparks: array[0..4] of TParticle;
    FDebris: array[0..8] of TParticle;
    FShockWave: TParticle;
  public
    constructor Create(AQuadRender: IQuadRender; X, Y: Double; Size: Double);
    procedure Draw;
    procedure Process(ADelta: Double);
  end;

  TExplosionManager = class
  private
    FQuadRender: IQuadRender;
    FExplosions: TList;
    FVibroTime: Double;
    procedure RemoveExplosion(index: Integer);
  public
    constructor Create(AQuadRender: IQuadRender);
    destructor Destroy; override;

    procedure Clear;
    procedure AddExplosion(X, Y: Double; Size: Double);
    procedure Draw;
    procedure Process(ADelta: Double);
  end;

var
  ExplosionManager: TExplosionManager;

implementation

uses
  Resources, defs;

function Animate(A, B, Time: Double): Double;
begin
  Result := (B - A) * (Time * Time * (3 - 2 * Time)) + A;
end;

{ TExplosion }

constructor TExplosion.Create(AQuadRender: IQuadRender; X, Y: Double; Size: Double);
var
  i: Integer;
begin
  BASS_SamplePlay(Sounds.Explosions[Random(4)]);

  FQuadRender := AQuadRender;

  FPosition := Tvec2F.Create(X, Y);

  for i := 0 to 4 do
  begin
    FFlames[i].Position := FPosition + TVec2f.Create(Random(200)/100 - 1, Random(200)/100 - 1).Normalize * 32;
    FFlames[i].Vector := TVec2f.Create(Random(200)/100 - 1, Random(200)/100 - 1).Normalize * 10;
    FFlames[i].LiveTime := 1.5/4;
    FFlames[i].Time := 0;
    FFlames[i].Angle := Random(360);
    FFlames[i].Rotation := (Random(200)/100 - 1) * 10;
    FFlames[i].Scale := Random(100)/100 * Size;
    FFlames[i].Frame := Random(4);
  end;

  for i := 0 to 4 do
  begin
    FSparks[i].Position := FPosition + TVec2f.Create(Random(200)/100 - 1, Random(200)/100 - 1).Normalize * 32;
    FSparks[i].Vector := TVec2f.Create(Random(200)/100 - 1, Random(200)/100 - 1).Normalize * 10;
    FSparks[i].LiveTime := 1.5;
    FSparks[i].Time := 0;
    FSparks[i].Angle := Random(360);
    FSparks[i].Rotation := (Random(200)/100 - 1) * 10;
    FSparks[i].Scale := Random(100)/100 * Size;
  end;


  for i := 0 to 8 do
  begin
    FDebris[i].Position := FPosition;
    FDebris[i].Vector := TVec2f.Create(Random(200)/100 - 1, Random(200)/100 - 1).Normalize * 100;
    FDebris[i].LiveTime := 1.5/3;
    FDebris[i].Time := 0;
    if FDebris[i].Vector.Y > 0 then
      FDebris[i].Angle := -FDebris[i].Vector.Angle(TVec2f.Create(-1, 0))
    else
      FDebris[i].Angle := FDebris[i].Vector.Angle(TVec2f.Create(-1, 0));
    FDebris[i].Rotation := (Random(200)/100 - 1) * 100;
    FDebris[i].Scale := (Random(100)/200 + 0.5) * Size;
    FDebris[i].Frame := Random(3);
  end;


  FShockWave.Position := FPosition;
  FShockWave.Vector := TVec2f.Create(0, 0);
  FShockWave.LiveTime := 1.5/3;
  FShockWave.Time := 0;
  FShockWave.Angle := Random(360);
  FShockWave.Rotation := 0;
  FShockWave.Scale := 0;
  FShockWave.Frame := 0;
end;

procedure TExplosion.Draw;
var
  i: Integer;
begin
 FQuadRender.SetBlendMode(qbmSrcAlphaAdd);

  for i := 0 to 8 do
  begin
    if FDebris[i].Time < FDebris[i].LiveTime then
      Textures.expSmokeTrail.DrawRotFrame(FDebris[i].Position.X, FDebris[i].Position.Y,
                                      FDebris[i].Angle, FDebris[i].Scale, FDebris[i].Frame,
                                      $00FFCC88 + Trunc(Animate(0, 0.7,  FDebris[i].Time * 3) * 255) shl 24)
  end;

  for i := 0 to 4 do
  begin
    if FFlames[i].Time < FFlames[i].LiveTime then
      Textures.expFlame.DrawRotFrame(FFlames[i].Position.X, FFlames[i].Position.Y,
                                     FFlames[i].Angle, FFlames[i].Scale, FFlames[i].Frame,
                                     $00FF8822 + Trunc(Animate(0, 1,  FFlames[i].Time * 4) * 255) shl 24);
  end;

  //FQuadRender.SetBlendMode(qbmSrcAlphaAdd);

  for i := 0 to 4 do
  begin
    if FSparks[i].Time < FSparks[i].LiveTime then
      Textures.expRoundSpark.DrawRot(FSparks[i].Position.X, FSparks[i].Position.Y,
                                     FSparks[i].Angle, FSparks[i].Scale,
                                     $00FFFFFF + Trunc(Animate(0, 1,  FSparks[i].Time * 4) * 255) shl 24);
  end;

  if FShockWave.Time < FShockWave.LiveTime then
    Textures.expShockwave.DrawRot(FShockWave.Position.X, FShockWave.Position.Y,
                                  FShockWave.Angle, FShockWave.Scale,
                                  $004488FF + Trunc(Animate(0, 0.5, FShockWave.Time * 3) * 255) shl 24);

end;

procedure TExplosion.Process(ADelta: Double);
var
  i: Integer;
begin
  FTime := FTime + ADelta;

  for i := 0 to 4 do
  begin
    FFlames[i].Position := FFlames[i].Position + FFlames[i].Vector * ADelta;
    FFlames[i].Time := FFlames[i].Time + ADelta;
    FFlames[i].Angle := FFlames[i].Angle + FFlames[i].Rotation * ADelta;
    FFlames[i].Scale := FFlames[i].Scale + 4 * Adelta;
  end;

  for i := 0 to 4 do
  begin
    FSparks[i].Position := FSparks[i].Position + FSparks[i].Vector * ADelta;
    FSparks[i].Time := FSparks[i].Time + ADelta;
    FSparks[i].Angle := FSparks[i].Angle + FSparks[i].Rotation * ADelta;
    FSparks[i].Scale := FSparks[i].Scale + Adelta;
  end;

  for i := 0 to 8 do
  begin
    FDebris[i].Position := FDebris[i].Position + FDebris[i].Vector * ADelta;
    FDebris[i].Time := FDebris[i].Time + ADelta;
  end;

  FShockWave.Time := FShockWave.Time + ADelta;
  FShockWave.Scale := FShockWave.Scale + 8 * Adelta;
end;

{ TExplosionManager }

procedure TExplosionManager.AddExplosion(X, Y: Double; Size: Double);
var
  Expl: TExplosion;
begin
  Expl := TExplosion.Create(FQuadRender, X, Y, Size);
  FExplosions.Add(Expl);

  FVibroTime := 0.5;

  inherited;
end;

procedure TExplosionManager.Clear;
var
  i: Integer;
begin
  if FExplosions.Count > 0 then
  for i := FExplosions.Count -1 downto 0 do
    RemoveExplosion(i);
end;

constructor TExplosionManager.Create(AQuadRender: IQuadRender);
begin
  FQuadRender := AQuadRender;
  FExplosions := TList.Create;
end;

destructor TExplosionManager.Destroy;
begin
  Clear;
  FExplosions.Free;
end;

procedure TExplosionManager.Draw;
var
  i: Integer;
begin
  if FExplosions.Count > 0 then
  for i := 0 to FExplosions.Count - 1 do
    TExplosion(FExplosions[i]).Draw;
end;

procedure TExplosionManager.Process(ADelta: Double);
var
  i: Integer;
  XInputVibration: TXInputVibration;
begin
  if FVibroTime > 0 then
    FVibroTime := FVibroTime - ADelta;

  if FVibroTime < 0 then
    FVibroTime := 0;


  if (IsGamepadUsed = 1) and IsForceFeedBack then
  begin
    XInputVibration.wLeftMotorSpeed := Trunc(FVibroTime * MAXSHORT * 2);
    XInputVibration.wRightMotorSpeed := Trunc(FVibroTime * MAXSHORT * 2);
    XInputSetState(0, @XInputVibration);
  end;

  if FExplosions.Count > 0 then
  begin
    for i := 0 to FExplosions.Count - 1 do
      TExplosion(FExplosions[i]).Process(ADelta);

    for i := FExplosions.Count - 1 downto 0 do
    if TExplosion(FExplosions[i]).FTime > 2 then
      RemoveExplosion(i);
  end;
end;

procedure TExplosionManager.RemoveExplosion(index: Integer);
begin
  TExplosion(FExplosions[index]).Free;
  FExplosions.Delete(index);
end;

end.
