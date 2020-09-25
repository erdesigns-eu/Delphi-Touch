{
  untERDButtonPanel v1.0.0
  for Delphi 2010 - 10.4 by Ernst Reidinga
  https://erdesigns.eu

  This unit is part of the ERDesigns UCC Components Pack.

  (c) Copyright 2020 Ernst Reidinga <ernst@erdesigns.eu>

  Bugfixes / Updates:
  - Initial Release 1.0.0

  If you use this unit, please give credits to the original author;
  Ernst Reidinga.

}

unit untERDButtonPanel;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Controls, Vcl.Graphics,
  Winapi.Messages, System.Types, VCL.Themes;

type
  TERDButtonPanelItemClickEvent = procedure(Sender: TObject; Index: Integer) of object;

  TERDButtonPanelItem = class(TCollectionItem)
  private
    { Private declarations }
    FGlyph   : TPicture;
    FHint    : string;
    FCaption : string;
    FEnabled : Boolean;
    FRect    : TRect;

    procedure SetGlyph(const P: TPicture);
    procedure SetHint(const S: string);
    procedure SetCaption(const S: string);
    procedure SetEnabled(const B: Boolean);
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
    property Caption: string read FCaption write SetCaption;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
  end;

  TERDButtonPanelItems = class(TOwnedCollection)
  private
    { Private declarations }
    FOnChange : TNotifyEvent;

    function GetItem(Index: Integer): TERDButtonPanelItem;
    procedure SetItem(Index: Integer; const Value: TERDButtonPanelItem);
  protected
    { Protected declarations }
    procedure Update(Item: TCollectionItem); override;
  public
    { Public declarations }
    constructor Create(AOwner: TPersistent);
    function Add: TERDButtonPanelItem;
    procedure Assign(Source: TPersistent); override;

    property Items[Index: Integer]: TERDButtonPanelItem read GetItem write SetItem;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TERDButtonPanel = class(TCustomControl)
  private
    { Private declarations }
    FItems  : TERDButtonPanelItems;
    FCols   : Integer;
    FRows   : Integer;
    FScroll : Integer;

    { Buffer - Avoid flickering }
    FBuffer        : TBitmap;
    FUpdateRect    : TRect;
    FRedraw        : Boolean;

    { Hot / Pressed }
    FPressedIndex : Integer;
    FHotIndex     : Integer;

    { Rows with items - and Max scroll position }
    FMaxRows   : Integer;
    FMaxScroll : Integer;

    { "Old" hint - when mouse is over an item we want to remember the original hint }
    FOldHint : string;

    { Events }
    FOnButtonClick : TERDButtonPanelItemClickEvent;

    procedure SetCols(const I: Integer);
    procedure SetRows(const I: Integer);
    procedure SetScroll(const I: Integer);

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
    property Items: TERDButtonPanelItems read FItems write FItems;
    property Rows: Integer read FRows write SetRows default 4;
    property Cols: Integer read FCols write SetCols default 5;
    property Scroll: Integer read FScroll write SetScroll default 0;

    property ButtonClick: TERDButtonPanelItemClickEvent read FOnButtonClick write FOnButtonClick;

    property Align default alClient;
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
  { Space between glyph and caption }
  GlyphOffset = 8;

