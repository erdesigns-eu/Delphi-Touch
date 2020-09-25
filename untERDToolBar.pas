{
  untERDToolBar v1.0.0
  for Delphi 2010 - 10.4 by Ernst Reidinga
  https://erdesigns.eu

  This unit is part of the ERDesigns UCC Components Pack.

  (c) Copyright 2020 Ernst Reidinga <ernst@erdesigns.eu>

  Bugfixes / Updates:
  - Initial Release 1.0.0

  If you use this unit, please give credits to the original author;
  Ernst Reidinga.

}

unit untERDToolBar;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Controls, Vcl.Graphics,
  Winapi.Messages, System.Types, VCL.Themes;

type
  TERDToolBarLogoPosition = (lpLeft, lpRight);
  TERDToolBarButtonAlign  = (baLeft, baRight);

  TERDToolBarButtonClickEvent = procedure(Sender: TObject; Index: Integer) of object;

  TERDToolBarItem = class(TCollectionItem)
  private
    { Private declarations }
    FGlyph : TPicture;
    FHint  : string;
    FSpace : Integer;
    FRect  : TRect;

    procedure SetGlyph(const P: TPicture);
    procedure SetHint(const S: string);
    procedure SetSpace(const I: Integer);
  protected
    { Protected declarations }
    function GetDisplayName: string; override;
  public
    { Public declarations }
    constructor Create(AOWner: TCollection); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    property ItemRect: TRect read FRect write FRect;
  published
    { Published declarations }
    property Glyph: TPicture read FGlyph write SetGlyph;
    property Hint: string read FHint write SetHint;
    property Space: Integer read FSpace write SetSpace default 0;
  end;

  TERDToolBarItems = class(TOwnedCollection)
  private
    { Private declarations }
    FOnChange : TNotifyEvent;

    function GetItem(Index: Integer): TERDToolBarItem;
    procedure SetItem(Index: Integer; const Value: TERDToolBarItem);
  protected
    { Protected declarations }
    procedure Update(Item: TCollectionItem); override;
  public
    { Public declarations }
    constructor Create(AOwner: TPersistent);
    function Add: TERDToolBarItem;
    procedure Assign(Source: TPersistent); override;

    property Items[Index: Integer]: TERDToolBarItem read GetItem write SetItem;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TERDTopNavigationBar = class(TCustomControl)
  private
    { Private declarations }
    FItems : TERDToolBarItems;
    FButtonWidth      : Integer;
    FFixedButtonWidth : Boolean;
    FOffset           : Integer;
    FGlyphOffset      : Integer;
    FButtonIndex      : Integer;
    FAutoButtonIndex  : Boolean;

    { Logo }
    FLogoPosition : TERDToolBarLogoPosition;
    FLogo         : TPicture;

    { Buffer - Avoid flickering }
    FBuffer        : TBitmap;
    FUpdateRect    : TRect;
    FRedraw        : Boolean;

    { Hot / Pressed }
    FPressedIndex : Integer;
    FHotIndex     : Integer;

    { "Old" hint - when mouse is over an item we want to remember the original hint }
    FOldHint : string;

    { Events }
    FOnButtonClick : TERDToolBarButtonClickEvent;

    procedure SetButtonWidth(const I: Integer);
    procedure SetFixedButtonWidth(const B: Boolean);
    procedure SetOffset(const I: Integer);
    procedure SetGlyphOffset(const I: Integer);
    procedure SetButtonIndex(const I: Integer);

    procedure SetLogoPosition(const P: TERDToolBarLogoPosition);
    procedure SetLogo(const P: TPicture);

    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
  protected
    { Protected declarations }
    procedure SettingsChanged(Sender: TObject);

    procedure Paint; override;
    procedure Resize; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Redraw: Boolean read FRedraw write FRedraw;
    property UpdateRect: TRect read FUpdateRect write FUpdateRect;
  published
    { Published declarations }
    property Items: TERDToolBarItems read FItems write FItems;
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth default 100;
    property FixedButtonWidth: Boolean read FFixedButtonWidth write SetFixedButtonWidth default False;
    property Offset: Integer read FOffset write SetOffset default 8;
    property GlyphOffset: Integer read FGlyphOffset write SetGlyphOffset default 16;
    property ButtonIndex: Integer read FButtonIndex write SetButtonIndex default -1;
    property AutoButtonIndex: Boolean read FAutoButtonIndex write FAutoButtonIndex default False;

    property LogoPosition: TERDToolBarLogoPosition read FLogoPosition write SetLogoPosition default lpLeft;
    property Logo: TPicture read FLogo write SetLogo;

    property OnButtonClick: TERDToolBarButtonClickEvent read FOnButtonClick write FOnButtonClick;

    property Align default alTop;
    property Anchors;
    property Color;
    property Constraints;
    property Enabled;
    property ParentColor;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Touch;
    property Visible;
    property StyleElements;
    property OnClick;
    property OnEnter;
    property OnExit;
    property OnGesture;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

  TERDBottomNavigationBar = class(TCustomControl)
  private
    { Private declarations }
    FItems : TERDToolBarItems;
    FButtonWidth      : Integer;
    FFixedButtonWidth : Boolean;
    FOffset           : Integer;
    FGlyphOffset      : Integer;
    FButtonAlign      : TERDToolBarButtonAlign;

    { Buffer - Avoid flickering }
    FBuffer        : TBitmap;
    FUpdateRect    : TRect;
    FRedraw        : Boolean;

    { Hot / Pressed }
    FPressedIndex : Integer;
    FHotIndex     : Integer;

    { "Old" hint - when mouse is over an item we want to remember the original hint }
    FOldHint : string;

    { Events }
    FOnButtonClick : TERDToolBarButtonClickEvent;

    procedure SetButtonWidth(const I: Integer);
    procedure SetFixedButtonWidth(const B: Boolean);
    procedure SetOffset(const I: Integer);
    procedure SetGlyphOffset(const I: Integer);
    procedure SetButtonAlign(const A: TERDToolBarButtonAlign);

    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
  protected
    { Protected declarations }
    procedure SettingsChanged(Sender: TObject);

    procedure Paint; override;
    procedure Resize; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Redraw: Boolean read FRedraw write FRedraw;
    property UpdateRect: TRect read FUpdateRect write FUpdateRect;
  published
    { Published declarations }
    property Items: TERDToolBarItems read FItems write FItems;
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth default 100;
    property FixedButtonWidth: Boolean read FFixedButtonWidth write SetFixedButtonWidth default False;
    property Offset: Integer read FOffset write SetOffset default 8;
    property GlyphOffset: Integer read FGlyphOffset write SetGlyphOffset default 16;
    property ButtonAlign: TERDToolBarButtonAlign read FButtonAlign write SetButtonAlign default baRight;

    property OnButtonClick: TERDToolBarButtonClickEvent read FOnButtonClick write FOnButtonClick;

    property Align default alBottom;
    property Anchors;
    property Color;
    property Constraints;
    property Enabled;
    property ParentColor;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Touch;
    property Visible;
    property StyleElements;
    property OnClick;
    property OnEnter;
    property OnExit;
    property OnGesture;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

