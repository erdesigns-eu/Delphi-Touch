{
  untERDNavigationIndicator v1.0.0
  for Delphi 2010 - 10.4 by Ernst Reidinga
  https://erdesigns.eu

  This unit is part of the ERDesigns UCC Components Pack.

  (c) Copyright 2020 Ernst Reidinga <ernst@erdesigns.eu>

  Bugfixes / Updates:
  - Initial Release 1.0.0

  If you use this unit, please give credits to the original author;
  Ernst Reidinga.

}

unit untERDNavigationIndicator;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Controls, Vcl.Graphics,
  Winapi.Messages, System.Types, VCL.Themes;

type
  TERDNavigationIndicator = class(TCustomControl)
  private
    { Private declarations }
    FBatteryFont    : TFont;
    FBattery        : string;
    FBatteryGlyph   : TPicture;
    FInterfaceFont  : TFont;
    FInterface      : string;
    FInterfaceGlyph : TPicture;
    FOffset         : Integer;

    { Buffer - Avoid flickering }
    FBuffer        : TBitmap;
    FUpdateRect    : TRect;
    FRedraw        : Boolean;

    procedure SetBatteryFont(const F: TFont);
    procedure SetBattery(const S: string);
    procedure SetBatteryGlyph(const P: TPicture);
    procedure SetInterfaceFont(const F: TFont);
    procedure SetInterface(const S: string);
    procedure SetInterfaceGlyph(const P: TPicture);
    procedure SetOffset(const I: Integer);

    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
  protected
    { Protected declarations }
    procedure SettingsChanged(Sender: TObject);

    procedure Paint; override;
    procedure Resize; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Redraw: Boolean read FRedraw write FRedraw;
    property UpdateRect: TRect read FUpdateRect write FUpdateRect;
  published
    { Published declarations }
    property BatteryFont: TFont read FBatteryFont write SetBatteryFont;
    property Battery: string read FBattery write SetBattery;
    property BatteryGlyph: TPicture read FBatteryGlyph write SetBatteryGlyph;
    property InterfaceFont: TFont read FInterfaceFont write SetInterfaceFont;
    property &Interface: string read FInterface write SetInterface;
    property InterfaceGlyph: TPicture read FInterfaceGlyph write SetInterfaceGlyph;
    property Offset: Integer read FOffset write SetOffset default 16;

    property Align default alTop;
    property Anchors;
    property Caption;
    property Color;
    property Constraints;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default False;
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

uses
  System.Math, untERDCommon;

const
  { Space between text and glyph }
  GlyphOffset = 4;

