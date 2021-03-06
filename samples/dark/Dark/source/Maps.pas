unit Maps;

interface

uses
  Windows, Graphics, Resources, QuadEngine, mSettings, Vec2f, Hero, Direct3D9,
  Classes, Collision, Math, SysUtils;

const
  MAP_SCALE: Integer = 64;

type
  TMapItem = record
    ItemType: Integer;
    ItemFrame: Integer;
    X, Y: Integer;
    Line: array [0 .. 3] of Boolean;
  end;

  PMapLine = ^TMapLine;

  TMapLine = record
    PointA, PointB: TVec2f;
  end;

  PLight = ^TLight;

  TLight = record
    Tip: Integer;
    Color: Cardinal;
    Radius: Single;
    Position: TVec2f;
    Angle, AngleSpeed: Single;
  end;

  TMap = class
  private const
    PATH = 'Data\Maps\';

  var
    FHero: THero;
    FQuad: IQuadRender;
    FMapW, FMapH: Integer;
    FMap: array of array of TMapItem;
    FLineList: TList;

    FLightList: TList;
    FLightAngle: TVec2f;

    FRefreshShadow: Boolean;

    function GetSize: TVec2f;
    procedure ItemToLine(AItem: TMapItem);
    procedure MapToLine;
  public
    Menu: Boolean;
    constructor Create(AQuadRender: IQuadRender);
    destructor Destroy; override;
    procedure LoadMap(ManNum: Integer = 1);
    procedure Draw(const dt: Double);
    procedure DrawLight(const dt: Double);
    procedure DrawLight1(const dt: Double);
    procedure DrawShadow(const dt: Double);
    procedure LightVsDark;
    procedure SetHero(AHero: THero);

    function LightAdd: PLight;
    procedure LightDel(AIndex: Integer);
    procedure LightDelAll;

    procedure LineAdd(PointA, PointB: TVec2f);
    procedure LineDelAll;

    procedure FormPaint;

    procedure Collides;
    procedure CollideLine(const ALine: PMapLine);
    procedure PushOut(const APoint: TVec2f);
    function LinesCollPoint(const A, B, C, D: TVec2f): TVec2f;
    function CollPlayerLight(Light: PLight): Boolean;
    function CollPlayerLightUgl(Light: PLight; AUgl: Single): Boolean;

    function GetHeroExit: Boolean;

    property Size: TVec2f read GetSize;
  end;

implementation

{ TMap }

procedure TMap.Collides;
var
  i: Integer;
begin

  for i := 0 to FLineList.Count - 1 do
    CollideLine(PMapLine(FLineList.Items[i]));

  // AObject: TMovableObject; const ALine: TObstacleLine
end;

function TMap.GetHeroExit: Boolean;
var
  X, Y: Integer;
begin
  Result := false;
  if not Assigned(FHero) then
    Exit;

  X := Round(FHero.Position.X) div 64;
  Y := Round(FHero.Position.Y) div 64;

  Result := FMap[X, Y].ItemType = 2;
  Result := FMap[X, Y].ItemType = 2;
end;

procedure TMap.FormPaint;

  procedure DrawLine(ALine: PMapLine);
  begin
    FQuad.DrawLine((ALine.PointA.X - Settings.GameCamera.X)
        * Settings.GameScale, (ALine.PointA.Y - Settings.GameCamera.Y)
        * Settings.GameScale, (ALine.PointB.X - Settings.GameCamera.X)
        * Settings.GameScale, (ALine.PointB.Y - Settings.GameCamera.Y)
        * Settings.GameScale, $FFFF0000);
  end;

var
  i: Integer;
begin
  for i := 0 to FLineList.Count - 1 do
    DrawLine(PMapLine(FLineList.Items[i]));
end;

constructor TMap.Create(AQuadRender: IQuadRender);
begin
  FQuad := AQuadRender;
  FLightList := TList.Create;
  FLightAngle := TVec2f.Create(0, 0);
  FLineList := TList.Create;
  Menu := false;
  // LightAdd(TVec2f.Create(480, 400), 400, $66FFFFFaa);
  // LightAdd(TVec2f.Create(600, 900), 400, $66FFFFFaa);
