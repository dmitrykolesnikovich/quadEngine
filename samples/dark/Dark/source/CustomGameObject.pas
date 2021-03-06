unit CustomGameObject;

interface

uses
  QuadEngine, Classes, Controls, Vec2f, mSettings;

type
  TCustomGameObject = class
  protected
    FQuad: IQuadRender;
    FPosition: TVec2f;
    FVector: TVec2f;
  public
    constructor Create(AQuadRender: IQuadRender);
    destructor Destroy; override;
    procedure Process(const dt: Double); virtual;
    procedure Draw(const dt: Double); virtual;

    property Position: TVec2f read FPosition write FPosition;
    property Vector: TVec2f read FVector write FVector;
  end;

implementation

{ TCustomGameObject }

constructor TCustomGameObject.Create(AQuadRender: IQuadRender);
begin
  FQuad := AQuadRender;
  FVector := TVec2f.Create(0,0);
end;

destructor TCustomGameObject.Destroy;
begin

  inherited;
end;

procedure TCustomGameObject.Draw(const dt: Double);
begin

end;

procedure TCustomGameObject.Process(const dt: Double);
begin

end;

end.
