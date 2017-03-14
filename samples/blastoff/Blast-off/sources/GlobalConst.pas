unit GlobalConst;

interface

uses
  Vec2f;

const
  ZINDEX_BACKGROUND = -1;
  ZINDEX_BULLETS = 5;
  ZINDEX_HERO = 4;
  ZINDEX_STONE = 3;

  Grav: TVec2f = (X: 0; Y: 250);

var
  MaxHeight: Integer = 50;
  MaxHeightTimer: Double = 0.0;
  FloorHeight: Double = 500.0;

  MouseX, MouseY: Integer;

function AngleFromPoints(X1, Y1, X2, Y2: Double): Double;

implementation

function ArcTan2(dx, dy : Double): Double;
begin
  Result := abs(ArcTan(dy / dx) * (180 / pi));
end;

function AngleFromPoints(X1, Y1, X2, Y2: Double): Double;
var
  dx, dy : Single;
begin
  dx := (X1 - X2);
  dy := (Y1 - Y2);

  if dx = 0 Then
    begin
      if dy > 0 Then
        Result := 90
      else
        Result := 270;
      exit;
    end;

  if dy = 0 Then
    begin
      if dx > 0 Then
        Result := 0
      else
        Result := 180;
      exit;
    end;

  if (dx < 0) and (dy > 0) Then
    Result := 180 - ArcTan2(dx, dy)
  else
    if (dx < 0) and ( dy < 0 ) Then
      Result := 180 + ArcTan2(dx, dy)
    else
      if (dx > 0) and (dy < 0) Then
        Result := 360 - ArcTan2(dx, dy)
      else
        Result := ArcTan2(dx, dy)
end;

end.
