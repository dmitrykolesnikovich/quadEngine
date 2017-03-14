unit Collision_2d;

interface

uses
  Vec2f;

type
  TLineVec2f = record
    A, B: TVec2f;
  end;

  PPoint = ^TPoint;
  TPoint = record
    X, Y: Double;
  end;

  TLine = record
    X0, Y0, X1, Y1: Double;
  end;

  TCircle = record
    cX, cY, Radius: Double;
  end;

  TRect = record
    X, Y, W, H: Double;
  end;

  TMath = class
  private
    function ArcTan2(dx, dy : Double): Double;
    function Angle(X1, Y1, X2, Y2: Double): double;
  public
    function GetAngle(PointA, PointB: TVec2f): double;
    function GetDistance(PointA, PointB: TVec2f): double;
  end;

  TCollision = class
  private
    cosTable: array[0..360] of Single;
    sinTable: array[0..360] of Single;
    function CollPointInRect(X, Y : Double; const Rect : TRect): Boolean;
    function CollPointInCircle(X, Y : Single; const Circle : TCircle): Boolean;
    function CollVsLine(const A, B: TLine; ColPoint: PPoint): Boolean;
    function CollLineVsRect(const Line : TLine; const Rect: TRect; ColPoint: PPoint): Boolean;
    function CollLineVsCircle(const Line: TLine; const Circle: TCircle): Boolean;
    function CollLineVsCircleXY(const Line: TLine; const Circle: TCircle; Precision: Byte; ColPoint: PPoint): Boolean;
    function CollVsRect(const Rect1, Rect2 : TRect): Boolean;
    function CollRectInCircle(const Rect : TRect; const Circle : TCircle): Boolean;
    function CollRectVsCircle(const Rect : TRect; const Circle : TCircle): Boolean;
    function CollVsCircle(const Circle1, Circle2 : TCircle): Boolean;
    function CollCircleInCircle(const Circle1, Circle2 : TCircle): Boolean;
    function CollCircleInRect(const Circle : TCircle; const Rect : TRect): Boolean;

    function ToLine(const PointA, PointB: TVec2f): TLine;
    function ToRect(const RectA, RectB: TVec2f): TRect;
    function ToRectCentrePos(const RectA, RectB: TVec2f): TRect;
    function ToCircle(const Pos: TVec2f; ARadius: Double): TCircle;
  public
    constructor Create;

    function m_Cos(Angle : Integer): Single;
    function m_Sin(Angle : Integer): Single;

    function PointInRect(const Point, RectA, RectB: TVec2f): Boolean;
    function PointInCircle(const Point, CirclePos: TVec2f; const CircleRadius: Double): Boolean;

    function VsLine(const Line1A, Line1B, Line2A, Line2B: TVec2f; Var CollPoint: TVec2f): Boolean;
    function LineVsRect(const LineA, LineB, RectA, RectB: TVec2f; Var CollPoint: TVec2f): Boolean;
    function LineVsCircle(const LineA, LineB, CirclePos: TVec2f; const CircleRadius: Double): Boolean;
    function LineVsCircleXY(const LineA, LineB, CirclePos: TVec2f; const CircleRadius: Double; Precision: Byte; Var CollPoint: TVec2f): Boolean;

    function VsRect(const Rect1A, Rect1B, Rect2A, Rect2B: TVec2f): Boolean;
    function RectInCircle(const RectA, RectB, CirclePos: TVec2f; const CircleRadius: Double): Boolean;
    function RectVsCircle(const RectA, RectB, CirclePos: TVec2f; const CircleRadius: Double): Boolean;

    function VsCircle(const CirclePos1: TVec2f; const CircleRadius1: Double; const CirclePos2: TVec2f; const CircleRadius2: Double): Boolean;
    function CircleInCircle(const CirclePos1, CirclePos2: TVec2f; const CircleRadius1, CircleRadius2: Double): Boolean;
    function CircleInRect(const CirclePos: TVec2f; const CircleRadius: Double; const RectA, RectB: TVec2f): Boolean;
  end;

