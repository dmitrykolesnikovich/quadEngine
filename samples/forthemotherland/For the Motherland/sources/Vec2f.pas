unit Vec2f;

interface

uses
  Windows;

type
  TVec2i = record
    class operator Add(const a, b : TVec2i): TVec2i;
    class operator Subtract(const a, b : TVec2i): TVec2i;
    class operator Multiply(const a, b : TVec2i): TVec2i;
    class operator Multiply(const a : TVec2i; X : Single): TVec2i;
    class operator Negative(const X : TVec2i): TVec2i;
    constructor Create(X, Y : Single);
    function Distance(const X : TVec2i) : Single;
    function Dot(const X : TVec2i) : Single;
    function Lerp(const X : TVec2i; dist : Single) : TVec2i;
        // data
    case Integer of
      0 : (X, Y : Single);
      1 : (U, V : Single);
      2 : (a : array[0..1] of Single);
  end;

  PVec2f = ^TVec2f;
  TVec2f = record
    class operator Add(const a, b : TVec2f): TVec2f;
    class operator Implicit(const X : TVec2i): TVec2f;
    class operator Subtract(X : Single; const a : TVec2f): TVec2f;
    class operator Subtract(const a, b : TVec2f): TVec2f;
    class operator Multiply(const a, b : TVec2f): TVec2f;
    class operator Multiply(const a : TVec2f; X : Single): TVec2f;
    class operator Divide(const a, b : TVec2f): TVec2f;
    class operator Divide(const a : TVec2f; X : Single): TVec2f;
    class operator Negative(const X : TVec2f): TVec2f;
    constructor Create(X, Y : Single);
    function Distance(const X : TVec2f) : Single;
    function Dot(const X : TVec2f) : Single;
    function Lerp(const X : TVec2f; dist : Single) : TVec2f;
    function Normal: TVec2f;
    function Normalize: TVec2f;
    function Length: Single;
        // data
    case Integer of
      0 : (X, Y : Single);
      1 : (U, V : Single);
      2 : (a : array[0..1] of Single);
  end;

  TVec3f = record
    class operator Add(const a, b : TVec3f): TVec3f;
    class operator Subtract(const a, b : TVec3f): TVec3f;
    class operator Multiply(const a, b : TVec3f): TVec3f;
    class operator Multiply(const a : TVec3f; X : Single): TVec3f;
    class operator Negative(const X : TVec3f): TVec3f;
    constructor Create(X, Y, Z : Single);
    function Distance(const X : TVec3f) : Single;
    function Dot(const X : TVec3f) : Single;
    function Lerp(const X : TVec3f; dist : Single) : TVec3f;
        // data
    case Integer of
      0 : (X, Y, Z : Single);
      1 : (U, V, W : Single);
      2 : (R, G, B : Single);
      3 : (a : array[0..2] of Single);
  end;

implementation

  {TVec2f}

class operator TVec2f.Add(const a, b : TVec2f): TVec2f;
begin
  Result.X := a.X + b.X;
  Result.Y := a.Y + b.Y;
end;

class operator TVec2f.Implicit(const X : TVec2i): TVec2f;
begin
  Result.X := X.X;
  Result.Y := X.Y;
end;

class operator TVec2f.Subtract(X : Single; const a : TVec2f): TVec2f;
begin
  Result.X := X - a.X;
  Result.Y := X - a.Y;
end;

class operator TVec2f.Subtract(const a, b : TVec2f): TVec2f;
begin
  Result.X := a.X - b.X;
  Result.Y := a.Y - b.Y;
end;

class operator TVec2f.Multiply(const a, b : TVec2f): TVec2f;
begin
  Result.X := a.X * b.X;
  Result.Y := a.Y * b.Y;
end;

class operator TVec2f.Multiply(const a : TVec2f; X : Single): TVec2f;
begin
  Result.X := a.X * X;
  Result.Y := a.Y * X;
end;

class operator TVec2f.Divide(const a, b : TVec2f): TVec2f;
begin
  Result.X := a.X / b.X;
  Result.Y := a.Y / b.Y;
end;

class operator TVec2f.Divide(const a : TVec2f; X : Single): TVec2f;
begin
  Result.X := a.X / X;
  Result.Y := a.Y / X;
end;

class operator TVec2f.Negative(const X : TVec2f): TVec2f;
begin
  Result.X := -X.X;
  Result.Y := -X.Y;
end;

function TVec2f.Normal: TVec2f;
begin
  Result.X := -Self.Y;
  Result.Y := Self.X;
end;

function TVec2f.Normalize: TVec2f;
var
  d: Single;
