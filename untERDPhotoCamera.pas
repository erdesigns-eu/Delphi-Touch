{
  untERDPhotoCamera v1.0.0
  for Delphi 2010 - 10.4 by Ernst Reidinga
  https://erdesigns.eu

  This unit is part of the ERDesigns UCC Components Pack.

  (c) Copyright 2020 Ernst Reidinga <ernst@erdesigns.eu>

  Bugfixes / Updates:
  - Initial Release 1.0.0

  ************************ PLEASE READ !!!! PLEASE READ ************************

  Portions used from the code found here:
  http://www.delphibasics.info/home/delphibasicsprojects/directxdelphiwebcamcaptureexample/DirectXDelphiWebcamCapture.rar

  Portions used from the DirectX Headers convertion by michael@grizzlymotion.com

  More info on Stack Overflow: 
  https://stackoverflow.com/questions/9106706/delphi-webcam-simple-program

  ************************ PLEASE READ !!!! PLEASE READ ************************

  If you use this unit, please give credits to the original author;
  Ernst Reidinga.

}

unit untERDPhotoCamera;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Controls, Vcl.Graphics,
  Winapi.Messages, System.Types, VCL.Themes, Winapi.MMSystem, DirectShow9,
  Vcl.Imaging.jpeg, Vcl.Forms, Vcl.AppEvnts, VSample;

const
  CBufferCnt = 3;

type
  TVideoProperty = (VP_Brightness, VP_Contrast, VP_Hue, VP_Saturation, VP_Sharpness,
                    VP_Gamma, VP_ColorEnable, VP_WhiteBalance, VP_BacklightCompensation,
                    VP_Gain);

  TERDPhotoCamera = class(TCustomControl)
  private
    { Private declarations }

    { --------------------------- FROM VFRAMES UNIT -------------------------- }
    VideoSample   : TVideoSample;
    OnNewFrameBusy: boolean;
    fVideoRunning : boolean;
    fBusy         : boolean;
    fSkipCnt      : integer;
    fFrameCnt     : integer;
    f30FrameTick  : cardinal;
    fFPS          : double;  // "Real" fps, even if not all frames will be displayed.
    fWidth,
    fHeight       : integer;
    fFourCC       : cardinal;
    fBitmap       : TBitmap;
    fImagePtr     : ARRAY[0..CBufferCnt] OF pointer; // Local copy of image data
    fImagePtrSize : ARRAY[0..CBufferCnt] OF integer;
    fImagePtrIndex: integer;
    AppEvent      : TApplicationEvents;
    IdleEventTick : cardinal;
    ValueY_298,
    ValueU_100,
    ValueU_516,
    ValueV_409,
    ValueV_208    : ARRAY[byte] OF integer;
    ValueClip     : ARRAY[-1023..1023] OF byte;
    fYUY2TablesPrepared : boolean;
    JPG           : TJPEGImage;
    MemStream     : TMemoryStream;
    fImageUnpacked: boolean;
    { --------------------------- FROM VFRAMES UNIT -------------------------- }

    { Buffer - Avoid flickering }
    FBuffer        : TBitmap;
    FBackBuffer    : TBitmap;
    FUpdateRect    : TRect;
    FRedraw        : Boolean;

    { Stretch draw the webcam still? }
    FStretch : Boolean;
    { List with Devices }
    FDevices : TStringList;
    { List with VideoSizes }
    FVideoSizes : TStringList;
    { No Camera Picture }
    FNoCamera : TPicture;

    { --------------------------- FROM VFRAMES UNIT -------------------------- }
    procedure AppEventsIdle(Sender: TObject; var Done: Boolean);
    procedure PrepareTables;
    procedure YUY2_to_RGB(pData: Pointer);
    procedure I420_to_RGB(pData: Pointer);
    procedure UnpackFrame(Size: Integer; pData: Pointer);
    procedure CallBack(PB: PByteArray; var Size: Integer);
    function  VideoSampleIsPaused : Boolean;
    { --------------------------- FROM VFRAMES UNIT -------------------------- }

    procedure SetStretch(const B: Boolean);
    function GetDevices : TStrings;
    function GetVideoSizes : TStrings;
    procedure SetNoCamera(const P: TPicture);

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

    { --------------------------- FROM VFRAMES UNIT -------------------------- }
    property IsPaused: Boolean read VideoSampleIsPaused;
    property VideoRunning : Boolean read fVideoRunning;
    property VideoWidth: Integer read fWidth;
    property VideoHeight: Integer read fHeight;
    property FramesPerSecond: Double read fFPS;
    property FramesSkipped: Integer read fSkipCnt;
    { --------------------------- FROM VFRAMES UNIT -------------------------- }

    function VideoStart(DeviceName: string): Integer;
    procedure VideoStop;
    procedure VideoPause;
    procedure VideoResume;
    procedure AssignBitmap(B: TBitmap);
    procedure SavePicture(const Filename: TFilename);
    procedure ShowPropertyDialog;
    procedure ShowVfWCaptureDialog;
    procedure LoadAvailableCameras(var L: TStringList);
    procedure SetVideoSize(const I: Integer);

    procedure UpdateDeviceList;
    procedure UpdateVideoSizes;
  published
    { Published declarations }
    property Stretch: Boolean read FStretch write SetStretch default False;
    property Devices: TStrings read GetDevices;
    property VideoSizes: TStrings read GetVideoSizes;
    property NoCamera: TPicture read FNoCamera write SetNoCamera;

    property Align default alClient;
    property Anchors;
    property Color;
    property Constraints;
    property ParentColor;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default False;
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

