unit Enemies;

interface

uses
  Classes, QuadEngine, Vec2f, Bullets, bass;

type
  TEnemyWave = record
    EnemyType: byte;
    Y: Word;
    Time: Word;
    Done: Boolean;
  end;

  TCustomEnemy = class
  protected
    FIsDead: Boolean;
    FQuadRender: IQuadRender;
    FPosition: TVec2f;
    FVector: TVec2f;
    FTime: Double;
    FLife: SmallInt;
    FSize: Integer;
  public
    constructor Create(AQuadRender: IQuadRender; X, Y: Double); virtual;

    procedure ApplyDamage(ADmg: Integer);
    procedure Die; virtual; abstract;
    procedure DrawLayer(ALayer: Byte); virtual; abstract;
    procedure Draw; virtual; abstract;
    procedure Process(ADelta: Double); virtual;
  end;

  TEnemyMine = class(TCustomEnemy)
  private
    FIsTargeting: Boolean;
    FTargetY: Double;
  public
    constructor Create(AQuadRender: IQuadRender; X, Y: Double); override;

    procedure Die; override;
    procedure DrawLayer(ALayer: Byte); override;
    procedure Process(ADelta: Double); override;
  end;

  TEnemyKamikaze = class(TCustomEnemy)
  private
    FIsTargeting: Boolean;
    FTargetY: Double;
  public
    constructor Create(AQuadRender: IQuadRender; X, Y: Double); override;

    procedure Die; override;
    procedure DrawLayer(ALayer: Byte); override;
    procedure Process(ADelta: Double); override;
  end;

  TEnemyDoubler = class(TCustomEnemy)
  private
    FIsTargeting: Boolean;
    FTargetY: Double;
  public
    constructor Create(AQuadRender: IQuadRender; X, Y: Double); override;

    procedure Die; override;
    procedure DrawLayer(ALayer: Byte); override;
    procedure Process(ADelta: Double); override;
  end;

  TEnemyManager = class
  strict private
    FQuadRender: IQuadRender;
    FEnemies: TList;
    FEnemyWaves: array of TEnemyWave;
    procedure RemoveEnemy(index: Integer);
  public
    constructor Create(AQuadRender: IQuadRender);
    destructor Destroy; override;

    procedure IWannaShootTheDog;
    procedure Clear;
    procedure AddMine(X, Y: Double);
    procedure AddKamikaze(X, Y: Double);
    procedure AddDoubler(X, Y: Double);
    procedure DrawLayer(ALayer: Byte);
    procedure Process(ADelta, ATime: Double);
    procedure LoadEnemyWaves(AFileName: string);
  end;

var
  EnemyManager: TEnemyManager;

implementation

Uses
  Resources, Player, defs, fxExplosion, Math;

function Animate(A, B, Time: Double): Double;
begin
  Result := (B - A) * (Time * Time * (3 - 2 * Time)) + A;
end;

{ TCustomEnemy }

procedure TCustomEnemy.ApplyDamage(ADmg: Integer);
begin
  FLife := FLife - ADmg;
  BASS_SamplePlay(Sounds.Hits[Random(4)]);
end;

constructor TCustomEnemy.Create(AQuadRender: IQuadRender; X, Y: Double);
begin
  FQuadRender := AQuadRender;
  FIsDead := False;
end;

procedure TCustomEnemy.Process(ADelta: Double);
begin
  FTime := FTime + ADelta;
  FPosition := FPosition + FVector * ADelta;

  if FLife < 0 then
    Die;
end;

{ TEnemyMine }

constructor TEnemyMine.Create(AQuadRender: IQuadRender; X, Y: Double);
begin
  inherited;

  FSize := 32;
  FLife := 100;
  FPosition := TVec2f.Create(X, Y);
  FIsTargeting := True;
  FVector := TVec2f.Create(-200, 0);

  FTargetY := Players[0].Position.Y;
end;

procedure TEnemyMine.Die;
begin
  FIsDead := True;
  ExplosionManager.AddExplosion(FPosition.X, FPosition.Y, 1);
  Players[0].AddScore(50);