var
  Collision: TCollision;
  mMath: TMath;

implementation

function TCollision.PointInRect(const Point, RectA, RectB: TVec2f): Boolean;
begin
  Result := CollPointInRect(Point.X, Point.Y, ToRect(RectA, RectB));
end;

function TCollision.PointInCircle(const Point, CirclePos: TVec2f; const CircleRadius: Double): Boolean;
begin
  Result := CollPointInCircle(Point.X, Point.Y, ToCircle(CirclePos, CircleRadius));
end;

function TCollision.VsLine(const Line1A, Line1B, Line2A, Line2B: TVec2f; Var CollPoint: TVec2f): Boolean;
Var
  CPoint: TPoint;
begin
  Result := CollVsLine(ToLine(Line1A, Line1B), ToLine(Line2A, Line2B), @CPoint);
  CollPoint.X := CPoint.X;
  CollPoint.Y := CPoint.Y;
end;

function TCollision.LineVsRect(const LineA, LineB, RectA, RectB: TVec2f; Var CollPoint: TVec2f): Boolean;
Var
  CPoint: TPoint;
begin
  Result := CollLineVsRect(ToLine(LineA, LineB), ToRect(RectA, RectB), @CPoint);
  CollPoint.X := CPoint.X;
  CollPoint.Y := CPoint.Y;
end;

function TCollision.LineVsCircle(const LineA, LineB, CirclePos: TVec2f; const CircleRadius: Double): Boolean;
begin
  Result := CollLineVsCircle(ToLine(LineA, LineB), ToCircle(CirclePos, CircleRadius));
end;

function TCollision.LineVsCircleXY(const LineA, LineB, CirclePos: TVec2f; const CircleRadius: Double; Precision: Byte; Var CollPoint: TVec2f): Boolean;
Var
  CPoint: TPoint;
begin
  Result := CollLineVsCircleXY(ToLine(LineA, LineB), ToCircle(CirclePos, CircleRadius), Precision, @CPoint);
  CollPoint.X := CPoint.X;
  CollPoint.Y := CPoint.Y;
end;

function TCollision.VsRect(const Rect1A, Rect1B, Rect2A, Rect2B: TVec2f): Boolean;
begin
  Result := CollVsRect(ToRect(Rect1A, Rect1B), ToRect(Rect2A, Rect2B));
end;

function TCollision.RectInCircle(const RectA, RectB, CirclePos: TVec2f; const CircleRadius: Double): Boolean;
begin
  Result := CollRectInCircle(ToRect(RectA, RectB), ToCircle(CirclePos, CircleRadius));
end;

function TCollision.RectVsCircle(const RectA, RectB, CirclePos: TVec2f; const CircleRadius: Double): Boolean;
begin
  Result := CollRectVsCircle(ToRect(RectA, RectB), ToCircle(CirclePos, CircleRadius));
end;

function TCollision.VsCircle(const CirclePos1: TVec2f; const CircleRadius1: Double; const CirclePos2: TVec2f; const CircleRadius2: Double): Boolean;
begin
  Result := CollVsCircle(ToCircle(CirclePos1, CircleRadius1), ToCircle(CirclePos2, CircleRadius2));
end;

function TCollision.CircleInCircle(const CirclePos1, CirclePos2: TVec2f; const CircleRadius1, CircleRadius2: Double): Boolean;
begin
  Result := CollCircleInCircle(ToCircle(CirclePos1, CircleRadius1), ToCircle(CirclePos2, CircleRadius2));
end;

function TCollision.CircleInRect(const CirclePos: TVec2f; const CircleRadius: Double; const RectA, RectB: TVec2f): Boolean;
begin
  Result := CollCircleInRect(ToCircle(CirclePos, CircleRadius), ToRect(RectA, RectB));
end;

function TCollision.ToLine(const PointA, PointB: TVec2f): TLine;
begin
  with Result do
  begin
    X0 := PointA.X;
    Y0 := PointA.Y;
    X1 := PointB.X;
    Y1 := PointB.Y;
  end;
end;

