unit iCamera;

interface

uses
  Vec2f;

type
  TCamera = class
  private
    FPos, FVec: TVec2f;
    Timer: Double;
    FForce: Integer;
    function GetPos: TVec2f;
  public
    constructor Create;
    procedure Process(dt: Double);
    procedure Jutter(ATime: Double = 0.5; Force: Integer = 20);
    property Pos: TVec2f read GetPos write FPos;
    property PosX: Single read FPos.X write FPos.X;
    property PosY: Single read FPos.Y write FPos.Y;
  end;

implementation

{ TCamera }

constructor TCamera.Create;
begin
  FPos.Create(0, 0);
  FVec.Create(0, 0);
  Timer := 0.0;
end;

function TCamera.GetPos: TVec2f;
begin
  Result := FPos + FVec;
end;

procedure TCamera.Jutter(ATime: Double; Force: Integer);
begin
  Timer := ATime;
  FForce := Force;
end;

procedure TCamera.Process(dt: Double);
begin
  if Timer > 0.0 then
  begin
    Timer := Timer - dt;
    FVec.Create(Random(FForce), Random(FForce));
  end
  else
    begin
      Timer := 0.0;
      FVec.Create(0, 0);
    end;
end;

end.
