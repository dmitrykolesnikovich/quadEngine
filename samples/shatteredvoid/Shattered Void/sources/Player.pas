unit Player;

interface

uses
  Vec2f, QuadEngine;

type
  TPlayer = class
  private
    FPosition: TVec2f;
    FVector: TVec2f;
    FHealth: ShortInt;
    FIsDead: Boolean;
    FExplosionTime: Double;
    FExplosionCounter: Integer;
    FScore: Cardinal;
    function GetCurrentFrame: Byte;
  public
    constructor Create;

    procedure Initialize;
    procedure DrawBackground;
    procedure Draw;
    procedure SetVector(X, Y: Single);
    procedure Process(ADelta: Double);
    procedure ApplyDamage(ADamage: Byte);
    procedure AddScore(AScore: Cardinal);

    property CurrentFrame: Byte read GetCurrentFrame;
    property Position: TVec2f read FPosition;
    property Vector: TVec2f read FVector;
    property Health: ShortInt read FHealth;
    property Score: Cardinal read FScore;
  end;

implementation

Uses
  resources, defs, fxExplosion;

{ TPlayer }

procedure TPlayer.AddScore(AScore: Cardinal);
begin
  FScore := FScore + AScore;
end;

procedure TPlayer.ApplyDamage(ADamage: Byte);
begin
  FHealth:= FHealth - ADamage;
  if FHealth < 1 then
    FIsDead := True;
end;

constructor TPlayer.Create;
begin

end;

procedure TPlayer.Draw;
begin
  if FExplosionTime < -0.1 then
  begin
    qr.SetBlendMode(qbmSrcAlpha);
    Fonts.Console.TextOut(ScreenWidth/2+2, ScreenHeight/2+2, 1, 'Game Over', $FFCCCCCC, qfaCenter);
    Fonts.Console.TextOut(ScreenWidth/2, ScreenHeight/2, 1, 'Game Over', $FF000000, qfaCenter);
    Exit;
  end;


  qr.SetBlendMode(qbmSrcAlpha);
  Textures.Hero.DrawRotFrame(FPosition.X, FPosition.Y, 0, 1.0, GetCurrentFrame, $FFCCCCCC);

  if FVector.X >= 0  then
  begin
    qr.SetBlendMode(qbmSrcAlphaAdd);
    Textures.HeroFlame.DrawRotFrame(FPosition.X, FPosition.Y, 0, 1.0 - random(50)/1000, GetCurrentFrame, $A0FFFFFF + Random(64) shl 24);
  end;
end;

procedure TPlayer.DrawBackground;
begin
  if FExplosionTime < -0.1 then
    Exit;

  qr.SetBlendMode(qbmSrcAlpha);
  Textures.Hero.DrawRotFrame(FPosition.X, FPosition.Y, 0, 1.0, GetCurrentFrame, $FF000000);
end;

function TPlayer.GetCurrentFrame: Byte;
begin
  if (FVector.Y > -0.1) and (FVector.Y < 0.1) then
    Exit(3);

  if FVector.Y < -0.7 then
    Exit(0);

  if FVector.Y < -0.4 then
    Exit(1);

  if FVector.Y < -0.1 then
    Exit(2);

  if FVector.Y > 0.7 then
    Exit(5);

  if FVector.Y > 0.4 then
    Exit(4);

  if FVector.Y > 0.1 then
    Exit(3);
end;

procedure TPlayer.Initialize;
begin
  FPosition := TVec2f.Create(200, 400);
  FHealth := 45;
  FIsDead := False;
  FExplosionCounter := 0;
  FExplosionTime := 0;
end;

procedure TPlayer.Process(ADelta: Double);
begin
  if FIsDead then
  begin
    FExplosionTime := FExplosionTime - ADelta;

    if (FExplosionTime < 0) and (FExplosionCounter < 15) then
    begin
      ExplosionManager.AddExplosion(FPosition.X + Random(96)-48, FPosition.Y + Random(96)-48, 1.0);
      FExplosionTime := 0.1;
      Inc(FExplosionCounter)
    end;

    if FExplosionTime < -4 then
    begin
      gm.IsInitialized := False;
      gm := gmMenu;
    end;

    Exit;
  end;

  FPosition := FPosition + FVector * Adelta * 500;

  if FPosition.X < (64) then
    FPosition.X := 64
  else
    if FPosition.X > (ScreenWidth - 64) then
      FPosition.X := ScreenWidth - 64;


  if FPosition.Y < (64) then
    FPosition.Y := 64
  else
    if FPosition.Y > (ScreenHeight - 64) then
      FPosition.Y := ScreenHeight - 64;
end;

procedure TPlayer.SetVector(X, Y: Single);
begin
  FVector.X := X;
  FVector.Y := Y;
end;

end.
