unit GBuffer;

interface

uses
  QuadEngine, Vec2f, system.generics.collections, Map;

type
  TGBuffer = class
  const
    GWidth = 1024;
    GHeight = 768;
  private
    FGBuf: IQuadGBuffer;
    FShader: IQuadShader;
    FLightPos: TVec3f;
    FVPM: TMatrix4x4;
    FLightUV: array[0..3] of Single;
    FBackGround: IQuadTexture;
    FCrater: IQuadTexture;
    FWall: IQuadTexture;
    FBox: IQuadTexture;
    procedure DrawDiffuse;
  public
    FCraters: TList<TVec2f>;

    constructor Create;
    procedure Draw;
    procedure DrawLight(const APos: TVec3f; ARadius: single; AColor: Cardinal);
    property GBuf: IQuadGBuffer read FGBuf;
  class var
    QuadDevice: IQuadDevice;
    QuadWindow: IQuadWindow;
    QuadRender: IQuadRender;
    QuadTimer: IQuadTimer;
    QuadCamera: IQuadCamera;
  end;

var
  Level: TMap;

implementation

{ TGBuffer }

constructor TGBuffer.Create;
begin
  QuadDevice.CreateGBuffer(FGBuf);

  QuadDevice.CreateAndLoadTexture(0, 'data\5216-diffuse.jpg', FBackGround);
  FBackGround.LoadFromFile(1, 'data\5216-normal.jpg');
  FBackGround.LoadFromFile(2, 'data\5216-specular.jpg');
  FBackGround.LoadFromFile(3, 'data\5216-bump.jpg');

  QuadDevice.CreateAndLoadTexture(0, 'data\crater.png', FCrater);
  FCrater.LoadFromFile(1, 'data\crater_normal.png');
  FCrater.LoadFromFile(2, 'data\crater_specular.png');
  FCrater.LoadFromFile(3, 'data\crater_height.png');

  QuadDevice.CreateAndLoadTexture(0, 'data\wall.png', FWall);
  FWall.LoadFromFile(1, 'data\wall_normal.png');
  FWall.LoadFromFile(2, 'data\blank_specular64.png');
  FWall.LoadFromFile(3, 'data\wall_height.png');

  QuadDevice.CreateAndLoadTexture(0, 'data\crate.png', FBox);
  FBox.LoadFromFile(1, 'data\crate_normal.png');
  FBox.LoadFromFile(2, 'data\blank_specular64.png');
  FBox.LoadFromFile(3, 'data\crate_height.png');

  TGBuffer.QuadDevice.CreateShader(FShader);
  FShader.LoadComplexShader('data\DefferedShading_vs.bin', 'data\DefferedShading_ps.bin');
  FShader.BindVariableToVS(4, @FlightPos, 1);
  FShader.BindVariableToPS(5, @FLightUV[0], 1);


  FShader.BindVariableToVS(0, @FVPM, 4);

  FCraters := TList<TVec2f>.Create;
end;

procedure TGBuffer.Draw;
begin
  DrawDiffuse;

  QuadRender.SetBlendMode(qbmNone);
  QuadCamera.Enable;
  FGBuf.DiffuseMap.Draw(TVec2f.Zero, $FF111111);
  QuadCamera.Disable;
end;

procedure TGBuffer.DrawDiffuse;
var
  i, j: Integer;
begin
  FVPM := TGBuffer.QuadCamera.GetMatrix;

  QuadCamera.Enable;
  QuadRender.RenderToGBuffer(True, FGBuf);

  QuadRender.SetBlendMode(qbmNone);
  FBackGround.Draw(TVec2f.Create(0, 0));
  FBackGround.Draw(TVec2f.Create(512, 512));
  FBackGround.Draw(TVec2f.Create(0, 512));
  FBackGround.Draw(TVec2f.Create(512, 0));
  FBackGround.Draw(TVec2f.Create(-512, -512));
  FBackGround.Draw(TVec2f.Create(0, -512));
  FBackGround.Draw(TVec2f.Create(-512, 0));

  for i := 0 to Level.Width - 1 do
    for j := 0 to Level.Height - 1 do
    case Level.Field[i, j] of
      mcBoxEmpty: FBox.Draw(TVec2f.Create(i*64, j*64));
      mcWall    : FWall.Draw(TVec2f.Create(i*64, j*64));
    end;

  QuadRender.SetBlendMode(qbmSrcAlpha);
  for i := 0 to FCraters.Count - 1 do
    FCrater.DrawRot(FCraters[i], 0, 1.5);

 QuadRender.RenderToGBuffer(False);

  QuadCamera.Disable;
end;

procedure TGBuffer.DrawLight(const APos: TVec3f; ARadius: single; AColor: Cardinal);
begin
  TGBuffer.QuadRender.SetBlendMode(qbmSrcAlphaAdd);

  Flightpos := TVec3f.Create(APos.X * GWidth * Aradius - (GWidth) / 2 + GWidth * Aradius / 2, APos.Y * GHeight * Aradius + GHeight * Aradius / 2 - GHeight / 3, Apos.Z);
  FlightUV[0] := APos.X;
  FlightUV[1] := APos.Y;
  FlightUV[2] := APos.Z;
  FlightUV[3] := Aradius;

  FShader.SetShaderState(True);
{  FGBuf.Buffer.DrawMap(TVec2f.Create((APos.X - Aradius) * GWidth, (APos.Y - Aradius) * GHeight),
                TVec2f.Create((APos.X + Aradius) * GWidth, (APos.Y + Aradius) * GHeight),
                TVec2f.Create(APos.X - Aradius, APos.Y - Aradius),
                TVec2f.Create(APos.X + Aradius, APos.Y + Aradius),
                AColor);}
  FGBuf.Buffer.DrawMap(TVec2f.Create((APos.X - Aradius) * GWidth, (APos.Y - Aradius) * GHeight),
                TVec2f.Create((APos.X + Aradius) * GWidth, (APos.Y + Aradius) * GHeight),
                TVec2f.Create(APos.X - Aradius, APos.Y - Aradius),
                TVec2f.Create(APos.X + Aradius, APos.Y + Aradius),
                AColor);
  FShader.SetShaderState(False);
end;

end.