end;

destructor TMap.Destroy;
begin
  LineDelAll;
  FLineList.Free;
  LightDelAll;
  FLightList.Free;
  inherited;
end;

function TMap.LightAdd: PLight;
begin
  new(Result);
  FLightList.Add(Result);
end;

procedure TMap.LightDel(AIndex: Integer);
begin
  //
end;

procedure TMap.LightDelAll;
var
  i: Integer;
begin
  for i := 0 to FLightList.Count - 1 do
    Dispose(PLight(FLightList.Items[i]));
  FLightList.Clear;
end;

procedure TMap.LoadMap(ManNum: Integer = 1);
type
  TZblColor = record
    case Integer of
      0:
        (Color: Cardinal);
      1:
        (R, G, B: Byte);
  end;
var
  Color: TZblColor;
  X, Y: Integer;
  bit: TBitMap;
  Light: PLight;
begin
  FHero.Refresh;
  LightDelAll;
  bit := TBitMap.Create;
  try
    bit.LoadFromFile(PATH + 'map' + IntToStr(ManNum) + '.bmp');
    FMapW := bit.Width;
    FMapH := bit.Height;

    SetLength(FMap, FMapH);
    for X := 0 to FMapW - 1 do
    begin
      SetLength(FMap[X], FMapH);
      for Y := 0 to FMapH - 1 do
      begin
        Color.Color := bit.Canvas.Pixels[X, Y];

        case bit.Canvas.Pixels[X, Y] of
          clBlack:
            FMap[X, Y].ItemType := 1;
        else
          begin
            FMap[X, Y].ItemType := 0;
            case Color.R of
              $FE:
                FHero.Position := TVec2f.Create(X * 64 + 32, Y * 64 + 32);
              $99:
                FMap[X, Y].ItemType := 2;
              $AA:
                begin
                  Light := LightAdd;
                  Light^.Tip := 1;
                  Light^.Position := TVec2f.Create(X * 64 + 32, Y * 64 + 32);
                  Light^.Radius := Color.G * 10;
                  Light^.AngleSpeed := 100;
                  Light^.Color := $66FFFFFAA;
                  Light^.Angle := Color.B/$FF*360;
                end;
              $AB:
                begin
                  Light := LightAdd;
                  Light^.Tip := 1;
                  Light^.Position := TVec2f.Create(X * 64 + 32, Y * 64 + 32);
                  Light^.Radius := Color.G * 10;
                  Light^.AngleSpeed := -100;
                  Light^.Color := $66FFFFFAA;
                  Light^.Angle := Color.B / $FF * 360;
                end;
              $BB:
                begin
                  Light := LightAdd;
                  Light^.Tip := 2;
                  Light^.Position := TVec2f.Create(X * 64 + 32, Y * 64 + 32);
                  Light^.Radius := Color.G * 10;
                  Light^.AngleSpeed := 100;
                  Light^.Color := $66FFFFFAA;
                  Light^.Angle := Color.B/$FF*360;
                end;
              $CC:
                begin
                  Light := LightAdd;
                  Light^.Tip := 0;
                  Light^.Position := TVec2f.Create(X * 64 + 32, Y * 64 + 32);
                  Light^.Radius := Color.G * 10;
                  Light^.AngleSpeed := 0;
                  Light^.Color := $66FFFFFAA;
                  Light^.Angle := Color.B/$FF*360;
                end;
              $B1:
                begin
                  Light := LightAdd;
                  Light^.Tip := 2;
                  Light^.Position := TVec2f.Create(X * 64 + 32, Y * 64 + 32);
                  Light^.Radius := 300;
                  Light^.AngleSpeed := 0;
                  Light^.Color := $66FFFFFAA;
                  Light^.Angle := Color.G/$FF*360;
                end;
            end;
          end;
        end;
        FMap[X, Y].ItemFrame := Random(16);
        FMap[X, Y].X := X;
        FMap[X, Y].Y := Y;
        FMap[X, Y].Line[0] := False;
        FMap[X, Y].Line[1] := False;
        FMap[X, Y].Line[2] := False;
        FMap[X, Y].Line[3] := False;
      end;
    end;
    MapToLine;
    FRefreshShadow := False;
  finally
    bit.Free;
  end;
