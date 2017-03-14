{==============================================================================

  Quad engine 0.3.0 header file for CodeGear™ Delphi®

     ╔═══════════╦═╗
     ║           ║ ║
     ║           ║ ║
     ║ ╔╗ ║║ ╔╗ ╔╣ ║
     ║ ╚╣ ╚╝ ╚╩ ╚╝ ║
     ║  ║ engine   ║
     ║  ║          ║
     ╚══╩══════════╝

  For further information please visit:
  http://quad-engine.com

==============================================================================}

unit QuadEngine;

interface

uses
  windows, Direct3d9;

const
  LibraryName: PChar = 'qei.dll';
  CreateQuadRenderProcName: PChar = 'CreateQuadRender';
  CreateQuadWindowProcName: PChar = 'CreateQuadWindow';
  SecretMagicFunctionProcName: PChar = 'SecretMagicFunction';

type
  // Blending mode types
  TQuadBlendMode = (qbmNone        = 0,     { Without blending }
                    qbmAdd         = 1,     { Add source to dest }
                    qbmSrcAlpha    = 2,     { Blend dest with alpha to source }
                    qbmSrcAlphaAdd = 3,     { Add source with alpha to dest }
                    qbmSrcAlphaMul = 4,     { Multiply source alpha with dest }
                    qbmMul         = 5,     { Multiply Source with dest }
                    qbmSrcColor    = 6,     { Blend source with color weight to dest }
                    qbmSrcColorAdd = 7);    { Blend source with color weight and alpha to dest }

  // Vector record declaration
  TVector = packed record
    x: Single;
    y: Single;
    z: Single;
  end;

  // vertex record declaration
  TVertex = packed record
    x, y, z : Single;         { X, Y of vertex. Z not used }
    normal  : TVector;        { Normal vector }
    color   : Cardinal;       { Color }
    u, v    : Single;         { Texture UV coord }
    tangent : TVector;        { Tangent vector }
    binormal: TVector;        { Binormal vector }
  end;

  // forward interfaces declaration
  IQuadRender  = interface;
  IQuadTexture = interface;
  IQuadShader  = interface;
  IQuadFont    = interface;
  IQuadLog     = interface;
  IQuadTimer   = interface;
  IQuadWindow  = interface;

  { Quad Render }

  // OnError routine. Calls whenever error occurs
  TOnErrorFunction = procedure(Errorstring: PAnsiChar);

  IQuadRender = interface(IUnknown)
    ['{D9E9C42B-E737-4CF9-A92F-F0AE483BA39B}']
    procedure AddTrianglesToBuffer(const AVertexes: array of TVertex; ACount: Cardinal); stdcall;
    procedure BeginRender; stdcall;
    procedure ChangeResolution(AWidth, AHeight: Word); stdcall;
    procedure Clear(AColor: Cardinal); stdcall;
    function CreateAndLoadFont(AFontTextureFilename, AUVFilename: PAnsiChar): IQuadFont; stdcall;
    function CreateAndLoadTexture(aRegister: Byte; aFilename: PAnsiChar;
      ColorKey: Integer = -1): IQuadTexture; overload; stdcall;
    function  CreateAndLoadTexture(aRegister: Byte; aFilename: PAnsiChar;
      PatternWidth, PatternHeight: Integer; ColorKey: Integer = -1): IQuadTexture; overload; stdcall;
    function CreateFont: IQuadFont; stdcall;
    procedure CreateOrthoMatrix; stdcall;
    procedure CreateRenderTexture(AWidth, AHeight: Word; var AQuadTexture: IQuadTexture; ARegister: Byte); stdcall;
    function CreateShader: IQuadShader; stdcall;
    function CreateTexture: IQuadTexture; stdcall;
    function CreateTimer: IQuadTimer; stdcall;
    procedure DrawDistort(x1, y1, x2, y2, x3, y3, x4, y4: Double; u1, v1, u2, v2: Double; Color: Cardinal); stdcall;
    procedure DrawRect(x, y, x2, y2: Double; u1, v1, u2, v2: Double; Color: Cardinal); stdcall;
    procedure DrawRectRot(x, y, x2, y2, ang, Scale: Double; u1, v1, u2, v2: Double; Color: Cardinal); stdcall;
    procedure DrawRectRotAxis(x, y, x2, y2, ang, Scale, xA, yA: Double; u1, v1, u2, v2: Double; Color: Cardinal); stdcall;
    procedure DrawLine(x, y, x2, y2: Single; Color: Cardinal); stdcall;
    procedure DrawPoint(x, y: Single; Color: Cardinal); stdcall;
    procedure EndRender; stdcall;
    procedure Finalize; stdcall;
    procedure FlushBuffer; stdcall;
    function GetAvailableTextureMemory: Cardinal; stdcall;
    function GetD3DDevice: IDirect3DDevice9; stdcall;
    function GetIsResolutionSupported(AWidth, AHeight: Word): Boolean; stdcall;
    function GetLastError: PAnsiChar; stdcall;
    function GetMaxAnisotropy: Cardinal; stdcall;
    function GetMaxTextureHeight: Cardinal; stdcall;
    function GetMaxTextureStages: Cardinal; stdcall;
    function GetMaxTextureWidth: Cardinal; stdcall;
    function GetMonitorsCount: Byte; stdcall;
    function GetPixelShaderVersionString: PAnsiChar; stdcall;
    function GetPSVersionMajor: Byte; stdcall;
    function GetPSVersionMinor: Byte; stdcall;
    function GetQuadLog: IQuadLog; stdcall;
    function GetRenderTexture(index: Integer): IDirect3DTexture9; stdcall;
    function GetSupportedScreenResolution(index: Integer): TCoord; stdcall;
    function GetVertexShaderVersionString: PAnsiChar; stdcall;
    function GetVSVersionMajor: Byte; stdcall;
    function GetVSVersionMinor: Byte; stdcall;
    procedure Initialize(AHandle : THandle; AWidth, AHeight : Integer;
      AIsFullscreen : Boolean; AIsCreateLog : Boolean = True);  stdcall;
    procedure InitializeFromIni(AHandle: THandle; AFilename: PAnsiChar); stdcall;
    procedure Rectangle(x, y, x2, y2: Double; Color: Cardinal); overload; stdcall;
    procedure Rectangle(x, y, x2, y2: Double; Color1, Color2, Color3, Color4: Cardinal); overload; stdcall;
    procedure RenderToTexture(AIsRenderToTexture : Boolean; AQuadTexture: IQuadTexture;
      ARegister: Byte = 0; AIsCropScreen: Boolean = False); stdcall;
    procedure ResetDevice; stdcall;
    procedure SetActiveMonitor(AMonitorIndex: Byte); stdcall;
    procedure SetAutoCalculateTBN(Value: Boolean); stdcall;
    procedure SetBlendMode(qbm: TQuadBlendMode); stdcall;
    procedure SetClipRect(X, Y, X2, Y2: Cardinal); stdcall;
    procedure SetPointSize(ASize: Cardinal); stdcall;
    procedure SetTexture(ARegister: Byte; ATexture: IDirect3DTexture9); stdcall;
    procedure SetTextureAdressing(ATextureAdressing: TD3DTextureAddress); stdcall;
    procedure SetTextureFiltering(ATextureFiltering: TD3DTextureFilterType); stdcall;
    procedure SkipClipRect; stdcall;
  end;

  { Quad Texture }

  IQuadTexture = interface(IUnknown)
    ['{9A617F86-2CEC-4701-BF33-7F4989031BBA}']
    procedure AddTexture(ARegister: Byte; ATexture: IDirect3DTexture9); stdcall;
    procedure Draw(x, y: Double; Color: Cardinal); overload; stdcall;
    procedure Draw(x, y: Double; Color: Cardinal; Pattern: Word); overload; stdcall;
    procedure DrawDistort(x1, y1, x2, y2, x3, y3, x4, y4: Double; Color: Cardinal); stdcall;
    procedure DrawMap(x, y, x2, y2, u1, v1, u2, v2: Double; Color: Cardinal); stdcall;
    procedure DrawMapRotAxis(x, y, x2, y2, u1, v1, u2, v2, xA, yA, angle, Scale: Double; Color: Cardinal); stdcall;    
    procedure DrawRot(x, y, angle, Scale: Double; Color: Cardinal); overload; stdcall;
    procedure DrawRot(x, y, angle, Scale: Double; Color: Cardinal; Pattern: Word); overload; stdcall;
    procedure DrawRotAxis(x, y, angle, Scale, xA, yA: Double; Color: Cardinal); overload; stdcall;
    procedure DrawRotAxis(x, y, angle, Scale, xA, yA: Double; Color: Cardinal; Pattern: Word); overload; stdcall;
    function GetIsLoaded: Boolean; stdcall;
    function GetPatternCount: Integer; stdcall;
    function GetPatternHeight: Word; stdcall;
    function GetPatternWidth: Word; stdcall;
    function GetSpriteHeight: Word; stdcall;
    function GetSpriteWidth: Word; stdcall;
    function GetTexture(i: Byte): IDirect3DTexture9; stdcall;
    function GetTextureHeight: Word; stdcall;
    function GetTextureWidth: Word; stdcall;
    procedure LoadFromFile(aRegister: Byte; aFilename: PAnsiChar; ColorKey: Integer = -1); overload; stdcall;
    procedure LoadFromFile(aRegister: Byte; aFilename: PAnsiChar; PatternWidth, PatternHeight: Integer;
      ColorKey: Integer = -1); overload; stdcall;
    procedure LoadFromRAW(ARegister: Byte; AData: Pointer; AWidth, AHeight: Integer); stdcall;
    procedure SetIsLoaded(AWidth, AHeight: Word); stdcall;
  end;

  { Quad Shader }

  IQuadShader = interface(IUnknown)
    ['{7B7F4B1C-7F05-4BC2-8C11-A99696946073}']
    procedure BindVariableToPS(ARegister: Byte; AVariable: Pointer; ASize: Byte); stdcall;
    procedure BindVariableToVS(ARegister: Byte; AVariable: Pointer; ASize: Byte); stdcall;
    function GetVertexShader: IDirect3DVertexShader9; stdcall;
    function GetPixelShader: IDirect3DPixelShader9; stdcall;
    procedure LoadComplexShader(AVertexShaderFilemname, APixelShaderFilename: PAnsiChar); stdcall;
    procedure LoadPixelShader(APixelShaderFilename: PAnsiChar); stdcall;
    procedure LoadVertexShader(AVertexShaderFilemname: PAnsiChar); stdcall;
    procedure SetShaderState(AIsEnabled: Boolean); stdcall;
  end;

  { Quad Font }


  { Predefined colors for SmartColoring:
      W - white
      Z - black (zero)
      R - red
      L - lime
      B - blue
      M - maroon
      G - green
      N - Navy
      Y - yellow
      F - fuchsia
      A - aqua
      O - olive
      P - purple
      T - teal
      D - gray (dark)
      S - silver

      ! - default DrawText color
    ** Do not override "!" char **  }

  // font alignments
  TqfAlign = (qfaLeft   = 0,      { Align by left }
              qfaRight  = 1,      { Align by right }
              qfaCenter = 2);     { Align by center }

  IQuadFont = interface(IUnknown)
    ['{A47417BA-27C2-4DE0-97A9-CAE546FABFBA}']
    function GetIsLoaded: Boolean; stdcall;
    function GetKerning: Single; stdcall;
    procedure LoadFromFile(ATextureFilename, AUVFilename : PAnsiChar); stdcall;
    procedure SetSmartColor(AColorChar: AnsiChar; AColor: Cardinal); stdcall;
    procedure SetIsSmartColoring(Value: Boolean); stdcall;
    procedure SetKerning(AValue: Single); stdcall;
    function TextHeight(AText: PAnsiChar; AScale: Single = 1.0): Single; stdcall;
    function TextWidth(AText: PAnsiChar; AScale: Single = 1.0): Single; stdcall;
    procedure TextOut(x, y, scale: Single; text: PAnsiChar; Color: Cardinal); stdcall;
    procedure TextOutAligned(x, y, scale: Single; text: PAnsiChar; Color: Cardinal; Align: TqfAlign = qfaLeft); stdcall;
    procedure TextOutCentered(x, y, scale: Single; text: PAnsiChar; Color: Cardinal); stdcall;
  end;

  {Quad Log}

  IQuadLog = interface(IUnknown)
    ['{7A4CE319-C7AF-4BF3-9218-C2A744F915E6}']
    procedure Write(const aString: string); stdcall;
  end;

  {Quad Timer}

  TTimerProcedure = procedure(var delta: Double);
  { template:
    procedure OnTimer(var delta: Double);
    begin

    end;
  }
  IQuadTimer = interface(IUnknown)
    ['{EA3BD116-01BF-4E12-B504-07D5E3F3AD35}']
    function GetCPUload: Single; stdcall;
    function GetDelta: Double; stdcall;
    function GetFPS: Single; stdcall;
    function GetWholeTime: Double; stdcall;
    procedure ResetWholeTimeCounter; stdcall;
    procedure SetCallBack(AProc: TTimerProcedure); stdcall;
    procedure SetInterval(AInterval: Word); stdcall;
    procedure SetState(AIsEnabled: Boolean); stdcall;
  end;

  {Quad Sprite}     {not implemented yet. do not use}

  IQuadSprite = interface(IUnknown)
  ['{3E6AF547-AB0B-42ED-A40E-8DC10FC6C45F}']
    procedure Draw; stdcall;
    procedure SetPosition(X, Y: Double); stdcall;
    procedure SetVelocity(X, Y: Double); stdcall;
  end;

  {Quad Window}     {not implemented yet. do not use}
  IQuadWindow = interface(IUnknown)
  ['{E8691EB1-4C5D-4565-8B78-3FC7C620DFFB}']
    function GetHandle: Cardinal; stdcall;
    procedure SetPosition(ATop, ALeft: Integer); stdcall;
    procedure SetDimentions(AWidth, AHeight: Integer); stdcall;
    procedure CreateWindow; stdcall;
  end;


  TCreateQuadRender    = function: IQuadRender;
  TCreateQuadWindow    = function: IQuadWindow;
  TSecretMagicFunction = function: PAnsiChar;

  function CreateQR: IQuadRender;
  function CreateWindow: IQuadWindow;

implementation

// Creating of main Quad interface object
function CreateQR: IQuadRender;
var
  h: THandle;
  Creator: TCreateQuadRender;
begin
  h := LoadLibrary(LibraryName);
  Creator := GetProcAddress(h, CreateQuadRenderProcName);
  if Assigned(Creator) then
  Result := Creator;
end;

// Creating of Quad window interface object
function CreateWindow: IQuadWindow;
var
  h: THandle;
  Creator: TCreateQuadWindow;
begin
  h := LoadLibrary(LibraryName);
  Creator := GetProcAddress(h, CreateQuadWindowProcName);
  if Assigned(Creator) then
  Result := Creator;
end;

end.
