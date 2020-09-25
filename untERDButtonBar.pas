{
  untERDButtonBar v1.0.0
  for Delphi 2010 - 10.4 by Ernst Reidinga
  https://erdesigns.eu

  This unit is part of the ERDesigns UCC Components Pack.

  (c) Copyright 2020 Ernst Reidinga <ernst@erdesigns.eu>

  Bugfixes / Updates:
  - Initial Release 1.0.0

  If you use this unit, please give credits to the original author;
  Ernst Reidinga.

}

unit untERDButtonBar;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Controls, Vcl.Graphics,
  Winapi.Messages, System.Types, VCL.Themes;

type
  TERDButtonBarChangeEvent = procedure(Sender: TObject; TabIndex: Integer) of object;

  TERDButtonBarItem = class(TCollectionItem)
  private
    { Private declarations }
    FGlyph   : TPicture;
    FCaption : TCaption;
    FHint    : string;
    FRect    : TRect;

    procedure SetGlyph(const P: TPicture);
    procedure SetCaption(const C: TCaption);
    procedure SetHint(const S: string);
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
    property Caption: TCaption read FCaption write SetCaption;
    property Hint: string read FHint write SetHint;
  end;

  TERDButtonBarItems = class(TOwnedCollection)
  private
    { Private declarations }
    FOnChange : TNotifyEvent;

    function GetItem(Index: Integer): TERDButtonBarItem;
    procedure SetItem(Index: Integer; const Value: TERDButtonBarItem);
  protected
    { Protected declarations }
    procedure Update(Item: TCollectionItem); override;
  public
    { Public declarations }
    constructor Create(AOwner: TPersistent);
    function Add: TERDButtonBarItem;
    procedure Assign(Source: TPersistent); override;

    property Items[Index: Integer]: TERDButtonBarItem read GetItem write SetItem;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TERDButtonBar = class(TCustomControl)
  private
    { Private declarations }
    FItems        : TERDButtonBarItems;
    FButtonHeight : Integer;
    FIndex        : Integer;
    FOnChange     : TERDButtonBarChangeEvent;

    { Buffer - Avoid flickering }
    FBuffer        : TBitmap;
    FUpdateRect    : TRect;
    FRedraw        : Boolean;
    FMouseOverItem : Integer;

    { "Old" hint - when mouse is over an item we want to remember the original
      hint }
    FOldHint : string;

    procedure SetButtonHeight(const I: Integer);
    procedure SetIndex(const I: Integer);

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
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Redraw: Boolean read FRedraw write FRedraw;
    property UpdateRect: TRect read FUpdateRect write FUpdateRect;
  published
    { Published declarations }
    property Items: TERDButtonBarItems read FItems write FItems;
    property ButtonHeight: Integer read FButtonHeight write SetButtonHeight default 52;
    property ButtonIndex: Integer read FIndex write SetIndex default -1;
    property OnChange: TERDButtonBarChangeEvent read FOnChange write FOnChange;

    property Align default alLeft;
    property Anchors;
    property Color;
    property Constraints;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Touch;
    property Visible;
    property ParentFont;
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

uses System.Math;

const
  { Space between buttons and border }
  OffSet      = 8;
  GlyphOffset = 8;