const
  WM_NEWFRAME = WM_USER + 662;

const
  FourCC_YUY2 = $32595559;
  FourCC_YUYV = $56595559;
  FourCC_YUNV = $564E5559;

  FourCC_MJPG = $47504A4D;

  FourCC_I420 = $30323449;
  FourCC_YV12 = $32315659;
  FourCC_IYUV = $56555949;

(******************************************************************************)
(*
(*  ERD Photo Camera (TERDPhotoCamera)
(*
(******************************************************************************)
constructor TERDPhotoCamera.Create(AOwner: TComponent);
var
  I : Integer;
begin
  inherited Create(AOwner);

  { If the ControlStyle property includes csOpaque, the control paints itself
    directly. We dont want the control to accept controls - this is a camera
    view panel like component }
  ControlStyle := ControlStyle + [csOpaque, {csAcceptsControls,}
    csCaptureMouse, csClickEvents, csDoubleClicks];

  { We dont want to be able to get focus, not needed anyway }
  TabStop := False;

  { Create Buffers }
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;
  FBackBuffer := TBitmap.Create;
  FBackBuffer.PixelFormat := pf32bit;

  { Width / Height }
  Width  := 640;
  Height := 480;

  { Initial Draw }
  Redraw := True;

  { Defaults }
  TabStop := False;
  Align   := alClient;

  { Device list }
  FDevices := TStringList.Create;
  UpdateDeviceList;
  FVideoSizes := TStringList.Create;
  //UpdateVideoSizes;
  
  { No Camera Picture }
  FNoCamera := TPicture.Create;
  FNoCamera.OnChange := SettingsChanged;

  { -------------------------- FROM VFRAMES UNIT ------------------------------}
  fVideoRunning   := False;
  OnNewFrameBusy  := False;
  fBitmap         := TBitmap.Create;
  fWidth          := 0;
  fHeight         := 0;
  fFourCC         := 0;
  for I := 0 to CBufferCnt -1 do
  begin
    fImagePtr[I]     := nil;
    fImagePtrSize[I] := 0;
  end;
  fBusy           := false;
  AppEvent        := TApplicationEvents.Create(Self);
  AppEvent.OnIdle := AppEventsIdle;
  JPG             := TJPEGImage.Create;
  MemStream       := TMemoryStream.Create;
  { -------------------------- FROM VFRAMES UNIT ------------------------------}
end;

destructor TERDPhotoCamera.Destroy;
var
  I : Integer;
begin
  { Free Buffers }
  FBuffer.Free;
  FBackBuffer.Free;

  { Free Device List }
  FDevices.Free;
  FVideoSizes.Free;

  { Free no camera picture }
  FNoCamera.Free;

  { -------------------------- FROM VFRAMES UNIT ------------------------------}
  for I := CBufferCnt -1 downto 0 do
  if fImagePtrSize[I] <> 0 then
  begin
    FreeMem(fImagePtr[I], fImagePtrSize[I]);
    fImagePtr[I]     := nil;
    fImagePtrSize[I] := 0;
  end;

  fBitmap.Free;
  AppEvent.OnIdle := nil;
  AppEvent.Free;
  AppEvent := nil;
  { -------------------------- FROM VFRAMES UNIT ------------------------------}

  inherited Destroy;
end;

procedure TERDPhotoCamera.WMPaint(var Msg: TWMPaint);
begin
  GetUpdateRect(Handle, FUpdateRect, False);
  inherited;
end;

procedure TERDPhotoCamera.WMEraseBkGnd(var Msg: TWMEraseBkgnd);
begin
  { Draw Buffer to the Control }
  BitBlt(Msg.DC, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := -1;
end;

procedure TERDPhotoCamera.AppEventsIdle(Sender: TObject; var Done: Boolean);
begin
  IdleEventTick := TimeGetTime;
  Done := true;
end;

procedure TERDPhotoCamera.PrepareTables;
var
  I : integer;
begin
  if fYUY2TablesPrepared then Exit;
  for I := 0 to 255 do
  begin
    ValueY_298[I] := Round(I *  298.082);
    ValueU_100[I] := Round(I * -100.291);
    ValueU_516[I] := Round(I *  516.412  - 276.836*256);
    ValueV_409[I] := Round(I *  408.583  - 222.921*256);
    ValueV_208[I] := Round(I * -208.120  + 135.576*256);
  end;
  FillChar(ValueClip, SizeOf(ValueClip), #0);
  for I := 0 to 255 do ValueClip[I] := I;
  for I := 256 to 1023 do ValueClip[I] := 255;
  fYUY2TablesPrepared := True;
end;

procedure TERDPhotoCamera.I420_to_RGB(pData: Pointer);
VAR
  L, X, Y    : Integer;
  ps         : PByte;
  pY, pU, pV : PByte;
begin
  pY := pData;
  PrepareTables;
  for Y := 0 to fBitmap.Height -1 do
  begin
    ps := fBitmap.ScanLine[Y];

    pU := pData;
    Inc(pU, fBitmap.Width*(fBitmap.height+ Y div 4));
    pV := PU;
    Inc(pV, fBitmap.Width*fBitmap.height div 4);

    for X := 0 to (fBitmap.Width div 2) -1 do
    begin
      L := ValueY_298[pY^];
      ps^ := ValueClip[(L + ValueU_516[pU^]) div 256];
      Inc(ps);
      ps^ := ValueClip[(L + ValueU_100[pU^] + ValueV_208[pV^]) div 256];
      Inc(ps);
      ps^ := ValueClip[(L + ValueV_409[pV^]) div 256];
      Inc(ps);
      Inc(pY);

      L := ValueY_298[pY^];
      ps^ := ValueClip[(L + ValueU_516[pU^]) div 256];
      Inc(ps);
      ps^ := ValueClip[(L + ValueU_100[pU^] + ValueV_208[pV^]) div 256];
      Inc(ps);
      ps^ := ValueClip[(L + ValueV_409[pV^]) div 256];
      Inc(ps);
      Inc(pY);

      Inc(pU);
      Inc(pV);
    end;
  end;
end;

procedure TERDPhotoCamera.YUY2_to_RGB(pData: Pointer);
type
  TFour  = array [0..3] of byte;
var
  L, X, Y : Integer;
  ps      : PByte;
  pf      : ^TFour;
begin
  pf := pData;
  PrepareTables;
  for Y := 0 to fBitmap.Height -1 do
  begin
    ps := fBitmap.ScanLine[Y];
    for X := 0 to (fBitmap.Width div 2) -1 do
    begin
      L := ValueY_298[pf^[0]];
      ps^ := ValueClip[(L + ValueU_516[pf^[1]]) div 256];
      Inc(ps);
      ps^ := ValueClip[(L + ValueU_100[pf^[1]] + ValueV_208[pf^[3]]) div 256];
      Inc(ps);
      ps^ := ValueClip[(L + ValueV_409[pf^[3]]) div 256];
      Inc(ps);
      L := ValueY_298[pf^[2]];
      ps^ := ValueClip[(L + ValueU_516[pf^[1]]) div 256];
      Inc(ps);
      ps^ := ValueClip[(L + ValueU_100[pf^[1]] + ValueV_208[pf^[3]]) div 256];
      Inc(ps);
      ps^ := ValueClip[(L + ValueV_409[pf^[3]]) div 256];
      Inc(ps);
      Inc(pf);
    end;
  end;
end;

procedure TERDPhotoCamera.UnpackFrame(Size: Integer; pData: Pointer);
var
  Unknown : Boolean;
  FourCCSt: string[4];
begin
  if pData = nil then Exit;
  Unknown := False;
  try
    case fFourCC of
      0           :  if (Size = fWidth*fHeight*3) then move(pData^, FBitmap.scanline[fHeight-1]^, Size) else Unknown := True;
      FourCC_YUY2,
      FourCC_YUYV,
      FourCC_YUNV :  if (Size = fWidth*fHeight*2) then YUY2_to_RGB(pData) else Unknown := True;
      FourCC_MJPG :  begin
                       try
                         MemStream.Clear;
                         MemStream.SetSize(Size);
                         MemStream.Position := 0;
                         MemStream.WriteBuffer(pData^, Size);
                         MemStream.Position := 0;
                         JPG.LoadFromStream(MemStream);
                         FBitmap.Canvas.Draw(0, 0, JPG);
                       except
                         Unknown := true;
                       end;
                     end;
      FourCC_I420,
      FourCC_YV12,
      FourCC_IYUV : if (Size = (fWidth*fHeight*3) div 2) then I420_to_RGB(pData) else Unknown := True;
      else          Unknown := True;
    end;
    if Unknown then
    begin
      if fFourCC = 0
        then FourCCSt := 'RGB'
        else begin
          FourCCSt := '    ';
          move(fFourCC, FourCCSt[1], 4);
        end;
      FBitmap.Canvas.TextOut(0,  0, 'Unknown compression');
      FBitmap.Canvas.TextOut(0, FBitmap.Canvas.TextHeight('X'), 'DataSize: '+INtToStr(Size)+'  FourCC: '+FourCCSt);
    end;
    fImageUnpacked := True;
  except
  end;
end;

procedure TERDPhotoCamera.CallBack(PB: PByteArray; var Size: Integer);
var
  I  : Integer;
  T1 : Cardinal;
begin
  Inc(fFrameCnt);

  // Calculate "Frames per second"...
  T1 := TimeGetTime;
  if fFrameCnt mod 30 = 0 then
  begin
    if f30FrameTick > 0 then fFPS := 30000 / (T1-f30FrameTick);
    f30FrameTick := T1;
  end;

  // Does the application run in unhealthy CPU usage?
  // Check, if no idle event has occured for at least 1 sec.
  // If so, skip current frame and give application time to "breathe".
  if Abs(T1 - IdleEventTick) > 1000 then
  begin
    Inc(fSkipCnt);
    Exit;
  end;

  // Adjust pointer to image data if necessary
  I := (fImagePtrIndex+1) mod CBufferCnt;
  if fImagePtrSize[I] <> Size then
  begin
    if fImagePtrSize[I] > 0 then FreeMem(fImagePtr[I], fImagePtrSize[I]);
    fImagePtrSize[I] := Size;
    GetMem(fImagePtr[I], fImagePtrSize[I]);
  end;
  // Save image data to local memory
  Move(PB^, fImagePtr[I]^, Size);
  fImagePtrIndex := I;
  fImageUnpacked := False;

  // This routine is called by the video software and therefore runs within their thread.
  // Posting a message to our own HWND will transport the information to the main thread.
  PostMessage(Handle, WM_NEWFRAME, Size, integer(fImagePtr[I]));
  Sleep(0);
end;

function TERDPhotoCamera.VideoSampleIsPaused : Boolean;
begin

end;

procedure TERDPhotoCamera.SetStretch(const B: Boolean);
begin
  if Stretch <> B then
  begin
    FStretch := B;
    Invalidate;
  end;
end;

function TERDPhotoCamera.GetDevices : TStrings;
begin
  Result := FDevices;
end;

function TERDPhotoCamera.GetVideoSizes : TStrings;
begin
  Result := FVideoSizes;
end;

procedure TERDPhotoCamera.SetNoCamera(const P: TPicture);
begin
  FNoCamera.Assign(P);
  SettingsChanged(Self);
end;

procedure TERDPhotoCamera.SettingsChanged(Sender: TObject);
begin
  Redraw := True;
  Invalidate;
end;

procedure TERDPhotoCamera.Paint;
var
  WorkRect : TRect;

  procedure DrawBackground;
  var
    LDetails : TThemedElementDetails;
  begin
    with FBackBuffer.Canvas do
    begin
      Brush.Color := StyleServices.GetStyleColor(scComboBox);
      LDetails := StyleServices.GetElementDetails(tcBorderNormal);
      StyleServices.DrawElement(FBackBuffer.Canvas.Handle, LDetails, WorkRect);
    end;
  end;

var
  X, Y, W, H : Integer;
begin
  WorkRect := ClientRect;

  { Draw the panel to the buffer }
  if Redraw then
  begin
    Redraw := False;

    { Set Buffers size }
    FBackBuffer.SetSize(ClientWidth, ClientHeight);
    FBuffer.SetSize(ClientWidth, ClientHeight);

    { Draw to buffer }
    DrawBackground;
  end;

  { Reset the workrect so we dont draw over the border }
  InflateRect(WorkRect, -1, -1);

  { Copy the background to the (main) Buffer }
  BitBlt(FBuffer.Canvas.Handle, 0, 0, ClientWidth, ClientHeight, FBackBuffer.Canvas.Handle, 0, 0, SRCCOPY);

  if Devices.Count > 0 then
  { Draw the webcam picture }
  begin
    if not fImageUnpacked then UnpackFrame(fImagePtrSize[fImagePtrIndex], fImagePtr[fImagePtrIndex]);
    if Stretch then
      FBuffer.Canvas.StretchDraw(WorkRect, fBitmap)
    else
      FBuffer.Canvas.Draw(WorkRect.Left + ((WorkRect.Width div 2) - (fBitmap.Width div 2)), WorkRect.Top + ((WorkRect.Height div 2) - (fBitmap.Height div 2)), fBitmap);
  end else
  { No camera available picture }
  begin
    if Assigned(FNoCamera) and (FNoCamera.Width > 0) then
    FBuffer.Canvas.Draw(WorkRect.Left + ((WorkRect.Width div 2) - (FNoCamera.Width div 2)), WorkRect.Top + ((WorkRect.Height div 2) - (FNoCamera.Height div 2)), FNoCamera.Graphic);
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
    BitBlt(Canvas.Handle, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, X, Y, SRCCOPY);

  inherited;
end;

procedure TERDPhotoCamera.Resize;
begin
  Redraw := True;
  inherited;
end;

procedure TERDPhotoCamera.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TERDPhotoCamera.WndProc(var Message: TMessage);
begin
  inherited;
  case Message.Msg of
    // Capture Keystrokes
    WM_GETDLGCODE:
      Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTALLKEYS;

    { The color changed }
    CM_COLORCHANGED:
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

    { New Frame }
    WM_NEWFRAME:
      begin
        try
          if not fBusy then
          begin
            fBusy := True;
            fImageUnpacked := False;
            Invalidate;
            fBusy := False;
          end else Inc(fSkipCnt);
        except
          Application.HandleException(Self);
          fBusy := False;
        end
      end;
  end;
end;

function TERDPhotoCamera.VideoStart(DeviceName: string) : Integer;
var
  hr     : HResult;
  st     : string;
  W, H   : Integer;
  FourCC : Cardinal;
begin
  fSkipCnt       := 0;
  fFrameCnt      := 0;
  f30FrameTick   := 0;
  fFPS           := 0;
  fImageUnpacked := false;

  Result := 0;
  if Assigned(VideoSample) then VideoStop;

  VideoSample := TVideoSample.Create(Application.MainForm.Handle, false, 0, HR);
  try
    hr := VideoSample.StartVideo(DeviceName, false, st);
  except
    hr := -1;
  end;

  if Failed(hr) then
  begin
    VideoStop;
    Result := 1;
  end else
  begin
   hr := VideoSample.GetStreamInfo(W, H, FourCC);
   if Failed(HR) then
   begin
     VideoStop;
     Result := 1;
   end else
   begin
     fWidth := W;
     fHeight := H;
     fFourCC := FourCC;
     FBitmap.PixelFormat := pf24bit;
     FBitmap.Width := W;
     FBitmap.Height := H;
     VideoSample.SetCallBack(CallBack);
    end;
  end;
end;

procedure TERDPhotoCamera.VideoStop;
begin
  fFPS := 0;
  if not assigned(VideoSample) then Exit;
  try
    VideoSample.Free;
    VideoSample := nil;
  except
  end;
  fVideoRunning := False;
end;

procedure TERDPhotoCamera.VideoPause;
begin
  if not assigned(VideoSample) then Exit;
  VideoSample.PauseVideo;
end;

procedure TERDPhotoCamera.VideoResume;
begin
  if not assigned(VideoSample) then Exit;
  VideoSample.ResumeVideo;
end;

procedure TERDPhotoCamera.AssignBitmap(B: TBitmap);
begin
  if not fImageUnpacked then UnpackFrame(fImagePtrSize[fImagePtrIndex], fImagePtr[fImagePtrIndex]);
  B.Assign(fBitmap);
end;

procedure TERDPhotoCamera.SavePicture(const Filename: TFileName);
var
  JPEG : TJPEGImage;
begin
  JPEG := TJPEGImage.Create;
  try
    JPEG.CompressionQuality := 100;
    JPEG.Assign(fBitmap);
    JPEG.SaveToFile(Filename);
  finally
    JPEG.Free;
  end;
end;

procedure TERDPhotoCamera.ShowPropertyDialog;
begin
  VideoSample.ShowPropertyDialog;
end;

procedure TERDPhotoCamera.ShowVfWCaptureDialog;
begin
  VideoSample.ShowVfWCaptureDlg;
end;

procedure TERDPhotoCamera.LoadAvailableCameras(var L: TStringList);
begin
  GetCaptureDeviceList(L);
end;

procedure TERDPhotoCamera.SetVideoSize(const I: Integer);
var
  hr     : HResult;
  W, H   : Integer;
  FourCC : Cardinal;
BEGIN
  VideoSample.SetVideoSizeByListIndex(I);
  hr := VideoSample.GetStreamInfo(W, H, FourCC);
  if Succeeded(HR) then 
  begin
    fWidth := W;
    fHeight := H;
    fFourCC := FourCC;
    FBitmap.PixelFormat := pf24bit;
    FBitmap.Width := W;
    FBitmap.Height := H;
  end;
end;

procedure TERDPhotoCamera.UpdateDeviceList;
begin
  GetCaptureDeviceList(FDevices);
end;

procedure TERDPhotoCamera.UpdateVideoSizes;
begin
  VideoSample.GetListOfVideoSizes(FVideoSizes);
end;

end.