(******************************************************************************)
(*
(*  ERD Navigation Indicator (TERDNavigationIndicator)
(*
(******************************************************************************)
constructor TERDNavigationIndicator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  { If the ControlStyle property includes csOpaque, the control paints itself
    directly. We do want the control to accept controls - because we might
    want to place some controls on it }
  ControlStyle := ControlStyle + [csOpaque, csAcceptsControls,
    csCaptureMouse, csClickEvents, csDoubleClicks];

  { We dont want to be able to get focus - this is just a indicator / Panel }
  TabStop := False;

  { Create Buffers }
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;

  { Width / Height }
  Width  := 300;
  Height := 32;
  Align  := alTop;

  { Defaults }
  FBatteryFont    := TFont.Create;
  FBatteryFont.OnChange := SettingsChanged;
  FBattery        := '';
  FBatteryGlyph   := TPicture.Create;
  FBatteryGlyph.OnChange := SettingsChanged;
  FInterfaceFont  := TFont.Create;
  FInterfaceFont.OnChange := SettingsChanged;
  FInterface      := '';
  FInterfaceGlyph := TPicture.Create;
  FInterfaceGlyph.OnChange := SettingsChanged;
  FOffset         := 16;

  { Initial Draw }
  Redraw := True;
end;

destructor TERDNavigationIndicator.Destroy;
begin
  { Free Buffer }
  FBuffer.Free;

  { Free Fonts }
  FBatteryFont.Free;
  FInterfaceFont.Free;

  { Free Glyphs }
  FBatteryGlyph.Free;
  FInterfaceGlyph.Free;

  inherited Destroy;
end;

procedure TERDNavigationIndicator.SetBatteryFont(const F: TFont);
begin
  FBatteryFont.Assign(F);
  SettingsChanged(Self);
end;

procedure TERDNavigationIndicator.SetBattery(const S: string);
begin
  if Battery <> S then
  begin
    FBattery := S;
    SettingsChanged(Self);
  end;
end;

procedure TERDNavigationIndicator.SetBatteryGlyph(const P: TPicture);
begin
  FBatteryGlyph.Assign(P);
  SettingsChanged(Self);
end;

procedure TERDNavigationIndicator.SetInterfaceFont(const F: TFont);
begin
  FInterfaceFont.Assign(F);
  SettingsChanged(Self);
end;

procedure TERDNavigationIndicator.SetInterface(const S: string);
begin
  if &Interface <> S then
  begin
    FInterface := S;
    SettingsChanged(Self);
  end;
end;

procedure TERDNavigationIndicator.SetInterfaceGlyph(const P: TPicture);
begin
  FInterfaceGlyph.Assign(P);
  SettingsChanged(Self);
end;

procedure TERDNavigationIndicator.SetOffset(const I: Integer);
begin
  if Offset <> I then
  begin
    FOffset := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDNavigationIndicator.WMPaint(var Msg: TWMPaint);
begin
  GetUpdateRect(Handle, FUpdateRect, False);
  inherited;
end;

procedure TERDNavigationIndicator.WMEraseBkGnd(var Msg: TWMEraseBkgnd);
begin
  { Draw Buffer to the Control }
  BitBlt(Msg.DC, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := -1;
end;

procedure TERDNavigationIndicator.SettingsChanged(Sender: TObject);
begin
  Redraw := True;
  Invalidate;
end;

procedure TERDNavigationIndicator.Paint;
var
  WorkRect : TRect;

  procedure DrawMain;
  var
    D : TThemedElementDetails;
  begin
    with FBuffer.Canvas do
    begin
      if TStyleManager.IsCustomStyleActive and (seClient in StyleElements) then
      begin
        D := StyleServices.GetElementDetails(tcBorderNormal);
        StyleServices.DrawElement(FBuffer.Canvas.Handle, D, WorkRect);
      end else
      begin
        DrawGradient(FBuffer.Canvas, gsVertical, Darken(Color, 10), Color, 0, WorkRect);
      end;
      Font.Assign(Self.Font);
      Brush.Style := bsClear;
      if TStyleManager.IsCustomStyleActive and (seFont in StyleElements) then
      begin
        Font.Color := StyleServices.GetStyleFontColor(sfComboBoxItemNormal);
        Brush.Color := StyleServices.GetStyleColor(scComboBox);
      end;
      DrawText(FBuffer.Canvas.Handle, Caption, Length(Caption), WorkRect, DT_VCENTER or DT_CENTER or DT_SINGLELINE or DT_WORD_ELLIPSIS);
    end;
  end;

  procedure DrawBattery;
  var
    W : Integer;
    R : TRect;
  begin
    if Length(Trim(Battery)) > 0 then
    with FBuffer.Canvas do
    begin
      Font.Assign(BatteryFont);
      Brush.Style := bsClear;
      R := WorkRect;
      R.Right := WorkRect.Right - Offset;
      W := TextWidth(Battery);
      if TStyleManager.IsCustomStyleActive and (seFont in StyleElements) then
      begin
        Font.Color := StyleServices.GetStyleFontColor(sfComboBoxItemNormal);
        Brush.Color := StyleServices.GetStyleColor(scComboBox);
      end;
      DrawText(FBuffer.Canvas.Handle, Battery, Length(Battery), R, DT_VCENTER or DT_RIGHT or DT_SINGLELINE or DT_WORD_ELLIPSIS);
      if (BatteryGlyph.Width > 0) and (BatteryGlyph.Height > 0) then
        Draw(WorkRect.Right - (W + Offset + GlyphOffset + BatteryGlyph.Width), WorkRect.Top + ((WorkRect.Height div 2) - (BatteryGlyph.Height div 2)), BatteryGlyph.Graphic);
    end;
  end;

  procedure DrawInterface;
  var
    W : Integer;
    R : TRect;
  begin
    if Length(Trim(&Interface)) > 0 then
    with FBuffer.Canvas do
    begin
      Font.Assign(InterfaceFont);
      Brush.Style := bsClear;
      R := WorkRect;
      R.Left := WorkRect.Left + Offset;
      W := TextWidth(&Interface);
      if TStyleManager.IsCustomStyleActive and (seFont in StyleElements) then
      begin
        Font.Color := StyleServices.GetStyleFontColor(sfComboBoxItemNormal);
        Brush.Color := StyleServices.GetStyleColor(scComboBox);
      end;
      DrawText(FBuffer.Canvas.Handle, &Interface, Length(&Interface), R, DT_VCENTER or DT_LEFT or DT_SINGLELINE or DT_WORD_ELLIPSIS);
      if (InterfaceGlyph.Width > 0) and (InterfaceGlyph.Height > 0) then
        Draw(WorkRect.Left + (W + Offset + GlyphOffset), WorkRect.Top + ((WorkRect.Height div 2) - (InterfaceGlyph.Height div 2)), InterfaceGlyph.Graphic);
    end;
  end;

var
  X, Y, W, H: Integer;
begin
  { Draw the panel to the buffer }
  if Redraw then
  begin
    Redraw := False;
    WorkRect := ClientRect;

    { Set Buffer size }
    FBuffer.SetSize(ClientWidth, ClientHeight);

    { Draw to buffer }
    DrawMain;
    DrawInterface;
    DrawBattery;
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

procedure TERDNavigationIndicator.Resize;
begin
  Redraw := True;
  inherited;
end;

procedure TERDNavigationIndicator.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TERDNavigationIndicator.WndProc(var Message: TMessage);
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

    { Caption changed }
    CM_TEXTCHANGED:
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

    { Style Changed }
    CM_STYLECHANGED:
      begin
        Redraw := True;
        Invalidate;
      end;
  end;
end;

end.
