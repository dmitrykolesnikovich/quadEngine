unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, quadengine, Direct3D9;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  qr: IQuadRender;
  qt: IQuadTimer;

  water: IQuadTexture;
  watershader: IQuadShader;

  LightPos: TD3DVector;
  Vector: TD3DVector;
  Time: Single;

implementation

uses Math;

{$R *.dfm}

procedure OnTimer(var delta: Double);
begin
  qr.BeginRender;
  qr.Clear(0);

  qr.SetBlendMode(qbmNone);

  qr.SetTextureAdressing(D3DTADDRESS_WRAP);
  watershader.SetShaderState(True);
  water.Draw(0, 0, $FFFFFFFF);
  watershader.SetShaderState(False);
  qr.SetTextureAdressing(D3DTADDRESS_CLAMP);

  qr.EndRender;

  Time := Time + delta / 100;
  if Time > 1.0 then
    Time := Time - 1.0;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  m: TD3DMatrix;
begin
  qr := CreateQR;
  qr.Initialize(Self.Handle, 800, 600, False);

  water := qr.CreateTexture;
  water.LoadFromFile(0, 'height2.jpg');
  water.LoadFromFile(1, 'normal2.jpg');
  water.LoadFromFile(2, 'sky.jpg');
  water.LoadFromFile(3, 'floor.jpg');

  watershader := qr.CreateShader;
  watershader.LoadComplexShader('vs_temp.bin', 'ps_temp.bin');

  qr.GetD3DDevice.GetTransform(D3DTS_PROJECTION,  m);
  qr.GetD3DDevice.SetVertexShaderConstantF(0, @m, 4);
  watershader.BindVariableToVS(4, @LightPos, 1);
  watershader.BindVariableToPS(0, @Time, 1);
  watershader.BindVariableToPS(1, @Vector, 1);

  Randomize;
  Vector.x := Random(200)/100 - 1;
  Vector.y := Random(200)/100 - 1;

  qt := qr.CreateTimer;
  qt.SetInterval(16);
  qt.SetCallBack(OnTimer);
  qt.SetState(True);
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  LightPos.x := X - 400;
  LightPos.y := Y - 300;
  LightPos.z := 1.0;

    Vector.x := -(x - 400) / 200;
  Vector.y := -(y - 300) / 150;
end;

end.
 