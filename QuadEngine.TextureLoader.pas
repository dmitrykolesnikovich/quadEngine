unit QuadEngine.TextureLoader;

interface

uses
  direct3d9, QuadEngine, Generics.Collections, sysutils, classes;

type
  TTextureSignature = array[0..31] of AnsiChar;

  TTextureResult = record
    Texture: IDirect3DTexture9;
    Width, Height: Integer;
    FrameWidth, FrameHeight: Integer;
  end;

  TQuadCustomTextureFormat = class abstract
    class var
      aData : TD3DLockedRect;
      Width, Height: Integer;
      FrameWidth, FrameHeight: Integer;
    class function LoadFromStream(AStream: TMemoryStream; ColorKey: Integer): IDirect3DTexture9; virtual; abstract;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; virtual; abstract;
  end;

  TQuadBMPTextureFormat = class sealed(TQuadCustomTextureFormat)
    class function LoadFromStream(AStream: TMemoryStream; ColorKey: Integer): IDirect3DTexture9; override;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadPNGTextureFormat = class sealed(TQuadCustomTextureFormat)
    class function LoadFromStream(AStream: TMemoryStream; ColorKey: Integer): IDirect3DTexture9; override;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadTGATextureFormat = class sealed(TQuadCustomTextureFormat)
    class function LoadFromStream(AStream: TMemoryStream; ColorKey: Integer): IDirect3DTexture9; override;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadJPGTextureFormat = class sealed(TQuadCustomTextureFormat)
    class function LoadFromStream(AStream: TMemoryStream; ColorKey: Integer): IDirect3DTexture9; override;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadDDSTextureFormat = class sealed(TQuadCustomTextureFormat)
    class function LoadFromStream(AStream: TMemoryStream; ColorKey: Integer): IDirect3DTexture9; override;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadCustomTextureClass = class of TQuadCustomTextureFormat;

  TQuadTextureLoader = class
  private
    class var FFormats: TList<TQuadCustomTextureClass>;
  public
    class constructor Create;
    class destructor Destroy;
    class procedure Register(AQuadCustomTextureClass: TQuadCustomTextureClass);
    class function LoadFromStream(AStream: TMemoryStream): TTextureResult;
  end;

  TQ = (TQuadBMPTextureClass, TQuadPNGTextureClass, TQuadTGATextureClass, TQuadJPGTextureClass, TQuadDDSTextureClass);

implementation

uses
  QuadEngine.Device, VCL.Graphics, VCL.Imaging.pngimage, VCL.Imaging.JPEG, QuadEngine.Utils, TGAReader, BeRoDDS, Math;

{ TQuadJPGTextureFormat }

class function TQuadJPGTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := (ASignature[6] = 'J') and (ASignature[7] = 'F') and (ASignature[8] = 'I') and (ASignature[9] = 'F');
end;

class function TQuadJPGTextureFormat.LoadFromStream(AStream: TMemoryStream; ColorKey: Integer): IDirect3DTexture9;
var
  bmp : TBitmap;
  jpg : TJPEGImage;
  i, j : Integer;
  p : Pointer;
begin
  bmp := TBitmap.Create;
  jpg := TJPEGImage.Create;
  jpg.LoadFromStream(AStream);
  bmp.Assign(jpg);
  jpg.Free;

  if Device.Render.IsSupportedNonPow2 then
  begin
    Width := Ceil(bmp.Width / 4) * 4;
    Height := Ceil(bmp.Height / 4) * 4;
  end
  else
  begin
    Width := NormalizeSize(bmp.Width);
    Height := NormalizeSize(bmp.Height);
  end;

  FrameWidth := bmp.Width;
  FrameHeight := bmp.Height;

  Device.LastResultCode := Device.Render.D3DDevice.CreateTexture(Width, Height, 0, D3DUSAGE_AUTOGENMIPMAP, D3DFMT_X8R8G8B8, D3DPOOL_MANAGED, Result, nil);
  Device.LastResultCode := result.LockRect(0, aData, nil, 0);

  for i := 0 to FrameHeight - 1 do
  begin
    p:= bmp.ScanLine[i];
    for j:= 0 to FrameWidth - 1 do
    begin
      Move(p^, aData.pBits^, 3);
      Inc(NativeInt(aData.pBits), 3);
      Byte(aData.pBits^) := 255;
      Inc(NativeInt(aData.pBits), 1);
      Inc(NativeInt(p), 3);
    end;
    Inc(NativeInt(aData.pBits), 4 * (Width - FrameWidth));
  end;

  Device.LastResultCode := Result.UnlockRect(0);

  bmp.Free;