end;

procedure TMap.SetHero(AHero: THero);
begin
  FHero := AHero;
end;

procedure TMap.Draw(const dt: Double);
var
  X, Y: Integer;
  Scale: Single;
begin
  Scale := MAP_SCALE;
  for X := 0 to FMapW - 1 do
    for Y := 0 to FMapH - 1 do
      case FMap[X, Y].ItemType of
        // 0: Textures.Floor.DrawRotFrame(-Settings.GameCamera.X + X * Scale + Scale/2, -Settings.GameCamera.Y + Y * Scale + Scale/2, 0, Settings.GameScale, FMap[X, Y].ItemFrame);
        1: begin
          FQuad.SetBlendMode(qbmNone);
        Textures.Wall.DrawFrame(-Settings.Camera.X + X * Scale,-Settings.Camera.Y + Y * Scale, FMap[X, Y].ItemFrame);
        end;
        2: begin
        FQuad.SetBlendMode(qbmSrcAlphaAdd);
        Textures.Exit.Draw(-Settings.Camera.X + X * Scale,-Settings.Camera.Y + Y * Scale);
        end;
      end;
  // (Position.X * Settings.GameScale)/2 - Settings.Camera.X
  FQuad.SetBlendMode(qbmNone);
  Scale := MAP_SCALE * Settings.GameScale / 2;
  FQuad.RenderToTexture(True, Textures.MapRender, 0, True);
  FQuad.Rectangle(0, 0, 512, 512, $FFFFFFFF);
  for X := 0 to FMapW - 1 do
    for Y := 0 to FMapH - 1 do
      if FMap[X, Y].ItemType = 1 then
        Textures.Black.DrawRot((X * Scale + Scale / 2) - Settings.Camera.X / 2,
          (Y * Scale + Scale / 2) - Settings.Camera.Y / 2, 0,
          Settings.GameScale / 2);
  FQuad.RenderToTexture(False, Textures.MapRender);



  // if Assigned(FHero) then
  // FHero.DrawMap(dt);

  FQuad.RenderToTexture(True, Textures.Shadows, 0, True);

  if not FRefreshShadow then
  begin
    FRefreshShadow := True;
    FQuad.Rectangle(0, 0, 1024, 1024, $FFFFFFFF);
  end;
  LightVsDark;
  FHero.DrawMap(dt);
  FQuad.RenderToTexture(False, Textures.Shadows);

  // Textures.Shadows.DrawMap(0, 0, 1025, 768, 0, 0, 1, 1);

  FQuad.SetBlendMode(qbmNone);
  FQuad.RenderToTexture(True, Textures.MapRender, 0, True);
  FQuad.SetBlendMode(qbmSrcAlpha);
  Shaders.DrawBlack.SetShaderState(True);
  Textures.Shadows.DrawMap(0, 0, 512, 512, Settings.Camera.X / (64 * FMapW),
    Settings.Camera.Y / (64 * FMapW),
    Settings.Camera.X / (64 * FMapW) + (1024 / (64 * FMapW)),
    Settings.Camera.Y / (64 * FMapW) + (1024 / (64 * FMapW)));
  Shaders.DrawBlack.SetShaderState(False);
  FQuad.RenderToTexture(False, Textures.MapRender);

  FQuad.RenderToTexture(True, Textures.ShadowsDraw, 0);
  FQuad.Clear(0);
  FQuad.SetBlendMode(qbmSrcAlpha);
  Shaders.DrawBlack.SetShaderState(True);
  Textures.Shadows.DrawMap(0, -15, 1024, 1024,
    Settings.Camera.X / (64 * FMapW), Settings.Camera.Y / (64 * FMapW),
    Settings.Camera.X / (64 * FMapW) + (1024 / (64 * FMapW)),
    Settings.Camera.Y / (64 * FMapW) + (1024 / (64 * FMapW)));
  Shaders.DrawBlack.SetShaderState(False);
  FQuad.RenderToTexture(False, Textures.ShadowsDraw, 0);

  FQuad.SetBlendMode(qbmNone);
