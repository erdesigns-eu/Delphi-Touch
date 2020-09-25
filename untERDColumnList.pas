{
  untERDColumnList v1.0.0 (A listbox like component)
  for Delphi 2010 - 10.4 by Ernst Reidinga
  https://erdesigns.eu

  This unit is part of the ERDesigns UCC Components Pack.

  (c) Copyright 2020 Ernst Reidinga <ernst@erdesigns.eu>

  Bugfixes / Updates:
  - Initial Release 1.0.0

  If you use this unit, please give credits to the original author;
  Ernst Reidinga.

}

unit untERDColumnList;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Controls, Vcl.Graphics,
  Winapi.Messages, System.Types, VCL.Themes;

type
  TERDListItemSelectEvent = procedure(Sender: TObject; Index: Integer) of object;

  TERDVehicleListItem = class(TCollectionItem)
  private
    { Private declarations }
    FLogo    : TPicture;
    FBrand   : string;
    FModel   : string;
    FPlate   : string;
    FVIN     : string;
    FID      : Integer;
    FDate    : TDateTime;
    FEnabled : Boolean;
    FRect    : TRect;

    procedure SetLogo(const P: TPicture);
    procedure SetBrand(const S: string);
    procedure SetModel(const S: string);
    procedure SetPlate(const S: string);
    procedure SetVIN(const S: string);
    procedure SetID(const I: Integer);
    procedure SetDate(const D: TDateTime);
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
    property Logo: TPicture read FLogo write SetLogo;
    property Brand: string read FBrand write SetBrand;
    property Model: string read FModel write SetModel;
    property LicensePlate: string read FPlate write SetPlate;
    property VIN: string read FVIN write SetVIN;
    property VehicleID: Integer read FID write SetID;
    property Date: TDateTime read FDate write SetDate;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
  end;

  TERDVehicleListItems = class(TOwnedCollection)
  private
    { Private declarations }
    FOnChange : TNotifyEvent;

    function GetItem(Index: Integer): TERDVehicleListItem;
    procedure SetItem(Index: Integer; const Value: TERDVehicleListItem);
  protected
    { Protected declarations }
    procedure Update(Item: TCollectionItem); override;
  public
    { Public declarations }
    constructor Create(AOwner: TPersistent);
    function Add: TERDVehicleListItem;
    procedure Assign(Source: TPersistent); override;

    property Items[Index: Integer]: TERDVehicleListItem read GetItem write SetItem;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TERDVehicleList = class(TCustomControl)
  private
    { Private declarations }
    FItems      : TERDVehicleListItems;
    FRows       : Integer;
    FScroll     : Integer;
    FDateFormat : string;

    { Buffer - Avoid flickering }
    FBuffer        : TBitmap;
    FUpdateRect    : TRect;
    FRedraw        : Boolean;

    { Hot / Pressed }
    FHotIndex     : Integer;
    FItemIndex    : Integer;

    { Max scroll position }
    FMaxScroll : Integer;

    { Events }
    FOnSelectItem : TERDListItemSelectEvent;

    procedure SetRows(const I: Integer);
    procedure SetScroll(const I: Integer);
    procedure SetItemIndex(const I: Integer);
    procedure SetDateFormat(const S: string);

    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
  protected
    { Protected declarations }
    procedure SettingsChanged(Sender: TObject);

    procedure Paint; override;
    procedure Resize; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function IndexOfVehicleID(const I: Integer) : Integer;

    property Redraw: Boolean read FRedraw write FRedraw;
    property UpdateRect: TRect read FUpdateRect write FUpdateRect;
  published
    { Published declarations }
    property Items: TERDVehicleListItems read FItems write FItems;
    property Rows: Integer read FRows write SetRows default 6;
    property Scroll: Integer read FScroll write SetScroll default 0;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property DateFormat: string read FDateFormat write SetDateFormat;

    property OnSelect: TERDListItemSelectEvent read FOnSelectItem write FOnSelectItem;

    property Align;
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

  TERDSimpleListItem = class(TCollectionItem)
  private
    { Private declarations }
    FGlyph   : TPicture;
    FCaption : string;
    FRect    : TRect;

    procedure SetGlyph(const P: TPicture);
    procedure SetCaption(const S: string);
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
    property Caption: string read FCaption write SetCaption;
  end;

  TERDSimpleListItems = class(TOwnedCollection)
  private
    { Private declarations }
    FOnChange : TNotifyEvent;

    function GetItem(Index: Integer): TERDSimpleListItem;
    procedure SetItem(Index: Integer; const Value: TERDSimpleListItem);
  protected
    { Protected declarations }
    procedure Update(Item: TCollectionItem); override;
  public
    { Public declarations }
    constructor Create(AOwner: TPersistent);
    function Add: TERDSimpleListItem;
    procedure Assign(Source: TPersistent); override;

    property Items[Index: Integer]: TERDSimpleListItem read GetItem write SetItem;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TERDSimpleList = class(TCustomControl)
  private
    { Private declarations }
    FItems      : TERDSimpleListItems;
    FRows       : Integer;
    FScroll     : Integer;
    FGlyphSize  : Integer;

    { Buffer - Avoid flickering }
    FBuffer        : TBitmap;
    FUpdateRect    : TRect;
    FRedraw        : Boolean;

    { Hot / Pressed }
    FHotIndex     : Integer;
    FItemIndex    : Integer;

    { Max scroll position }
    FMaxScroll : Integer;

    { Events }
    FOnSelectItem : TERDListItemSelectEvent;

    procedure SetRows(const I: Integer);
    procedure SetScroll(const I: Integer);
    procedure SetItemIndex(const I: Integer);
    procedure SetGlyphSize(const I: Integer);

    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
  protected
    { Protected declarations }
    procedure SettingsChanged(Sender: TObject);

    procedure Paint; override;
    procedure Resize; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
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
    property Items: TERDSimpleListItems read FItems write FItems;
    property Rows: Integer read FRows write SetRows default 6;
    property Scroll: Integer read FScroll write SetScroll default 0;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property GlyphSize: Integer read FGlyphSize write SetGlyphSize default 48;

    property OnSelect: TERDListItemSelectEvent read FOnSelectItem write FOnSelectItem;

    property Align;
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

  TERDSubListItem = class(TCollectionItem)
  private
    { Private declarations }
    FGlyph      : TPicture;
    FCaption    : string;
    FSubCaption : string;
    FRect       : TRect;

    procedure SetGlyph(const P: TPicture);
    procedure SetCaption(const S: string);
    procedure SetSubCaption(const S: string);
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
    property Caption: string read FCaption write SetCaption;
    property SubCaption: string read FSubCaption write SetSubCaption;
  end;

  TERDSubListItems = class(TOwnedCollection)
  private
    { Private declarations }
    FOnChange : TNotifyEvent;

    function GetItem(Index: Integer): TERDSubListItem;
    procedure SetItem(Index: Integer; const Value: TERDSubListItem);
  protected
    { Protected declarations }
    procedure Update(Item: TCollectionItem); override;
  public
    { Public declarations }
    constructor Create(AOwner: TPersistent);
    function Add: TERDSubListItem;
    procedure Assign(Source: TPersistent); override;

    property Items[Index: Integer]: TERDSubListItem read GetItem write SetItem;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TERDSubList = class(TCustomControl)
  private
    { Private declarations }
    FItems      : TERDSubListItems;
    FRows       : Integer;
    FScroll     : Integer;
    FGlyphSize  : Integer;

    { Buffer - Avoid flickering }
    FBuffer        : TBitmap;
    FUpdateRect    : TRect;
    FRedraw        : Boolean;

    { Hot / Pressed }
    FHotIndex     : Integer;
    FItemIndex    : Integer;

    { Max scroll position }
    FMaxScroll : Integer;

    { Events }
    FOnSelectItem : TERDListItemSelectEvent;

    procedure SetRows(const I: Integer);
    procedure SetScroll(const I: Integer);
    procedure SetItemIndex(const I: Integer);
    procedure SetGlyphSize(const I: Integer);

    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
  protected
    { Protected declarations }
    procedure SettingsChanged(Sender: TObject);

    procedure Paint; override;
    procedure Resize; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
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
    property Items: TERDSubListItems read FItems write FItems;
    property Rows: Integer read FRows write SetRows default 6;
    property Scroll: Integer read FScroll write SetScroll default 0;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property GlyphSize: Integer read FGlyphSize write SetGlyphSize default 48;

    property OnSelect: TERDListItemSelectEvent read FOnSelectItem write FOnSelectItem;

    property Align;
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

  TERDDTCListItem = class(TCollectionItem)
  private
    { Private declarations }
    FDTC         : string;
    FDescription : string;
    FVehicleArea : string;
    FSystem      : string;
    FRect        : TRect;

    procedure SetDTC(const S: string);
    procedure SetDescription(const S: string);
    procedure SetVehicleArea(const S: string);
    procedure SetSystem(const S: string);
  protected
    { Protected declarations }
    function GetDisplayName: string; override;
  public
    { Public declarations }
    constructor Create(AOWner: TCollection); override;

    procedure Assign(Source: TPersistent); override;
    property ItemRect: TRect read FRect write FRect;
  published
    { Published declarations }
    property DTC: string read FDTC write SetDTC;
    property Description: string read FDescription write SetDescription;
    property VehicleArea: string read FVehicleArea write SetVehicleArea;
    property System: string read FSystem write SetSystem;
  end;

  TERDDTCListItems = class(TOwnedCollection)
  private
    { Private declarations }
    FOnChange : TNotifyEvent;

    function GetItem(Index: Integer): TERDDTCListItem;
    procedure SetItem(Index: Integer; const Value: TERDDTCListItem);
  protected
    { Protected declarations }
    procedure Update(Item: TCollectionItem); override;
  public
    { Public declarations }
    constructor Create(AOwner: TPersistent);
    function Add: TERDDTCListItem;
    procedure Assign(Source: TPersistent); override;

    property Items[Index: Integer]: TERDDTCListItem read GetItem write SetItem;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TERDDTCList = class(TCustomControl)
  private
    { Private declarations }
    FItems      : TERDDTCListItems;
    FRows       : Integer;
    FScroll     : Integer;

    { Column Sizes }
    FColHeight        : Integer;
    FDTCWidth         : Integer;
    FVehicleAreaWidth : Integer;
    FSystemWidth      : Integer;
    { Column Captions }
    FDTC              : string;
    FDescription      : string;
    FVehicleArea      : string;
    FSystem           : string;

    { Buffer - Avoid flickering }
    FBuffer        : TBitmap;
    FUpdateRect    : TRect;
    FRedraw        : Boolean;

    { Hot / Pressed }
    FHotIndex     : Integer;
    FItemIndex    : Integer;

    { Max scroll position }
    FMaxScroll : Integer;

    { Events }
    FOnSelectItem : TERDListItemSelectEvent;

    procedure SetRows(const I: Integer);
    procedure SetScroll(const I: Integer);
    procedure SetItemIndex(const I: Integer);

    procedure SetColHeight(const I: Integer);
    procedure SetDTCWidth(const I: Integer);
    procedure SetVehicleAreaWidth(const I: Integer);
    procedure SetSystemWidth(const I: Integer);

    procedure SetDTC(const S: string);
    procedure SetDescription(const S: string);
    procedure SetVehicleArea(const S: string);
    procedure SetSystem(const S: string);

    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
  protected
    { Protected declarations }
    procedure SettingsChanged(Sender: TObject);

    procedure Paint; override;
    procedure Resize; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
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
    property Items: TERDDTCListItems read FItems write FItems;
    property Rows: Integer read FRows write SetRows default 10;
    property Scroll: Integer read FScroll write SetScroll default 0;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;

    property ColHeight: Integer read FColHeight write SetColHeight default 40;
    property DTCWidth: Integer read FDTCWidth write SetDTCWidth default 100;
    property VehicleAreaWidth: Integer read FVehicleAreaWidth write SetVehicleAreaWidth default 250;
    property SystemWidth: Integer read FSystemWidth write SetSystemWidth default 250;

    property DTC: string read FDTC write SetDTC;
    property Description: string read FDescription write SetDescription;
    property VehicleArea: string read FVehicleArea write SetVehicleArea;
    property System: string read FSystem write SetSystem;

    property OnSelect: TERDListItemSelectEvent read FOnSelectItem write FOnSelectItem;

    property Align;
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

  TERDFreezeFrameListItem = class(TCollectionItem)
  private
    { Private declarations }
    FPID         : string;
    FDescription : string;
    FValue       : string;
    FUnit        : string;
    FRect        : TRect;

    procedure SetPID(const S: string);
    procedure SetDescription(const S: string);
    procedure SetValue(const S: string);
    procedure SetUnit(const S: string);
  protected
    { Protected declarations }
    function GetDisplayName: string; override;
  public
    { Public declarations }
    constructor Create(AOWner: TCollection); override;

    procedure Assign(Source: TPersistent); override;
    property ItemRect: TRect read FRect write FRect;
  published
    { Published declarations }
    property PID: string read FPID write SetPID;
    property Description: string read FDescription write SetDescription;
    property Value: string read FValue write SetValue;
    property &Unit: string read FUnit write SetUnit;
  end;

  TERDFreezeFrameListItems = class(TOwnedCollection)
  private
    { Private declarations }
    FOnChange : TNotifyEvent;

    function GetItem(Index: Integer): TERDFreezeFrameListItem;
    procedure SetItem(Index: Integer; const Value: TERDFreezeFrameListItem);
  protected
    { Protected declarations }
    procedure Update(Item: TCollectionItem); override;
  public
    { Public declarations }
    constructor Create(AOwner: TPersistent);
    function Add: TERDFreezeFrameListItem;
    procedure Assign(Source: TPersistent); override;

    property Items[Index: Integer]: TERDFreezeFrameListItem read GetItem write SetItem;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TERDFreezeFrameList = class(TCustomControl)
  private
    { Private declarations }
    FItems      : TERDFreezeFrameListItems;
    FRows       : Integer;
    FScroll     : Integer;

    { Column Sizes }
    FColHeight        : Integer;
    FPIDWidth         : Integer;
    FValueWidth       : Integer;
    FUnitWidth        : Integer;
    { Column Captions }
    FPID              : string;
    FDescription      : string;
    FValue            : string;
    FUnit             : string;

    { Buffer - Avoid flickering }
    FBuffer        : TBitmap;
    FUpdateRect    : TRect;
    FRedraw        : Boolean;

    { Hot / Pressed }
    FHotIndex     : Integer;
    FItemIndex    : Integer;

    { Max scroll position }
    FMaxScroll : Integer;

    { Events }
    FOnSelectItem : TERDListItemSelectEvent;

    procedure SetRows(const I: Integer);
    procedure SetScroll(const I: Integer);
    procedure SetItemIndex(const I: Integer);

    procedure SetColHeight(const I: Integer);
    procedure SetPIDWidth(const I: Integer);
    procedure SetValueWidth(const I: Integer);
    procedure SetUnitWidth(const I: Integer);

    procedure SetPID(const S: string);
    procedure SetDescription(const S: string);
    procedure SetValue(const S: string);
    procedure SetUnit(const S: string);

    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
  protected
    { Protected declarations }
    procedure SettingsChanged(Sender: TObject);

    procedure Paint; override;
    procedure Resize; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
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
    property Items: TERDFreezeFrameListItems read FItems write FItems;
    property Rows: Integer read FRows write SetRows default 10;
    property Scroll: Integer read FScroll write SetScroll default 0;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;

    property ColHeight: Integer read FColHeight write SetColHeight default 40;
    property PIDWidth: Integer read FPIDWidth write SetPIDWidth default 100;
    property ValueWidth: Integer read FValueWidth write SetValueWidth default 250;
    property UnitWidth: Integer read FUnitWidth write SetUnitWidth default 250;

    property PID: string read FPID write SetPID;
    property Description: string read FDescription write SetDescription;
    property Value: string read FValue write SetValue;
    property &Unit: string read FUnit write SetUnit;

    property OnSelect: TERDListItemSelectEvent read FOnSelectItem write FOnSelectItem;

    property Align;
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

