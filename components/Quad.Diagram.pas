unit Quad.Diagram;

interface

uses
  Winapi.Windows, Vcl.ExtCtrls, System.Classes, Vcl.Controls, System.Generics.Collections,
  System.SysUtils, System.Variants, Winapi.Messages, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Forms, Vcl.Graphics, Vcl.Themes, GDIPAPI, GDIPOBJ;

type
  TQuadDiagram = class;
  TQuadDiagramLinePointItem = class;
  TQuadDiagramLineItem = class;

  TQuadPointChangeEvent = procedure(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem) of object;

  //
  TQuadDiagramLinePointItem = class(TCollectionItem)
  private
    FX: Double;
    FY: Double;
    FColor: TColor;
    procedure SetX(const Value: Double);
    procedure SetY(const Value: Double);
    procedure SetColor(const Value: TColor);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property X: Double read FX write SetX;
    property Y: Double read FY write SetY;
    property Color: TColor read FColor write SetColor;
  end;
  //
  TQuadDiagramLinePointCollection = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TQuadDiagramLinePointItem;
    procedure SetItem(Index: Integer; const Value: TQuadDiagramLinePointItem);
  protected
    procedure Update(Item: TCollectionItem); override;
    function GetOwner: TQuadDiagramLineItem;
  public
    constructor Create(AOwner: TQuadDiagramLineItem);
    destructor Destroy; override;
    function Add: TQuadDiagramLinePointItem; overload;
    function Add(X, Y: Double): TQuadDiagramLinePointItem; overload;
    property Items[Index: Integer]: TQuadDiagramLinePointItem read GetItem write SetItem; default;
    function Insert(Index: Integer): TQuadDiagramLinePointItem;
  end;
  //
  TQuadDiagramLineItem = class(TCollectionItem)
  private
    FColor: TColor;
    FPoints: TQuadDiagramLinePointCollection;
    FWidth: Integer;
    FStyle: TDashStyle;
    FEnabled: Boolean;
    FCaption: String;
    procedure SetColor(const Value: TColor);
    procedure SetPoints(const Value: TQuadDiagramLinePointCollection);
    function GetPoints: TQuadDiagramLinePointCollection;
    procedure SetWidth(const Value: Integer);
    procedure SetStyle(const Value: TDashStyle);
    procedure SetEnabled(const Value: Boolean);
    procedure SetCaption(const Value: String);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property Color: TColor read FColor write SetColor;
    property Points: TQuadDiagramLinePointCollection read GetPoints write SetPoints;
    property Width: Integer read FWidth write SetWidth;
    property Style: TDashStyle read FStyle write SetStyle;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property Caption: String read FCaption write SetCaption;
  end;
  //
  TQuadDiagramLineCollection = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TQuadDiagramLineItem;
    procedure SetItem(Index: Integer; const Value: TQuadDiagramLineItem);
  protected
    procedure Update(Item: TCollectionItem); override;
    function GetOwner: TQuadDiagram;
  public
    constructor Create(AOwner: TQuadDiagram);
    destructor Destroy; override;
    function Add: TQuadDiagramLineItem;
    property Items[Index: Integer]: TQuadDiagramLineItem read GetItem write SetItem; default;
  end;
  //
  TQuadDiagramStyle = class(TPersistent)
  private
    FOwner: TQuadDiagram;
    FBackground1: TColor;
    FBackground2: TColor;
    FGridLine: TColor;
    FAxis: TColor;
    FAxisTitle: TColor;
    FGradient: TLinearGradientMode;
    FLegendVisible: Boolean;
    FLegendColumns: Integer;
    procedure SetGridLine(const Value: TColor);
    procedure SetAxis(const Value: TColor);
    procedure SetAxisTitle(const Value: TColor);
    procedure SetBackground1(const Value: TColor);
    procedure SetBackground2(const Value: TColor);
    procedure SetGradient(const Value: TLinearGradientMode);
    procedure SetLegendColumns(const Value: Integer);
    procedure SetLegendVisible(const Value: Boolean);
  public
    constructor Create(AOwner: TQuadDiagram);
    procedure Assign(ASource: TPersistent); override;
    procedure RefreshSystemStyle;
  published
    property Background1: TColor read FBackground1 write SetBackground1;
    property Background2: TColor read FBackground2 write SetBackground2;
    property GridLine: TColor read FGridLine write SetGridLine;
    property Axis: TColor read FAxis write SetAxis;
    property AxisTitle: TColor read FAxisTitle write SetAxisTitle;
    property Gradient: TLinearGradientMode read FGradient write SetGradient;
    property LegendVisible: Boolean read FLegendVisible write SetLegendVisible;
    property LegendColumns: Integer read FLegendColumns write SetLegendColumns;
  end;
  //
  TQuadDiagramAxis = class(TPersistent)
  private
    FOwner: TQuadDiagram;
    FName: String;
    FFormat: String;
    FMinValue: Single;
    FMaxValue: Single;
    FGridSize: Single;
    FLowMin: Single;
    FLowMax: Single;
    FHighMin: Single;
    FHighMax: Single;
  public
    constructor Create(AOwner: TQuadDiagram);
    procedure Assign(ASource: TPersistent); override;
    procedure SetName(Value: String);
    procedure SetFormat(Value: String);
    procedure SetMinValue(Value: Single);
    procedure SetMaxValue(Value: Single);
    procedure SetGridSize(Value: Single);
    procedure SetLowMin(Value: Single);
    procedure SetLowMax(Value: Single);
    procedure SetHighMin(Value: Single);
    procedure SetHighMax(Value: Single);
  published
    property Name: String read FName write SetName;
    property Format: String read FFormat write SetFormat;
    property MinValue: Single read FMinValue write SetMinValue;
    property MaxValue: Single read FMaxValue write SetMaxValue;
    property GridSize: Single read FGridSize write SetGridSize;
    property LowMin: Single read FLowMin write SetLowMin;
    property LowMax: Single read FLowMax write SetLowMax;
    property HighMin: Single read FHighMin write SetHighMin;
    property HighMax: Single read FHighMax write SetHighMax;
  end;
  //
  TQuadDiagram = class(TCustomControl)
  private
    FUpdateCount: Integer;
    FBg: TBitmap;
    FIsDisable: Boolean;
    FGraphics: TGPGraphics;
    FPen: TGPPen;
    FBrush: TGPSolidBrush;
    FBackground: TGPLinearGradientBrush;
    FFont: TGPFont;
    FFontFamily: TGPFontFamily;

    FLineMouseMove: Boolean;
    FLineMouseMoveDraw: Boolean;
    FPointMouseMove: Boolean;
    FLineMouseMoveIndex: Integer;
    FPointMouseMoveIndex: Integer;
    FMouse: TGPPointF;
    FPointSelected: TQuadDiagramLinePointItem;
    FMaxNotPointSelected: TQuadDiagramLinePointItem;
    FMinNotPointSelected: TQuadDiagramLinePointItem;
    FPosition: Double;

    FAxisV: TQuadDiagramAxis;
    FAxisH: TQuadDiagramAxis;

    FPaintRect: TRect;
    FPaintWidth: Integer;
    FPaintHeight: Integer;
    FStyle: TQuadDiagramStyle;
    FLines: TQuadDiagramLineCollection;
    FRepaint: Boolean;

    FOnPointChange: TQuadPointChangeEvent;
    FOnPointAdd: TQuadPointChangeEvent;
    FOnPointDelete: TQuadPointChangeEvent;

    procedure DrawGrid;
    procedure DrawGraf;
    procedure DrawPosition;
    procedure DrawLine(ALine: TQuadDiagramLineItem);
    procedure DrawSegment(pen: TGPPen; x1, y1, x2, y2: Single);
    procedure DrawPoint(APoint: TQuadDiagramLinePointItem);
    procedure SetStyle(const Value: TQuadDiagramStyle);
    procedure SetLines(const Value: TQuadDiagramLineCollection);
    function PointToGridPoint(APoint: TQuadDiagramLinePointItem): TGPPointF;
    procedure GridPointToPoint(APoint: TQuadDiagramLinePointItem; X, Y: Double);
    function GetGPRect: TGPRect;
    function PointMouseMove(const Point: TGPPointF): Boolean;
    function LineMouseMove(const Point1, Point2: TGPPointF): Boolean;
    procedure SetLineMouseMove(AMove: Boolean);
    procedure SetPointMouseMove(AMove: Boolean);
    procedure SetPosition(const Value: Double);
    procedure MouseLeave(var Msg: TMessage); message CM_MouseLeave;
    function GetValueInPosition(ALine: TQuadDiagramLineItem; APosition: Double): Double;
    procedure SetAxisV(const Value: TQuadDiagramAxis);
    procedure SetAxisH(const Value: TQuadDiagramAxis);
    procedure SetPointSelected(const Value: TQuadDiagramLinePointItem);
    property PointSelected: TQuadDiagramLinePointItem read FPointSelected write SetPointSelected;
  protected
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Repaint; override;
    procedure DisableControl;
    procedure EnableControl;
  published
    property Visible;
    property Align;
    property Anchors;
    property PaintRect: TRect read FPaintRect write FPaintRect;
    property Style: TQuadDiagramStyle read FStyle write SetStyle;
    property Lines: TQuadDiagramLineCollection read FLines write SetLines;
    property Position: Double read FPosition write SetPosition;
    function GetValue(ALine: Integer): Double;
    procedure BeginUpdate;
    procedure EndUpdate;

    property AxisV: TQuadDiagramAxis read FAxisV write SetAxisV;
    property AxisH: TQuadDiagramAxis read FAxisH write SetAxisH;

    property OnPointChange: TQuadPointChangeEvent read FOnPointChange write FOnPointChange;
    property OnPointAdd: TQuadPointChangeEvent read FOnPointAdd write FOnPointAdd;
    property OnPointDelete: TQuadPointChangeEvent read FOnPointDelete write FOnPointDelete;
  end;

