unit Map;

interface

uses
  Windows, Vcl.Graphics, Math;

type
  TMapCell = (mcNone = 0,
              mcWall = 1,
              mcBoxEmpty  = 100,
              mcBoxExit = 101,
              mcBoxBonus = 102,
              mcEnemy = 200,
              mcStart = 255
             );

  TMap = class sealed
  const
    MaxWidth = 32;
    MaxHeight = 32;
  private
    FField: array[0..MaxWidth - 1, 0..MaxHeight - 1] of TMapCell;
    FWidth: Byte;
    FHeight: Byte;
    procedure SetHeight(const Value: Byte);
    procedure SetWidth(const Value: Byte);
    function GetField(x, y: Byte): TMapCell;
  public
    constructor Create;
    procedure Clear;
    procedure LoadFromFile(AFileName: string);
    property Width: Byte read FWidth write SetWidth;
    property Height: Byte read FHeight write SetHeight;
    property Field[x, y: Byte]: TMapCell read GetField;
  end;

implementation

{ TMap }

procedure TMap.Clear;
begin
  FillChar(FField[0], MaxWidth * MaxHeight, 0);
  FWidth := 0;
  FHeight := 0;
end;

constructor TMap.Create;
begin
  Clear;
end;

function TMap.GetField(x, y: Byte): TMapCell;
begin
  Result := FField[x, y];
end;

procedure TMap.LoadFromFile(AFileName: string);
var
  Bitmap: TBitmap;
  i, j: Integer;
begin
  Clear;

  Bitmap := TBitmap.Create;
  Bitmap.LoadFromFile(AFileName);

  Width := Bitmap.Width;
  Height := Bitmap.Height;

  for i := 0 to Width - 1 do
    for j := 0 to Height - 1 do
    begin
      case Bitmap.Canvas.Pixels[i, j] of
        $000000: FField[i, j] := mcNone;
        $FFFFFF: FField[i, j] := mcWall;
        $FF0000: FField[i, j] := mcEnemy;
        $00FF00: FField[i, j] := mcBoxEmpty;
        $00FFFF: FField[i, j] := mcBoxExit;
        $FFFF00: FField[i, j] := mcBoxBonus;
        $FF9933: FField[i, j] := mcStart;
      end;
    end;

  Bitmap.Free;
end;

procedure TMap.SetHeight(const Value: Byte);
begin
  FHeight := Min(Value, MaxHeight);
end;

procedure TMap.SetWidth(const Value: Byte);
begin
  FWidth := Min(Value, MaxWidth);
end;

end.
