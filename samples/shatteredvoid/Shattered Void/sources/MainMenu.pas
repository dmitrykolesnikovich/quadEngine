unit MainMenu;

interface

uses
  Windows, Graphics, Classes, QuadEngine;

type
  // forward declaration
  TCustomMenuItem = class;
  TSubMenuItem = class;
  TTopMenuItem = class;
  TSubMenuBooleanItem = class;
  TSubMenuIntegerItem = class;
  TSubMenuSelectionItem = class;

  TMenu = class;

  TOnChangeItem = procedure(AIsNext: Boolean) of object;
  TOnEnterItem = procedure of object;

  TCustomMenuItem = class
  private
    FFontSize: Single;
    FFontColor: Cardinal;
    FQuadRender: IQuadRender;
    FCaption: String;
    FHeight: Single;
    FEnabled: Boolean;
    FMenu: TMenu;
    FOnChange: TOnChangeItem;
    FOnEnter: TOnEnterItem;
    FParent: TCustomMenuItem;
    FWidth: Single;
    procedure SetCaption(const Value: String);
  public
    constructor Create(AQuadRender: IQuadRender; AMenu: TMenu); virtual;

    procedure DoOnChange(AIsNext: Boolean); virtual;
    procedure Draw(AXpos, AYpos: Double); virtual; abstract;

    property Caption: String read FCaption write SetCaption;
    property Height: Single read FHeight;
    property Enabled: Boolean read FEnabled write FEnabled;
    property OnChange: TOnChangeItem read FOnChange write FOnChange;
    property OnEnter: TOnEnterItem read FOnEnter write FOnEnter;
    property Parent: TCustomMenuItem read FParent;
    property Width: Single read FWidth;
  end;

  TTopMenuItem = class(TCustomMenuItem)
  public
    function AddSubMenuItem: TSubMenuItem;
    function AddSubMenuBooleanItem: TSubMenuBooleanItem;
    function AddSubMenuIntegerItem: TSubMenuIntegerItem;
    function AddSubMenuSelectionItem: TSubMenuSelectionItem;
    procedure Draw(AXpos, AYpos: Double); override;
  end;

  TSubMenuItem = class(TCustomMenuItem)
  private

  public
    procedure Draw(AXpos, AYpos: Double); override;
    constructor Create(AQuadRender: IQuadRender; AMenu: TMenu); override;
  end;

  TSubMenuBooleanItem = class(TSubMenuItem)
  private
    FValue: Boolean;
    FLinkedValue: PBoolean;
    function GetValue: Boolean;
    procedure SetValue(const Value: Boolean);
  public
    procedure DoOnChange(AIsNext: Boolean); override;
    procedure Draw(AXpos, AYpos: Double); override;
    procedure LinkWithVar(aVar: PBoolean);

    property Value: Boolean read GetValue write SetValue;
  end;

  TSubMenuIntegerItem = class(TSubMenuItem)
  private
    FMaxValue: Integer;
    FMinValue: Integer;
    FValue: Integer;
    FLinkedValue: PInteger;
    function GetValue: Integer;
    procedure SetValue(const AValue: Integer);
  public
    procedure DoOnChange(AIsNext: Boolean); override;
    procedure Draw(AXpos, AYpos: Double); override;
    procedure LinkWithVar(aVar: PInteger);

    property MaxValue: Integer read FMaxValue write FMaxValue;
    property MinValue: Integer read FMinValue write FMinValue;
    property Value: Integer read GetValue write SetValue;
  end;

  TSubMenuSelectionItem = class(TSubMenuItem)
  private
    FItems: TStringList;
    FItemIndex: Integer;
    FLinkedValue: PInteger;
    function GetItemIndex: Integer;
    procedure SetItemIndex(const Value: Integer);
  public
    destructor Destroy; override;

    procedure AfterConstruction; override;
    procedure DoOnChange(AIsNext: Boolean); override;
    procedure Draw(AXpos, AYpos: Double); override;
    procedure LinkWithVar(aVar: PInteger);

    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property Items: TStringList read FItems write FItems;
  end;

  TMenu = class
  private
    FQuadRender: IQuadRender;
    FList: TList;
    FSelectedItem: TCustomMenuItem;
    FSelectedSubItem: TCustomMenuItem;
    FTopMenuPosition: Integer;
    FTime: Double;
    function GetItem(Index: Integer): TCustomMenuItem;
    function GetItemsCount: Integer;
    procedure FindNextItem;
    procedure FindNextSubItem;
    procedure FindPrevItem;
    procedure FindPrevSubItem;
  public
    constructor Create(AQuadRender: IQuadRender);
    destructor Destroy; override;

    function AddItem: TTopMenuItem;
    procedure Draw(ADelta: Double);
    procedure KeyPress(Key: Word);

    property Items[Index: Integer]: TCustomMenuItem read GetItem; default;
    property ItemsCount: Integer read GetItemsCount;
  end;