implementation

uses
  Math;

function ColorToARGB(AColor: TColor; Alpha: byte = 255): DWORD;
begin
  AColor := ColorToRgb(AColor);
  result := MakeColor(Alpha, GetRValue(AColor), GetGValue(AColor), GetBValue(AColor));
end;

{ TQuadDiagram }

constructor TQuadDiagram.Create(AOwner: TComponent);
begin
  inherited;
  FUpdateCount := 0;
  FIsDisable := False;
  FBg := TBitmap.Create;
  FBg.Width := 0;
  FBg.Height := 0;
  //ControlStyle := ControlStyle + [csAcceptsControls];
  FStyle := TQuadDiagramStyle.Create(Self);
  FLines := TQuadDiagramLineCollection.Create(Self{, TQuadDiagramLineItem});
  FAxisV := TQuadDiagramAxis.Create(Self);
  FAxisH := TQuadDiagramAxis.Create(Self);
  DoubleBuffered := True;

  FAxisV.Name := 'Angle, �';
  FAxisH.Name := 'Life, %';

  FAxisH.MaxValue := 100;
  FAxisV.MaxValue := 50;

  Width := 300;
  Height := 200;
  FLineMouseMove := False;
  FPointMouseMove := False;
  FPosition := -1;

  FPointSelected := nil;
  FMaxNotPointSelected := nil;
  FMinNotPointSelected := nil;

  FRepaint := False;
end;

destructor TQuadDiagram.Destroy;
begin
  FBg.Free;
  FLines.Free;
  FStyle.Free;
  FAxisV.Free;
  FAxisH.Free;
  inherited;
end;

procedure TQuadDiagram.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TQuadDiagram.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then
    Repaint;
end;