const
  { Change this if another language is needed - or make them published }
  StrKenteken = 'Kenteken: ';
  StrVIN      = 'VIN: ';
  StrDate     = 'Datum:';

(******************************************************************************)
(*
(*  ERD Vehicle List Item (TERDVehicleListItem)
(*
(******************************************************************************)
constructor TERDVehicleListItem.Create(AOWner: TCollection);
begin
  inherited Create(AOwner);
  FLogo    := TPicture.Create;
  FBrand   := '';
  FModel   := '';
  FPlate   := '';
  FDate    := Now;
  FEnabled := True;
end;

destructor TERDVehicleListItem.Destroy;
begin
  FLogo.Free;
  inherited;
end;

procedure TERDVehicleListItem.SetLogo(const P: TPicture);
begin
  FLogo.Assign(P);
  Changed(False);
end;

procedure TERDVehicleListItem.SetBrand(const S: string);
begin
  if Brand <> S then
  begin
    FBrand := S;
    Changed(False);
  end;
end;

procedure TERDVehicleListItem.SetModel(const S: string);
begin
  if Model <> S then
  begin
    FModel := S;
    Changed(False);
  end;
end;

procedure TERDVehicleListItem.SetPlate(const S: string);
begin
  if LicensePlate <> S then
  begin
    FPlate := S;
    Changed(False);
  end;
end;

procedure TERDVehicleListItem.SetVIN(const S: string);
begin
  if VIN <> S then
  begin
    FVIN := S;
    Changed(False);
  end;
end;

procedure TERDVehicleListItem.SetID(const I: Integer);
begin
  if VehicleID <> I then
  begin
    FID := I;
    Changed(False);
  end;
end;

procedure TERDVehicleListItem.SetDate(const D: TDateTime);
begin
  if Date <> D then
  begin
    FDate := D;
    Changed(False);
  end;
end;

procedure TERDVehicleListItem.SetEnabled(const B: Boolean);
begin
  if Enabled <> B then
  begin
    FEnabled := B;
    Changed(False);
  end;
end;

function TERDVehicleListItem.GetDisplayName : string;
begin
  Result := Format('Item %d', [Index]);
end;

procedure TERDVehicleListItem.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TERDVehicleListItem then
  begin
    FLogo.Assign(TERDVehicleListItem(Source).Logo);
    FBrand   := TERDVehicleListItem(Source).Brand;
    FModel   := TERDVehicleListItem(Source).Model;
    FPlate   := TERDVehicleListItem(Source).LicensePlate;
    FVIN     := TERDVehicleListItem(Source).VIN;
    FID      := TERDVehicleListItem(Source).VehicleID;
    FDate    := TERDVehicleListItem(Source).Date;
    FEnabled := TERDVehicleListItem(Source).Enabled;
    Changed(False);
  end else Inherited;
end;

(******************************************************************************)
(*
(*  ERD Vehicle List Item Collection (TERDVehicleListItems)
(*
(******************************************************************************)
constructor TERDVehicleListItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TERDVehicleListItem);
end;

procedure TERDVehicleListItems.SetItem(Index: Integer; const Value: TERDVehicleListItem);
begin
  inherited SetItem(Index, Value);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TERDVehicleListItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TERDVehicleListItems.GetItem(Index: Integer) : TERDVehicleListItem;
begin
  Result := inherited GetItem(Index) as TERDVehicleListItem;
end;

function TERDVehicleListItems.Add : TERDVehicleListItem;
begin
  Result := TERDVehicleListItem(inherited Add);
end;

procedure TERDVehicleListItems.Assign(Source: TPersistent);
var
  LI   : TERDVehicleListItems;
  Loop : Integer;
begin
  if (Source is TERDVehicleListItems)  then
  begin
    LI := TERDVehicleListItems(Source);
    Clear;
    for Loop := 0 to LI.Count - 1 do
        Add.Assign(LI.Items[Loop]);
  end else inherited;
end;

(******************************************************************************)
(*
(*  ERD Vehicle List (TERDVehicleList)
(*
(******************************************************************************)
constructor TERDVehicleList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  { If the ControlStyle property includes csOpaque, the control paints itself
    directly. We dont want the control to accept controls - this is a list }
  ControlStyle := ControlStyle + [csOpaque, {csAcceptsControls,}
    csCaptureMouse, csClickEvents, csDoubleClicks];

  { We want to be able to get focus }
  TabStop := True;

  { Create Buffers }
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;

  { Create Items }
  FItems := TERDVehicleListItems.Create(Self);
  Fitems.OnChange := SettingsChanged;

  { Width / Height }
  Width  := 300;
  Height := 200;

  { Defaults }
  FRows   := 6;
  FScroll := 0;

  FHotIndex     := -1;
  FItemIndex    := -1;
  FDateFormat   := 'dd/mm/yyyy';

  { Initial Draw }
  Redraw := True;
end;

destructor TERDVehicleList.Destroy;
begin
  { Free Buffer }
  FBuffer.Free;

  { Free Items }
  FItems.Free;

  inherited Destroy;
end;

function TERDVehicleList.IndexOfVehicleID(const I: Integer) : Integer;
var
  X : Integer;
begin
  Result := -1;
  for X := 0 to Items.Count -1 do
  if Items.Items[X].VehicleID = I then
  begin
    Result := X;
    Break;
  end;
end;

procedure TERDVehicleList.SetRows(const I: Integer);
begin
  if Rows <> I then
  begin
    FRows := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDVehicleList.SetScroll(const I: Integer);
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

procedure TERDVehicleList.SetItemIndex(const I: Integer);
begin
  if ItemIndex <> I then
  begin
    if (I <= Items.Count -1) then
    begin
      if (I >= Rows - Scroll) and (I > ItemIndex) then
        Scroll := Scroll +1
      else
      if (I < ItemIndex) and (I - Scroll < 0) then
        Scroll := Scroll -1;

      FItemIndex := I;
      SettingsChanged(Self);
    end else
    if (I < 0) then
    begin
      FItemIndex := 0;
      SettingsChanged(Self);
    end;
  end;
end;

procedure TERDVehicleList.SetDateFormat(const S: string);
begin
  if DateFormat <> S then
  begin
    FDAteFormat := S;
    SettingsChanged(Self);
  end;
end;

procedure TERDVehicleList.WMPaint(var Msg: TWMPaint);
begin
  GetUpdateRect(Handle, FUpdateRect, False);
  inherited;
end;

procedure TERDVehicleList.WMEraseBkGnd(var Msg: TWMEraseBkgnd);
begin
  { Draw Buffer to the Control }
  BitBlt(Msg.DC, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := -1;
end;

procedure TERDVehicleList.SettingsChanged(Sender: TObject);
begin
  Redraw := True;
  Invalidate;
end;

procedure TERDVehicleList.Paint;
var
  WorkRect : TRect;

  procedure DrawBackground;
  var
    LDetails : TThemedElementDetails;
  begin
    with FBuffer.Canvas do
    begin
      Brush.Color := StyleServices.GetStyleColor(scComboBox);
      LDetails := StyleServices.GetElementDetails(tcBorderNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, LDetails, WorkRect);
    end;
  end;

  procedure CalculateItemRects;
  var
    I, H, R : Integer;
  begin
    if Items.Count = 0 then Exit;
    InflateRect(WorkRect, -1, -1);
    H := WorkRect.Height div Rows;
    R := 0 - Scroll;
    for I := 0 to Items.Count -1 do
    begin
      Items.Items[I].ItemRect := Rect(
        WorkRect.Left,
        WorkRect.Top + (R * H),
        WorkRect.Right,
        WorkRect.Top + (R * H) + H
      );
      Inc(R);
    end;
    FMaxScroll := Items.Count - Rows;
  end;

  procedure DrawItems;
  var
    I  : Integer;
    R  : TRect;
    D  : TThemedElementDetails;
    S  : string;
    RP : Boolean;
  begin
    RP := False;
    FBuffer.Canvas.Font.Assign(Font);
    for I := 0 to Items.Count -1 do
    with FBuffer.Canvas do
    begin
      if (Items.Items[I].ItemRect.Bottom < WorkRect.Top) or (Items.Items[I].ItemRect.Top > WorkRect.Bottom) then Continue;
      if ItemIndex = I then
        D := StyleServices.GetElementDetails(tgCellSelected)
      else
      if FHotIndex = I then
        D := StyleServices.GetElementDetails(tgFixedCellHot)
      else
        D := StyleServices.GetElementDetails(tgCellNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, D, Items.Items[I].ItemRect);
      Draw(LogoOffset, Items.Items[I].ItemRect.Top + ((Items.Items[I].ItemRect.Height div 2) - (Items.Items[I].Logo.Height div 2)), Items.Items[I].Logo.Graphic);
      { Set Font color }
      if I = FHotIndex then
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfGridItemFixedHot)
      else
      if I = ItemIndex then
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfGridItemSelected)
      else
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfGridItemFixedNormal);
      { Draw Brand and Model }
      R := Items.Items[I].ItemRect;
      R.Left := R.Left + LogoOffset + Items.Items[I].Logo.Width + LogoOffset;
      S := Items.Items[I].Brand + #13 + Items.Items[I].Model;
      DrawText(FBuffer.Canvas.Handle, PChar(S), Length(S), R, DT_LEFT or DT_WORDBREAK or DT_CALCRECT);
      R := Rect(
        R.Left,
        Items.Items[I].ItemRect.Top + ((Items.Items[I].ItemRect.Height div 2) - (R.Height div 2)),
        Items.Items[I].ItemRect.Right,
        Items.Items[I].ItemRect.Bottom
      );
      if (I = FHotIndex) or (I = ItemIndex)  then
        Font.Color := StyleServices.GetSystemColor(clHighlightText)
      else
        Font.Color := StyleServices.GetSystemColor(clWindowText);
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, S, R, TTextFormatFlags(DT_LEFT or DT_END_ELLIPSIS), Font.Color);
      { Draw License plate and VIN }
      R := Items.Items[I].ItemRect;
      R.Left := (WorkRect.Width div 3);
      S := StrKenteken + Items.Items[I].LicensePlate + #13 + StrVIN + Items.Items[I].VIN;
      DrawText(FBuffer.Canvas.Handle, PChar(S), Length(S), R, DT_LEFT or DT_WORDBREAK or DT_CALCRECT);
      R := Rect(
        (WorkRect.Width div 3),
        Items.Items[I].ItemRect.Top + ((Items.Items[I].ItemRect.Height div 2) - (R.Height div 2)),
        Items.Items[I].ItemRect.Right,
        Items.Items[I].ItemRect.Bottom
      );
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, S, R, TTextFormatFlags(DT_LEFT or DT_END_ELLIPSIS), Font.Color);
      { Draw Date }
      R := Items.Items[I].ItemRect;
      S := StrDate + #13 + FormatDateTime(DateFormat, Items.Items[I].Date);
      DrawText(FBuffer.Canvas.Handle, PChar(S), Length(S), R, DT_RIGHT or DT_WORDBREAK or DT_CALCRECT);
      R := Rect(
        Items.Items[I].ItemRect.Left,
        Items.Items[I].ItemRect.Top + ((Items.Items[I].ItemRect.Height div 2) - (R.Height div 2)),
        Items.Items[I].ItemRect.Right - LogoOffset,
        Items.Items[I].ItemRect.Bottom
      );
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, S, R, TTextFormatFlags(DT_RIGHT or DT_END_ELLIPSIS), Font.Color);
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
    DrawItems;
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

procedure TERDVehicleList.Resize;
begin
  Redraw := True;
  inherited;
end;

procedure TERDVehicleList.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TERDVehicleList.WndProc(var Message: TMessage);
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
          FHotIndex := -1;
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

procedure TERDVehicleList.MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

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
      ItemIndex := I;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDVehicleList.MouseMove(Shift: TShiftState; X: Integer; Y: Integer);

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
    if IsMouseOverItem(I) and Items.Items[I].Enabled then
    begin
      FHotIndex := I;
      SettingsChanged(Self);
    end else
    if FHotIndex > -1 then
    begin
      FHotIndex := -1;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDVehicleList.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_UP) and (ItemIndex > 0) then
  begin
    ItemIndex := ItemIndex -1;
  end else
  if (Key = VK_DOWN) and (ItemIndex < Items.Count -1) then
  begin
    ItemIndex := ItemIndex +1;
  end;
end;

(******************************************************************************)
(*
(*  ERD Simple List Item (TERDSimpleListItem)
(*
(******************************************************************************)
constructor TERDSimpleListItem.Create(AOWner: TCollection);
begin
  inherited Create(AOwner);
  FGlyph   := TPicture.Create;
  FCaption := Format('Item %d', [Index]);
end;

destructor TERDSimpleListItem.Destroy;
begin
  FGlyph.Free;
  inherited;
end;

procedure TERDSimpleListItem.SetGlyph(const P: TPicture);
begin
  FGlyph.Assign(P);
  Changed(False);
end;

procedure TERDSimpleListItem.SetCaption(const S: string);
begin
  if Caption <> S then
  begin
    FCaption := S;
    Changed(False);
  end;
end;

function TERDSimpleListItem.GetDisplayName : string;
begin
  if Caption <> '' then
    Result := Caption
  else
    Result := Format('Item %d', [Index]);
end;

procedure TERDSimpleListItem.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TERDSimpleListItem then
  begin
    FGlyph.Assign(TERDSimpleListItem(Source).Glyph);
    FCaption := TERDSimpleListItem(Source).Caption;
    Changed(False);
  end else Inherited;
end;

(******************************************************************************)
(*
(*  ERD Simple List Item Collection (TERDSimpleListItems)
(*
(******************************************************************************)
constructor TERDSimpleListItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TERDSimpleListItem);
end;

procedure TERDSimpleListItems.SetItem(Index: Integer; const Value: TERDSimpleListItem);
begin
  inherited SetItem(Index, Value);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TERDSimpleListItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TERDSimpleListItems.GetItem(Index: Integer) : TERDSimpleListItem;
begin
  Result := inherited GetItem(Index) as TERDSimpleListItem;
end;

function TERDSimpleListItems.Add : TERDSimpleListItem;
begin
  Result := TERDSimpleListItem(inherited Add);
end;

procedure TERDSimpleListItems.Assign(Source: TPersistent);
var
  LI   : TERDSimpleListItems;
  Loop : Integer;
begin
  if (Source is TERDSimpleListItems)  then
  begin
    LI := TERDSimpleListItems(Source);
    Clear;
    for Loop := 0 to LI.Count - 1 do
        Add.Assign(LI.Items[Loop]);
  end else inherited;
end;

(******************************************************************************)
(*
(*  ERD Simple List (TERDSimpleList)
(*
(******************************************************************************)
constructor TERDSimpleList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  { If the ControlStyle property includes csOpaque, the control paints itself
    directly. We dont want the control to accept controls - this is a list }
  ControlStyle := ControlStyle + [csOpaque, {csAcceptsControls,}
    csCaptureMouse, csClickEvents, csDoubleClicks];

  { We want to be able to get focus }
  TabStop := True;

  { Create Buffers }
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;

  { Create Items }
  FItems := TERDSimpleListItems.Create(Self);
  Fitems.OnChange := SettingsChanged;

  { Width / Height }
  Width  := 300;
  Height := 200;

  { Defaults }
  FRows   := 6;
  FScroll := 0;

  FHotIndex  := -1;
  FItemIndex := -1;
  FGlyphSize := 48;

  { Initial Draw }
  Redraw := True;
end;

destructor TERDSimpleList.Destroy;
begin
  { Free Buffer }
  FBuffer.Free;

  { Free Items }
  FItems.Free;

  inherited Destroy;
end;

procedure TERDSimpleList.SetRows(const I: Integer);
begin
  if Rows <> I then
  begin
    FRows := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDSimpleList.SetScroll(const I: Integer);
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

procedure TERDSimpleList.SetItemIndex(const I: Integer);
begin
  if ItemIndex <> I then
  begin
    if (I <= Items.Count -1) then
    begin
      if (I >= Rows - Scroll) and (I > ItemIndex) then
        Scroll := Scroll +1
      else
      if (I < ItemIndex) and (I - Scroll < 0) then
        Scroll := Scroll -1;

      FItemIndex := I;
      SettingsChanged(Self);
    end else
    if (I < 0) then
    begin
      FItemIndex := 0;
      SettingsChanged(Self);
    end;
  end;
end;

procedure TERDSimpleList.SetGlyphSize(const I: Integer);
begin
  if GlyphSize <> I then
  begin
    if I >= 0 then
      FGlyphSize := I
    else
      FGlyphSize := 0;
    SettingsChanged(Self);
  end;
end;

procedure TERDSimpleList.WMPaint(var Msg: TWMPaint);
begin
  GetUpdateRect(Handle, FUpdateRect, False);
  inherited;
end;

procedure TERDSimpleList.WMEraseBkGnd(var Msg: TWMEraseBkgnd);
begin
  { Draw Buffer to the Control }
  BitBlt(Msg.DC, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := -1;
end;

procedure TERDSimpleList.SettingsChanged(Sender: TObject);
begin
  Redraw := True;
  Invalidate;
end;

procedure TERDSimpleList.Paint;
var
  WorkRect : TRect;

  procedure DrawBackground;
  var
    LDetails : TThemedElementDetails;
  begin
    with FBuffer.Canvas do
    begin
      Brush.Color := StyleServices.GetStyleColor(scComboBox);
      LDetails := StyleServices.GetElementDetails(tcBorderNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, LDetails, WorkRect);
    end;
  end;

  procedure CalculateItemRects;
  var
    I, H, R : Integer;
  begin
    if Items.Count = 0 then Exit;
    InflateRect(WorkRect, -1, -1);
    H := WorkRect.Height div Rows;
    R := 0 - Scroll;
    for I := 0 to Items.Count -1 do
    begin
      Items.Items[I].ItemRect := Rect(
        WorkRect.Left,
        WorkRect.Top + (R * H),
        WorkRect.Right,
        WorkRect.Top + (R * H) + H
      );
      Inc(R);
    end;
    FMaxScroll := Items.Count - Rows;
  end;

  procedure DrawItems;
  var
    I : Integer;
    R : TRect;
    D : TThemedElementDetails;
  begin
    FBuffer.Canvas.Font.Assign(Font);
    for I := 0 to Items.Count -1 do
    with FBuffer.Canvas do
    begin
      if (Items.Items[I].ItemRect.Bottom < WorkRect.Top) or (Items.Items[I].ItemRect.Top > WorkRect.Bottom) then Continue;
      if ItemIndex = I then
        D := StyleServices.GetElementDetails(tgCellSelected)
      else
      if FHotIndex = I then
        D := StyleServices.GetElementDetails(tgFixedCellHot)
      else
        D := StyleServices.GetElementDetails(tgCellNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, D, Items.Items[I].ItemRect);
      Draw(LogoOffset, Items.Items[I].ItemRect.Top + ((Items.Items[I].ItemRect.Height div 2) - (Items.Items[I].Glyph.Height div 2)), Items.Items[I].Glyph.Graphic);
      { Set Font color }
      if I = FHotIndex then
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfGridItemFixedHot)
      else
      if I = ItemIndex then
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfGridItemSelected)
      else
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfGridItemFixedNormal);
      { Draw item caption }
      R := Items.Items[I].ItemRect;
      R.Left  := R.Left + LogoOffset + GlyphSize + LogoOffset;
      R.Right := R.Right - LogoOffset;
      DrawText(FBuffer.Canvas.Handle, PChar(Items.Items[I].Caption), Length(Items.Items[I].Caption), R, DT_LEFT or DT_WORDBREAK or DT_CALCRECT);
      R := Rect(
        R.Left,
        Items.Items[I].ItemRect.Top + ((Items.Items[I].ItemRect.Height div 2) - (R.Height div 2)),
        Items.Items[I].ItemRect.Right - LogoOffset,
        Items.Items[I].ItemRect.Bottom
      );
      if (I = FHotIndex) or (I = ItemIndex)  then
        Font.Color := StyleServices.GetSystemColor(clHighlightText)
      else
        Font.Color := StyleServices.GetSystemColor(clWindowText);
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, Items.Items[I].Caption, R, TTextFormatFlags(DT_LEFT or DT_WORDBREAK or DT_END_ELLIPSIS), Font.Color);
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
    DrawItems;
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

procedure TERDSimpleList.Resize;
begin
  Redraw := True;
  inherited;
end;

procedure TERDSimpleList.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TERDSimpleList.WndProc(var Message: TMessage);
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
          FHotIndex := -1;
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
        FHotIndex := -1;
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

procedure TERDSimpleList.MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

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
      ItemIndex := I;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDSimpleList.MouseMove(Shift: TShiftState; X: Integer; Y: Integer);

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
    if IsMouseOverItem(I) then
    begin
      FHotIndex := I;
      SettingsChanged(Self);
    end else
    if FHotIndex <> -1 then
    begin
      FHotIndex := -1;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDSimpleList.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_UP) and (ItemIndex > 0) then
  begin
    ItemIndex := ItemIndex -1;
  end else
  if (Key = VK_DOWN) and (ItemIndex < Items.Count -1) then
  begin
    ItemIndex := ItemIndex +1;
  end;
end;

(******************************************************************************)
(*
(*  ERD Sub List Item (TERDSubListItem)
(*
(******************************************************************************)
constructor TERDSubListItem.Create(AOWner: TCollection);
begin
  inherited Create(AOwner);
  FGlyph      := TPicture.Create;
  FCaption    := Format('Item %d', [Index]);
  FSubCaption := '';
end;

destructor TERDSubListItem.Destroy;
begin
  FGlyph.Free;
  inherited;
end;

procedure TERDSubListItem.SetGlyph(const P: TPicture);
begin
  FGlyph.Assign(P);
  Changed(False);
end;

procedure TERDSubListItem.SetCaption(const S: string);
begin
  if Caption <> S then
  begin
    FCaption := S;
    Changed(False);
  end;
end;

procedure TERDSubListItem.SetSubCaption(const S: string);
begin
  if SubCaption <> S then
  begin
    FSubCaption := S;
    Changed(False);
  end;
end;

function TERDSubListItem.GetDisplayName : string;
begin
  if Caption <> '' then
    Result := Caption
  else
    Result := Format('Item %d', [Index]);
end;

procedure TERDSubListItem.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TERDSubListItem then
  begin
    FGlyph.Assign(TERDSubListItem(Source).Glyph);
    FCaption    := TERDSubListItem(Source).Caption;
    FSubCaption := TERDSubListItem(Source).SubCaption;
    Changed(False);
  end else Inherited;
end;

(******************************************************************************)
(*
(*  ERD Sub List Item Collection (TERDSubListItems)
(*
(******************************************************************************)
constructor TERDSubListItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TERDSubListItem);
end;

procedure TERDSubListItems.SetItem(Index: Integer; const Value: TERDSubListItem);
begin
  inherited SetItem(Index, Value);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TERDSubListItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TERDSubListItems.GetItem(Index: Integer) : TERDSubListItem;
begin
  Result := inherited GetItem(Index) as TERDSubListItem;
end;

function TERDSubListItems.Add : TERDSubListItem;
begin
  Result := TERDSubListItem(inherited Add);
end;

procedure TERDSubListItems.Assign(Source: TPersistent);
var
  LI   : TERDSubListItems;
  Loop : Integer;
begin
  if (Source is TERDSubListItems)  then
  begin
    LI := TERDSubListItems(Source);
    Clear;
    for Loop := 0 to LI.Count - 1 do
        Add.Assign(LI.Items[Loop]);
  end else inherited;
end;

(******************************************************************************)
(*
(*  ERD Sub List (TERDSubList) - This is a simple list with a extra
(*  sub-caption in a different font.
(*
(******************************************************************************)
constructor TERDSubList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  { If the ControlStyle property includes csOpaque, the control paints itself
    directly. We dont want the control to accept controls - this is a list }
  ControlStyle := ControlStyle + [csOpaque, {csAcceptsControls,}
    csCaptureMouse, csClickEvents, csDoubleClicks];

  { We want to be able to get focus }
  TabStop := True;

  { Create Buffers }
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;

  { Create Items }
  FItems := TERDSubListItems.Create(Self);
  Fitems.OnChange := SettingsChanged;

  { Width / Height }
  Width  := 300;
  Height := 200;

  { Defaults }
  FRows   := 6;
  FScroll := 0;

  FHotIndex  := -1;
  FItemIndex := -1;
  FGlyphSize := 48;

  { Initial Draw }
  Redraw := True;
end;

destructor TERDSubList.Destroy;
begin
  { Free Buffer }
  FBuffer.Free;

  { Free Items }
  FItems.Free;

  inherited Destroy;
end;

procedure TERDSubList.SetRows(const I: Integer);
begin
  if Rows <> I then
  begin
    FRows := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDSubList.SetScroll(const I: Integer);
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

procedure TERDSubList.SetItemIndex(const I: Integer);
begin
  if ItemIndex <> I then
  begin
    if (I <= Items.Count -1) then
    begin
      if (I >= Rows - Scroll) and (I > ItemIndex) then
        Scroll := Scroll +1
      else
      if (I < ItemIndex) and (I - Scroll < 0) then
        Scroll := Scroll -1;

      FItemIndex := I;
      SettingsChanged(Self);
    end else
    if (I < 0) then
    begin
      FItemIndex := 0;
      SettingsChanged(Self);
    end;
  end;
end;

procedure TERDSubList.SetGlyphSize(const I: Integer);
begin
  if GlyphSize <> I then
  begin
    if I >= 0 then
      FGlyphSize := I
    else
      FGlyphSize := 0;
    SettingsChanged(Self);
  end;
end;

procedure TERDSubList.WMPaint(var Msg: TWMPaint);
begin
  GetUpdateRect(Handle, FUpdateRect, False);
  inherited;
end;

procedure TERDSubList.WMEraseBkGnd(var Msg: TWMEraseBkgnd);
begin
  { Draw Buffer to the Control }
  BitBlt(Msg.DC, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := -1;
end;

procedure TERDSubList.SettingsChanged(Sender: TObject);
begin
  Redraw := True;
  Invalidate;
end;

procedure TERDSubList.Paint;
var
  WorkRect : TRect;

  procedure DrawBackground;
  var
    LDetails : TThemedElementDetails;
  begin
    with FBuffer.Canvas do
    begin
      Brush.Color := StyleServices.GetStyleColor(scComboBox);
      LDetails := StyleServices.GetElementDetails(tcBorderNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, LDetails, WorkRect);
    end;
  end;

  procedure CalculateItemRects;
  var
    I, H, R : Integer;
  begin
    if Items.Count = 0 then Exit;
    InflateRect(WorkRect, -1, -1);
    H := WorkRect.Height div Rows;
    R := 0 - Scroll;
    for I := 0 to Items.Count -1 do
    begin
      Items.Items[I].ItemRect := Rect(
        WorkRect.Left,
        WorkRect.Top + (R * H),
        WorkRect.Right,
        WorkRect.Top + (R * H) + H
      );
      Inc(R);
    end;
    FMaxScroll := Items.Count - Rows;
  end;

  procedure DrawItems;
  var
    I, X : Integer;
    R, S : TRect;
    D    : TThemedElementDetails;
  begin
    FBuffer.Canvas.Font.Assign(Font);
    for I := 0 to Items.Count -1 do
    with FBuffer.Canvas do
    begin
      if (Items.Items[I].ItemRect.Bottom < WorkRect.Top) or (Items.Items[I].ItemRect.Top > WorkRect.Bottom) then Continue;
      if ItemIndex = I then
        D := StyleServices.GetElementDetails(tgCellSelected)
      else
      if FHotIndex = I then
        D := StyleServices.GetElementDetails(tgFixedCellHot)
      else
        D := StyleServices.GetElementDetails(tgCellNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, D, Items.Items[I].ItemRect);
      Draw(LogoOffset, Items.Items[I].ItemRect.Top + ((Items.Items[I].ItemRect.Height div 2) - (Items.Items[I].Glyph.Height div 2)), Items.Items[I].Glyph.Graphic);
      { Set Font color }
      if I = FHotIndex then
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfGridItemFixedHot)
      else
      if I = ItemIndex then
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfGridItemSelected)
      else
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfGridItemFixedNormal);
      { Calculate height of caption }
      R := Items.Items[I].ItemRect;
      R.Left  := R.Left + LogoOffset + GlyphSize + LogoOffset;
      R.Right := R.Right - LogoOffset;
      DrawText(FBuffer.Canvas.Handle, PChar(Items.Items[I].Caption), Length(Items.Items[I].Caption), R, DT_LEFT or DT_WORDBREAK or DT_CALCRECT);
      X := R.Height;
      { Calculate height of subcaption }
      S := Items.Items[I].ItemRect;
      S.Left  := S.Left + LogoOffset + GlyphSize + LogoOffset;
      S.Right := S.Right - LogoOffset;
      Font.Style := [fsBold];
      DrawText(FBuffer.Canvas.Handle, PChar(Items.Items[I].SubCaption), Length(Items.Items[I].SubCaption), S, DT_LEFT or DT_WORDBREAK or DT_CALCRECT);
      { Draw the caption }
      R := Rect(
        R.Left,
        Items.Items[I].ItemRect.Top + ((Items.Items[I].ItemRect.Height div 2) - ((R.Height + S.Height + 4) div 2)),
        Items.Items[I].ItemRect.Right - LogoOffset,
        Items.Items[I].ItemRect.Bottom
      );
      Font.Assign(Self.Font);
      if (I = FHotIndex) or (I = ItemIndex)  then
        Font.Color := StyleServices.GetSystemColor(clHighlightText)
      else
        Font.Color := StyleServices.GetSystemColor(clWindowText);
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, Items.Items[I].Caption, R, TTextFormatFlags(DT_LEFT or DT_WORDBREAK or DT_END_ELLIPSIS), Font.Color);
      { Draw the subcaption }
      S := Rect(
        S.Left,
        (Items.Items[I].ItemRect.Top + ((Items.Items[I].ItemRect.Height div 2) - ((X + S.Height + 4) div 2))) + X + 4,
        Items.Items[I].ItemRect.Right - LogoOffset,
        Items.Items[I].ItemRect.Bottom
      );
      FBuffer.Canvas.Font.Assign(Font);
      Font.Style := [fsBold];
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, Items.Items[I].SubCaption, S, TTextFormatFlags(DT_LEFT or DT_WORDBREAK or DT_END_ELLIPSIS), Font.Color);
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
    DrawItems;
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

procedure TERDSubList.Resize;
begin
  Redraw := True;
  inherited;
end;

procedure TERDSubList.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TERDSubList.WndProc(var Message: TMessage);
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
          FHotIndex := -1;
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
        FHotIndex := -1;
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

procedure TERDSubList.MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

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
      ItemIndex := I;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDSubList.MouseMove(Shift: TShiftState; X: Integer; Y: Integer);

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
    if IsMouseOverItem(I) then
    begin
      FHotIndex := I;
      SettingsChanged(Self);
    end else
    if FHotIndex <> -1 then
    begin
      FHotIndex := -1;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDSubList.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_UP) and (ItemIndex > 0) then
  begin
    ItemIndex := ItemIndex -1;
  end else
  if (Key = VK_DOWN) and (ItemIndex < Items.Count -1) then
  begin
    ItemIndex := ItemIndex +1;
  end;
end;

(******************************************************************************)
(*
(*  ERD DTC List Item (TERDDTCListItem)
(*
(******************************************************************************)
constructor TERDDTCListItem.Create(AOWner: TCollection);
begin
  inherited Create(AOwner);
  FDTC         := '';
  FDescription := '';
  FVehicleArea := '';
  FSystem      := '';
end;

procedure TERDDTCListItem.SetDTC(const S: string);
begin
  if DTC <> S then
  begin
    FDTC := S;
    Changed(False);
  end;
end;

procedure TERDDTCListItem.SetDescription(const S: string);
begin
  if Description <> S then
  begin
    FDescription := S;
    Changed(False);
  end;
end;

procedure TERDDTCListItem.SetVehicleArea(const S: string);
begin
  if VehicleArea <> S then
  begin
    FVehicleArea := S;
    Changed(False);
  end;
end;

procedure TERDDTCListItem.SetSystem(const S: string);
begin
  if System <> S then
  begin
    FSystem := S;
    Changed(False);
  end;
end;

function TERDDTCListItem.GetDisplayName : string;
begin
  if DTC <> '' then
    Result := DTC
  else
    Result := Format('Item %d', [Index]);
end;

procedure TERDDTCListItem.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TERDDTCListItem then
  begin
    FDTC         := TERDDTCListItem(Source).DTC;
    FDescription := TERDDTCListItem(Source).Description;
    FVehicleArea := TERDDTCListItem(Source).VehicleArea;
    FSystem      := TERDDTCListItem(Source).System;
    Changed(False);
  end else Inherited;
end;

(******************************************************************************)
(*
(*  ERD DTC List Item Collection (TERDDTCListItems)
(*
(******************************************************************************)
constructor TERDDTCListItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TERDDTCListItem);
end;

procedure TERDDTCListItems.SetItem(Index: Integer; const Value: TERDDTCListItem);
begin
  inherited SetItem(Index, Value);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TERDDTCListItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TERDDTCListItems.GetItem(Index: Integer) : TERDDTCListItem;
begin
  Result := inherited GetItem(Index) as TERDDTCListItem;
end;

function TERDDTCListItems.Add : TERDDTCListItem;
begin
  Result := TERDDTCListItem(inherited Add);
end;

procedure TERDDTCListItems.Assign(Source: TPersistent);
var
  LI   : TERDDTCListItems;
  Loop : Integer;
begin
  if (Source is TERDDTCListItems)  then
  begin
    LI := TERDDTCListItems(Source);
    Clear;
    for Loop := 0 to LI.Count - 1 do
        Add.Assign(LI.Items[Loop]);
  end else inherited;
end;

(******************************************************************************)
(*
(*  ERD DTC List (TERDDTCList) - This is a multi column list
(*
(******************************************************************************)
constructor TERDDTCList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  { If the ControlStyle property includes csOpaque, the control paints itself
    directly. We dont want the control to accept controls - this is a list }
  ControlStyle := ControlStyle + [csOpaque, {csAcceptsControls,}
    csCaptureMouse, csClickEvents, csDoubleClicks];

  { We want to be able to get focus }
  TabStop := True;

  { Create Buffers }
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;

  { Create Items }
  FItems := TERDDTCListItems.Create(Self);
  Fitems.OnChange := SettingsChanged;

  { Width / Height }
  Width  := 300;
  Height := 200;

  { Defaults }
  FRows   := 10;
  FScroll := 0;

  FHotIndex  := -1;
  FItemIndex := -1;

  FColHeight        := 40;
  FDTCWidth         := 100;
  FVehicleAreaWidth := 250;
  FSystemWidth      := 250;

  FDTC              := 'DTC';
  FDescription      := 'Beschrijving';
  FVehicleArea      := 'Voertuig Gebied';
  FSystem           := 'Systeem';

  { Initial Draw }
  Redraw := True;
end;

destructor TERDDTCList.Destroy;
begin
  { Free Buffer }
  FBuffer.Free;

  { Free Items }
  FItems.Free;

  inherited Destroy;
end;

procedure TERDDTCList.SetRows(const I: Integer);
begin
  if Rows <> I then
  begin
    FRows := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDDTCList.SetScroll(const I: Integer);
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

procedure TERDDTCList.SetItemIndex(const I: Integer);
begin
  if ItemIndex <> I then
  begin
    if (I <= Items.Count -1) then
    begin
      if (I >= Rows - Scroll) and (I > ItemIndex) then
        Scroll := Scroll +1
      else
      if (I < ItemIndex) and (I - Scroll < 0) then
        Scroll := Scroll -1;

      FItemIndex := I;
      SettingsChanged(Self);
    end else
    if (I < 0) then
    begin
      FItemIndex := 0;
      SettingsChanged(Self);
    end;
  end;
end;

procedure TERDDTCList.SetColHeight(const I: Integer);
begin
  if ColHeight <> I then
  begin
    if I >= 0 then
      FColHeight := I
    else
      FColHeight := 0;
  end;
end;

procedure TERDDTCList.SetDTCWidth(const I: Integer);
begin
  if DTCWidth <> I then
  begin
    FDTCWidth := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDDTCList.SetVehicleAreaWidth(const I: Integer);
begin
  if VehicleAreaWidth <> I then
  begin
    FVehicleAreaWidth := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDDTCList.SetSystemWidth(const I: Integer);
begin
  if SystemWidth <> I then
  begin
    FSystemWidth := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDDTCList.SetDTC(const S: string);
begin
  if DTC <> S then
  begin
    FDTC := S;
    SettingsChanged(Self);
  end;
end;

procedure TERDDTCList.SetDescription(const S: string);
begin
  if Description <> S then
  begin
    FDescription := S;
    SettingsChanged(Self);
  end;
end;

procedure TERDDTCList.SetVehicleArea(const S: string);
begin
  if VehicleArea <> S then
  begin
    FVehicleArea := S;
    SettingsChanged(Self);
  end;
end;

procedure TERDDTCList.SetSystem(const S: string);
begin
  if System <> S then
  begin
    FSystem := S;
    SettingsChanged(Self);
  end;
end;

procedure TERDDTCList.WMPaint(var Msg: TWMPaint);
begin
  GetUpdateRect(Handle, FUpdateRect, False);
  inherited;
end;

procedure TERDDTCList.WMEraseBkGnd(var Msg: TWMEraseBkgnd);
begin
  { Draw Buffer to the Control }
  BitBlt(Msg.DC, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := -1;
end;

procedure TERDDTCList.SettingsChanged(Sender: TObject);
begin
  Redraw := True;
  Invalidate;
end;

procedure TERDDTCList.Paint;
var
  WorkRect : TRect;

  procedure DrawBackground;
  var
    LDetails : TThemedElementDetails;
  begin
    with FBuffer.Canvas do
    begin
      Brush.Color := StyleServices.GetStyleColor(scComboBox);
      LDetails := StyleServices.GetElementDetails(tcBorderNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, LDetails, ClientRect);
    end;
  end;

  procedure DrawHeaders;
  var
    D    : TThemedElementDetails;
    R, W : TRect;
  begin
    FBuffer.Canvas.Font.Assign(Font);
    FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfHeaderSectionTextNormal);
    with FBuffer.Canvas do
    begin
      W := Rect(ClientRect.Left +1, ClientRect.Top, ClientRect.Right -1, ClientRect.Top + ColHeight);
      { DTC }
      R := Rect(W.Left, W.Top, W.Left + LogoOffset + DTCWidth, W.Bottom);
      D := StyleServices.GetElementDetails(thHeaderItemLeftNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, D, R);
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, DTC, R, TTextFormatFlags(DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
      { Description }
      R := Rect(W.Left + LogoOffset + DTCWidth, W.Top, (W.Right - LogoOffset) - (VehicleAreaWidth + SystemWidth), W.Bottom);
      D := StyleServices.GetElementDetails(thHeaderItemNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, D, R);
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, Description, R, TTextFormatFlags(DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
      { Vehicle Area }
      R := Rect((W.Right - LogoOffset) - (VehicleAreaWidth + SystemWidth), W.Top, (W.Right - LogoOffset) - SystemWidth, W.Bottom);
      D := StyleServices.GetElementDetails(thHeaderItemNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, D, R);
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, VehicleArea, R, TTextFormatFlags(DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
      { System }
      R := Rect((W.Right - LogoOffset) - SystemWidth, W.Top, W.Right, W.Bottom);
      D := StyleServices.GetElementDetails(thHeaderItemRightNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, D, R);
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, System, R, TTextFormatFlags(DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
    end;
  end;

  procedure CalculateItemRects;
  var
    I, H, R : Integer;
  begin
    if Items.Count = 0 then Exit;
    InflateRect(WorkRect, -1, -1);
    H := WorkRect.Height div Rows;
    R := 0 - Scroll;
    for I := 0 to Items.Count -1 do
    begin
      Items.Items[I].ItemRect := Rect(
        WorkRect.Left,
        WorkRect.Top + (R * H),
        WorkRect.Right,
        WorkRect.Top + (R * H) + H
      );
      Inc(R);
    end;
    FMaxScroll := Items.Count - Rows;
  end;

  procedure DrawItems;
  var
    I : Integer;
    R : TRect;
    D : TThemedElementDetails;
  begin
    FBuffer.Canvas.Font.Assign(Font);
    for I := 0 to Items.Count -1 do
    with FBuffer.Canvas do
    begin
      if (Items.Items[I].ItemRect.Bottom < WorkRect.Top) or (Items.Items[I].ItemRect.Top > WorkRect.Bottom) then Continue;
      if ItemIndex = I then
        D := StyleServices.GetElementDetails(tgCellSelected)
      else
      if FHotIndex = I then
        D := StyleServices.GetElementDetails(tgFixedCellHot)
      else
        D := StyleServices.GetElementDetails(tgCellNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, D, Items.Items[I].ItemRect);
      FBuffer.Canvas.Font.Assign(Font);
      { Set Font color }
      if I = FHotIndex then
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfGridItemFixedHot)
      else
      if I = ItemIndex then
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfGridItemSelected)
      else
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfGridItemFixedNormal);
      { DTC }
      R := Items.Items[I].ItemRect;
      R.Left  := R.Left + LogoOffset;
      R.Right := R.Left + DTCWidth;
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, Items.Items[I].DTC, R, TTextFormatFlags(DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
      { Description }
      R := Items.Items[I].ItemRect;
      R.Left  := R.Left + LogoOffset + DTCWidth + 4;
      R.Right := (R.Right - LogoOffset) - (VehicleAreaWidth + SystemWidth);
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, Items.Items[I].Description, R, TTextFormatFlags(DT_LEFT or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
      { Vehicle Area }
      R := Items.Items[I].ItemRect;
      R.Left  := (R.Right - LogoOffset) - (VehicleAreaWidth + SystemWidth);
      R.Right := (R.Right - LogoOffset) - SystemWidth;
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, Items.Items[I].VehicleArea, R, TTextFormatFlags(DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
      { System }
      R := Items.Items[I].ItemRect;
      R.Left  := (R.Right - LogoOffset) - SystemWidth;
      R.Right := R.Right - LogoOffset;
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, Items.Items[I].System, R, TTextFormatFlags(DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
    end;
  end;

var
  X, Y, W, H : Integer;
begin
  { Draw the panel to the buffer }
  if Redraw then
  begin
    Redraw := False;
    WorkRect := Rect(
      ClientRect.Left,
      ClientRect.Top + ColHeight,
      ClientRect.Right,
      ClientRect.Bottom
    );

    { Set Buffer size }
    FBuffer.SetSize(ClientWidth, ClientHeight);

    { Draw to buffer }
    DrawBackground;
    CalculateItemRects;
    DrawItems;
    DrawHeaders;
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

procedure TERDDTCList.Resize;
begin
  Redraw := True;
  inherited;
end;

procedure TERDDTCList.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TERDDTCList.WndProc(var Message: TMessage);
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
          FHotIndex := -1;
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
        FHotIndex := -1;
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

procedure TERDDTCList.MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

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
      ItemIndex := I;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDDTCList.MouseMove(Shift: TShiftState; X: Integer; Y: Integer);

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
    if IsMouseOverItem(I) then
    begin
      FHotIndex := I;
      SettingsChanged(Self);
    end else
    if FHotIndex <> -1 then
    begin
      FHotIndex := -1;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDDTCList.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_UP) and (ItemIndex > 0) then
  begin
    ItemIndex := ItemIndex -1;
  end else
  if (Key = VK_DOWN) and (ItemIndex < Items.Count -1) then
  begin
    ItemIndex := ItemIndex +1;
  end;
end;

(******************************************************************************)
(*
(*  ERD Freeze Frame List Item (TERDFreezeFrameListItem)
(*
(******************************************************************************)
constructor TERDFreezeFrameListItem.Create(AOWner: TCollection);
begin
  inherited Create(AOwner);
  FPID         := '';
  FDescription := '';
  FValue       := '';
  FUnit        := '';
end;

procedure TERDFreezeFrameListItem.SetPID(const S: string);
begin
  if PID <> S then
  begin
    FPID := S;
    Changed(False);
  end;
end;

procedure TERDFreezeFrameListItem.SetDescription(const S: string);
begin
  if Description <> S then
  begin
    FDescription := S;
    Changed(False);
  end;
end;

procedure TERDFreezeFrameListItem.SetValue(const S: string);
begin
  if Value <> S then
  begin
    FValue := S;
    Changed(False);
  end;
end;

procedure TERDFreezeFrameListItem.SetUnit(const S: string);
begin
  if &Unit <> S then
  begin
    FUnit := S;
    Changed(False);
  end;
end;

function TERDFreezeFrameListItem.GetDisplayName : string;
begin
  if PID <> '' then
    Result := PID
  else
    Result := Format('Item %d', [Index]);
end;

procedure TERDFreezeFrameListItem.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TERDFreezeFrameListItem then
  begin
    FPID         := TERDFreezeFrameListItem(Source).PID;
    FDescription := TERDFreezeFrameListItem(Source).Description;
    FValue       := TERDFreezeFrameListItem(Source).Value;
    FUnit        := TERDFreezeFrameListItem(Source).&Unit;
    Changed(False);
  end else Inherited;
end;

(******************************************************************************)
(*
(*  ERD Freeze Frame Item Collection (TERDFreezeFrameListItems)
(*
(******************************************************************************)
constructor TERDFreezeFrameListItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TERDFreezeFrameListItem);
end;

procedure TERDFreezeFrameListItems.SetItem(Index: Integer; const Value: TERDFreezeFrameListItem);
begin
  inherited SetItem(Index, Value);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TERDFreezeFrameListItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TERDFreezeFrameListItems.GetItem(Index: Integer) : TERDFreezeFrameListItem;
begin
  Result := inherited GetItem(Index) as TERDFreezeFrameListItem;
end;

function TERDFreezeFrameListItems.Add : TERDFreezeFrameListItem;
begin
  Result := TERDFreezeFrameListItem(inherited Add);
end;

procedure TERDFreezeFrameListItems.Assign(Source: TPersistent);
var
  LI   : TERDFreezeFrameListItems;
  Loop : Integer;
begin
  if (Source is TERDFreezeFrameListItems)  then
  begin
    LI := TERDFreezeFrameListItems(Source);
    Clear;
    for Loop := 0 to LI.Count - 1 do
        Add.Assign(LI.Items[Loop]);
  end else inherited;
end;

(******************************************************************************)
(*
(*  ERD Freeze Frame List (TERDFreezeFrameList) - This is a multi column list
(*
(******************************************************************************)
constructor TERDFreezeFrameList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  { If the ControlStyle property includes csOpaque, the control paints itself
    directly. We dont want the control to accept controls - this is a list }
  ControlStyle := ControlStyle + [csOpaque, {csAcceptsControls,}
    csCaptureMouse, csClickEvents, csDoubleClicks];

  { We want to be able to get focus }
  TabStop := True;

  { Create Buffers }
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;

  { Create Items }
  FItems := TERDFreezeFrameListItems.Create(Self);
  Fitems.OnChange := SettingsChanged;

  { Width / Height }
  Width  := 300;
  Height := 200;

  { Defaults }
  FRows   := 10;
  FScroll := 0;

  FHotIndex  := -1;
  FItemIndex := -1;

  FColHeight   := 40;
  FPIDWidth    := 100;
  FValueWidth  := 250;
  FUnitWidth   := 250;

  FPID         := 'PID';
  FDescription := 'Beschrijving';
  FValue       := 'Waarde';
  FUnit        := 'Meeteenheid';

  { Initial Draw }
  Redraw := True;
end;

destructor TERDFreezeFrameList.Destroy;
begin
  { Free Buffer }
  FBuffer.Free;

  { Free Items }
  FItems.Free;

  inherited Destroy;
end;

procedure TERDFreezeFrameList.SetRows(const I: Integer);
begin
  if Rows <> I then
  begin
    FRows := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDFreezeFrameList.SetScroll(const I: Integer);
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

procedure TERDFreezeFrameList.SetItemIndex(const I: Integer);
begin
  if ItemIndex <> I then
  begin
    if (I <= Items.Count -1) then
    begin
      if (I >= Rows - Scroll) and (I > ItemIndex) then
        Scroll := Scroll +1
      else
      if (I < ItemIndex) and (I - Scroll < 0) then
        Scroll := Scroll -1;

      FItemIndex := I;
      SettingsChanged(Self);
    end else
    if (I < 0) then
    begin
      FItemIndex := 0;
      SettingsChanged(Self);
    end;
  end;
end;

procedure TERDFreezeFrameList.SetColHeight(const I: Integer);
begin
  if ColHeight <> I then
  begin
    if I >= 0 then
      FColHeight := I
    else
      FColHeight := 0;
  end;
end;

procedure TERDFreezeFrameList.SetPIDWidth(const I: Integer);
begin
  if PIDWidth <> I then
  begin
    FPIDWidth := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDFreezeFrameList.SetValueWidth(const I: Integer);
begin
  if ValueWidth <> I then
  begin
    FValueWidth := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDFreezeFrameList.SetUnitWidth(const I: Integer);
begin
  if UnitWidth <> I then
  begin
    FUnitWidth := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDFreezeFrameList.SetPID(const S: string);
begin
  if PID <> S then
  begin
    FPID := S;
    SettingsChanged(Self);
  end;
end;

procedure TERDFreezeFrameList.SetDescription(const S: string);
begin
  if Description <> S then
  begin
    FDescription := S;
    SettingsChanged(Self);
  end;
end;

procedure TERDFreezeFrameList.SetValue(const S: string);
begin
  if Value <> S then
  begin
    FValue := S;
    SettingsChanged(Self);
  end;
end;

procedure TERDFreezeFrameList.SetUnit(const S: string);
begin
  if &Unit <> S then
  begin
    FUnit := S;
    SettingsChanged(Self);
  end;
end;

procedure TERDFreezeFrameList.WMPaint(var Msg: TWMPaint);
begin
  GetUpdateRect(Handle, FUpdateRect, False);
  inherited;
end;

procedure TERDFreezeFrameList.WMEraseBkGnd(var Msg: TWMEraseBkgnd);
begin
  { Draw Buffer to the Control }
  BitBlt(Msg.DC, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := -1;
end;

procedure TERDFreezeFrameList.SettingsChanged(Sender: TObject);
begin
  Redraw := True;
  Invalidate;
end;

procedure TERDFreezeFrameList.Paint;
var
  WorkRect : TRect;

  procedure DrawBackground;
  var
    LDetails : TThemedElementDetails;
  begin
    with FBuffer.Canvas do
    begin
      Brush.Color := StyleServices.GetStyleColor(scComboBox);
      LDetails := StyleServices.GetElementDetails(tcBorderNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, LDetails, ClientRect);
    end;
  end;

  procedure DrawHeaders;
  var
    D    : TThemedElementDetails;
    R, W : TRect;
  begin
    FBuffer.Canvas.Font.Assign(Font);
    FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfHeaderSectionTextNormal);
    with FBuffer.Canvas do
    begin
      W := Rect(ClientRect.Left +1, ClientRect.Top, ClientRect.Right -1, ClientRect.Top + ColHeight);
      { PID }
      R := Rect(W.Left, W.Top, W.Left + LogoOffset + PIDWidth, W.Bottom);
      D := StyleServices.GetElementDetails(thHeaderItemLeftNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, D, R);
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, PID, R, TTextFormatFlags(DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
      { Description }
      R := Rect(W.Left + LogoOffset + PIDWidth, W.Top, (W.Right - LogoOffset) - (ValueWidth + UnitWidth), W.Bottom);
      D := StyleServices.GetElementDetails(thHeaderItemNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, D, R);
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, Description, R, TTextFormatFlags(DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
      { Value }
      R := Rect((W.Right - LogoOffset) - (ValueWidth + UnitWidth), W.Top, (W.Right - LogoOffset) - UnitWidth, W.Bottom);
      D := StyleServices.GetElementDetails(thHeaderItemNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, D, R);
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, Value, R, TTextFormatFlags(DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
      { Unit }
      R := Rect((W.Right - LogoOffset) - UnitWidth, W.Top, W.Right, W.Bottom);
      D := StyleServices.GetElementDetails(thHeaderItemRightNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, D, R);
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, &Unit, R, TTextFormatFlags(DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
    end;
  end;

  procedure CalculateItemRects;
  var
    I, H, R : Integer;
  begin
    if Items.Count = 0 then Exit;
    InflateRect(WorkRect, -1, -1);
    H := WorkRect.Height div Rows;
    R := 0 - Scroll;
    for I := 0 to Items.Count -1 do
    begin
      Items.Items[I].ItemRect := Rect(
        WorkRect.Left,
        WorkRect.Top + (R * H),
        WorkRect.Right,
        WorkRect.Top + (R * H) + H
      );
      Inc(R);
    end;
    FMaxScroll := Items.Count - Rows;
  end;

  procedure DrawItems;
  var
    I : Integer;
    R : TRect;
    D : TThemedElementDetails;
  begin
    FBuffer.Canvas.Font.Assign(Font);
    for I := 0 to Items.Count -1 do
    with FBuffer.Canvas do
    begin
      if (Items.Items[I].ItemRect.Bottom < WorkRect.Top) or (Items.Items[I].ItemRect.Top > WorkRect.Bottom) then Continue;
      if ItemIndex = I then
        D := StyleServices.GetElementDetails(tgCellSelected)
      else
      if FHotIndex = I then
        D := StyleServices.GetElementDetails(tgFixedCellHot)
      else
        D := StyleServices.GetElementDetails(tgCellNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, D, Items.Items[I].ItemRect);
      FBuffer.Canvas.Font.Assign(Font);
      { Set Font color }
      if I = FHotIndex then
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfGridItemFixedHot)
      else
      if I = ItemIndex then
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfGridItemSelected)
      else
        FBuffer.Canvas.Font.Color := StyleServices.GetStyleFontColor(sfGridItemFixedNormal);
      { DTC }
      R := Items.Items[I].ItemRect;
      R.Left  := R.Left + LogoOffset;
      R.Right := R.Left + PIDWidth;
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, Items.Items[I].PID, R, TTextFormatFlags(DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
      { Description }
      R := Items.Items[I].ItemRect;
      R.Left  := R.Left + LogoOffset + PIDWidth + 4;
      R.Right := (R.Right - LogoOffset) - (ValueWidth + UnitWidth);
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, Items.Items[I].Description, R, TTextFormatFlags(DT_LEFT or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
      { Vehicle Area }
      R := Items.Items[I].ItemRect;
      R.Left  := (R.Right - LogoOffset) - (ValueWidth + UnitWidth);
      R.Right := (R.Right - LogoOffset) - UnitWidth;
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, Items.Items[I].Value, R, TTextFormatFlags(DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
      { System }
      R := Items.Items[I].ItemRect;
      R.Left  := (R.Right - LogoOffset) - UnitWidth;
      R.Right := R.Right - LogoOffset;
      StyleServices.DrawText(FBuffer.Canvas.Handle, D, Items.Items[I].&Unit, R, TTextFormatFlags(DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS), Font.Color);
    end;
  end;

var
  X, Y, W, H : Integer;
begin
  { Draw the panel to the buffer }
  if Redraw then
  begin
    Redraw := False;
    WorkRect := Rect(
      ClientRect.Left,
      ClientRect.Top + ColHeight,
      ClientRect.Right,
      ClientRect.Bottom
    );

    { Set Buffer size }
    FBuffer.SetSize(ClientWidth, ClientHeight);

    { Draw to buffer }
    DrawBackground;
    CalculateItemRects;
    DrawItems;
    DrawHeaders;
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

procedure TERDFreezeFrameList.Resize;
begin
  Redraw := True;
  inherited;
end;

procedure TERDFreezeFrameList.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TERDFreezeFrameList.WndProc(var Message: TMessage);
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
          FHotIndex := -1;
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
        FHotIndex := -1;
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

procedure TERDFreezeFrameList.MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);

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
      ItemIndex := I;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDFreezeFrameList.MouseMove(Shift: TShiftState; X: Integer; Y: Integer);

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
    if IsMouseOverItem(I) then
    begin
      FHotIndex := I;
      SettingsChanged(Self);
    end else
    if FHotIndex <> -1 then
    begin
      FHotIndex := -1;
      SettingsChanged(Self);
    end;
  end;
  inherited;
end;

procedure TERDFreezeFrameList.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_UP) and (ItemIndex > 0) then
  begin
    ItemIndex := ItemIndex -1;
  end else
  if (Key = VK_DOWN) and (ItemIndex < Items.Count -1) then
  begin
    ItemIndex := ItemIndex +1;
  end;
end;

end.