end;

procedure TMap.DrawShadow(const dt: Double);
begin
  FQuad.SetTextureAdressing(D3DTADDRESS_WRAP);
  FQuad.SetBlendMode(qbmSrcAlpha);
  Shaders.DarkVector := Shaders.DarkVector - TVec2f.Create(0, dt * 0.1);
  Shaders.Dark.SetShaderState(True);
  Textures.ShadowsDraw.DrawMap(0, 0, 1025, 768, 0, 0, 1, 1);
  Shaders.Dark.SetShaderState(False);
  FQuad.SetTextureAdressing(D3DTADDRESS_CLAMP);

  FQuad.SetBlendMode(qbmNone);
end;

procedure TMap.DrawLight(const dt: Double);
var
  Light: PLight;
  i: Integer;
begin
  if FLightList.Count = 0 then
    Exit;

  FQuad.RenderToTexture(True, Textures.LightRender1, 0, True);
  FQuad.Clear(0);
  FQuad.Rectangle(0, 0, 512, 512, $FF222222);
  FQuad.RenderToTexture(False, Textures.LightRender1);

  for i := 0 to FLightList.Count - 1 do
  begin
    Light := PLight(FLightList.Items[i]);
    if Assigned(Light) then
    begin
      if not Menu then
      begin
        Light^.Angle := Light^.Angle + Light^.AngleSpeed * dt;
        if Light^.Angle > 360 then
          Light^.Angle := Light^.Angle - 360;
        if Light^.Angle < 0 then
          Light^.Angle := Light^.Angle + 360;
      end;

      Shaders.LightParam.Radius := (Light^.Radius / Settings.WindowWidth * 3);
      Shaders.LightParam.X :=
        (Light^.Position.X / Settings.WindowWidth - Settings.GameCamera.X /
          Settings.WindowWidth);
      Shaders.LightParam.Y :=
        (Light^.Position.Y / Settings.WindowWidth - Settings.GameCamera.Y /
          Settings.WindowWidth);

      if (Light^.Position.X + Shaders.LightParam.Radius * 512 > Settings.GameCamera.x) and
        (Light^.Position.X - Shaders.LightParam.Radius * 512 < Settings.GameCamera.x + 1024) and
        (Light^.Position.Y + Shaders.LightParam.Radius * 512 > Settings.GameCamera.Y) and
        (Light^.Position.Y - Shaders.LightParam.Radius * 512 < Settings.GameCamera.Y + 768) then
      begin
        FQuad.RenderToTexture(True, Textures.MapRender, 1, True);
        FQuad.SetBlendMode(qbmNone);
        FQuad.Rectangle(0, 0, 512, 512, $FF000000);
        case Light^.Tip of
          0:
            Textures.Light2.DrawRot(Shaders.LightParam.X * 512,
              Shaders.LightParam.Y * 512, Light^.Angle,
              Shaders.LightParam.Radius);
          1:
            Textures.Light4.DrawRot(Shaders.LightParam.X * 512,
              Shaders.LightParam.Y * 512, Light^.Angle,
              Shaders.LightParam.Radius);
          2:
            Textures.Light5.DrawRot(Shaders.LightParam.X * 512,
              Shaders.LightParam.Y * 512, Light^.Angle,
              Shaders.LightParam.Radius);
        end;
        FQuad.RenderToTexture(False, Textures.MapRender);

        FQuad.SetBlendMode(qbmAdd);
        FQuad.RenderToTexture(True, Textures.LightRender1, 0, True);
        Shaders.Light.SetShaderState(True);
        Textures.MapRender.Draw(0, 0, Light^.Color);
        Shaders.Light.SetShaderState(False);
        FQuad.RenderToTexture(False, Textures.LightRender1);
      end;
    end;
  end;

  // �����������
  FQuad.SetBlendMode(qbmNone);

  FQuad.RenderToTexture(True, Textures.LightRender2, 0, True);
  FQuad.Rectangle(0, 0, 512, 512, $FF000000);
  Shaders.Smoothing1.SetShaderState(True);
  Textures.LightRender1.Draw(0, 0);
  Shaders.Smoothing1.SetShaderState(False);
  FQuad.RenderToTexture(False, Textures.LightRender2);


  // FQuad.SetBlendMode(qbmNone);
  // Textures.LightRender2.Draw(512, 256);

  FQuad.RenderToTexture(True, Textures.LightRender1, 0, True);
  FQuad.SetBlendMode(qbmNone);
  Shaders.Smoothing2.SetShaderState(True);
  Textures.LightRender2.Draw(0, 0);
  Shaders.Smoothing2.SetShaderState(False);
  FQuad.RenderToTexture(False, Textures.LightRender1);

  FQuad.SetBlendMode(qbmMul);
  Textures.LightRender1.DrawMap(0, 0, 1024, 1024, 0, 0, 1, 1);

  FQuad.SetBlendMode(qbmNone);