end;

procedure TEnemyMine.DrawLayer(ALayer: Byte);
begin
  if FIsDead then
    Exit;

 // case ALayer of
 //   0: begin
   FQuadRender.RenderToTexture(False, Textures.postprocess);
      FQuadRender.SetBlendMode(qbmNone);
      FQuadRender.RenderToTexture(True, Textures.enemy_ball, 2, 0, True);
      Textures.postprocess.Draw(-FPosition.X + 64, -FPosition.Y + 64, $FFFFFFFF);
      FQuadRender.RenderToTexture(False, Textures.enemy_ball);
   FQuadRender.RenderToTexture(True, Textures.postprocess);
  //  end;
 //   255: begin

      FQuadRender.SetBlendMode(qbmSrcAlpha);
      Shaders.dudv.SetShaderState(True);
      Textures.enemy_ball.DrawRot(FPosition.X, FPosition.Y, 0.0, 0.75, $FFFFFFFF);
      Shaders.dudv.SetShaderState(False);
      FQuadRender.SetBlendMode(qbmSrcAlphaAdd);

     // if FVector.Y > 0 then
    //    Textures.enemy_ball_glow.DrawRot(FPosition.X, FPosition.Y, 0, 0.75, $FFFF0000 + (Trunc(FTime * 255) mod 256) shl 8)
    //  else
        Textures.enemy_ball_glow.DrawRot(FPosition.X, FPosition.Y, 0, 0.75, $FF000000 + (255 - Min(Trunc(Abs(FPosition.X - Players[0].Position.X) / 2), 255)) shl 16);
 //   end;
  //end;
end;

procedure TEnemyMine.Process(ADelta: Double);
begin
  inherited;

  if FIsDead then
    Exit;

  if FPosition.X < 0 then
    FIsDead := True;

  if FIsTargeting {and (abs(FPosition.X - Players[0].Position.X) < 400) }then
  begin
   // FTargetY := Players[0].Position.Y;
    FVector := (Players[0].Position - FPosition) * 0.75;
    FVector := FVector.Normalize * 700;
 //   if Abs(FVector.Y) < 10 then
      FIsTargeting := False;
  end;
//  else
  //  FVector.Y := 0;

  if FPosition.Distance(Players[0].Position) < 64 then
  begin
    Die;
    Players[0].ApplyDamage(13);
  end;
end;

{ TEnemyKamikaze }

constructor TEnemyKamikaze.Create(AQuadRender: IQuadRender; X, Y: Double);
begin
  inherited;

  FSize := 24;
  FLife := 20;
  FPosition := TVec2f.Create(X, Y);
  FIsTargeting := True;
  FVector := TVec2f.Create(-200, 0);

  FTargetY := Players[0].Position.Y;
end;

procedure TEnemyKamikaze.Die;
begin
  FIsDead := True;
  ExplosionManager.AddExplosion(FPosition.X, FPosition.Y, 0.5);
  Players[0].AddScore(25);
end;

procedure TEnemyKamikaze.DrawLayer(ALayer: Byte);
begin
  if FIsDead then
    Exit;

 // case ALayer of
 //   0: begin
   FQuadRender.RenderToTexture(False, Textures.postprocess);
      FQuadRender.SetBlendMode(qbmNone);
      FQuadRender.RenderToTexture(True, Textures.enemy_ball, 2, 0, True);
      Textures.postprocess.Draw(-FPosition.X + 64, -FPosition.Y + 64, $FFFFFFFF);
      FQuadRender.RenderToTexture(False, Textures.enemy_ball);
   FQuadRender.RenderToTexture(True, Textures.postprocess);
  //  end;
 //   255: begin

      FQuadRender.SetBlendMode(qbmSrcAlpha);
      Shaders.dudv.SetShaderState(True);
      Textures.enemy_ball.DrawRot(FPosition.X, FPosition.Y, 0.0, 0.5, $FFFFFFFF);
      Shaders.dudv.SetShaderState(False);
      FQuadRender.SetBlendMode(qbmSrcAlphaAdd);

     // if FVector.Y > 0 then
    //    Textures.enemy_ball_glow.DrawRot(FPosition.X, FPosition.Y, 0, 0.75, $FFFF0000 + (Trunc(FTime * 255) mod 256) shl 8)
    //  else
        Textures.enemy_ball_glow.DrawRot(FPosition.X, FPosition.Y, 0, 0.5, $FF0000FF + (255 - Min(Trunc(Abs(FPosition.X - Players[0].Position.X) / 2), 255)) shl 16);
 //   end;
  //end;