function Animate(A, B, Time: Double): Double;

implementation

uses SysUtils, Math, Resources, iSettings;

function Animate(A, B, Time: Double): Double;
begin
  Result := (B - A) * (Time * Time * (3 - 2 * Time)) + A;
end;

{ TCustomListItem }

constructor TCustomMenuItem.Create(AQuadRender: IQuadRender; AMenu: TMenu);
begin
  FFontSize := 1.0;
  FFontColor := $FFFFFFFF;
  FQuadRender := AQuadRender;
  FMenu := AMenu;
  FEnabled := True;

  AfterConstruction; 
end;

{ TMenu }

function TMenu.AddItem: TTopMenuItem;
begin
  Result := TTopMenuItem.Create(FQuadRender, Self);
  FList.Add(Result);

  if FSelectedItem = nil then
    FSelectedItem := Result;
end;

constructor TMenu.Create(AQuadRender: IQuadRender);
begin
  FQuadRender := AQuadRender;
  FSelectedItem := nil;
  FList := TList.Create;
  FTopMenuPosition := 0;
end;

destructor TMenu.Destroy;
var
  i: Integer;
begin
  if ItemsCount > 0 then
    for i := ItemsCount - 1 downto 0 do
      Items[i].Free;

  FList.Free;

  inherited;
end;

procedure TMenu.Draw(ADelta: Double);
var
  i, j: Integer;
  TopItemPos, SubItemPos: Single;
  SelColor: Cardinal;
begin
  FTime := FTime + ADelta;
  if FTime > 1.5 then
    FTime := FTime - 1.5;

  TopItemPos := 100;

  FQuadRender.SetBlendMode(qbmSrcAlpha);

  if ItemsCount > 0 then
    for i := 0 to ItemsCount - 1 do
    begin
      if (Items[i] is TTopMenuItem) then
      begin
        if FSelectedItem = Items[i] then
        begin
          FQuadRender.Rectangle(TopItemPos, 200, TopItemPos + Items[i].Width, 200 + Items[i].Height, $FF224444);

          SubItemPos := Items[i].Height + 20;
          for j := 0 to ItemsCount - 1 do
            if (Items[j] is TSubMenuItem) and (Items[j].Parent = FSelectedItem) then
            begin
              if FSelectedSubItem = Items[j] then
              begin
                SelColor := $00000000 + Trunc(Animate($00, $22, FTime)) shl 16 + Trunc(Animate($00, $44, FTime)) shl 8 + Trunc(Animate($00, $44, FTime));
                FQuadRender.SetBlendMode(qbmAdd);
                FQuadRender.Rectangle(0, 200 + SubItemPos, Settings.WindowWidth, 200 + SubItemPos + Items[j].Height, SelColor);
                FQuadRender.SetBlendMode(qbmSrcAlpha);
              end;

              Items[j].Draw(TopItemPos, 200 + SubItemPos);
              SubItemPos := SubItemPos + Items[j].Height + 5;
            end;
        end;

        Items[i].Draw(TopItemPos, 200);
        TopItemPos := TopItemPos + Items[i].Width + 40;
      end;
    end;
end;

procedure TMenu.FindNextItem;
var
  i, j: Integer;
begin
  if FSelectedSubItem <> nil then
    Exit;

  j := ItemsCount;
  for i := 0 to ItemsCount - 1 do
  begin
    if FSelectedItem = Items[i] then
      j := i;

    if (Items[i] is TTopMenuItem) and (j < i) then
    begin
      FSelectedItem := Items[i];
      Exit;
    end;
  end;
end;

procedure TMenu.FindNextSubItem;
var
  i, j: Integer;
begin
  FTime := 0.75;

  if FSelectedSubItem = nil then
    j := 0
  else
    j := ItemsCount;

  for i := 0 to ItemsCount - 1 do
  begin
    if FSelectedSubItem = Items[i] then
      j := i;

    if Items[i].Enabled and (Items[i] is TSubMenuItem) and (j < i) and (Items[i].Parent = FSelectedItem) then
    begin
      FSelectedSubItem := Items[i];
      Exit;
    end;
  end;

  FSelectedSubItem := nil;
end;

procedure TMenu.FindPrevItem;
var
  i, j: Integer;