procedure TQuadDiagram.Paint;
begin
  if FIsDisable or (FUpdateCount > 0) then
    Exit;

  inherited;
  FGraphics := TGPGraphics.Create(Canvas.Handle);
  FGraphics.SetSmoothingMode(SmoothingModeAntiAlias);

  FPaintRect.Left := 30;
  FPaintRect.Top := 22;
  if FStyle.LegendVisible then
    FPaintRect.Bottom := Height - 28 - Round(FLines.Count / FStyle.LegendColumns) * 20
  else
    FPaintRect.Bottom := Height - 28;
  FPaintRect.Right := Width - 24;

  FPaintWidth := FPaintRect.Right - FPaintRect.Left;
  FPaintHeight := FPaintRect.Bottom - FPaintRect.Top;

  if (FPaintWidth <= 0) or (FPaintHeight <= 0) then
  begin
    Canvas.Pen.Style := psClear;
    Canvas.Rectangle(0, 0, Width, Height);
    Exit;
  end;

  if FRepaint or (FBg.Width <> Width) or (FBg.Height <> Height) then
    DrawGrid;

  Canvas.Draw(0, 0, FBg);

  DrawGraf;
  DrawPosition;

  FGraphics.Free;
end;

function TQuadDiagram.LineMouseMove(const Point1, Point2: TGPPointF): Boolean;
var
  p1, p2: TGPPointF;
  dx, dy: Double;
  a, b, c: Double;
begin
  p1.X := Point1.X - FMouse.X;
  p1.Y := Point1.Y - FMouse.Y;
  p2.X := Point2.X - FMouse.X;
  p2.Y := Point2.Y - FMouse.Y;
  dx := p2.X - p1.X;
  dy := p2.Y - p1.Y;
  a := sqr(dx) + sqr(dy);
  b := (p1.X * dx + p1.Y * dy) * 2;
  c := sqr(p1.X) + sqr(p1.Y) - sqr(3);
  if -b < 0 Then
    Result := c < 0
  else
    if -b < a * 2 Then
      Result := a * c * 4 - sqr(b)  < 0
    else
      Result := a + b + c < 0;
end;

function TQuadDiagram.PointMouseMove(const Point: TGPPointF): Boolean;
begin
  Result := sqr(Point.X - FMouse.X) + sqr(Point.Y - FMouse.Y) < 16;
end;

function TQuadDiagram.PointToGridPoint(APoint: TQuadDiagramLinePointItem): TGPPointF;
begin
  Result.X := FPaintWidth / (FAxisH.MaxValue - FAxisH.MinValue) * (APoint.X - FAxisH.MinValue) + FPaintRect.Left;
  Result.Y := FPaintRect.Bottom - FPaintHeight / (FAxisV.MaxValue - FAxisV.MinValue) * (APoint.Y - FAxisV.MinValue);
end;

procedure TQuadDiagram.GridPointToPoint(APoint: TQuadDiagramLinePointItem; X, Y: Double);
begin
  APoint.X := ((FAxisH.MaxValue - FAxisH.FMinValue) / FPaintWidth * (X - FPaintRect.Left)) + FAxisH.MinValue;
  APoint.Y := ((FAxisV.MaxValue - FAxisV.FMinValue) / FPaintHeight * (FPaintHeight - Y + FPaintRect.Top)) + FAxisV.MinValue;
end;

procedure TQuadDiagram.Repaint;
begin
  FRepaint := True;
  inherited;
end;

procedure TQuadDiagram.SetPointMouseMove(AMove: Boolean);
var
  temp: Boolean;
begin
  temp := FPointMouseMove;
  FPointMouseMove := AMove;
  if FPointMouseMove or (AMove <> temp) then
  begin
    FLineMouseMove := AMove;
    Repaint;
  end;
end;

procedure TQuadDiagram.SetLineMouseMove(AMove: Boolean);
var
  temp: Boolean;
begin
  temp := FLineMouseMove;
  FLineMouseMove := AMove;
  if FLineMouseMove or (AMove <> temp) then
    Repaint;
end;

procedure TQuadDiagram.SetLines(const Value: TQuadDiagramLineCollection);
begin
  FLines.Assign(Value);
end;

procedure TQuadDiagram.SetStyle(const Value: TQuadDiagramStyle);
begin
  FStyle.Assign(Value);
end;

procedure TQuadDiagram.SetAxisV(const Value: TQuadDiagramAxis);
begin
  FAxisV.Assign(Value);
end;

procedure TQuadDiagram.SetAxisH(const Value: TQuadDiagramAxis);
begin
  FAxisH.Assign(Value);
end;

procedure TQuadDiagram.DrawGrid;
var
  Position: Double;
  GridSize: Double;
  GridValue: Double;
  Str: String;
  Points: TPointFDynArray;
  FontFormat: TGPStringFormat;
  Graphics: TGPGraphics;
begin
  FRepaint := False;
  FBg.Width := Width;
  FBg.Height := Height;

  Graphics := TGPGraphics.Create(FBg.Canvas.Handle);
  Graphics.SetSmoothingMode(SmoothingModeAntiAlias);

  FBackground := TGPLinearGradientBrush.Create(GetGPRect, ColorToARGB(FStyle.Background1),
                                               ColorToARGB(FStyle.Background2), FStyle.Gradient);
  Graphics.FillRectangle(FBackground, 0, 0, Width, Height);
  FBackground.Free;
  FPen := TGPPen.Create(ColorToARGB(FStyle.GridLine), 1);
  FPen.SetDashStyle(DashStyleDash);