end;

{ TQuadTGATextureFormat }

class function TQuadTGATextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := Copy(ASignature, 1, 16) = 'TRUEVISION-XFILE';
end;

class function TQuadTGATextureFormat.LoadFromStream(AStream: TMemoryStream; ColorKey: Integer): IDirect3DTexture9;
var
  bmp: TBitmapEx;
  i, j: Integer;
  p: Pointer;
begin
  bmp := TBitmapEx.Create;
  bmp.LoadFromStream(AStream);

  if Device.Render.IsSupportedNonPow2 then
  begin
    Width := Ceil(bmp.Width / 4) * 4;
    Height := Ceil(bmp.Height / 4) * 4;
  end
  else
  begin
    Width := NormalizeSize(bmp.Width);
    Height := NormalizeSize(bmp.Height);
  end;

  FrameWidth := bmp.Width;
  FrameHeight := bmp.Height;

  Device.LastResultCode := Device.Render.D3DDevice.CreateTexture(Width, Height, 0, D3DUSAGE_AUTOGENMIPMAP, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Result, nil);
  Device.LastResultCode := Result.LockRect(0, aData, nil, 0);

  for I := 0 to FrameHeight - 1 do
  begin
    p:= bmp.ScanLine[i];
    for j:= 0 to FrameWidth - 1 do
    begin
      Move(p^, aData.pBits^, 4);
      Inc(NativeInt(aData.pBits), 4);
      Inc(NativeInt(p), 4);
    end;
    Inc(NativeInt(aData.pBits), 4 * (Width - FrameWidth));
  end;

  Device.LastResultCode := Result.UnlockRect(0);

  bmp.Free;
end;

{ TQuadPNGTextureFormat }

class function TQuadPNGTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := Copy(ASignature, 2, 3) = 'PNG';
end;

class function TQuadPNGTextureFormat.LoadFromStream(AStream: TMemoryStream; ColorKey: Integer): IDirect3DTexture9;
var
  bmp : TPngImage;
  i, j : Integer;
  p, pa : Pointer;
begin
  bmp := TPngImage.Create;
  bmp.LoadFromStream(AStream);

  if Device.Render.IsSupportedNonPow2 then
  begin
    Width := Ceil(bmp.Width / 4) * 4;
    Height := Ceil(bmp.Height / 4) * 4;
  end
  else
  begin
    Width := NormalizeSize(bmp.Width);
    Height := NormalizeSize(bmp.Height);
  end;

  FrameWidth := bmp.Width;
  FrameHeight := bmp.Height;

  Device.LastResultCode := Device.Render.D3DDevice.CreateTexture(Width, Height, 0, D3DUSAGE_AUTOGENMIPMAP, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Result, nil);
  Device.LastResultCode := Result.LockRect(0, aData, nil, 0);

  for I := 0 to FrameHeight - 1 do
  begin
    p := bmp.ScanLine[i];
    pa := bmp.AlphaScanline[i];
    for j:= 0 to FrameWidth - 1 do
    begin
      Move(p^, aData.pBits^, 3);
      Inc(NativeInt(aData.pBits), 3);
      Inc(NativeInt(p), 3);

      if pa <> nil then
      begin
        Move(pa^, aData.pBits^, 1);
        Inc(NativeInt(pa), 1);
      end;
      Inc(NativeInt(aData.pBits), 1);

    end;
    Inc(NativeInt(aData.pBits), 4 * (Width - FrameWidth));
  end;

  Device.LastResultCode := Result.UnlockRect(0);

  bmp.Free;
end;

{ TQuadBMPTextureFormat }

class function TQuadBMPTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := Copy(ASignature, 1, 2) = 'BM';
end;

class function TQuadBMPTextureFormat.LoadFromStream(AStream: TMemoryStream; ColorKey: Integer): IDirect3DTexture9;
var
  bmp : TBitmap;
  i, j : Integer;
  p : Pointer;