end;

procedure TEnemyKamikaze.Process(ADelta: Double);
begin
  inherited;

  if FIsDead then
    Exit;

  if FPosition.X < 0 then
    FIsDead := True;

  if FIsTargeting and ((FPosition.X - Players[0].Position.X) < 48) then
  begin
    FTargetY := Players[0].Position.Y;
    FVector.Y := (FTargetY - FPosition.Y) * 2;
  end
  else
    FVector.Y := 0;

  if FPosition.Distance(Players[0].Position) < 64 then
  begin
    Die;
    Players[0].ApplyDamage(5);
  end;
end;

{ TEnemyManager }

procedure TEnemyManager.AddDoubler(X, Y: Double);
var
  Enemy: TEnemyDoubler;
begin
  Enemy := TEnemyDoubler.Create(FQuadRender, X, Y);
  FEnemies.Add(Enemy);
end;

procedure TEnemyManager.AddKamikaze(X, Y: Double);
var
  Enemy: TEnemyKamikaze;
begin
  Enemy := TEnemyKamikaze.Create(FQuadRender, X, Y);
  FEnemies.Add(Enemy);
end;

procedure TEnemyManager.AddMine(X, Y: Double);
var
  Enemy: TEnemyMine;
begin
  Enemy := TEnemyMine.Create(FQuadRender, X, Y);
  FEnemies.Add(Enemy);
end;

procedure TEnemyManager.Clear;
var
  i: Integer;
begin
  if FEnemies.Count > 0 then
  for i := FEnemies.Count -1 downto 0 do
    RemoveEnemy(i);
end;

constructor TEnemyManager.Create(AQuadRender: IQuadRender);
begin
  FQuadRender := AQuadRender;
  FEnemies := TList.Create;
end;

destructor TEnemyManager.Destroy;
begin
  Clear;
  FEnemies.Free;
end;

procedure TEnemyManager.DrawLayer(ALayer: Byte);
var
  i: Integer;
begin
  if FEnemies.Count > 0 then
  for i := 0 to FEnemies.Count - 1 do
    TCustomEnemy(FEnemies[i]).DrawLayer(ALayer);
end;

procedure TEnemyManager.IWannaShootTheDog;
var
  i, j: Integer;
begin
  for i := FEnemies.Count - 1 downto 0 do
  if not TCustomEnemy(FEnemies[i]).FIsDead then
  begin
    for j := BulletManager.BulletsCount - 1 downto 0 do
    if not BulletManager.Bullets[j].IsDead then
    begin
      if BulletManager.Bullets[j].Position.Distance(TCustomEnemy(FEnemies[i]).FPosition) < TCustomEnemy(FEnemies[i]).FSize then
      begin
        BulletManager.RemoveBullet(j);
        TCustomEnemy(FEnemies[i]).ApplyDamage(40);
      end;
    end;
  end;

end;

procedure TEnemyManager.LoadEnemyWaves(AFileName: string);
var
  f: TextFile;
  Count: Integer;
begin
  AssignFile(f, AFileName);
  Reset(f);

  Count := 0;

  while not eof(f) do
  begin
    inc(Count);
    SetLength(FEnemyWaves, Count);
    Readln(f, FEnemyWaves[Count - 1].EnemyType, FEnemyWaves[Count - 1].Y, FEnemyWaves[Count - 1].Time);
    FEnemyWaves[Count - 1].Done := False;
  end;

  CloseFile(f);
end;

procedure TEnemyManager.Process(ADelta, ATime: Double);
var
  i: Integer;