function TCollision.ToCircle(const Pos: TVec2f; ARadius: Double): TCircle;
begin
  with Result do
  begin
    cX := Pos.X;
    cY := Pos.Y;
    Radius := ARadius;
  end;
end;

function TCollision.ToRect(const RectA, RectB: TVec2f): TRect;
begin
  with Result do
  begin
    X := RectA.X;
    Y := RectA.Y;
    W := RectB.X - RectA.X;
    H := RectB.Y - RectA.Y;
  end;
end;

function TCollision.ToRectCentrePos(const RectA, RectB: TVec2f): TRect;
begin
  with Result do
  begin
    X := RectA.X - RectB.X / 2;
    Y := RectA.Y - RectB.Y / 2;
    W := RectA.X + RectB.X / 2;
    H := RectA.Y + RectB.Y / 2;
  end;
end;

constructor TCollision.Create;
var
  i: Integer;
  rad_angle: Single;
begin
  for i := 0 to 360 do
    begin
      rad_angle := i * (pi / 180);
      cosTable[i] := cos(rad_angle);
      sinTable[i] := sin(rad_angle);
    end;
end;

function TCollision.m_Cos( Angle : Integer ) : Single;
begin
  if Angle > 360 Then
    DEC( Angle, ( Angle div 360 ) * 360 )
  else
    if Angle < 0 Then
      INC( Angle, ( abs( Angle ) div 360 + 1 ) * 360 );
  Result := cosTable[ Angle ];
end;

function TCollision.m_Sin( Angle : Integer ) : Single;
begin
  if Angle > 360 Then
    DEC( Angle, ( Angle div 360 ) * 360 )
  else
    if Angle < 0 Then
      INC( Angle, ( abs( Angle ) div 360 + 1 ) * 360 );
  Result := sinTable[ Angle ];
end;

function TCollision.CollPointInRect(X, Y: Double; const Rect: TRect): Boolean;
begin
  Result := (X >= Rect.X) and (X < Rect.X + Rect.W) and (Y >= Rect.Y) and (Y < Rect.Y + Rect.H);
end;

function TCollision.CollPointInCircle(X, Y: Single; const Circle: TCircle): Boolean;
begin
  Result := sqr(Circle.cX - X) + sqr(Circle.cY - Y) < sqr(Circle.Radius);
end;

function TCollision.CollVsLine(const A, B: TLine; ColPoint: PPoint): Boolean;
  var
    s, t, tmp : Single;
    s1, s2    : array[ 0..1 ] of Single;
begin
  Result := FALSE;

  s1[ 0 ] := A.x1 - A.x0;
  s1[ 1 ] := A.y1 - A.y0;
  s2[ 0 ] := B.x1 - B.x0;
  s2[ 1 ] := B.y1 - B.y0;

  s := ( s2[ 0 ] * ( -s1[ 1 ] ) - ( -s1[ 0 ] ) * s2[ 1 ] );
  if s <> 0 Then
    tmp := 1 / ( s2[ 0 ] * ( -s1[ 1 ] ) - ( -s1[ 0 ] ) * s2[ 1 ] )
  else
    exit;

  s := ( ( A.x0 - B.x0 ) * ( -s1[ 1 ] ) - ( -s1[ 0 ] ) * ( A.y0 - B.y0 ) ) * tmp;
  t := ( s2[ 0 ] * ( A.y0 - B.y0 ) - ( A.x0 - B.x0 ) * s2[ 1 ] ) * tmp;

  Result := ( s >= 0 ) and ( s <= 1 ) and ( t >= 0 ) and ( t <= 1 );

  if Assigned( ColPoint ) Then
    begin
      ColPoint.X := A.x0 + t * s1[ 0 ];
      ColPoint.Y := A.y0 + t * s1[ 1 ];
    end;
end;

function TCollision.CollLineVsRect(const Line : TLine; const Rect: TRect; ColPoint: PPoint): Boolean;
var
  line0: TLine;