//  Graphics.DrawLine(FPen, 0, 0, Width, 0);

  FFontFamily := TGPFontFamily.Create('Verdana');
  FFont := TGPFont.Create(FFontFamily, 12, FontStyleRegular, UnitPixel);
  FBrush := TGPSolidBrush.Create(ColorToARGB(FStyle.AxisTitle));
  Graphics.DrawString(FAxisV.Name, Length(FAxisV.Name), FFont, MakePoint(FPaintRect.Left + 8.0, FPaintRect.Top - 18.0), FBrush);
  FontFormat := TGPStringFormat.Create;
  FontFormat.SetAlignment(StringAlignmentFar);
  Graphics.DrawString(FAxisH.Name, Length(FAxisH.Name), FFont, MakePoint(FPaintRect.Right+6, FPaintRect.Bottom + 11.0), FontFormat, FBrush);
  FontFormat.Free;
  FFont.Free;

  {TDashStyle
    DashStyleSolid,          // 0
    DashStyleDash,           // 1
    DashStyleDot,            // 2
    DashStyleDashDot,        // 3
    DashStyleDashDotDot,     // 4
    DashStyleCustom          // 5   }
  FFont := TGPFont.Create(FFontFamily, 8, FontStyleRegular, UnitPixel);
  FontFormat := TGPStringFormat.Create;

  FontFormat.SetAlignment(StringAlignmentCenter);
   /////////////////////////////////////////////
{  Str := FormatFloat(FAxisH.Format, FAxisV.FHighMax);
  Graphics.DrawString(Str, Length(Str), FFont, MakePoint(FPaintRect.Left + 100.0, 30), FontFormat, FBrush);
  Str := FormatFloat(FAxisH.Format, FAxisV.FMaxValue);
  Graphics.DrawString(Str, Length(Str), FFont, MakePoint(FPaintRect.Left + 100.0, 45), FontFormat, FBrush);
  Str := FormatFloat(FAxisH.Format, FAxisV.FHighMin);
  Graphics.DrawString(Str, Length(Str), FFont, MakePoint(FPaintRect.Left + 100.0, 60), FontFormat, FBrush);

  Str := FormatFloat(FAxisH.Format, FAxisV.FLowMax);
  Graphics.DrawString(Str, Length(Str), FFont, MakePoint(FPaintRect.Left + 60.0, 30), FontFormat, FBrush);
  Str := FormatFloat(FAxisH.Format, FAxisV.FMinValue);
  Graphics.DrawString(Str, Length(Str), FFont, MakePoint(FPaintRect.Left + 60.0, 45), FontFormat, FBrush);
  Str := FormatFloat(FAxisH.Format, FAxisV.FLowMin);
  Graphics.DrawString(Str, Length(Str), FFont, MakePoint(FPaintRect.Left + 60.0, 60), FontFormat, FBrush);
                   }
  if Assigned(PointSelected) then
  begin
    Str := FormatFloat(FAxisH.Format, PointSelected.Y);
    Graphics.DrawString(Str, Length(Str), FFont, MakePoint(FPaintRect.Left + 200.0, 30), FontFormat, FBrush);
  end;
  if Assigned(FMaxNotPointSelected) then
  begin
    Str := FormatFloat(FAxisH.Format, FMaxNotPointSelected.Y);
    Graphics.DrawString(Str, Length(Str), FFont, MakePoint(FPaintRect.Left + 200.0, 45), FontFormat, FBrush);
  end;
  if Assigned(FMinNotPointSelected) then
  begin
    Str := FormatFloat(FAxisH.Format, FMinNotPointSelected.Y);
    Graphics.DrawString(Str, Length(Str), FFont, MakePoint(FPaintRect.Left + 200.0, 60), FontFormat, FBrush);
  end;

     /////////////////////////////////////////
  GridSize := (FPaintRect.Right - FPaintRect.Left) / (FAxisH.MaxValue - FAxisH.MinValue) * FAxisH.GridSize;
  GridValue := abs(Frac(FAxisH.MinValue / FAxisH.GridSize));
  Position := GridValue * GridSize;
  GridValue := FAxisH.MinValue - (1 - GridValue) * FAxisH.GridSize + FAxisH.GridSize;
  while GridValue <= FAxisH.MaxValue do
  begin
    Str := FormatFloat(FAxisH.Format, GridValue);
    Graphics.DrawLine(FPen, FPaintRect.Left + Position, FPaintRect.Top, FPaintRect.Left + Position, FPaintRect.Bottom);
    Graphics.DrawString(Str, Length(Str), FFont, MakePoint(FPaintRect.Left + Position, FPaintRect.Bottom + 2), FontFormat, FBrush);

    Position := Position + GridSize;
    GridValue := GridValue + FAxisH.GridSize;
  end;

  FontFormat.SetAlignment(StringAlignmentFar);
  GridSize := (FPaintRect.Bottom - FPaintRect.Top) / (FAxisV.MaxValue - FAxisV.MinValue) * FAxisV.GridSize;
  GridValue := abs(Frac(FAxisV.MinValue / FAxisV.GridSize));
  Position := GridValue * GridSize;
  GridValue := FAxisV.MinValue - (1 - GridValue) * FAxisV.GridSize + FAxisV.GridSize;
  while GridValue <= FAxisV.MaxValue do
  begin
    Str := FormatFloat(FAxisV.Format, GridValue);
    Graphics.DrawLine(FPen, FPaintRect.Left, FPaintRect.Bottom - Position, FPaintRect.Right, FPaintRect.Bottom - Position);
    Graphics.DrawString(Str, Length(Str), FFont, MakePoint(FPaintRect.Left - 2, FPaintRect.Bottom - Position - 7), FontFormat, FBrush);

    Position := Position + GridSize;
    GridValue := GridValue + FAxisV.GridSize;
  end;

  FGraphics.DrawString('0', 1, FFont, MakePoint(FPaintRect.Left - 2, FPaintRect.Bottom + 2.0), FontFormat, FBrush);

  FontFormat.Free;
  FFont.Free;
  FPen.Free;
  FBrush.Free;
  FFontFamily.Free;

  FPen := TGPPen.Create(ColorToARGB(FStyle.Axis), 1);
  Graphics.DrawLine(FPen, FPaintRect.Left, FPaintRect.Top - 10,
                     FPaintRect.Left, FPaintRect.Bottom);
  Graphics.DrawLine(FPen, FPaintRect.Left, FPaintRect.Bottom,
                     FPaintRect.Right + 10, FPaintRect.Bottom);
  FPen.Free;

  FBrush := TGPSolidBrush.Create(ColorToARGB(FStyle.Axis));
  SetLength(Points, 4);
  Points[0] := MakePoint(FPaintRect.Right + 4, FPaintRect.Bottom - 3.5);
  Points[1] := MakePoint(FPaintRect.Right + 7, FPaintRect.Bottom + 0.0);
  Points[2] := MakePoint(FPaintRect.Right + 4, FPaintRect.Bottom + 3.5);
  Points[3] := MakePoint(FPaintRect.Right + 16, FPaintRect.Bottom + 0.0);
  Graphics.FillPolygon(FBrush, PGPPointF(@Points[0]), 4);
  Points[0] := MakePoint(FPaintRect.Left + 3.5, FPaintRect.Top - 4);
  Points[1] := MakePoint(FPaintRect.Left + 0.0, FPaintRect.Top - 7);
  Points[2] := MakePoint(FPaintRect.Left - 3.5, FPaintRect.Top - 4);
  Points[3] := MakePoint(FPaintRect.Left + 0.0, FPaintRect.Top - 14);
  Graphics.FillPolygon(FBrush, PGPPointF(@Points[0]), 4);
  FBrush.Free;
  Graphics.Free;
end;

procedure TQuadDiagram.DrawGraf;
var
  i, p: Integer;
begin
  FLineMouseMoveDraw := False;
  for i := FLines.Count - 1 downto 0 do
    DrawLine(FLines.Items[i]);

  FPen := TGPPen.Create($88000000, 1);
  for i := FLines.Count - 1 downto 0 do
  begin
    FBrush := TGPSolidBrush.Create(ColorToARGB(FLines.Items[i].Color));
    for p := 0 to FLines.Items[i].Points.Count - 1 do
      DrawPoint(FLines.Items[i].Points.Items[p]);

    FBrush.Free;
  end;
  FPen.Free;
end;

procedure TQuadDiagram.DrawPosition;
var
  X, Y: Double;
  i: Integer;
begin
  if Position < 0 then
    Exit;

  FPen := TGPPen.Create(ColorToARGB(clRed), 1);
  X := FPaintRect.Left + Position / FAxisH.MaxValue * FPaintWidth;
  FGraphics.DrawLine(FPen, X, FPaintRect.Top, X, FPaintRect.Bottom);
  FPen.Free;

  FPen := TGPPen.Create(ColorToARGB(clBlack), 1);
  FBrush := TGPSolidBrush.Create(ColorToARGB(clRed));
  for i := 0 to FLines.Count - 1 do
  begin
    Y := FPaintRect.Bottom - FPaintHeight / FAxisV.MaxValue * GetValueInPosition(FLines.Items[i], Position);
    FGraphics.FillEllipse(FBrush, X - 3, Y - 3, 6, 6);
    FGraphics.DrawEllipse(FPen, X - 3, Y - 3, 6, 6);
  end;

  FBrush.Free;
  FPen.Free;
end;

procedure TQuadDiagram.DrawLine(ALine: TQuadDiagramLineItem);
var
  i: Integer;
  PointL, PointR: TGPPointF;
begin
  if ALine.Points.Count = 0 then
    Exit;
  //Canvas.Pen.Style := ALine.Style;
  //FPen.SetDashStyle(DashStyleDash);

  FPen := TGPPen.Create(ColorToARGB(ALine.Color), ALine.Width);
  FPen.SetDashStyle(ALine.Style);
  PointL := PointToGridPoint(ALine.Points.Items[0]);
  DrawSegment(FPen, FPaintRect.Left, PointL.Y, PointL.X, PointL.Y);
  for i := 0 to ALine.Points.Count - 1 do
  begin
    PointR := PointToGridPoint(ALine.Points.Items[i]);
    DrawSegment(FPen, PointL.X, PointL.Y, PointR.X, PointR.Y);
    PointL := PointR;
  end;
  DrawSegment(FPen, PointL.X, PointL.Y, FPaintRect.Right, PointL.Y);
  FPen.Free;
end;

procedure TQuadDiagram.DrawSegment(pen: TGPPen; x1, y1, x2, y2: Single);
var
  P: TGPPen;
  Color: Cardinal;
begin
  if FLineMouseMove and not FPointMouseMove and not FLineMouseMoveDraw and
     not Assigned(PointSelected) and LineMouseMove(MakePoint(x1, y1), MakePoint(x2, y2)) then
  begin
    FLineMouseMoveDraw := True;
    pen.GetColor(Color);
    p := TGPPen.Create(Color {- $66000000}, 2);
    p.SetDashStyle(DashStyleDash);
    FGraphics.DrawLine(P, x1, y1, FMouse.X, FMouse.Y);
    FGraphics.DrawLine(P, FMouse.X, FMouse.Y, x2, y2);
    FGraphics.DrawEllipse(FPen, FMouse.X - 3, FMouse.Y - 3, 6, 6);
    p.Free;
  end
  else
    FGraphics.DrawLine(pen, x1, y1, x2, y2);
end;

procedure TQuadDiagram.DrawPoint(APoint: TQuadDiagramLinePointItem);
var
  Point: TGPPointF;
begin
  Point := PointToGridPoint(APoint);
  FGraphics.FillEllipse(FBrush, Point.X - 3, Point.Y - 3, 6, 6);
  FGraphics.DrawEllipse(FPen, Point.X - 3, Point.Y - 3, 6, 6);
     {
  FBrush := TGPSolidBrush.Create(ColorToARGB(FStyle.Axis));
  Str := FormatFloat(FAxisH.Format, FAxisV.FLowMax);
  FGraphics.DrawString(Str, Length(Str), FFont, MakePoint(Point.X - 3.0, Point.Y - 3), FBrush);
  FBrush.Free;    }
end;

function TQuadDiagram.GetGPRect: TGPRect;
begin
  Result.X := 0;
  Result.Y := 0;
  Result.Width := Width;
  Result.Height := Height;
end;

procedure TQuadDiagram.SetPosition(const Value: Double);
begin
  FPosition := Value;
  Repaint;
end;

function TQuadDiagram.GetValue(ALine: Integer): Double;
begin
  Result := GetValueInPosition(FLines.Items[ALine], FPosition);
end;

procedure TQuadDiagram.SetPointSelected(const Value: TQuadDiagramLinePointItem);
var
  i: Integer;
  Points: TQuadDiagramLinePointCollection;
begin
  FMaxNotPointSelected := nil;
  FMinNotPointSelected := nil;
  if Value <> nil then
  begin
    Points := FLines.Items[FLineMouseMoveIndex].Points;
    for i := 0 to Points.Count - 1 do
      if Points.Items[i] <> Value then
      begin
        if (FMaxNotPointSelected = nil) or (Points.Items[i].Y > FMaxNotPointSelected.Y) then
          FMaxNotPointSelected := Points.Items[i];

        if (FMinNotPointSelected = nil) or (Points.Items[i].Y < FMinNotPointSelected.Y) then
          FMinNotPointSelected := Points.Items[i];
      end;
  end;
  FPointSelected := Value;
end;

function TQuadDiagram.GetValueInPosition(ALine: TQuadDiagramLineItem; APosition: Double): Double;
var
  i: Integer;
begin
  for i := 0 to ALine.Points.Count - 1 do
    if (i = 0) and (ALine.Points.Items[i].X >= APosition) or
       (i = ALine.Points.Count - 1) and (ALine.Points.Items[i].X <= APosition) then
    begin
      Result := ALine.Points.Items[i].Y;
      Exit;
    end
    else
      if (i <> 0) and (ALine.Points.Items[i-1].X <= APosition) and
         (APosition <= ALine.Points.Items[i].X) then
      begin
        Result := ALine.Points.Items[i-1].Y + (ALine.Points.Items[i].Y - ALine.Points.Items[i-1].Y) /
                  (ALine.Points.Items[i].X - ALine.Points.Items[i-1].X) *
                  (APosition - ALine.Points.Items[i-1].X);
        Exit;
      end;
  Result := 0;
end;

procedure TQuadDiagram.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = TMouseButton.mbLeft then
  begin
    if FPointMouseMove then
    begin
      PointSelected := FLines.Items[FLineMouseMoveIndex].Points.Items[FPointMouseMoveIndex];
      FLineMouseMove := False;
      Repaint;
    end
    else
      if FLineMouseMove then
      begin
        FPointMouseMove := False;
        if FPointMouseMoveIndex > -1 then
          PointSelected := FLines.Items[FLineMouseMoveIndex].Points.Insert(FPointMouseMoveIndex)
        else
          PointSelected := FLines.Items[FLineMouseMoveIndex].Points.Add;
        GridPointToPoint(PointSelected, FMouse.X, FMouse.Y);
        if Assigned(FOnPointAdd) then
          FOnPointAdd(
            Self, FLines.Items[FLineMouseMoveIndex],
            FLines.Items[FLineMouseMoveIndex].Points.Items[FPointMouseMoveIndex]
          );
        Repaint;
      end;
  end
  else
    if (Button = TMouseButton.mbRight) and FPointMouseMove and (FLines.Items[FLineMouseMoveIndex].Points.Count > 1) then
    begin
      FPointMouseMove := False;
      if Assigned(FOnPointDelete) then
        FOnPointDelete(
          Self, FLines.Items[FLineMouseMoveIndex],
          FLines.Items[FLineMouseMoveIndex].Points.Items[FPointMouseMoveIndex]
        );
      FLines.Items[FLineMouseMoveIndex].Points.Delete(FPointMouseMoveIndex);
      Repaint;
    end;
end;

procedure TQuadDiagram.MouseLeave(var Msg: TMessage);
begin
  inherited;
  FLineMouseMove := False;
  FPointMouseMove := False;
  Repaint;
end;

procedure TQuadDiagram.DisableControl;
begin
  FIsDisable := True;
end;

procedure TQuadDiagram.EnableControl;
begin
  FIsDisable := False;
  Repaint;
end;

procedure TQuadDiagram.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i, p: Integer;
  PointL, PointR: TGPPointF;
begin
  FMouse.X := X;
  FMouse.Y := Y;

  if Assigned(PointSelected) then
  begin
    GridPointToPoint(PointSelected, FMouse.X, FMouse.Y);

    if (FPointMouseMoveIndex > 0) and (FLines.Items[FLineMouseMoveIndex].Points.Items[FPointMouseMoveIndex-1].X > PointSelected.X) then
      PointSelected.X := FLines.Items[FLineMouseMoveIndex].Points.Items[FPointMouseMoveIndex-1].X
    else
      if (FPointMouseMoveIndex < FLines.Items[FLineMouseMoveIndex].Points.Count - 1) and (FLines.Items[FLineMouseMoveIndex].Points.Items[FPointMouseMoveIndex+1].X < PointSelected.X) then
        PointSelected.X := FLines.Items[FLineMouseMoveIndex].Points.Items[FPointMouseMoveIndex+1].X
      else
        if PointSelected.X < FAxisH.MinValue then
          PointSelected.X := FAxisH.MinValue
        else
          if PointSelected.X > FAxisH.MaxValue then
            PointSelected.X := FAxisH.MaxValue;

    if PointSelected.Y > FAxisV.MaxValue then
    begin
      if PointSelected.Y > FAxisV.HighMax then
      begin
        if FAxisV.MaxValue < FAxisV.HighMax then
          FAxisV.MaxValue := FAxisV.HighMax;

        PointSelected.Y := FAxisV.MaxValue;
      end
      else
        FAxisV.MaxValue := PointSelected.Y;
    end
    else
      if PointSelected.Y < FAxisV.MinValue then
      begin
        if PointSelected.Y < FAxisV.LowMin then
        begin
          if FAxisV.MinValue > FAxisV.LowMin then
            FAxisV.MinValue := FAxisV.LowMin;

          PointSelected.Y := FAxisV.MinValue;
        end
        else
          FAxisV.MinValue := PointSelected.Y;
      end ;
      {else
        if (PointSelected.Y < FAxisV.MaxValue) and (FAxisV.HighMin < FAxisV.MaxValue) then
        begin
          if PointSelected.Y < FAxisV.HighMin then
          begin
           // if Assigned(FMaxNotPointSelected) and (FMaxNotPointSelected.Y > FAxisV.HighMin) then
           //   FAxisV.MaxValue := FMaxNotPointSelected.Y
           // else
              FAxisV.MaxValue := FAxisV.HighMin
          end
          else
            FAxisV.MaxValue := PointSelected.Y;
        end;
        }
    if Assigned(FOnPointChange) then
      FOnPointChange(
        Self, FLines.Items[FLineMouseMoveIndex],
        FLines.Items[FLineMouseMoveIndex].Points.Items[FPointMouseMoveIndex]
      );

   // Repaint;
  end
  else
  begin
    for i := 0 to FLines.Count - 1 do
    begin
      if FLines.Items[i].Enabled then
      begin
        FLineMouseMoveIndex := i;
        for p := 0 to FLines.Items[i].Points.Count - 1 do
        begin
          FPointMouseMoveIndex := p;
          if PointMouseMove(PointToGridPoint(FLines.Items[i].Points.Items[p])) then
          begin
            SetPointMouseMove(True);
            Exit;
          end;
        end;
      end;
    end;
    SetPointMouseMove(False);

    for i := 0 to FLines.Count - 1 do
    begin
      if FLines.Items[i].Enabled then
      begin
        FLineMouseMoveIndex := i;
        PointL := PointToGridPoint(FLines.Items[i].Points.Items[0]);
        PointL.X := FPaintRect.Left;
        for p := 0 to FLines.Items[i].Points.Count - 1 do
        begin
          FPointMouseMoveIndex := p;
          PointR := PointToGridPoint(FLines.Items[i].Points.Items[p]);
          if LineMouseMove(PointL, PointR) then
          begin
            SetLineMouseMove(True);
            Exit;
          end;
          PointL := PointR;
        end;
        PointR.X := FPaintRect.Right;
        if LineMouseMove(PointL, PointR) then
        begin
          inc(FPointMouseMoveIndex);
          SetLineMouseMove(True);
          Exit;
        end;
      end;
    end;
    SetLineMouseMove(False);
  end;
end;

procedure TQuadDiagram.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = TMouseButton.mbLeft then
    PointSelected := nil;
end;

{ TQuadDiagramStyle }

constructor TQuadDiagramStyle.Create(AOwner: TQuadDiagram);
begin
  FOwner := AOwner;
  RefreshSystemStyle;
end;

procedure TQuadDiagramStyle.RefreshSystemStyle;
begin
  FBackground1 := TStyleManager.ActiveStyle.GetSystemColor(clBtnFace);
  FBackground2 := TStyleManager.ActiveStyle.GetSystemColor(clBtnFace);

  FGridLine := TStyleManager.ActiveStyle.GetStyleFontColor(sfTextLabelNormal);
  FAxis := TStyleManager.ActiveStyle.GetStyleFontColor(sfTextLabelNormal);
  FAxisTitle := TStyleManager.ActiveStyle.GetStyleFontColor(sfTextLabelNormal);
  FGradient := LinearGradientModeVertical;
end;

procedure TQuadDiagramStyle.Assign(ASource: TPersistent);
begin
  if ASource is TQuadDiagramStyle then
  begin
    FBackground1 := TQuadDiagramStyle(ASource).Background1;
    FBackground2 := TQuadDiagramStyle(ASource).Background2;
    FGridLine := TQuadDiagramStyle(ASource).GridLine;
    FAxis := TQuadDiagramStyle(ASource).Axis;
    FAxisTitle := TQuadDiagramStyle(ASource).AxisTitle;
    FGradient := TQuadDiagramStyle(ASource).Gradient;
  end
  else
    inherited;
end;

procedure TQuadDiagramStyle.SetAxis(const Value: TColor);
begin
  if FAxis <> Value then
  begin
    FAxis := Value;
    FOwner.Repaint;
  end;
end;

procedure TQuadDiagramStyle.SetAxisTitle(const Value: TColor);
begin
  if FAxisTitle <> Value then
  begin
    FAxisTitle := Value;
    FOwner.Repaint;
  end;
end;

procedure TQuadDiagramStyle.SetBackground1(const Value: TColor);
begin
  if FBackground1 <> Value then
  begin
    FBackground1 := Value;
    FOwner.Repaint;
  end;
end;

procedure TQuadDiagramStyle.SetBackground2(const Value: TColor);
begin
  if FBackground2 <> Value then
  begin
    FBackground2 := Value;
    FOwner.Repaint;
  end;
end;

procedure TQuadDiagramStyle.SetGradient(const Value: TLinearGradientMode);
begin
  if FGradient <> Value then
  begin
    FGradient := Value;
    FOwner.Repaint;
  end;
end;

procedure TQuadDiagramStyle.SetGridLine(const Value: TColor);
begin
  if FGridLine <> Value then
  begin
    FGridLine := Value;
    FOwner.Repaint;
  end;
end;

procedure TQuadDiagramStyle.SetLegendColumns(const Value: Integer);
begin
  if FLegendColumns <> Value then
  begin
    FLegendColumns := Value;
    FOwner.Repaint;
  end;
end;

procedure TQuadDiagramStyle.SetLegendVisible(const Value: Boolean);
begin
  if FLegendVisible <> Value then
  begin
    FLegendVisible := Value;
    FOwner.Repaint;
  end;
end;

{ TQuadDiagramLineItem }

constructor TQuadDiagramLineItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  //FPoints := TQuadDiagramLinePointCollection.Create(Self, TQuadDiagramLinePointItem);
  FWidth := 1;
end;

destructor TQuadDiagramLineItem.Destroy;
begin
  if Assigned(FPoints) then
    FPoints.Free;
  inherited;
end;

function TQuadDiagramLineItem.GetPoints: TQuadDiagramLinePointCollection;
begin
  if FPoints = nil then
    FPoints := TQuadDiagramLinePointCollection.Create(Self);
  Result := FPoints;
end;

procedure TQuadDiagramLineItem.SetColor(const Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Changed(False);
  end;
end;

procedure TQuadDiagramLineItem.SetPoints(const Value: TQuadDiagramLinePointCollection);
begin
  FPoints.Assign(Value);
end;

procedure TQuadDiagramLineItem.SetWidth(const Value: Integer);
begin
  if FWidth <> Value then
  begin
    FWidth := Value;
    Changed(False);
  end;
end;

procedure TQuadDiagramLineItem.SetStyle(const Value: TDashStyle);
begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    Changed(False);
  end;
end;

procedure TQuadDiagramLineItem.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    Changed(False);
  end;
end;

procedure TQuadDiagramLineItem.SetCaption(const Value: String);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    Changed(False);
  end;
end;

{ TQuadDiagramLineCollection }

constructor TQuadDiagramLineCollection.Create(AOwner: TQuadDiagram);
begin
  inherited Create(AOwner, TQuadDiagramLineItem);

end;

destructor TQuadDiagramLineCollection.Destroy;
begin

  inherited;
end;

function TQuadDiagramLineCollection.Add: TQuadDiagramLineItem;
begin
  Result := TQuadDiagramLineItem(inherited Add);
end;

function TQuadDiagramLineCollection.GetOwner: TQuadDiagram;
begin
  Result := TQuadDiagram(inherited GetOwner);
end;

function TQuadDiagramLineCollection.GetItem(Index: Integer): TQuadDiagramLineItem;
begin
  Result := TQuadDiagramLineItem(inherited Items[index]);
end;

procedure TQuadDiagramLineCollection.SetItem(Index: Integer; const Value: TQuadDiagramLineItem);
begin
  Items[index].Assign(Value);
end;

procedure TQuadDiagramLineCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
//  if GetOwner <> nil then
    GetOwner.Repaint;
end;

{ TQuadDiagramLinePointItem }

constructor TQuadDiagramLinePointItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FColor := 0;
  FX := 0;
  FY := 0;
end;

destructor TQuadDiagramLinePointItem.Destroy;
begin
  inherited;
end;

procedure TQuadDiagramLinePointItem.SetColor(const Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Changed(False);
  end;
end;

procedure TQuadDiagramLinePointItem.SetX(const Value: Double);
begin
  if FX <> Value then
  begin
    FX := Value;
    Changed(False);
  end;
end;

procedure TQuadDiagramLinePointItem.SetY(const Value: Double);
begin
  if FY <> Value then
  begin
    FY := Value;
    Changed(False);
  end;
end;

{ TQuadDiagramLinePointCollection }

constructor TQuadDiagramLinePointCollection.Create(AOwner: TQuadDiagramLineItem);
begin
  inherited Create(AOwner, TQuadDiagramLinePointItem);
end;

destructor TQuadDiagramLinePointCollection.Destroy;
begin

  inherited;
end;

function TQuadDiagramLinePointCollection.Add: TQuadDiagramLinePointItem;
begin
  Result := TQuadDiagramLinePointItem(inherited Add);
end;

function TQuadDiagramLinePointCollection.Add(X, Y: Double): TQuadDiagramLinePointItem;
begin
  Result := TQuadDiagramLinePointItem(inherited Add);
  Result.FX := X;
  Result.FY := Y;
  Result.FColor := 0;
end;

function TQuadDiagramLinePointCollection.GetItem(Index: Integer): TQuadDiagramLinePointItem;
begin
  Result := TQuadDiagramLinePointItem(inherited Items[index]);
end;

function TQuadDiagramLinePointCollection.Insert(Index: Integer): TQuadDiagramLinePointItem;
begin
  Result := TQuadDiagramLinePointItem(inherited Insert(Index));
end;

procedure TQuadDiagramLinePointCollection.SetItem(Index: Integer; const Value: TQuadDiagramLinePointItem);
begin
  Items[index].Assign(Value);
end;

procedure TQuadDiagramLinePointCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  GetOwner.Changed(false);
end;

function TQuadDiagramLinePointCollection.GetOwner: TQuadDiagramLineItem;
begin
  Result := TQuadDiagramLineItem(inherited GetOwner);
end;

{ TQuadDiagramAxis }

constructor TQuadDiagramAxis.Create(AOwner: TQuadDiagram);
begin
  FOwner := AOwner;
  FName := 'Name';
  FFormat := '0';
  FMinValue := 0;
  FMaxValue := 100;
  FGridSize := 20;
  FLowMin := 100;
  FLowMax := 100;
  FHighMin := 0;
  FHighMax := 0;
end;

procedure TQuadDiagramAxis.Assign(ASource: TPersistent);
begin
  if ASource is TQuadDiagramAxis then
  begin
    FName := TQuadDiagramAxis(ASource).Name;
    FFormat := TQuadDiagramAxis(ASource).Format;
    FMinValue := TQuadDiagramAxis(ASource).MinValue;
    FMaxValue := TQuadDiagramAxis(ASource).MaxValue;
    FGridSize := TQuadDiagramAxis(ASource).GridSize;
    FLowMin := TQuadDiagramAxis(ASource).LowMin;
    FLowMax := TQuadDiagramAxis(ASource).LowMax;
    FHighMin := TQuadDiagramAxis(ASource).HighMin;
    FHighMax := TQuadDiagramAxis(ASource).HighMax;
  end
  else
    inherited;
end;

procedure TQuadDiagramAxis.SetName(Value: String);
begin
  if FName <> Value then
  begin
    FName := Value;
    FOwner.Repaint;
  end;
end;

procedure TQuadDiagramAxis.SetFormat(Value: String);
begin
  if FFormat <> Value then
  begin
    FFormat := Value;
    FOwner.Repaint;
  end;
end;

procedure TQuadDiagramAxis.SetMinValue(Value: Single);
begin
  if FMinValue <> Value then
  begin
    FMinValue := Value;
    FOwner.Repaint;
  end;
end;

procedure TQuadDiagramAxis.SetMaxValue(Value: Single);
begin
  if FMaxValue <> Value then
  begin
    FMaxValue := Value;
    FOwner.Repaint;
  end;
end;

procedure TQuadDiagramAxis.SetGridSize(Value: Single);
begin
  if FGridSize <> Value then
  begin
    FGridSize := Value;
    FOwner.Repaint;
  end;
end;

procedure TQuadDiagramAxis.SetLowMin(Value: Single);
begin
  if FLowMin <> Value then
  begin
    FLowMin := Value;
    FOwner.Repaint;
  end;
end;

procedure TQuadDiagramAxis.SetLowMax(Value: Single);
begin
  if FLowMax <> Value then
  begin
    FLowMax := Value;
    FOwner.Repaint;
  end;
end;

procedure TQuadDiagramAxis.SetHighMin(Value: Single);
begin
  if FHighMin <> Value then
  begin
    FHighMin := Value;
    FOwner.Repaint;
  end;
end;

procedure TQuadDiagramAxis.SetHighMax(Value: Single);
begin
  if FHighMax <> Value then
  begin
    FHighMax := Value;
    FOwner.Repaint;
  end;
end;

end.
