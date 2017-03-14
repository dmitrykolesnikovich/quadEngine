unit Cursor;

interface

uses
  Controls, QuadEngine, mSettings, Resources;

type
  TCursors = class
  private
    FQuad: IQuadRender;
  public
    Tip: Integer;
    constructor Create(AQuad: IQuadRender);
    procedure Draw(X, Y: Integer);
  end;

var
  Cursors: TCursors;

implementation

{ TCursors }

constructor TCursors.Create(AQuad: IQuadRender);
begin
  FQuad := AQuad;
end;

procedure TCursors.Draw(X, Y: Integer);
var
  Mouse: TMouse;
begin
  Textures.Cursor.Draw(X-32, Y-32, $FFFFFFFF, Tip);
end;

end.