begin
  if not Assigned(ColPoint) Then
    begin
      Result := CollPointInRect(Line.x0, Line.y0, Rect) or CollPointInRect(Line.x1, Line.y1, Rect);
      if not Result Then
        begin
          line0.x0 := Rect.X;
          line0.y0 := Rect.Y;
          line0.x1 := Rect.X + Rect.W;
          line0.y1 := Rect.Y + Rect.H;
          Result   := CollVsLine(Line, line0, ColPoint);
          if not Result Then
            begin
              line0.x0 := Rect.X;
              line0.y0 := Rect.Y + Rect.H;
              line0.x1 := Rect.X + Rect.W;
              line0.y1 := Rect.Y;
              Result   := CollVsLine(Line, line0, ColPoint);
            end;
        end;
    end else
      begin
        line0.x0 := Rect.X;
        line0.y0 := Rect.Y;
        line0.x1 := Rect.X + Rect.W;
        line0.y1 := Rect.Y;
        Result   := CollVsLine(Line, line0, ColPoint);
        if Result Then exit;

        line0.x0 := Rect.X + Rect.W;
        line0.y0 := Rect.Y;
        line0.x1 := Rect.X + Rect.W;
        line0.y1 := Rect.Y + Rect.H;
        Result   := CollVsLine(Line, line0, ColPoint);
        if Result Then exit;

        line0.x0 := Rect.X + Rect.W;
        line0.y0 := Rect.Y + Rect.H;
        line0.x1 := Rect.X;
        line0.y1 := Rect.Y + Rect.H;
        Result   := CollVsLine(Line, line0, ColPoint);
        if Result Then exit;

        line0.x0 := Rect.X;
        line0.y0 := Rect.Y;
        line0.x1 := Rect.X;
        line0.y1 := Rect.Y + Rect.H;
        Result   := CollVsLine(Line, line0, ColPoint);
      end;
end;

function TCollision.CollLineVsCircle(const Line: TLine; const Circle: TCircle): Boolean;
var
  p1, p2  : array[ 0..1 ] of Single;
  dx, dy  : Single;
  a, b, c : Single;
begin
  p1[ 0 ] := Line.x0 - Circle.cX;
  p1[ 1 ] := Line.y0 - Circle.cY;
  p2[ 0 ] := Line.x1 - Circle.cX;
  p2[ 1 ] := Line.y1 - Circle.cY;

  dx := p2[ 0 ] - p1[ 0 ];
  dy := p2[ 1 ] - p1[ 1 ];

  a := sqr( dx ) + sqr( dy );
  b := ( p1[ 0 ] * dx + p1[ 1 ] * dy ) * 2;
  c := sqr( p1[ 0 ] ) + sqr( p1[ 1 ] ) - sqr( Circle.Radius );

  if -b < 0 Then
    Result := c < 0
  else
    if -b < a * 2 Then
      Result := a * c * 4 - sqr( b )  < 0
    else
      Result := a + b + c < 0;
end;

function TCollision.CollLineVsCircleXY(const Line: TLine; const Circle: TCircle; Precision: Byte; ColPoint: PPoint): Boolean;
  var
    p1      : array of TPoint;
    line0   : TLine;
    i, t, k : Integer;
begin
  if not CollLineVsCircle( Line, Circle ) Then
    begin
      Result := FALSE;
      exit;
    end;
  Result := TRUE;

  t := 0;
  k := Round( 360 / Precision );
  SetLength( p1, Precision + 1 );
  for i := 0 to Precision - 1 do
    begin
      p1[ i ].X := Circle.cX + m_Cos( k * i ) * Circle.Radius;
      p1[ i ].Y := Circle.cY + m_Sin( k * i ) * Circle.Radius;
    end;
  p1[ Precision ].X := p1[ 0 ].X;
  p1[ Precision ].Y := p1[ 0 ].Y;


  for i := 0 to Precision - 1 do
    begin
      line0.x0 := p1[ i     ].X;
      line0.y0 := p1[ i     ].Y;
      line0.x1 := p1[ i + 1 ].X;
      line0.y1 := p1[ i + 1 ].Y;
      if CollVsLine(Line, line0, ColPoint) Then
        begin
          INC( t );
          if t = 2 Then exit;
        end;
    end;