begin
  if FEnemies.Count > 0 then
  begin
    for i := 0 to FEnemies.Count - 1 do
      TCustomEnemy(FEnemies[i]).Process(ADelta);

    for i := FEnemies.Count - 1 downto 0 do
    if TCustomEnemy(FEnemies[i]).FIsDead then
      RemoveEnemy(i);
  end;

  i := 0;
  while (i < (length(FEnemyWaves) - 1)) or (FEnemyWaves[i].Time/4 > Atime) do
  begin
    if not FEnemyWaves[i].Done and (FEnemyWaves[i].Time/4 < Atime) then
    begin
      FEnemyWaves[i].Done := True;
      case FEnemyWaves[i].EnemyType of
        1: AddMine(1280, FEnemyWaves[i].Y);
        2: AddDoubler(1300, FEnemyWaves[i].Y);
        3: AddKamikaze(1280, FEnemyWaves[i].Y);
      end;
    end;
    inc(i);
  end;

end;

procedure TEnemyManager.RemoveEnemy(index: Integer);
begin
  TCustomEnemy(FEnemies[index]).Free;
  FEnemies.Delete(index);
end;

{ TEnemyDoubler }

constructor TEnemyDoubler.Create(AQuadRender: IQuadRender; X, Y: Double);
begin
  inherited;

  FSize := 64;
  FLife := 300;
  FPosition := TVec2f.Create(X, Y);
  FIsTargeting := True;
  FVector := TVec2f.Create(-200, 0);

  FTargetY := Players[0].Position.Y;
end;

procedure TEnemyDoubler.Die;
begin
  FIsDead := True;
  ExplosionManager.AddExplosion(FPosition.X + random(64) - 32, FPosition.Y + random(64) - 32, 1.5);
  ExplosionManager.AddExplosion(FPosition.X + random(64) - 32, FPosition.Y + random(64) - 32, 1.5);

  Players[0].AddScore(75);
  EnemyManager.AddMine(FPosition.X - 32, FPosition.Y - 32);
  EnemyManager.AddMine(FPosition.X + 32, FPosition.Y + 32);
end;

procedure TEnemyDoubler.DrawLayer(ALayer: Byte);
begin
  if FIsDead then
    Exit;

 // case ALayer of
 //   0: begin
   FQuadRender.RenderToTexture(False, Textures.postprocess);
      FQuadRender.SetBlendMode(qbmNone);
      FQuadRender.RenderToTexture(True, Textures.enemy_ball, 2, 0, True);
      Textures.postprocess.Draw(-FPosition.X + 64, -FPosition.Y + 64, $FFFFFFFF);
      FQuadRender.RenderToTexture(False, Textures.enemy_ball);
   FQuadRender.RenderToTexture(True, Textures.postprocess);
  //  end;
 //   255: begin

      FQuadRender.SetBlendMode(qbmSrcAlpha);
      Shaders.dudv.SetShaderState(True);
      Textures.enemy_ball.DrawRot(FPosition.X, FPosition.Y, 0.0, 1.5, $FFFFFFFF);
      Shaders.dudv.SetShaderState(False);
      FQuadRender.SetBlendMode(qbmSrcAlphaAdd);

     // if FVector.Y > 0 then
    //    Textures.enemy_ball_glow.DrawRot(FPosition.X, FPosition.Y, 0, 0.75, $FFFF0000 + (Trunc(FTime * 255) mod 256) shl 8)
    //  else
        Textures.enemy_ball_glow.DrawRot(FPosition.X, FPosition.Y, 0, 1.5, $FF008800 + (255 - Min(Trunc(Abs(FPosition.X - Players[0].Position.X) / 2), 255)) shl 16);
 //   end;
  //end;
end;

procedure TEnemyDoubler.Process(ADelta: Double);
begin
  inherited;

  if FIsDead then
    Exit;

  if FPosition.X < -64 then
    FIsDead := True;

  if FPosition.Distance(Players[0].Position) < 96 then
  begin
    Die;
    Players[0].ApplyDamage(10);
  end;
end;

end.