end;

procedure TMap.LightVsDark;
var
  Light: PLight;
  i: Integer;
begin
  if FLightList.Count = 0 then
    Exit;
  FQuad.SetBlendMode(qbmSrcAlphaAdd);
  {
    Settings.Camera.X  ,
    Settings.Camera.Y / (64 * FMapW),
    Settings.Camera.X / (64 * FMapW) + (1024 / (64 * FMapW)),
    Settings.Camera.Y / (64 * FMapW)+ (1024 / (64 * FMapW)));
    }
  for i := 0 to FLightList.Count - 1 do
  begin
    Light := PLight(FLightList.Items[i]);
    if Assigned(Light) then
    begin
      Textures.Light1.DrawRot(Light^.Position.X * 1024 / 64 / FMapW,
        Light^.Position.Y * 1024 / 64 / FMapW

          , FLightAngle.X, Light^.Radius / 512 , $44666666);

    end;
  end;
  FQuad.SetBlendMode(qbmNone);
end;

procedure TMap.DrawLight1(const dt: Double);
  procedure DrawCircle(Light: PLight);
  var
    i: Integer;
    Q: Integer;
  begin
    Q := 16;
    for i := 0 to Q - 1 do
      FQuad.DrawLine(Light^.Position.X + cos(Pi * 2 / Q * i)
          * Light^.Radius * 0.7 - Settings.GameCamera.X,
        Light^.Position.Y + sin(Pi * 2 / Q * i)
          * Light^.Radius * 0.7 - Settings.GameCamera.Y,
        Light^.Position.X + cos(Pi * 2 / Q * (i + 1))
          * Light^.Radius * 0.7 - Settings.GameCamera.X,
        Light^.Position.Y + sin(Pi * 2 / Q * (i + 1))
          * Light^.Radius * 0.7 - Settings.GameCamera.Y, $FFFF0000);
  end;

  procedure Jarit(Dis: Single);
  begin
    if not Menu and (FHero.Scale > 0) then
      FHero.Scale := FHero.Scale - 0.01;
  end;

var
  Light: PLight;
  i: Integer;
  Dis: Single;