begin
  if (abs(Self.X) < 0.0001) and (abs(Self.Y) <= 0.0001) then
    Result := TVec2f.Create(0,0)
  else begin
    d := 1.0 / Length;
    Result := TVec2f.Create(d * Self.X, d * Self.Y);
  end;
end;

function TVec2f.Distance(const X : TVec2f): Single;
begin
  Result := Sqrt(Sqr(X.X - Self.X) + Sqr(X.Y - Self.Y));
end;

function TVec2f.Dot(const X : TVec2f) : Single;
begin
  Result := X.X * Self.X + X.Y * Self.Y;
end;

constructor TVec2f.Create(X, Y : Single);
begin
  Self.X:= X;
  Self.Y:= Y;
end;

function TVec2f.Length: Single;
begin
  Result := Sqrt(Sqr(Self.X) + Sqr(Self.Y));
end;

function TVec2f.Lerp(const X : TVec2f; dist : Single): TVec2f;
begin
  Result := (X - Self) * dist + Self;
end;

  {TVec2i}

class operator TVec2i.Add(const a, b : TVec2i): TVec2i;
begin
  Result.X := a.X + b.X;
  Result.Y := a.Y + b.Y;
end;

class operator TVec2i.Subtract(const a, b : TVec2i): TVec2i;
begin
  Result.X := a.X - b.X;
  Result.Y := a.Y - b.Y;
end;

class operator TVec2i.Multiply(const a, b : TVec2i): TVec2i;
begin
  Result.X := a.X * b.X;
  Result.Y := a.Y * b.Y;
end;

class operator TVec2i.Multiply(const a : TVec2i; X : Single): TVec2i;
begin
  Result.X := a.X * X;
  Result.Y := a.Y * X;
end;

class operator TVec2i.Negative(const X : TVec2i): TVec2i;
begin
  Result.X := - X.X;
  Result.Y := - X.Y;
end;

function TVec2i.Distance(const X : TVec2i): Single;
begin
  Result := Sqrt(Sqr(X.X - Self.X) + Sqr(X.Y - Self.Y));
end;

function TVec2i.Dot(const X : TVec2i) : Single;
begin
  Result := X.X * Self.X + X.Y * Self.Y;
end;

constructor TVec2i.Create(X, Y : Single);
begin
  Self.X:= X;
  Self.Y:= Y;
end;

function TVec2i.Lerp(const X : TVec2i; dist : Single): TVec2i;
begin
  Result := (X - Self) * dist + Self;
end;

 {TVec3f}

class operator TVec3f.Add(const a, b : TVec3f): TVec3f;
begin
  Result.X := a.X + b.X;
  Result.Y := a.Y + b.Y;
  Result.Z := a.Z + b.Z;
end;

class operator TVec3f.Subtract(const a, b : TVec3f): TVec3f;
begin
  Result.X := a.X - b.X;
  Result.Y := a.Y - b.Y;
  Result.Z := a.Z - b.Z;
end;

class operator TVec3f.Multiply(const a, b : TVec3f): TVec3f;
begin
  Result.X := a.X * b.X;
  Result.Y := a.Y * b.Y;
  Result.Z := a.Z * b.Z;
end;

class operator TVec3f.Multiply(const a : TVec3f; X : Single): TVec3f;
begin
  Result.X := a.X * X;
  Result.Y := a.Y * X;
  Result.Z := a.Z * X;
end;

class operator TVec3f.Negative(const X : TVec3f): TVec3f;
begin
  Result.X := - X.X;
  Result.Y := - X.Y;
  Result.Z := - X.Z;
end;

function TVec3f.Distance(const X : TVec3f): Single;
begin
  Result := Sqrt(Sqr(X.X - Self.X) + Sqr(X.Y - Self.Y) + Sqr(X.Z - Self.Z));
end;

function TVec3f.Dot(const X : TVec3f) : Single;
begin
  Result := X.X * Self.X + X.Y * Self.Y + X.Z * Self.Z;
end;

constructor TVec3f.Create(X, Y, Z : Single);
begin
  Self.X:= X;
  Self.Y:= Y;
  Self.Z:= Z;
end;

function TVec3f.Lerp(const X : TVec3f; dist : Single): TVec3f;
begin
  Result := (X - Self) * dist + Self;     
end;

//=============================================================================
//
//=============================================================================
procedure SinCos(Theta: Single; out Sin, Cos: Single); assembler;
asm
  fld Theta
  fsincos
  fstp dword ptr [edx]
  fstp dword ptr [eax]
  fwait
end;






end.

