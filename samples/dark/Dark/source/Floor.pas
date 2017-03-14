unit Floor;

interface

uses
  QuadEngine, Classes, Controls, Resources, CustomGameObject, mSettings;

type
  TFloor = class(TCustomGameObject)
  private

  public
    constructor Create(AQuadRender: IQuadRender);
    destructor Destroy; override;
    procedure Process(const dt: Double); override;
    procedure Draw(const dt: Double); override;
  end;

implementation

{ TFloor }

constructor TFloor.Create(AQuadRender: IQuadRender);
begin

end;

destructor TFloor.Destroy;
begin

  inherited;
end;

procedure TFloor.Process(const dt: Double);
begin
  inherited;

end;

procedure TFloor.Draw(const dt: Double);
  function myMod(ANum1, ANum2: Single): single;
  begin
    Result := ANum1 - round(ANum1 / ANum2-0.5) * ANum2;
  end;
var
  x, y: Integer;
  Scale: Single;
begin
  inherited;
  Scale := 256 * Settings.GameScale;
  for y := 0 to Round(Settings.WindowHeight / Scale + 0.5) do
    for x := 0 to Round(Settings.WindowWidth / Scale + 0.5) do
      Textures.Floor.DrawRot(Scale * x - myMod(Settings.Camera.X, Scale) + Scale/2, Scale * y - myMod(Settings.Camera.Y, Scale) + Scale/2, 0, Settings.GameScale, );

end;

end.