begin
  if FLightList.Count = 0 then
    Exit;

  if not Menu then
    FLightAngle := FLightAngle + TVec2f.Create(7 * dt, -dt * 3.5);

  for i := 0 to FLightList.Count - 1 do
  begin
    Light := PLight(FLightList.Items[i]);
    if Assigned(Light) then
    begin
    //  DrawCircle(Light);
      FQuad.SetBlendMode(qbmSrcAlphaAdd);
      Textures.Light.DrawRot(Settings.GetCoordX(Light^.Position.X),
        Settings.GetCoordY(Light^.Position.Y), FLightAngle.X,
        Light^.Radius / 512 * Settings.GameScale, $66FFFFFF);
      Textures.Light.DrawRot(Settings.GetCoordX(Light^.Position.X),
        Settings.GetCoordY(Light^.Position.Y), FLightAngle.Y,
        Light^.Radius / 512 * Settings.GameScale, $66FFFFFF);


      FQuad.SetBlendMode(qbmNone);

      Dis := Light^.Position.Distance(FHero.Position) - FHero.Radius;
      case Light^.Tip of
        0: if (Dis < Light^.Radius * 0.7) and not CollPlayerLight(Light) then
          Jarit(Dis);
        1: if (Dis < Light^.Radius * 0.7) and not CollPlayerLight(Light) and CollPlayerLightUgl(Light, 30) then
          Jarit(Dis);
        2: if (Dis < Light^.Radius * 0.7) and not CollPlayerLight(Light) and CollPlayerLightUgl(Light, 65) then
          Jarit(Dis);
       end;
    end;
  end;

  FQuad.SetBlendMode(qbmNone);
end;

function TMap.CollPlayerLight(Light: PLight): Boolean;
var
  Line: T2DLine;
  Rect: T2DRect;
  X, Y: Integer;
  sPos, fPos: TVec2f;
begin
  Result := False;
  Line.A := FHero.Position;
  Line.B := Light^.Position;
  {FQuad.DrawLine(Settings.GetCoordX(Line.A.X), Settings.GetCoordY(Line.A.Y),
    Settings.GetCoordX(Line.B.X), Settings.GetCoordY(Line.B.Y), $FF000000);
    }
  sPos := TVec2f.Create(Min(Line.A.X, Line.B.X), Min(Line.A.Y, Line.B.Y));
  fPos := TVec2f.Create(Max(Line.A.X, Line.B.X), Max(Line.A.Y, Line.B.Y));
  Rect.W := 64;
  Rect.H := 64;

  for Y := Round(sPos.Y) div 64 to Round(fPos.Y) div 64 do
    for X := Round(sPos.X) div 64 to Round(fPos.X) div 64 do
      if FMap[X, Y].ItemType = 1 then
      begin
        Rect.X := X * 64;
        Rect.Y := Y * 64;

       { FQuad.Rectangle(Settings.GetCoordX(Rect.X + 16),
          Settings.GetCoordY(Rect.Y + 16),
          Settings.GetCoordX(Rect.X + Rect.W - 16),
          Settings.GetCoordY(Rect.Y + Rect.H - 16), $FFFF0000);
             }
        if Coll.LineRect(Line, Rect) then
        begin
          Result := True;
          Exit;
        end;
      end;
end;

function TMap.CollPlayerLightUgl(Light: PLight; AUgl: Single): Boolean;
  function Ornt(P: TVec2f; Line: T2DLine): Single;
  begin
    Result := (Line.b.X - Line.a.X) * (P.Y - Line.a.Y) - (P.X - Line.a.X) * (Line.b.Y - Line.a.Y);
  end;
var
  Line1, Line2: T2DLine;
  L, R: Single;
  Ugl: Single;
begin
  Line1.a := Light^.Position;
  Ugl := (Light^.Angle - AUgl)/180*Pi;
  Line1.b.X := Line1.a.X + Light^.Radius * cos(Ugl);
  Line1.b.Y := Line1.a.Y + Light^.Radius * sin(Ugl);

  R := Ornt(FHero.Position, Line1);
                {
  FQuad.DrawLine(Settings.GetCoordX(Line1.A.X), Settings.GetCoordY(Line1.A.Y),
    Settings.GetCoordX(Line1.B.X), Settings.GetCoordY(Line1.B.Y), $FF000000);
                 }
  Line2.a := Light^.Position;
  Ugl := (Light^.Angle + AUgl)/180*Pi;
  Line2.b.X := Line2.a.X + Light^.Radius * cos(Ugl);
  Line2.b.Y := Line2.a.Y + Light^.Radius * sin(Ugl);
                 {
  FQuad.DrawLine(Settings.GetCoordX(Line2.A.X), Settings.GetCoordY(Line2.A.Y),
    Settings.GetCoordX(Line2.B.X), Settings.GetCoordY(Line2.B.Y), $FF000000);
                  }
  L := Ornt(FHero.Position, Line2);

  Result := (L < 0) and (R > 0);