(******************************************************************************)
(*
(*  ERD Button Panel Item (TERDButtonPanelItem)
(*
(******************************************************************************)
constructor TERDButtonPanelItem.Create(AOWner: TCollection);
begin
  inherited Create(AOwner);
  FGlyph   := TPicture.Create;
  FCaption := Format('Button %d', [Index]);
  Fhint    := FCaption;
  FEnabled := True;
end;

destructor TERDButtonPanelItem.Destroy;
begin
  FGlyph.Free;
  inherited;
end;

procedure TERDButtonPanelItem.SetGlyph(const P: TPicture);
begin
  FGlyph.Assign(P);
  Changed(False);
end;

procedure TERDButtonPanelItem.SetHint(const S: string);
begin
  if Hint <> S then
  begin
    FHint := S;
    Changed(False);
  end;
end;

procedure TERDButtonPanelItem.SetCaption(const S: string);
begin
  if Caption <> S then
  begin
    FCaption := S;
    Changed(False);
  end;
end;

procedure TERDButtonPanelItem.SetEnabled(const B: Boolean);
begin
  if Enabled <> B then
  begin
    FEnabled := B;
    Changed(False);
  end;
end;

function TERDButtonPanelItem.GetDisplayName : string;
begin
  if Caption <> '' then
    Result := Caption
  else
    Result := Format('Button %d', [Index]);
end;

procedure TERDButtonPanelItem.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TERDButtonPanelItem then
  begin
    FGlyph.Assign(TERDButtonPanelItem(Source).Glyph);
    FHint    := TERDButtonPanelItem(Source).Hint;
    FCaption := TERDButtonPanelItem(Source).Caption;
    FEnabled := TERDButtonPanelItem(Source).Enabled;
    Changed(False);
  end else Inherited;
end;

(******************************************************************************)
(*
(*  ERD Button Panel Item Collection (TERDButtonPanelItems)
(*
(******************************************************************************)
constructor TERDButtonPanelItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TERDButtonPanelItem);
end;

procedure TERDButtonPanelItems.SetItem(Index: Integer; const Value: TERDButtonPanelItem);
begin
  inherited SetItem(Index, Value);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TERDButtonPanelItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TERDButtonPanelItems.GetItem(Index: Integer) : TERDButtonPanelItem;
begin
  Result := inherited GetItem(Index) as TERDButtonPanelItem;
end;

function TERDButtonPanelItems.Add : TERDButtonPanelItem;
begin
  Result := TERDButtonPanelItem(inherited Add);
end;

procedure TERDButtonPanelItems.Assign(Source: TPersistent);
var
  LI   : TERDButtonPanelItems;
  Loop : Integer;
begin
  if (Source is TERDButtonPanelItems)  then
  begin
    LI := TERDButtonPanelItems(Source);
    Clear;
    for Loop := 0 to LI.Count - 1 do
        Add.Assign(LI.Items[Loop]);
  end else inherited;
end;

(******************************************************************************)
(*
(*  ERD Button Panel (TERDButtonPanel)
(*
(******************************************************************************)
constructor TERDButtonPanel.Create(AOwner: TComponent);
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
  FItems := TERDButtonPanelItems.Create(Self);
  Fitems.OnChange := SettingsChanged;

  { Width / Height }
  Width  := 300;
  Height := 300;
  Align  := alClient;

  { Defaults }
  FCols   := 5;
  FRows   := 4;
  FScroll := 0;

  FPressedIndex := -1;
  FHotIndex     := -1;

  { Initial Draw }
  Redraw := True;
end;

destructor TERDButtonPanel.Destroy;
begin
  { Free Buffer }
  FBuffer.Free;

  { Free Items }
  FItems.Free;

  inherited Destroy;
end;

procedure TERDButtonPanel.SetCols(const I: Integer);
begin
  if Cols <> I then
  begin
    FCols := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDButtonPanel.SetRows(const I: Integer);
begin
  if Rows <> I then
  begin
    FRows := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDButtonPanel.SetScroll(const I: Integer);
begin
  if Scroll <> I then
  begin
    if (I <= FMaxScroll) then
    begin
      FScroll := I;
      SettingsChanged(Self);
    end else
    if (I < 0) then
    begin
      FScroll := 0;
      SettingsChanged(Self);
    end;
  end;
end;

procedure TERDButtonPanel.WMPaint(var Msg: TWMPaint);
begin
  GetUpdateRect(Handle, FUpdateRect, False);
  inherited;
end;

procedure TERDButtonPanel.WMEraseBkGnd(var Msg: TWMEraseBkgnd);
begin
  { Draw Buffer to the Control }
  BitBlt(Msg.DC, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := -1;
end;

procedure TERDButtonPanel.SettingsChanged(Sender: TObject);
begin
  Redraw := True;
  Invalidate;
end;

procedure TERDButtonPanel.Paint;
var
  WorkRect : TRect;

  procedure DrawBackground;
  begin
    with FBuffer.Canvas do
    begin
      FBuffer.Canvas.Brush.Style := bsSolid;
      if TStyleManager.IsCustomStyleActive and (seClient in StyleElements) then
      begin
        Brush.Color := StyleServices.GetStyleColor(scGenericBackground);
        FillRect(WorkRect);
      end else
      begin
        Brush.Color := Color;
        FillRect(WorkRect);
      end;
    end;
  end;

  procedure CalculateItemRects;
  var
    I, W, H, R, C : Integer;
  begin
    if Items.Count = 0 then Exit;
    InflateRect(WorkRect, -1, -1);
    W := Round(WorkRect.Width / Cols);
    H := WorkRect.Height div Rows;
    R := 0 - Scroll;
    C := 0;
    for I := 0 to Items.Count -1 do
    begin
      Items.Items[I].ItemRect := Rect(
        WorkRect.Left + (C * W),
        WorkRect.Top + (R * H),
        WorkRect.Left + (C * W) + W,
        WorkRect.Top + (R * H) + H
      );
      if (C = Cols -1) then
      begin
        C := 0;
        Inc(R);
      end else Inc(C);
    end;
    FMaxRows   := Ceil(Items.Count / Cols);
    FMaxScroll := FMaxRows - Rows;
  end;

  procedure DrawButtons;
  var
    I, H : Integer;
    R    : TRect;
    D    : TThemedElementDetails;
  begin
    FBuffer.Canvas.Font.Assign(Font);
    for I := 0 to Items.Count -1 do
    with FBuffer.Canvas do
    begin
      if (Items.Items[I].ItemRect.Bottom < WorkRect.Top) or (Items.Items[I].ItemRect.Top > WorkRect.Bottom) then Continue;
      if (not Enabled) or (not Items.Items[I].Enabled) then
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
      { Set Font color }
      if I = FHotIndex then
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfButtonTextHot)
      else
      if I = FPressedIndex then
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfButtonTextPressed)
      else
      if (not Enabled) or (not Items.Items[I].Enabled) then
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfButtonTextDisabled)
      else
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfButtonTextNormal);
      { Set Brush Color }
      if (not Enabled) or (not Items.Items[I].Enabled) then
        FBuffer.Canvas.Brush.Color := StyleServices.GetStyleColor(scButtonDisabled)
      else
      if I = FHotIndex then
        FBuffer.Canvas.Brush.Color := StyleServices.GetStyleColor(scButtonHot)
      else
      if I = FPressedIndex then
        FBuffer.Canvas.Brush.Color := StyleServices.GetStyleColor(scButtonPressed)
      else
        FBuffer.Canvas.Brush.Color := StyleServices.GetStyleColor(scButtonNormal);
      FBuffer.Canvas.Brush.Style := bsClear;
      { Glyph and caption }
      if (Trim(Items.Items[I].Caption) <> '') then
      begin
        R := Items.Items[I].ItemRect;
        InflateRect(R, -4, -4);
        DrawText(FBuffer.Canvas.Handle, PChar(Items.Items[I].Caption), Length(Items.Items[I].Caption), R, DT_LEFT or DT_WORDBREAK or DT_CALCRECT);
        H := Items.Items[I].Glyph.Height + GlyphOffset + R.Height;
        FBuffer.Canvas.Draw(
          Items.Items[I].ItemRect.Left + ((Items.Items[I].ItemRect.Width div 2) - (Items.Items[I].Glyph.Width div 2)),
          Items.Items[I].ItemRect.Top + ((Items.Items[I].ItemRect.Height div 2) - (H div 2)),
          Items.Items[I].Glyph.Graphic
        );
        R.Left   := Items.Items[I].ItemRect.Left + 8;
        R.Top    := Items.Items[I].ItemRect.Top + ((Items.Items[I].ItemRect.Height div 2) - (H div 2)) + Items.Items[I].Glyph.Height + GlyphOffset;
        R.Right  := Items.Items[I].ItemRect.Right - 8;
        R.Bottom := Items.Items[I].ItemRect.Bottom - 8;
        DrawText(FBuffer.Canvas.Handle, Items.Items[I].Caption, Length(Items.Items[I].Caption), R, DT_CENTER or DT_WORDBREAK or DT_END_ELLIPSIS);
      end else
      { Glyph only }
      if (Items.Items[I].Glyph.Width > 0) then
      begin
        FBuffer.Canvas.Draw(
          Items.Items[I].ItemRect.Left + ((Items.Items[I].ItemRect.Width div 2) - (Items.Items[I].Glyph.Width div 2)),
          Items.Items[I].ItemRect.Top + ((Items.Items[I].ItemRect.Height div 2) - (Items.Items[I].Glyph.Height div 2)),
          Items.Items[I].Glyph.Graphic
        );
      end;
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

procedure TERDButtonPanel.Resize;
begin
  Redraw := True;
  inherited;
end;

procedure TERDButtonPanel.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TERDButtonPanel.WndProc(var Message: TMessage);
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

procedure TERDButtonPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

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
    if IsMouseOverItem(I) and Items.Items[I].Enabled then
    begin
      FPressedIndex := I;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDButtonPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

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
      if IsMouseOverItem(I) and Items.Items[I].Enabled and (I = FPressedIndex) then
      begin
        if Assigned(FOnButtonClick) then FOnButtonClick(Self, I);
      end;
      FPressedIndex := -1;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDButtonPanel.MouseMove(Shift: TShiftState; X: Integer; Y: Integer);

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
    if IsMouseOverItem(I) and Items.Items[I].Enabled and (FPressedIndex = -1) then
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