begin
  if FSelectedSubItem <> nil then
    Exit;
    
  j := 0;
  for i := ItemsCount - 1 downto 0 do
  begin
    if FSelectedItem = Items[i] then
      j := i;

    if (Items[i] is TTopMenuItem) and (j > i) then
    begin
      FSelectedItem := Items[i];
      Exit;
    end;
  end;
end;

procedure TMenu.FindPrevSubItem;
var
  i, j: Integer;
begin
  FTime := 0.75;

  if FSelectedSubItem = nil then
    j := ItemsCount
  else
    j := 0;

  for i := ItemsCount - 1 downto 0 do
  begin
    if FSelectedSubItem = Items[i] then
      j := i;

    if Items[i].Enabled and (Items[i] is TSubMenuItem) and (j > i) and (Items[i].Parent = FSelectedItem) then
    begin
      FSelectedSubItem := Items[i];
      Exit;
    end;
  end;
  FSelectedSubItem := nil;
end;

function TMenu.GetItem(Index: Integer): TCustomMenuItem;
begin
  Result := TCustomMenuItem(FList[Index]);
end;

function TMenu.GetItemsCount: Integer;
begin
  Result := FList.Count;
end;

procedure TMenu.KeyPress(Key: Word);
begin
  if FSelectedSubItem = nil then
  case Key of
    VK_RIGHT: FindNextItem;
    VK_LEFT: FindPrevItem;
  end
  else
  begin
    case Key of
      VK_RIGHT, VK_LEFT: FSelectedSubItem.DoOnChange(Key = VK_RIGHT);
    end;
  end;

  case Key of
    VK_DOWN: FindNextSubItem;
    VK_UP: FindPrevSubItem;
    VK_ESCAPE: FSelectedSubItem := nil;
    VK_RETURN:
      if (FSelectedSubItem <> nil) then
      begin
        if Assigned(FSelectedSubItem.OnEnter) then
          FSelectedSubItem.OnEnter;
      end
      else
        if Assigned(FSelectedItem.OnEnter) then
          FSelectedItem.OnEnter;
      
  end;
end;

{ TTopMenuItem }

function TTopMenuItem.AddSubMenuBooleanItem: TSubMenuBooleanItem;
begin
  Result := TSubMenuBooleanItem.Create(FQuadRender, FMenu);
  Result.FParent := Self;
  FMenu.FList.Add(Result);
end;

function TTopMenuItem.AddSubMenuIntegerItem: TSubMenuIntegerItem;
begin
  Result := TSubMenuIntegerItem.Create(FQuadRender, FMenu);
  Result.FParent := Self;
  FMenu.FList.Add(Result);
end;

function TTopMenuItem.AddSubMenuItem: TSubMenuItem;
begin
  Result := TSubMenuItem.Create(FQuadRender, FMenu);
  Result.FParent := Self;
  FMenu.FList.Add(Result);
end;

function TTopMenuItem.AddSubMenuSelectionItem: TSubMenuSelectionItem;
begin
  Result := TSubMenuSelectionItem.Create(FQuadRender, FMenu);
  Result.FParent := Self;
  FMenu.FList.Add(Result);
end;

procedure TTopMenuItem.Draw(AXpos, AYpos: Double);
begin
  inherited;
  Fonts.Console.TextOut(AXpos+2, AYPos+2, FFontSize, PChar(FCaption), $FFCCCCCC);
  Fonts.Console.TextOut(AXpos, AYPos, FFontSize, PChar(FCaption), $FF000000);
end;

procedure TCustomMenuItem.DoOnChange(AIsNext: Boolean);
begin
  if Assigned(FOnChange) then
    FOnChange(AIsNext);
end;

procedure TCustomMenuItem.SetCaption(const Value: String);
begin
  FCaption := Value;
  FWidth:= Fonts.Console.TextWidth(PChar(FCaption), FFontSize);
  FHeight:= Fonts.Console.TextHeight(PChar(FCaption), FFontSize);

  if Value = '-' then
  begin
    FHeight := FHeight / 4;
    FCaption := '';
    FEnabled := False;
  end;
end;

{ TSubMenuItem }

constructor TSubMenuItem.Create(AQuadRender: IQuadRender; AMenu: TMenu);
begin
  inherited;
  FFontSize := 0.5;
  FFontColor := $FFCCCCCC;
end;

procedure TSubMenuItem.Draw(AXpos, AYpos: Double);
begin
  inherited;
  Fonts.Console.TextOut(AXpos+1, AYPos+1, FFontSize, PChar(FCaption), FFontColor);
  Fonts.Console.TextOut(AXpos, AYPos, FFontSize, PChar(FCaption), $FF000000);
end;

{ TSubMenuBooleanItem }

procedure TSubMenuBooleanItem.DoOnChange(AIsNext: Boolean);
begin
  Value := not Value;
  inherited;