(******************************************************************************)
(*
(*  ERD Button Bar Item (TERDButtonBarItem)
(*
(******************************************************************************)
constructor TERDButtonBarItem.Create(AOWner: TCollection);
begin
  inherited Create(AOwner);
  FCaption := Format('Button %d', [Index]);
  FGlyph   := TPicture.Create;
  Fhint    := FCaption;
end;

destructor TERDButtonBarItem.Destroy;
begin
  FGlyph.Free;
  inherited;
end;

procedure TERDButtonBarItem.SetGlyph(const P: TPicture);
begin
  FGlyph.Assign(P);
  Changed(False);
end;

procedure TERDButtonBarItem.SetCaption(const C: TCaption);
begin
  if Caption <> C then
  begin
    FCaption := C;
    Changed(False);
  end;
end;

procedure TERDButtonBarItem.SetHint(const S: string);
begin
  if Hint <> S then
  begin
    FHint := S;
    Changed(False);
  end;
end;

function TERDButtonBarItem.GetDisplayName : string;
begin
  if (Caption <> '') then
    Result := Caption
  else
    Result := Format('Button %d', [Index]);
end;

procedure TERDButtonBarItem.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TERDButtonBarItem then
  begin
    FCaption := TERDButtonBarItem(Source).Caption;
    FGlyph.Assign(TERDButtonBarItem(Source).Glyph);
    FHint    := TERDButtonBarItem(Source).Hint;
    Changed(False);
  end else Inherited;
end;

(******************************************************************************)
(*
(*  ERD Button Bar Item Collection (TERDButtonBarItems)
(*
(******************************************************************************)
constructor TERDButtonBarItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TERDButtonBarItem);
end;

procedure TERDButtonBarItems.SetItem(Index: Integer; const Value: TERDButtonBarItem);
begin
  inherited SetItem(Index, Value);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TERDButtonBarItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TERDButtonBarItems.GetItem(Index: Integer) : TERDButtonBarItem;
begin
  Result := inherited GetItem(Index) as TERDButtonBarItem;
end;

function TERDButtonBarItems.Add : TERDButtonBarItem;
begin
  Result := TERDButtonBarItem(inherited Add);
end;

procedure TERDButtonBarItems.Assign(Source: TPersistent);
var
  LI   : TERDButtonBarItems;
  Loop : Integer;
begin
  if (Source is TERDButtonBarItems)  then
  begin
    LI := TERDButtonBarItems(Source);
    Clear;
    for Loop := 0 to LI.Count - 1 do
        Add.Assign(LI.Items[Loop]);
  end else inherited;
end;

(******************************************************************************)
(*
(*  ERD Button Bar (TERDButtonBar)
(*
(******************************************************************************)
constructor TERDButtonBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  { If the ControlStyle property includes csOpaque, the control paints itself
    directly. We do want the control to accept controls - because we might
    want to place some controls on the right }
  ControlStyle := ControlStyle + [csOpaque, csAcceptsControls,
    csCaptureMouse, csClickEvents, csDoubleClicks];

  { We want to be able to get focus }
  TabStop := True;

  { Create Buffers }
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;

  { Items }
  FItems := TERDButtonBarItems.Create(Self);
  FItems.OnChange := SettingsChanged;

  { Width / Height }
  Width  := 145;
  Height := 300;
  Align  := alLeft;

  { Defaults }
  FButtonHeight   := 92;
  FMouseOverItem  := -1;

  { Initial Draw }
  Redraw := True;
end;

destructor TERDButtonBar.Destroy;
begin
  { Free Buffer }
  FBuffer.Free;

  { Free Items }
  FItems.Free;

  inherited Destroy;
end;

procedure TERDButtonBar.WMPaint(var Msg: TWMPaint);
begin
  GetUpdateRect(Handle, FUpdateRect, False);
  inherited;
end;

procedure TERDButtonBar.WMEraseBkGnd(var Msg: TWMEraseBkgnd);
begin
  { Draw Buffer to the Control }
  BitBlt(Msg.DC, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := -1;
end;

procedure TERDButtonBar.SetButtonHeight(const I: Integer);
begin
  if ButtonHeight <> I then
  begin
    if I < 32 then
      FButtonHeight := 32
    else
      FButtonHeight := I;
    Redraw := True;
    Invalidate;
  end;
end;

procedure TERDButtonBar.SetIndex(const I: Integer);
begin
  if ButtonIndex <> I then
  begin
    if (I > Items.Count -1) then
      FIndex := Items.Count -1
    else
    if (I < -1) then
    begin
      if Items.Count > 0 then
        FIndex := 0
      else
        FIndex := -1;
    end else
      FIndex := I;
    if Assigned(FOnChange) then FOnChange(Self, FIndex);
    Redraw := True;
    Invalidate;
  end;
end;

procedure TERDButtonBar.SettingsChanged(Sender: TObject);
begin
  Redraw := True;
  Invalidate;
end;

procedure TERDButtonBar.Paint;
var
  WorkRect : TRect;

  procedure DrawBackground;
  var
    LDetails : TThemedElementDetails;
  begin
    with FBuffer.Canvas do
    begin
      if TStyleManager.IsCustomStyleActive and (seClient in StyleElements) then
      begin
        Brush.Color := StyleServices.GetStyleColor(scComboBox);
        LDetails := StyleServices.GetElementDetails(tcBorderNormal);
        StyleServices.DrawElement(FBuffer.Canvas.Handle, LDetails, WorkRect);
      end else
      begin
        Brush.Color := Color;
        FillRect(WorkRect);
        DrawEdge(FBuffer.Canvas.Handle, WorkRect, EDGE_SUNKEN, BF_RECT);
      end;
    end;
  end;

  procedure CalculateItemRects;
  var
    I : Integer;
  begin
    for I := 0 to Items.Count -1 do
    begin
      if I = 0 then
      begin
        Items.Items[I].ItemRect := Rect(
          WorkRect.Left + OffSet,
          WorkRect.Top + OffSet,
          WorkRect.Right - OffSet,
          WorkRect.Top + OffSet + ButtonHeight
        );
      end else
      begin
        Items.Items[I].ItemRect := Rect(
          WorkRect.Left + OffSet,
          Items.Items[I -1].ItemRect.Bottom + OffSet,
          WorkRect.Right - OffSet,
          Items.Items[I -1].ItemRect.Bottom + OffSet + ButtonHeight
        );
      end;
    end;
  end;

  procedure DrawButton(const I: Integer);
  var
    GlyphRect, CaptionRect : TRect;
  begin
    with FBuffer.Canvas do
    begin
      { Assign Colors }
      Font.Assign(Self.Font);
      if TStyleManager.IsCustomStyleActive and (seClient in StyleElements) then
      begin
        if I = ButtonIndex then
          Brush.Color := StyleServices.GetStyleColor(scButtonFocused)
        else
          Brush.Color := StyleServices.GetStyleColor(scComboBox);
      end else
      begin
        if I = ButtonIndex then
          Brush.Color := clActiveBorder
        else
          Brush.Color := Color;
      end;
      if TStyleManager.IsCustomStyleActive and (seFont in StyleElements) then
      begin
        if I = ButtonIndex then
          Font.Color := StyleServices.GetStyleFontColor(sfButtonTextHot)
        else
          Font.Color := StyleServices.GetStyleFontColor(sfButtonTextNormal);
      end;
      { Draw Button face }
      if I = ButtonIndex then FillRect(Items.Items[I].ItemRect);
      { Draw Glyph }
      GlyphRect := Rect(
        Items.Items[I].ItemRect.Left,
        Items.Items[I].ItemRect.Top + GlyphOffset,
        Items.Items[I].ItemRect.Right,
        Items.Items[I].ItemRect.Bottom - (GlyphOffset + Offset + TextHeight(Items.Items[I].Caption))
      );
      if Assigned(Items.Items[I].Glyph) then
      Draw(GlyphRect.Left + ((GlyphRect.Width div 2) - (Items.Items[I].Glyph.Width div 2)), GlyphRect.Top + ((GlyphRect.Height div 2) - (Items.Items[I].Glyph.Height div 2)), Items.Items[I].Glyph.Graphic);
      { Draw Text }
      CaptionRect := Rect(
        Items.Items[I].ItemRect.Left + OffSet,
        GlyphRect.Bottom,
        Items.Items[I].ItemRect.Right - OffSet,
        Items.Items[I].ItemRect.Bottom
      );
      DrawText(FBuffer.Canvas.Handle, Items.Items[I].Caption, Length(Items.Items[I].Caption), CaptionRect, DT_VCENTER or DT_CENTER or DT_SINGLELINE or DT_WORD_ELLIPSIS);
      if Focused and (I = ButtonIndex) then DrawFocusRect(Items.Items[I].ItemRect);
    end;
  end;

var
  X, Y, W, H, I : Integer;
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
    for I := 0 to Items.Count -1 do DrawButton(I);
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

procedure TERDButtonBar.Resize;
begin
  Redraw := True;
  inherited;
end;

procedure TERDButtonBar.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TERDButtonBar.WndProc(var Message: TMessage);
begin
  inherited;
  case Message.Msg of
    // Capture Keystrokes
    WM_GETDLGCODE:
      Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTALLKEYS;

    { Enabled/Disabled - Redraw }
    CM_ENABLEDCHANGED:
      begin
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
        FMouseOverItem := -1;
        Redraw := True;
        Invalidate;
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

procedure TERDButtonBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
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
  if CanFocus and (not Focused) then SetFocus;
  if IsMouseOverItem(I) then
  begin
    ButtonIndex := I;
  end;
  inherited;
end;

procedure TERDButtonBar.MouseMove(Shift: TShiftState; X: Integer; Y: Integer);

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
  if IsMouseOverItem(I) then
  begin
    if FMouseOverItem <> I then
    begin
      FMouseOverItem := I;
      if Hint <> Items.Items[I].Hint then
      begin
        FOldHint := Hint;
        Hint := Items.Items[I].Hint;
      end;
      Redraw := True;
      Invalidate;
    end;
  end else
  begin
    if Hint <> FOldHint then Hint := FOldHint;
    if FMouseOverItem <> -1 then
    begin
      FMouseOverItem := -1;
      Redraw := True;
      Invalidate;
    end;
  end;
  inherited;
end;

procedure TERDButtonBar.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_UP) then
  begin
    ButtonIndex := ButtonIndex -1;
  end else
  if (Key = VK_DOWN) then
  begin
    ButtonIndex := ButtonIndex +1;
  end;
  inherited;
end;

end.