end;

function TMap.GetSize: TVec2f;
begin
  Result := TVec2f.Create(FMapW * MAP_SCALE, FMapH * MAP_SCALE);
end;

procedure TMap.MapToLine;
var
  X, Y: Integer;
begin
  LineDelAll;
  for X := 0 to FMapW - 1 do
    for Y := 0 to FMapH - 1 do
      if FMap[X, Y].ItemType = 1 then
        ItemToLine(FMap[X, Y]);
end;

procedure TMap.ItemToLine(AItem: TMapItem);
var
  PointA, PointB: TVec2f;
  i: Integer;
begin
  if (AItem.X > 0) and (FMap[AItem.X - 1, AItem.Y].ItemType <> 1)
    and not AItem.Line[0] then
  begin
    PointA := TVec2f.Create(AItem.X * MAP_SCALE, AItem.Y * MAP_SCALE);
    PointB := TVec2f.Create(AItem.X * MAP_SCALE,
      AItem.Y * MAP_SCALE + MAP_SCALE);
    AItem.Line[0] := True;
    if (FMap[AItem.X, AItem.Y + 1].ItemType = 1) then
      for i := AItem.Y + 1 to FMapH - 1 do
      begin
        if not FMap[AItem.X, i].Line[0] and (FMap[AItem.X, i].ItemType = 1) and
          (FMap[AItem.X - 1, i].ItemType <> 1) then
        begin
          PointB.Y := PointB.Y + MAP_SCALE;
          FMap[AItem.X, i].Line[0] := True;
        end
        else
          Break;
      end;
    PointB.Y := PointB.Y - 5;
    LineAdd(PointA, PointB);
  end;

  if (AItem.Y <> 0) and (FMap[AItem.X, AItem.Y - 1].ItemType <> 1)
    and not AItem.Line[1] then
  begin
    PointA := TVec2f.Create(AItem.X * MAP_SCALE, AItem.Y * MAP_SCALE);
    PointB := TVec2f.Create(AItem.X * MAP_SCALE + MAP_SCALE,
      AItem.Y * MAP_SCALE);
    AItem.Line[1] := True;
    if (FMap[AItem.X + 1, AItem.Y].ItemType = 1) then
      for i := AItem.X + 1 to FMapW - 1 do
      begin
        if not FMap[i, AItem.Y].Line[1] and (FMap[i, AItem.Y].ItemType = 1) and
          (FMap[i, AItem.Y - 1].ItemType <> 1) then
        begin
          PointB.X := PointB.X + MAP_SCALE;
          FMap[i, AItem.Y].Line[1] := True;
        end
        else
          Break;
      end;
    PointB.X := PointB.X - 5;
    LineAdd(PointA, PointB);
  end;

  if (AItem.X <> FMapW - 1) and (FMap[AItem.X + 1, AItem.Y].ItemType <> 1)
    and not AItem.Line[2] then
  begin
    PointA := TVec2f.Create(AItem.X * MAP_SCALE + MAP_SCALE,
      AItem.Y * MAP_SCALE);
    PointB := TVec2f.Create(AItem.X * MAP_SCALE + MAP_SCALE,
      AItem.Y * MAP_SCALE + MAP_SCALE);
    AItem.Line[2] := True;

    if (FMap[AItem.X, AItem.Y + 1].ItemType = 1) then
      for i := AItem.Y + 1 to FMapH - 1 do
      begin
        if not FMap[AItem.X, i].Line[2] and (FMap[AItem.X, i].ItemType = 1) and
          (FMap[AItem.X + 1, i].ItemType <> 1) then
        begin
          PointB.Y := PointB.Y + MAP_SCALE;
          FMap[AItem.X, i].Line[2] := True;
        end
        else
          Break;
      end;
    PointB.Y := PointB.Y - 5;
    LineAdd(PointA, PointB);
  end;

  if (AItem.Y <> FMapH - 1) and (FMap[AItem.X, AItem.Y + 1].ItemType <> 1)
    and not AItem.Line[3] then
  begin
    PointA := TVec2f.Create(AItem.X * MAP_SCALE,
      AItem.Y * MAP_SCALE + MAP_SCALE);
    PointB := TVec2f.Create(AItem.X * MAP_SCALE + MAP_SCALE,
      AItem.Y * MAP_SCALE + MAP_SCALE);
    AItem.Line[3] := True;

    if (FMap[AItem.X + 1, AItem.Y].ItemType = 1) then
      for i := AItem.X + 1 to FMapW - 1 do
      begin
        if not FMap[i, AItem.Y].Line[3] and (FMap[i, AItem.Y].ItemType = 1) and
          (FMap[i, AItem.Y + 1].ItemType <> 1) then
        begin
          PointB.X := PointB.X + MAP_SCALE;
          FMap[i, AItem.Y].Line[3] := True;
        end
        else
          Break;
      end;
    PointB.X := PointB.X - 5;
    LineAdd(PointA, PointB);
  end;