end;

procedure TSubMenuBooleanItem.Draw(AXpos, AYpos: Double);
begin
  inherited;
  if Enabled then
    if Value then
    begin
      Fonts.Console.TextOut(AXpos + 401, AYPos + 1, FFontSize, '<On>', FFontColor, qfaCenter);
      Fonts.Console.TextOut(AXpos + 400, AYPos, FFontSize, '<On>', $FF000000, qfaCenter);
    end
    else
    begin
      Fonts.Console.TextOut(AXpos + 401, AYPos + 1, FFontSize, '<Off>', FFontColor, qfaCenter);
      Fonts.Console.TextOut(AXpos + 400, AYPos, FFontSize, '<Off>', $FF000000, qfaCenter);
    end
end;

function TSubMenuBooleanItem.GetValue: Boolean;
begin
  if FLinkedValue <> nil then
    Result := FLinkedValue^
  else
    Result := FValue;
end;

procedure TSubMenuBooleanItem.LinkWithVar(aVar: PBoolean);
begin
  FLinkedValue := aVar;
end;

procedure TSubMenuBooleanItem.SetValue(const Value: Boolean);
begin
  if FLinkedValue <> nil then
    FLinkedValue^ := Value
  else
    FValue := Value;
end;

{ TSubMenuIntegerItem }

procedure TSubMenuIntegerItem.DoOnChange(AIsNext: Boolean);
begin
  if AIsNext then
  begin
    if Value < FMaxValue then
      Value := Value + 1;
  end
  else
    if Value > FMinValue then
      Value := Value - 1;

  inherited;      
end;

procedure TSubMenuIntegerItem.Draw(AXpos, AYpos: Double);
begin
  inherited;
  if Enabled then
  begin
    Fonts.Console.TextOut(AXpos + 401, AYPos + 1, FFontSize, PWideChar('<'+IntToStr(Value)+'>'), FFontColor, qfaCenter);
    Fonts.Console.TextOut(AXpos + 400, AYPos, FFontSize, PWideChar('<'+IntToStr(Value)+'>'), $FF000000, qfaCenter);
  end;
end;

function TSubMenuIntegerItem.GetValue: Integer;
begin
  if FLinkedValue <> nil then
    Result := FLinkedValue^
  else
    Result := FValue;
end;

procedure TSubMenuIntegerItem.LinkWithVar(aVar: PInteger);
begin
  FLinkedValue := aVar;
end;

procedure TSubMenuIntegerItem.SetValue(const AValue: Integer);
begin
  if FLinkedValue <> nil then
    FLinkedValue^ := AValue
  else
    FValue := AValue;
end;

{ TSubMenuSelectionItem }

procedure TSubMenuSelectionItem.AfterConstruction;
begin
  inherited;
  FItems := TStringList.Create;
end;

destructor TSubMenuSelectionItem.Destroy;
begin
  FItems.Free;

  inherited;
end;

procedure TSubMenuSelectionItem.DoOnChange(AIsNext: Boolean);
begin
  if Items.Count = 0 then
  begin
    ItemIndex := -1;
    Exit;
  end;

  if AIsNext then
  begin
    if (ItemIndex < FItems.Count - 1) then
      ItemIndex := ItemIndex + 1;
  end
  else
    if ItemIndex > 0 then
      ItemIndex := ItemIndex - 1;

  inherited;
end;

procedure TSubMenuSelectionItem.Draw(AXpos, AYpos: Double);
var
  AText: string;
begin
  inherited;
  if Enabled then
    if ItemIndex <> -1 then
    begin
      AText := FItems[ItemIndex];
      if ItemIndex > 0 then
        AText := '<' + Atext;
      if ItemIndex < (FItems.Count - 1) then
        AText := Atext +'>';

      begin
        Fonts.Console.TextOut(AXpos + 401, AYPos + 1, FFontSize, PWideChar(AText), FFontColor, qfaCenter);
        Fonts.Console.TextOut(AXpos + 400, AYPos, FFontSize, PWideChar(AText), $FF000000, qfaCenter);
      end;
    end;
end;

function TSubMenuSelectionItem.GetItemIndex: Integer;
begin
  if FLinkedValue <> nil then
    Result := FLinkedValue^
  else
    Result := FItemIndex;
end;

procedure TSubMenuSelectionItem.LinkWithVar(aVar: PInteger);
begin
  FLinkedValue := aVar;
end;

procedure TSubMenuSelectionItem.SetItemIndex(const Value: Integer);
begin
  if FLinkedValue <> nil then
    FLinkedValue^ := Value
  else
    FItemIndex := Value;
end;

end.

//t*t*(3-2*t);