begin
  bmp := TBitmap.Create;
  bmp.LoadFromStream(AStream);
  if (bmp.PixelFormat <> pf24bit) and (bmp.PixelFormat <> pf32bit) then
    bmp.PixelFormat := pf24bit;

  if Device.Render.IsSupportedNonPow2 then
  begin
    Width := Ceil(bmp.Width / 4) * 4;
    Height := Ceil(bmp.Height / 4) * 4;
  end
  else
  begin
    Width := NormalizeSize(bmp.Width);
    Height := NormalizeSize(bmp.Height);
  end;

  FrameWidth := bmp.Width;
  FrameHeight := bmp.Height;

  Device.LastResultCode := Device.Render.D3DDevice.CreateTexture(Width, Height, 0, D3DUSAGE_AUTOGENMIPMAP, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Result, nil);
  Device.LastResultCode := Result.LockRect(0, aData, nil, 0);

  for I := 0 to FrameHeight - 1 do
  begin
    p := bmp.ScanLine[i];
    for j := 0 to FrameWidth - 1 do
    begin

      if bmp.PixelFormat = pf24bit then
      begin
        Move(p^, aData.pBits^, 3);

        Cardinal(aData.pBits^) := Cardinal(aData.pBits^) ;//and $FF000000 + $00FFFFFF;

        Inc(NativeInt(aData.pBits), 3);

        if ColorKey <> -1 then
        begin
          if (Byte(p^) = (ColorKey shr 16) and $FF) and
             (Byte(Pointer(Integer(p) + 1)^) = (ColorKey shr 8) and $FF) and
             (Byte(Pointer(Integer(p) + 2)^) = ColorKey and $FF) then
            Byte(aData.pBits^) := 0
          else
            Byte(aData.pBits^) := 255;
        end;
        Inc(NativeInt(aData.pBits), 1);
        Inc(NativeInt(p), 3);
      end else
      if bmp.PixelFormat = pf32bit then
      begin
        Move(p^, aData.pBits^, 4);
        Cardinal(aData.pBits^) := Cardinal(aData.pBits^) and $FF000000 + $00FFFFFF;
        Inc(NativeInt(aData.pBits), 4);
        Inc(NativeInt(p), 4);
      end;
    end;
    Inc(NativeInt(aData.pBits), 4 * (Width - FrameWidth));
  end;

  Device.LastResultCode := Result.UnlockRect(0);

  bmp.Free;
end;

class function TQuadDDSTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := Copy(ASignature, 1, 4) = 'DDS ';
end;

class function TQuadDDSTextureFormat.LoadFromStream(AStream: TMemoryStream; ColorKey: Integer): IDirect3DTexture9;
var
  i, j: Integer;
  p: Pointer;
begin
  LoadDDSImage(AStream.Memory, AStream.Size, p, FrameWidth, FrameWidth);

  if Device.Render.IsSupportedNonPow2 then
  begin
    Width := Ceil(FrameWidth / 4) * 4;
    Height := Ceil(FrameHeight / 4) * 4;
  end
  else
  begin
    Width := NormalizeSize(FrameWidth);
    Height := NormalizeSize(FrameHeight);
  end;

  Device.LastResultCode := Device.Render.D3DDevice.CreateTexture(Width, Height, 0, D3DUSAGE_AUTOGENMIPMAP, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Result, nil);
  Device.LastResultCode := Result.LockRect(0, aData, nil, 0);

  System.Move(p, aData, FrameWidth * FrameHeight * 4);

  Device.LastResultCode := Result.UnlockRect(0);
end;

{ TQuadTextureLoader }

class constructor TQuadTextureLoader.Create;
begin
  FFormats := TList<TQuadCustomTextureClass>.Create;
  Register(TQuadBMPTextureFormat);
  Register(TQuadPNGTextureFormat);
  Register(TQuadTGATextureFormat);
  Register(TQuadJPGTextureFormat);
  Register(TQuadDDSTextureFormat);
end;

class destructor TQuadTextureLoader.Destroy;
begin
  FFormats.Free;
end;

class function TQuadTextureLoader.LoadFromStream(AStream: TMemoryStream): TTextureResult;
var
  tf: TQuadCustomTextureClass;
  Signature: TTextureSignature;
  res: Boolean;
begin
  Result.Texture := nil;
  tf := nil;

  AStream.Position := 0;
  AStream.Read(Signature[0], 31);

  res := False;

  for tf in FFormats do
  begin
    res := tf.CheckSignature(Signature);

    if res then
      Break;
  end;

  if (not res) or (not Assigned(tf)) then
  begin
    FreeAndNil(AStream);
    Exit;
  end;

  AStream.Position := 0;
  Result.Texture := tf.LoadFromStream(AStream, -1);
  Result.Width := tf.Width;
  Result.Height := tf.Height;
  Result.FrameWidth := tf.FrameWidth;
  Result.FrameHeight := tf.FrameHeight;

  FreeAndNil(AStream);
end;

class procedure TQuadTextureLoader.Register(AQuadCustomTextureClass: TQuadCustomTextureClass);
begin
  FFormats.Add(AQuadCustomTextureClass);
end;

end.
