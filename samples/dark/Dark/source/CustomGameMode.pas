unit CustomGameMode;

interface

uses
  QuadEngine, Classes, Controls;

type
  TCustomGameMode = class
  protected
    FQuad: IQuadRender;
  public
    constructor Create(AQuadRender: IQuadRender);
    procedure Draw(dt: Double); virtual;
    procedure OnMouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); virtual;
    procedure Process(const dt: Double); virtual;
  end;

implementation

{ TCustomGameMode }

constructor TCustomGameMode.Create(AQuadRender: IQuadRender);
begin
  FQuad := AQuadRender;
end;

procedure TCustomGameMode.Draw(dt: Double);
begin

end;

procedure TCustomGameMode.OnMouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin

end;

procedure TCustomGameMode.Process(const dt: Double);
begin

end;

end.