end;

function TCollision.CollVsRect(const Rect1, Rect2 : TRect): Boolean;
begin
  Result := (Rect1.X + Rect1.W >= Rect2.X) and (Rect1.X <= Rect2.X + Rect2.W) and
    (Rect1.Y + Rect1.H >= Rect2.Y) and (Rect1.Y <= Rect2.Y + Rect2.H);
end;

function RectInRect(const Rect1, Rect2 : TRect): Boolean;
begin
  Result := (Rect1.X > Rect2.X) and (Rect1.X + Rect1.W < Rect2.X + Rect2.W) and
    (Rect1.Y > Rect2.Y) and (Rect1.Y + Rect1.H < Rect2.Y + Rect2.H);
end;

function TCollision.CollRectInCircle(const Rect : TRect; const Circle : TCircle): Boolean;
begin
  Result := CollPointInCircle( Rect.X, Rect.Y, Circle ) and CollPointInCircle( Rect.X + Rect.W, Rect.Y, Circle ) and
            CollPointInCircle( Rect.X + Rect.W, Rect.Y + Rect.H, Circle ) and CollPointInCircle( Rect.X, Rect.Y + Rect.H, Circle );
end;

function TCollision.CollRectVsCircle(const Rect : TRect; const Circle : TCircle): Boolean;
begin
  Result := (CollPointInCircle( Rect.X, Rect.Y, Circle ) or CollPointInCircle( Rect.X + Rect.W, Rect.Y, Circle ) or
            CollPointInCircle( Rect.X + Rect.W, Rect.Y + Rect.H, Circle ) or CollPointInCircle( Rect.X, Rect.Y + Rect.H, Circle ) ) or
            (CollPointInRect( Circle.cX - Circle.Radius, Circle.cY, Rect ) or CollPointInRect( Circle.cX + Circle.Radius, Circle.cY, Rect ) or
            CollPointInRect( Circle.cX, Circle.cY - Circle.Radius, Rect ) or CollPointInRect( Circle.cX, Circle.cY + Circle.Radius, Rect ) );
end;

function TCollision.CollVsCircle( const Circle1, Circle2 : TCircle ) : Boolean;
begin
  Result := sqr( Circle1.cX - Circle2.cX ) + sqr( Circle1.cY - Circle2.cY ) <= sqr( Circle1.Radius + Circle2.Radius );
end;

function TCollision.CollCircleInCircle( const Circle1, Circle2 : TCircle ) : Boolean;
begin
  Result := sqr( Circle1.cX - Circle2.cX ) + sqr( Circle1.cY - Circle2.cY ) < sqr( Circle1.Radius + Circle2.Radius );
end;

function TCollision.CollCircleInRect( const Circle : TCircle; const Rect : TRect ) : Boolean;
begin
  Result := CollPointInRect(Circle.cX + Circle.Radius, Circle.cY + Circle.Radius, Rect) and
            CollPointInRect(Circle.cX - Circle.Radius, Circle.cY + Circle.Radius, Rect) and
            CollPointInRect(Circle.cX - Circle.Radius, Circle.cY - Circle.Radius, Rect) and
            CollPointInRect(Circle.cX + Circle.Radius, Circle.cY - Circle.Radius, Rect);
end;

{ TMath }

function TMath.ArcTan2(dx, dy : Double): Double;
begin
  Result := abs(ArcTan(dy / dx) * (180 / pi));
end;

function TMath.Angle(X1, Y1, X2, Y2: Double): double;
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

function TMath.GetAngle(PointA, PointB: TVec2f): double;
begin
  Result := Angle(PointA.X, PointA.Y, PointB.X, PointB.Y);
end;

function TMath.GetDistance(PointA, PointB: TVec2f): double;
begin
  Result := sqrt(sqr(PointA.X - PointA.X) + sqr(PointA.Y - PointA.Y));
end;

initialization
  Collision := TCollision.Create;
  mMath := TMath.Create;

finalization
  if Assigned(Collision) then
    Collision.Free;
  if Assigned(mMath) then
    mMath.Free;

end.