end;

procedure TMap.LineAdd(PointA, PointB: TVec2f);
var
  Line: PMapLine;
begin
  new(Line);

  Line^.PointA := PointA;
  Line^.PointB := PointB;

  FLineList.Add(Line);
end;

procedure TMap.LineDelAll;
var
  i: Integer;
begin
  if FLineList.Count = 0 then
    Exit;

  for i := 0 to FLineList.Count - 1 do
    Dispose(PMapLine(FLineList.Items[i]));
  FLineList.Clear;
end;

function TMap.LinesCollPoint(const A, B, C, D: TVec2f): TVec2f;
var
  t, tmp: Single;
  PointA, PointB: TVec2f;
begin
  PointA := B - A;
  PointB := C - D;

  tmp := 1 / (PointB.X * (-PointA.Y) - (-PointA.X) * PointB.Y);
  t := (PointB.X * (A.Y - C.Y) - (A.X - C.X) * PointB.Y) * tmp;

  Result.X := A.X + t * PointA.X;
  Result.Y := A.Y + t * PointA.Y;
end;

procedure TMap.CollideLine(const ALine: PMapLine);
var
  A, B, C: Single;
  Vector: TVec2f;
  PointA, PointB, PointC, PointD: TVec2f;
begin
  PointA := ALine.PointA - FHero.Position;
  PointB := ALine.PointB - FHero.Position;

  Vector.X := PointB.X - PointA.X;
  Vector.Y := PointB.Y - PointA.Y;

  A := sqr(Vector.X) + sqr(Vector.Y);
  B := (PointA.X * Vector.X + PointA.Y * Vector.Y) * 2;
  C := sqr(PointA.X) + sqr(PointA.Y) - sqr(FHero.Radius);

  if B <= 0 then
  begin
    if -B < A * 2 then
    begin
      if A * C * 4 - sqr(B) < 0 then
      begin
        Vector := (PointB - PointA).Normal.Normalize * FHero.Radius;
        PointC := Vector;
        PointD := -Vector;

        PushOut(LinesCollPoint(PointA, PointB, PointC,
            PointD) + FHero.Position);
      end;
    end
    else if A + B + C < 0 then
      PushOut(ALine.PointB);
  end
  else if C < 0 then
    PushOut(ALine.PointA);
end;

procedure TMap.PushOut(const APoint: TVec2f);
var
  temp: TVec2f;
begin
  temp := FHero.Position - APoint;
  FHero.Move(temp.Normalize * (FHero.Radius - temp.Length));
end;

end.