implementation

uses
  System.Math, untERDCommon;

const
  LogoOffset = 16;

(******************************************************************************)
(*
(*  ERD ToolBar Item (TERDToolBarItem)
(*
(******************************************************************************)
constructor TERDToolBarItem.Create(AOWner: TCollection);
begin
  inherited Create(AOwner);
  FGlyph := TPicture.Create;
  FSpace := 0;
  Fhint  := Format('Button %d', [Index]);
end;

destructor TERDToolBarItem.Destroy;
begin
  FGlyph.Free;
  inherited;
end;

procedure TERDToolBarItem.SetGlyph(const P: TPicture);
begin
  FGlyph.Assign(P);
  Changed(False);
end;

procedure TERDToolBarItem.SetHint(const S: string);
begin
  if Hint <> S then
  begin
    FHint := S;
    Changed(False);
  end;
end;

procedure TERDToolBarItem.SetSpace(const I: Integer);
begin
  if Space <> I then
  begin
    FSpace := I;
    Changed(False);
  end;
end;

function TERDToolBarItem.GetDisplayName : string;
begin
  Result := Format('Button %d', [Index]);
end;

procedure TERDToolBarItem.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TERDToolBarItem then
  begin
    FGlyph.Assign(TERDToolBarItem(Source).Glyph);
    FHint  := TERDToolBarItem(Source).Hint;
    FSpace := TERDToolBarItem(Source).Space;
    Changed(False);
  end else Inherited;
end;

(******************************************************************************)
(*
(*  ERD ToolBar Item Collection (TERDToolBarItems)
(*
(******************************************************************************)
constructor TERDToolBarItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TERDToolBarItem);
end;

procedure TERDToolBarItems.SetItem(Index: Integer; const Value: TERDToolBarItem);
begin
  inherited SetItem(Index, Value);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TERDToolBarItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TERDToolBarItems.GetItem(Index: Integer) : TERDToolBarItem;
begin
  Result := inherited GetItem(Index) as TERDToolBarItem;
end;

function TERDToolBarItems.Add : TERDToolBarItem;
begin
  Result := TERDToolBarItem(inherited Add);
end;

procedure TERDToolBarItems.Assign(Source: TPersistent);
var
  LI   : TERDToolBarItems;
  Loop : Integer;
begin
  if (Source is TERDToolBarItems)  then
  begin
    LI := TERDToolBarItems(Source);
    Clear;
    for Loop := 0 to LI.Count - 1 do
        Add.Assign(LI.Items[Loop]);
  end else inherited;
end;

(******************************************************************************)
(*
(*  ERD Top Navigation Bar (TERDTopNavigationBar)
(*
(******************************************************************************)
constructor TERDTopNavigationBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  { If the ControlStyle property includes csOpaque, the control paints itself
    directly. We do want the control to accept controls - because we might
    want to place some controls on it }
  ControlStyle := ControlStyle + [csOpaque, csAcceptsControls,
    csCaptureMouse, csClickEvents, csDoubleClicks];

  { We want to be able to get focus }
  TabStop := True;

  { Create Buffers }
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;

  { Create Items }
  FItems := TERDToolBarItems.Create(Self);
  Fitems.OnChange := SettingsChanged;

  { Width / Height }
  Width  := 300;
  Height := 68;
  Align  := alTop;

  { Defaults }
  FButtonWidth      := 100;
  FFixedButtonWidth := False;
  FOffSet           := 8;
  FGlyphOffset      := 16;
  FButtonIndex      := -1;
  FAutoButtonIndex  := False;
  FLogoPosition     := lpLeft;

  FLogo := TPicture.Create;
  FLogo.OnChange := SettingsChanged;

  FPressedIndex := -1;
  FHotIndex     := -1;

  { Initial Draw }
  Redraw := True;
end;

destructor TERDTopNavigationBar.Destroy;
begin
  { Free Buffer }
  FBuffer.Free;

  { Free Items }
  FItems.Free;

  { Free Logo }
  FLogo.Free;

  inherited Destroy;
end;

procedure TERDTopNavigationBar.SetButtonWidth(const I: Integer);
begin
  if ButtonWidth <> I then
  begin
    FButtonWidth := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDTopNavigationBar.SetFixedButtonWidth(const B: Boolean);
begin
  if FixedButtonWidth <> B then
  begin
    FFixedButtonWidth := B;
    SettingsChanged(Self);
  end;
end;

procedure TERDTopNavigationBar.SetOffset(const I: Integer);
begin
  if Offset <> I then
  begin
    FOffset := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDTopNavigationBar.SetGlyphOffset(const I: Integer);
begin
  if GlyphOffset <> I then
  begin
    FGlyphOffset := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDTopNavigationBar.SetButtonIndex(const I: Integer);
begin
  if ButtonIndex <> I then
  begin
    if I > Items.Count -1 then
      FButtonIndex := Items.Count -1
    else
    if I < -1 then
      FButtonIndex := -1
    else
      FButtonIndex := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDTopNavigationBar.SetLogoPosition(const P: TERDToolBarLogoPosition);
begin
  if LogoPosition <> P then
  begin
    FLogoPosition := P;
    SettingsChanged(Self);
  end;
end;

procedure TERDTopNavigationBar.SetLogo(const P: TPicture);
begin
  FLogo.Assign(P);
  SettingsChanged(Self);
end;

procedure TERDTopNavigationBar.WMPaint(var Msg: TWMPaint);
begin
  GetUpdateRect(Handle, FUpdateRect, False);
  inherited;
end;

procedure TERDTopNavigationBar.WMEraseBkGnd(var Msg: TWMEraseBkgnd);
begin
  { Draw Buffer to the Control }
  BitBlt(Msg.DC, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := -1;
end;

procedure TERDTopNavigationBar.SettingsChanged(Sender: TObject);
begin
  Redraw := True;
  Invalidate;
end;

procedure TERDTopNavigationBar.Paint;
var
  WorkRect : TRect;

  procedure DrawBackground;
  begin
    with FBuffer.Canvas do
    begin
      if TStyleManager.IsCustomStyleActive and (seClient in StyleElements) then
      begin
        DrawGradient(FBuffer.Canvas, gsVertical, StyleServices.GetStyleColor(scGenericGradientBase), StyleServices.GetStyleColor(scGenericGradientEnd), 0, WorkRect);
      end else
      begin
        DrawGradient(FBuffer.Canvas, gsVertical, Brighten(Color, 10), Darken(Color, 10), 0, WorkRect);
      end;
      if Assigned(Logo) and (Logo.Width > 0) and (Logo.Height > 0) then
      case LogoPosition of
        lpLeft  : FBuffer.Canvas.Draw(WorkRect.Left + LogoOffset, WorkRect.Top + ((WorkRect.Height div 2) - (Logo.Height div 2)), Logo.Graphic);
        lpRight : FBuffer.Canvas.Draw(WorkRect.Right - (LogoOffset + Logo.Width), WorkRect.Top + ((WorkRect.Height div 2) - (Logo.Height div 2)), Logo.Graphic);
      end;
    end;
  end;

  function ButtonsBorderWidth : Integer;
  var
    I : Integer;
  begin
    Result := 0;
    for I := 0 to Items.Count -1 do
    begin
      if FixedButtonWidth then
        Result := Result + ButtonWidth + Items.Items[I].Space
      else
        Result := Result + (GlyphOffset * 2) + Items.Items[I].Glyph.Width + Items.Items[I].Space;
    end;
  end;

  procedure CalculateItemRects;
  var
    I, L : Integer;
  begin
    for I := 0 to Items.Count -1 do
    begin
      if I = 0 then
        L := WorkRect.Left + ((WorkRect.Width div 2) - (ButtonsBorderWidth div 2))
      else
        L := Items.Items[I -1].ItemRect.Right + Items.Items[I -1].Space;
      { Set item rect }
      if FixedButtonWidth then
      begin
        Items.Items[I].ItemRect := Rect(
          L,
          WorkRect.Top + OffSet,
          L + ButtonWidth,
          WorkRect.Bottom - OffSet
        );
      end else
      begin
        Items.Items[I].ItemRect := Rect(
          L,
          WorkRect.Top + OffSet,
          L + GlyphOffset + Items.Items[I].Glyph.Width + GlyphOffset,
          WorkRect.Bottom - OffSet
        );
      end;
    end;
  end;

  procedure DrawButtons;
  var
    I : Integer;
    D : TThemedElementDetails;
  begin
    for I := 0 to Items.Count -1 do
    with FBuffer.Canvas do
    begin
      if not Enabled then
        D := StyleServices.GetElementDetails(tbPushButtonDisabled)
      else
      if I = FPressedIndex then
        D := StyleServices.GetElementDetails(tbPushButtonPressed)
      else
      if I = ButtonIndex then
        D := StyleServices.GetElementDetails(tbPushButtonDefaulted)
      else
      if I = FHotIndex then
        D := StyleServices.GetElementDetails(tbPushButtonHot)
      else
        D := StyleServices.GetElementDetails(tbPushButtonNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, D, Items.Items[I].ItemRect);
      FBuffer.Canvas.Draw(
        Items.Items[I].ItemRect.Left + ((Items.Items[I].ItemRect.Width div 2) - (Items.Items[I].Glyph.Width div 2)),
        Items.Items[I].ItemRect.Top + ((Items.Items[I].ItemRect.Height div 2) - (Items.Items[I].Glyph.Height div 2)),
        Items.Items[I].Glyph.Graphic
      );
    end;
  end;

var
  X, Y, W, H : Integer;
begin
  { Draw the panel to the buffer }
  if Redraw then
  begin
    Redraw := False;
    WorkRect := ClientRect;

    { Set Buffer size }
    FBuffer.SetSize(ClientWidth, ClientHeight);

    { Draw to buffer }
    DrawBackground;
    CalculateItemRects;
    DrawButtons;
  end;

  { Now draw the Buffer to the components surface }
  X := UpdateRect.Left;
  Y := UpdateRect.Top;
  W := UpdateRect.Right - UpdateRect.Left;
  H := UpdateRect.Bottom - UpdateRect.Top;
  if (W <> 0) and (H <> 0) then
    { Only update part - invalidated }
    BitBlt(Canvas.Handle, X, Y, W, H, FBuffer.Canvas.Handle, X,  Y, SRCCOPY)
  else
    { Repaint the whole buffer to the surface }
    BitBlt(Canvas.Handle, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, X,  Y, SRCCOPY);

  inherited;
end;

procedure TERDTopNavigationBar.Resize;
begin
  Redraw := True;
  inherited;
end;

procedure TERDTopNavigationBar.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TERDTopNavigationBar.WndProc(var Message: TMessage);
begin
  inherited;
  case Message.Msg of
    // Capture Keystrokes
    WM_GETDLGCODE:
      Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTALLKEYS;

    { Enabled/Disabled - Redraw }
    CM_ENABLEDCHANGED:
      begin
        if not Enabled then
        begin
          FPressedIndex := -1;
          FHotIndex     := -1;
        end;
        Redraw := True;
        Invalidate;
      end;

    { The color changed }
    CM_COLORCHANGED:
      begin
        Redraw := True;
        Invalidate;
      end;

    { Font Changed }
    CM_FONTCHANGED:
      begin
        Redraw := True;
        Invalidate;
      end;

    { Mouse leave }
    CM_MOUSELEAVE:
      if not (csDesigning in ComponentState) then
      begin
        FHotIndex     := -1;
        FPressedIndex := -1;
        SettingsChanged(Self);
      end;

    { Focus is lost }
    WM_KILLFOCUS:
      begin
        Redraw := True;
        Invalidate;
      end;

    { Focus is set }
    WM_SETFOCUS:
      begin
        Redraw := True;
        Invalidate;
      end;

    { Style Changed }
    CM_STYLECHANGED:
      begin
        Redraw := True;
        Invalidate;
      end;
  end;
end;

procedure TERDTopNavigationBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

  function IsMouseOverItem(var Item: Integer) : Boolean;
  var
    I : Integer;
  begin
    Result := False;
    for I := 0 to Items.Count -1 do
    if PtInRect(Items.Items[I].ItemRect, Point(X, Y)) then
    begin
      Result := True;
      Item := I;
      Break;
    end;
  end;

var
  I : Integer;
begin
  if Enabled then
  begin
    if CanFocus and (not Focused) then SetFocus;
    if IsMouseOverItem(I) then
    begin
      FPressedIndex := I;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDTopNavigationBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

  function IsMouseOverItem(var Item: Integer) : Boolean;
  var
    I : Integer;
  begin
    Result := False;
    for I := 0 to Items.Count -1 do
    if PtInRect(Items.Items[I].ItemRect, Point(X, Y)) then
    begin
      Result := True;
      Item := I;
      Break;
    end;
  end;
VAR
  I: Integer;
begin
  if Enabled then
  begin
    if (FPressedIndex <> -1) then
    begin
      if IsMouseOverItem(I) and (I = FPressedIndex) then
      begin
        if Assigned(FOnButtonClick) then FOnButtonClick(Self, I);
        if AutoButtonIndex then ButtonIndex := I;
      end;
      FPressedIndex := -1;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDTopNavigationBar.MouseMove(Shift: TShiftState; X: Integer; Y: Integer);

  function IsMouseOverItem(var Item: Integer) : Boolean;
  var
    I : Integer;
  begin
    Result := False;
    for I := 0 to Items.Count -1 do
    if PtInRect(Items.Items[I].ItemRect, Point(X, Y)) then
    begin
      Result := True;
      Item := I;
      Break;
    end;
  end;

var
  I : Integer;
begin
  if Enabled then
  begin
    if IsMouseOverItem(I) and (FPressedIndex = -1) then
    begin
      if FHotIndex <> I then
      begin
        FHotIndex := I;
        if Hint <> Items.Items[I].Hint then
        begin
          FOldHint := Hint;
          Hint := Items.Items[I].Hint;
        end;
        SettingsChanged(Self);
      end;
    end else
    begin
      if Hint <> FOldHint then Hint := FOldHint;
      if FHotIndex <> -1 then
      begin
        FHotIndex := -1;
        SettingsChanged(Self);
      end;
    end;
  end;
  inherited;
end;

procedure TERDTopNavigationBar.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Enabled then
  begin
    if (Key = VK_LEFT) then
    begin
      if ButtonIndex > 0 then
      ButtonIndex := ButtonIndex -1;
    end else
    if (Key = VK_RIGHT) then
    begin
      ButtonIndex := ButtonIndex +1;
    end;
    if ((Key = VK_RETURN) or (Key = VK_SPACE)) and (ButtonIndex > -1) then
    begin
      FPressedIndex := ButtonIndex;
      if Assigned(FOnButtonClick) then FOnButtonClick(Self, ButtonIndex);
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDTopNavigationBar.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if Enabled then
  begin
    if (FPressedIndex <> -1) then
    begin
      FPressedIndex := -1;
      SettingsChanged(Self);
    end;
  end;
end;

(******************************************************************************)
(*
(*  ERD Bottom Navigation Bar (TERDBottomNavigationBar)
(*
(******************************************************************************)
constructor TERDBottomNavigationBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  { If the ControlStyle property includes csOpaque, the control paints itself
    directly. We do want the control to accept controls - because we might
    want to place some controls on it }
  ControlStyle := ControlStyle + [csOpaque, csAcceptsControls,
    csCaptureMouse, csClickEvents, csDoubleClicks];

  { We want to be able to get focus }
  TabStop := True;

  { Create Buffers }
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;

  { Create Items }
  FItems := TERDToolBarItems.Create(Self);
  Fitems.OnChange := SettingsChanged;

  { Width / Height }
  Width  := 300;
  Height := 68;
  Align  := alBottom;

  { Defaults }
  FButtonWidth      := 100;
  FFixedButtonWidth := False;
  FOffSet           := 8;
  FGlyphOffset      := 16;
  FButtonAlign      := baRight;

  FPressedIndex := -1;
  FHotIndex     := -1;

  { Initial Draw }
  Redraw := True;
end;

destructor TERDBottomNavigationBar.Destroy;
begin
  { Free Buffer }
  FBuffer.Free;

  { Free Items }
  FItems.Free;

  inherited Destroy;
end;

procedure TERDBottomNavigationBar.SetButtonWidth(const I: Integer);
begin
  if ButtonWidth <> I then
  begin
    FButtonWidth := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDBottomNavigationBar.SetFixedButtonWidth(const B: Boolean);
begin
  if FixedButtonWidth <> B then
  begin
    FFixedButtonWidth := B;
    SettingsChanged(Self);
  end;
end;

procedure TERDBottomNavigationBar.SetOffset(const I: Integer);
begin
  if Offset <> I then
  begin
    FOffset := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDBottomNavigationBar.SetGlyphOffset(const I: Integer);
begin
  if GlyphOffset <> I then
  begin
    FGlyphOffset := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDBottomNavigationBar.SetButtonAlign(const A: TERDToolBarButtonAlign);
begin
  if ButtonAlign <> A then
  begin
    FButtonAlign := A;
    SettingsChanged(Self);
  end;
end;

procedure TERDBottomNavigationBar.WMPaint(var Msg: TWMPaint);
begin
  GetUpdateRect(Handle, FUpdateRect, False);
  inherited;
end;

procedure TERDBottomNavigationBar.WMEraseBkGnd(var Msg: TWMEraseBkgnd);
begin
  { Draw Buffer to the Control }
  BitBlt(Msg.DC, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := -1;
end;

procedure TERDBottomNavigationBar.SettingsChanged(Sender: TObject);
begin
  Redraw := True;
  Invalidate;
end;

procedure TERDBottomNavigationBar.Paint;
var
  WorkRect : TRect;

  procedure DrawBackground;
  begin
    with FBuffer.Canvas do
    begin
      if TStyleManager.IsCustomStyleActive and (seClient in StyleElements) then
      begin
        DrawGradient(FBuffer.Canvas, gsVertical, StyleServices.GetStyleColor(scGenericGradientBase), StyleServices.GetStyleColor(scGenericGradientEnd), 0, WorkRect);
      end else
      begin
        DrawGradient(FBuffer.Canvas, gsVertical, Brighten(Color, 10), Darken(Color, 10), 0, WorkRect);
      end;
    end;
  end;

  function ButtonsBorderWidth : Integer;
  var
    I : Integer;
  begin
    Result := 0;
    for I := 0 to Items.Count -1 do
    begin
      if FixedButtonWidth then
        Result := Result + ButtonWidth + Items.Items[I].Space
      else
        Result := Result + (GlyphOffset * 2) + Items.Items[I].Glyph.Width + Items.Items[I].Space;
    end;
  end;

  procedure CalculateItemRects;
  var
    I, L : Integer;
  begin
    L := 0;
    for I := 0 to Items.Count -1 do
    begin
      case ButtonAlign of
        { Align Left }
        baLeft:
        begin
          if I = 0 then
            L := WorkRect.Left + OffSet
          else
            L := Items.Items[I -1].ItemRect.Right + Items.Items[I -1].Space;
        end;

        { Align Right }
        baRight:
        begin
          if I = 0 then
            L := WorkRect.Right - (OffSet + ButtonsBorderWidth)
          else
            L := Items.Items[I -1].ItemRect.Right + Items.Items[I -1].Space;
        end;
      end;
      if FixedButtonWidth then
      begin
        Items.Items[I].ItemRect := Rect(
          L,
          WorkRect.Top + OffSet,
          L + ButtonWidth,
          WorkRect.Bottom - OffSet
        );
      end else
      begin
        Items.Items[I].ItemRect := Rect(
          L,
          WorkRect.Top + OffSet,
          L + GlyphOffset + Items.Items[I].Glyph.Width + GlyphOffset,
          WorkRect.Bottom - OffSet
        );
      end;
    end;
  end;

  procedure DrawButtons;
  var
    I : Integer;
    D : TThemedElementDetails;
  begin
    for I := 0 to Items.Count -1 do
    with FBuffer.Canvas do
    begin
      if not Enabled then
        D := StyleServices.GetElementDetails(tbPushButtonDisabled)
      else
      if I = FPressedIndex then
        D := StyleServices.GetElementDetails(tbPushButtonPressed)
      else
      if I = FHotIndex then
        D := StyleServices.GetElementDetails(tbPushButtonHot)
      else
        D := StyleServices.GetElementDetails(tbPushButtonNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, D, Items.Items[I].ItemRect);
      FBuffer.Canvas.Draw(
        Items.Items[I].ItemRect.Left + ((Items.Items[I].ItemRect.Width div 2) - (Items.Items[I].Glyph.Width div 2)),
        Items.Items[I].ItemRect.Top + ((Items.Items[I].ItemRect.Height div 2) - (Items.Items[I].Glyph.Height div 2)),
        Items.Items[I].Glyph.Graphic
      );
    end;
  end;

var
  X, Y, W, H : Integer;
begin
  { Draw the panel to the buffer }
  if Redraw then
  begin
    Redraw := False;
    WorkRect := ClientRect;

    { Set Buffer size }
    FBuffer.SetSize(ClientWidth, ClientHeight);

    { Draw to buffer }
    DrawBackground;
    CalculateItemRects;
    DrawButtons;
  end;

  { Now draw the Buffer to the components surface }
  X := UpdateRect.Left;
  Y := UpdateRect.Top;
  W := UpdateRect.Right - UpdateRect.Left;
  H := UpdateRect.Bottom - UpdateRect.Top;
  if (W <> 0) and (H <> 0) then
    { Only update part - invalidated }
    BitBlt(Canvas.Handle, X, Y, W, H, FBuffer.Canvas.Handle, X,  Y, SRCCOPY)
  else
    { Repaint the whole buffer to the surface }
    BitBlt(Canvas.Handle, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, X,  Y, SRCCOPY);

  inherited;
end;

procedure TERDBottomNavigationBar.Resize;
begin
  Redraw := True;
  inherited;
end;

procedure TERDBottomNavigationBar.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TERDBottomNavigationBar.WndProc(var Message: TMessage);
begin
  inherited;
  case Message.Msg of
    // Capture Keystrokes
    WM_GETDLGCODE:
      Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTALLKEYS;

    { Enabled/Disabled - Redraw }
    CM_ENABLEDCHANGED:
      begin
        if not Enabled then
        begin
          FPressedIndex := -1;
          FHotIndex     := -1;
        end;
        Redraw := True;
        Invalidate;
      end;

    { The color changed }
    CM_COLORCHANGED:
      begin
        Redraw := True;
        Invalidate;
      end;

    { Font Changed }
    CM_FONTCHANGED:
      begin
        Redraw := True;
        Invalidate;
      end;

    { Mouse leave }
    CM_MOUSELEAVE:
      if not (csDesigning in ComponentState) then
      begin
        FHotIndex     := -1;
        FPressedIndex := -1;
        SettingsChanged(Self);
      end;

    { Focus is lost }
    WM_KILLFOCUS:
      begin
        Redraw := True;
        Invalidate;
      end;

    { Focus is set }
    WM_SETFOCUS:
      begin
        Redraw := True;
        Invalidate;
      end;

    { Style Changed }
    CM_STYLECHANGED:
      begin
        Redraw := True;
        Invalidate;
      end;
  end;
end;

procedure TERDBottomNavigationBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

  function IsMouseOverItem(var Item: Integer) : Boolean;
  var
    I : Integer;
  begin
    Result := False;
    for I := 0 to Items.Count -1 do
    if PtInRect(Items.Items[I].ItemRect, Point(X, Y)) then
    begin
      Result := True;
      Item := I;
      Break;
    end;
  end;

var
  I : Integer;
begin
  if Enabled then
  begin
    if CanFocus and (not Focused) then SetFocus;
    if IsMouseOverItem(I) then
    begin
      FPressedIndex := I;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDBottomNavigationBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

  function IsMouseOverItem(var Item: Integer) : Boolean;
  var
    I : Integer;
  begin
    Result := False;
    for I := 0 to Items.Count -1 do
    if PtInRect(Items.Items[I].ItemRect, Point(X, Y)) then
    begin
      Result := True;
      Item := I;
      Break;
    end;
  end;

var
  I : Integer;
begin
  if Enabled then
  begin
    if (FPressedIndex <> -1) then
    begin
      if IsMouseOverItem(I) and (I = FPressedIndex) then
      begin
        if Assigned(FOnButtonClick) then FOnButtonClick(Self, I);
      end;
      FPressedIndex := -1;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDBottomNavigationBar.MouseMove(Shift: TShiftState; X: Integer; Y: Integer);

  function IsMouseOverItem(var Item: Integer) : Boolean;
  var
    I : Integer;
  begin
    Result := False;
    for I := 0 to Items.Count -1 do
    if PtInRect(Items.Items[I].ItemRect, Point(X, Y)) then
    begin
      Result := True;
      Item := I;
      Break;
    end;
  end;

var
  I : Integer;
begin
  if Enabled then
  begin
    if IsMouseOverItem(I) and (FPressedIndex = -1) then
    begin
      if FHotIndex <> I then
      begin
        FHotIndex := I;
        if Hint <> Items.Items[I].Hint then
        begin
          FOldHint := Hint;
          Hint := Items.Items[I].Hint;
        end;
        SettingsChanged(Self);
      end;
    end else
    begin
      if Hint <> FOldHint then Hint := FOldHint;
      if FHotIndex <> -1 then
      begin
        FHotIndex := -1;
        SettingsChanged(Self);
      end;
    end;
  end;
  inherited;
end;

end.
