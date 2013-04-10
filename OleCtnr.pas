{������������ ������ OleCtnrs}

(*$HPPEMIT '#include <DocObj.h>'*)

unit OLECtnr;

{$T-,H+,X+}
{$WARN SYMBOL_PLATFORM OFF}

interface

uses Windows, Messages, CommCtrl, ActiveX, OleDlg, SysUtils, Classes,
  Controls, Forms, Menus, Graphics, ComObj, OleCtnrs;

type
  TStreamHeader = record
    case Integer of
      0: ( { New }
        Signature: Integer;
        DrawAspect: Integer;
        DataSize: Integer);
      1: ( { Old }
        PartRect: TSmallRect);
  end;

  TCustomOleContainer = class;
  TCustomOleForm = class;

  ICustomVCLFrameForm = interface(IVCLFrameForm)
    ['{56C2834C-28A9-4909-A245-74BB61453D68}']
    procedure AddCustomContainer(Instance: TCustomOleContainer);
    procedure RemoveCustomContainer(Instance: TCustomOleContainer);
  end;

  ICustomOleForm = interface(IOleForm)
    ['{4CA35885-BCBD-4B1B-8444-82BB4981DE55}']
    procedure ForcedResize;
  end;

  TCustomObjectMoveEvent = procedure(OleContainer: TCustomOleContainer;
    const Bounds: TRect) of object;

  TCustomOleContainer = class(TCustomControl, IUnknown, IOleClientSite,
    IOleInPlaceSite, IAdviseSink, IOleDocumentSite, IOleUIObjInfo)
  private
    FRefCount: Longint;
    FLockBytes: ILockBytes;
    FStorage: IStorage;
    FOleObject: IOleObject;
    FDrawAspect: Longint;
    FViewSize: TPoint;
    FObjectVerbs: TStringList;
    FDataConnection: Longint;
    FDocForm: ICustomVCLFrameForm;
    FFrameForm: ICustomVCLFrameForm;
    FOleInPlaceObject: IOleInPlaceObject;
    FOleInPlaceActiveObject: IOleInPlaceActiveObject;
    FAccelTable: HAccel;
    FAccelCount: Integer;
    FPopupVerbMenu: TPopupMenu;
    FAllowInPlace: Boolean;
    FAllowActiveDoc: Boolean;
    FAutoActivate: TAutoActivate;
    FAutoVerbMenu: Boolean;
    FBorderStyle: TBorderStyle;
    FCopyOnSave: Boolean;
    FOldStreamFormat: Boolean;
    FSizeMode: TSizeMode;
    FObjectOpen: Boolean;
    FUIActive: Boolean;
    FModified: Boolean;
    FModSinceSave: Boolean;
    FFocused: Boolean;
    FNewInserted: Boolean;
    FOnActivate: TNotifyEvent;
    FOnDeactivate: TNotifyEvent;
    FOnObjectMove: TCustomObjectMoveEvent;
    FOnResize: TNotifyEvent;
    FDocView: IOleDocumentView;
    FDocObj: Boolean;
    FChangeDecimalSymbol:boolean;
    FForcedDecimalSymbol:Char;
    { IOleClientSite }
    function SaveObject: HResult; stdcall;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      out mk: IMoniker): HResult; stdcall;
    function GetContainer(out container: IOleContainer): HResult; stdcall;
    function ShowObject: HResult; stdcall;
    function OnShowWindow(fShow: BOOL): HResult; stdcall;
    function RequestNewObjectLayout: HResult; stdcall;
    { IOleInPlaceSite }
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;
    function GetWindow(out wnd: HWnd): HResult; stdcall;
    function CanInPlaceActivate: HResult; stdcall;
    function OnInPlaceActivate: HResult; stdcall;
    function OnUIActivate: HResult; stdcall;
    function GetWindowContext(out frame: IOleInPlaceFrame;
      out doc: IOleInPlaceUIWindow; out rcPosRect: TRect;
      out rcClipRect: TRect; out frameInfo: TOleInPlaceFrameInfo): HResult;
      stdcall;
    function Scroll(scrollExtent: TPoint): HResult; stdcall;
    function OnUIDeactivate(fUndoable: BOOL): HResult; stdcall;
    function OnInPlaceDeactivate: HResult; stdcall;
    function DiscardUndoState: HResult; stdcall;
    function DeactivateAndUndo: HResult; stdcall;
    function OnPosRectChange(const rcPosRect: TRect): HResult; stdcall;
    { IAdviseSink }
    procedure OnDataChange(const formatetc: TFormatEtc;
      const stgmed: TStgMedium); stdcall;
    procedure OnViewChange(dwAspect: Longint; lindex: Longint); stdcall;
    procedure OnRename(const mk: IMoniker); stdcall;
    procedure OnSave; stdcall;
    procedure OnClose; stdcall;
    { IOleDocumentSite }
    function ActivateMe(View: IOleDocumentView): HRESULT; stdcall;
    { IOleUIObjInfo }
    function GetObjectInfo(dwObject: Longint;
      var dwObjSize: Longint; var lpszLabel: PChar;
      var lpszType: PChar; var lpszShortType: PChar;
      var lpszLocation: PChar): HResult; stdcall;
    function GetConvertInfo(dwObject: Longint; var ClassID: TCLSID;
      var wFormat: Word; var ConvertDefaultClassID: TCLSID;
      var lpClsidExclude: PCLSID; var cClsidExclude: Longint): HResult; stdcall;
    function ConvertObject(dwObject: Longint;
      const clsidNew: TCLSID): HResult; stdcall;
    function GetViewInfo(dwObject: Longint; var hMetaPict: HGlobal;
      var dvAspect: Longint; var nCurrentScale: Integer): HResult; stdcall;
    function SetViewInfo(dwObject: Longint; hMetaPict: HGlobal;
      dvAspect: Longint; nCurrentScale: Integer;
      bRelativeToOrig: BOOL): HResult; stdcall;
    { TCustomOleContainer }
    procedure AdjustBounds;
    procedure CheckObject;
    procedure CreateAccelTable;
    procedure CreateStorage;
    procedure DesignModified;
    procedure DestroyAccelTable;
    procedure DestroyVerbs;
    function GetBorderWidth: Integer;
    function GetCanPaste: Boolean;
    function GetIconic: Boolean;
    function GetLinked: Boolean;
    function GetObjectDataSize: Integer;
    function GetObjectVerbs: TStrings;
    function GetOleClassName: string;
    function GetOleObject: Variant;
    function GetPrimaryVerb: Integer;
    function GetSourceDoc: string;
    function GetState: TObjectState;
    procedure InitObject;
    procedure ObjectMoved(const ObjectRect: TRect);
    procedure PopupVerbMenuClick(Sender: TObject);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetDrawAspect(Iconic: Boolean; IconMetaPict: HGlobal);
    procedure SetFocused(Value: Boolean);
    procedure SetIconic(Value: Boolean);
    procedure SetSizeMode(Value: TSizeMode);
    procedure SetUIActive(Active: Boolean);
    procedure SetViewAdviseSink(Enable: Boolean);
    procedure UpdateObjectRect;
    procedure UpdateView;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMDocWindowActivate(var Message: TMessage); message CM_DOCWINDOWACTIVATE;
    procedure CMUIDeactivate(var Message: TMessage); message CM_UIDEACTIVATE;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
  protected
    { IUnknown }
    function QueryInterface(const IID: TGUID; out Obj): HResult; override; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    procedure Changed; dynamic;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DblClick; override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure DoEnter; override;
    function GetPopupMenu: TPopupMenu; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ChangeIconDialog: Boolean;
    procedure Close;
    procedure Copy;
    procedure CreateLinkToFile(const FileName: string; Iconic: Boolean);
    procedure CreateObject(const OleClassName: string; Iconic: Boolean);
    procedure CreateObjectFromFile(const FileName: string; Iconic: Boolean);
    procedure CreateObjectFromInfo(const CreateInfo: TCreateInfo);
    procedure DestroyObject;
    procedure DoVerb(Verb: Integer);
    function GetIconMetaPict: HGlobal;
    function InsertObjectDialog: Boolean;
    procedure LoadFromFile(const FileName: string);
    procedure LoadFromStream(Stream: TStream);
    function ObjectPropertiesDialog: Boolean;
    procedure Paste;
    function PasteSpecialDialog: Boolean;
    procedure Run;
    procedure SaveAsDocument(const FileName: string);
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure UpdateObject;
    procedure UpdateVerbs;
    property ChangeDecimalSymbol:boolean read FChangeDecimalSymbol write FChangeDecimalSymbol; //��������� �������!!!
    property CanPaste: Boolean read GetCanPaste;
    property ForcedDecimalSymbol:Char read FForcedDecimalSymbol write FForcedDecimalSymbol; //��������� �������!!!
    property Linked: Boolean read GetLinked;
    property Modified: Boolean read FModified write FModified;
    property NewInserted: Boolean read FNewInserted;
    property ObjectVerbs: TStrings read GetObjectVerbs;
    property OleClassName: string read GetOleClassName;
    property OleObject: Variant read GetOleObject;
    property OleObjectInterface: IOleObject read FOleObject;
    property PrimaryVerb: Integer read GetPrimaryVerb;
    property SourceDoc: string read GetSourceDoc;
    property State: TObjectState read GetState;
    property StorageInterface: IStorage read FStorage;
  published
    property AllowInPlace: Boolean read FAllowInPlace write FAllowInPlace default True;
    property AllowActiveDoc: Boolean read FAllowActiveDoc write FAllowActiveDoc default True;
    property AutoActivate: TAutoActivate read FAutoActivate write FAutoActivate default aaDoubleClick;
    property AutoVerbMenu: Boolean read FAutoVerbMenu write FAutoVerbMenu default True;
    property Align;
    property Anchors;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property Caption;
    property Color;
    property Constraints;
    property CopyOnSave: Boolean read FCopyOnSave write FCopyOnSave default True;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Iconic: Boolean read GetIconic write SetIconic stored False;
    property OldStreamFormat: Boolean read FOldStreamFormat write FOldStreamFormat default False;
    property ParentColor default False;
    property ParentCtl3D;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property SizeMode: TSizeMode read FSizeMode write SetSizeMode default smClip;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnObjectMove: TCustomObjectMoveEvent read FOnObjectMove write FOnObjectMove;
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
    property OnStartDrag;
  end;

  {���������� ����� ���������: ICustomOleForm}
  TCustomOleForm = class(TInterfacedObject, IOleForm, ICustomOleForm,
    IOleWindow, IOleInPlaceUIWindow, IOleInPlaceFrame, IVCLFrameForm,
    ICustomVCLFrameForm)
  private
    FForm: TCustomForm;
    FContainers: TList;
    FActiveObject: IOleInPlaceActiveObject;
    FSaveWidth: Integer;
    FSaveHeight: Integer;
    FHiddenControls: TList;
    FSpacers: array[0..3] of TControl;
    {ICustomOleForm}
    procedure ForcedResize;
    {IOleForm}
    procedure OnDestroy;
    procedure OnResize;
    {IOleWindow}
    function GetWindow(out wnd: HWnd): HResult; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;
    {IOleInPlaceUIWindow}
    function GetBorder(out BorderRect: TRect): HResult; stdcall;
    function RequestBorderSpace(const borderwidths: TRect): HResult; stdcall;
    function SetBorderSpace(pborderwidths: PRect): HResult; stdcall;
    function SetActiveObject(const ActiveObject: IOleInPlaceActiveObject;
      pszObjName: POleStr): HResult; stdcall;
    {IOleInPlaceFrame}
    function InsertMenus(hmenuShared: HMenu;
      var menuWidths: TOleMenuGroupWidths): HResult; stdcall;
    function SetMenu(hmenuShared: HMenu; holemenu: HMenu;
      hwndActiveObject: HWnd): HResult; stdcall;
    function RemoveMenus(hmenuShared: HMenu): HResult; stdcall;
    function SetStatusText(pszStatusText: POleStr): HResult; stdcall;
    function EnableModeless(fEnable: BOOL): HResult; stdcall;
    function TranslateAccelerator(var msg: TMsg; wID: Word): HResult; stdcall;
    {CustomIVCLFrameForm}
    procedure AddCustomContainer(Instance: TCustomOleContainer);
    procedure RemoveCustomContainer(Instance: TCustomOleContainer);
    {IVCLFrameForm}
    procedure AddContainer(Instance: TOleContainer);
    procedure RemoveContainer(Instance: TOleContainer);
    function Form: TCustomForm;
    procedure ClearBorderSpace;
    {TCustomOleForm}
    function IsSpacer(Control: TControl): Boolean;
    function IsToolControl(Control: TControl): Boolean;
  public
    constructor Create(Form: TCustomForm);
    destructor Destroy; override;
  end;

procedure Register;

implementation

uses OleConst;

const
  DataFormatCount = 2;
  StreamSignature = $434F4442; {'BDOC'}

{Private variables}

var PixPerInch: TPoint;
    CFObjectDescriptor: Integer;
    CFEmbeddedObject: Integer;
    CFLinkSource: Integer;
    DataFormats: array[0..DataFormatCount - 1] of TFormatEtc;

procedure DebugMsg(Msg:String);
begin
  MessageBox(0,PChar(Msg),'OLECtnr Debug',0);
end;

{Return length of PWideChar string}
function WStrLen(Str:PWideChar):Integer;
begin
  Result:=0;
  while Str[Result]<>#0 do Inc(Result);
end;

{Convert point from pixels to himetric}
function PixelsToHimetric(const P:TPoint):TPoint;
begin
  Result.X:=MulDiv(P.X, 2540, PixPerInch.X);
  Result.Y:=MulDiv(P.Y, 2540, PixPerInch.Y);
end;

{Convert point from himetric to pixels}
function HimetricToPixels(const P: TPoint): TPoint;
begin
  Result.X:=MulDiv(P.X, PixPerInch.X, 2540);
  Result.Y:=MulDiv(P.Y, PixPerInch.Y, 2540);
end;

{Center the given window on the screen}
procedure CenterWindow(Wnd: HWnd);
var Rect:TRect;
begin
  GetWindowRect(Wnd, Rect);
  SetWindowPos(Wnd, 0,
    (GetSystemMetrics(SM_CXSCREEN) - Rect.Right + Rect.Left) div 2,
    (GetSystemMetrics(SM_CYSCREEN) - Rect.Bottom + Rect.Top) div 3,
    0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOZORDER);
end;

{ Generic dialog hook. Centers the dialog on the screen in response to
  the WM_INITDIALOG message }
function OleDialogHook(Wnd: HWnd; Msg, WParam, LParam: Longint): Longint; stdcall;
begin
  Result := 0;
  if Msg = WM_INITDIALOG then begin
    if GetWindowLong(Wnd, GWL_STYLE)and WS_CHILD<>0 then
      Wnd:=GetWindowLong(Wnd, GWL_HWNDPARENT);
    CenterWindow(Wnd);
    Result := 1;
  end;
end;

{ Shade rectangle }

procedure ShadeRect(DC: HDC; const Rect: TRect);
const
  HatchBits: array[0..7] of Word = ($11, $22, $44, $88, $11, $22, $44, $88);
var
  Bitmap: HBitmap;
  SaveBrush: HBrush;
  SaveTextColor, SaveBkColor: TColorRef;
begin
  Bitmap := CreateBitmap(8, 8, 1, 1, @HatchBits);
  SaveBrush := SelectObject(DC, CreatePatternBrush(Bitmap));
  SaveTextColor := SetTextColor(DC, clWhite);
  SaveBkColor := SetBkColor(DC, clBlack);
  with Rect do PatBlt(DC, Left, Top, Right - Left, Bottom - Top, $00A000C9);
  SetBkColor(DC, SaveBkColor);
  SetTextColor(DC, SaveTextColor);
  DeleteObject(SelectObject(DC, SaveBrush));
  DeleteObject(Bitmap);
end;

{ Return the first piece of a moniker }

function OleStdGetFirstMoniker(const Moniker: IMoniker): IMoniker;
var
  Mksys: Longint;
  EnumMoniker: IEnumMoniker;
begin
  Result := nil;
  if Moniker <> nil then
  begin
    if (Moniker.IsSystemMoniker(Mksys) = 0) and
      (Mksys = MKSYS_GENERICCOMPOSITE) then
    begin
      if Moniker.Enum(True, EnumMoniker) <> 0 then Exit;
      EnumMoniker.Next(1, Result, nil);
    end
    else
      Result := Moniker;
  end;
end;

{ Return length of file moniker piece of the given moniker }

function OleStdGetLenFilePrefixOfMoniker(const Moniker: IMoniker): Integer;
var
  MkFirst: IMoniker;
  BindCtx: IBindCtx;
  Mksys: Longint;
  P: PWideChar;
begin
  Result := 0;
  if Moniker <> nil then
  begin
    MkFirst := OleStdGetFirstMoniker(Moniker);
    if (MkFirst <> nil) and
      (MkFirst.IsSystemMoniker(Mksys) = 0) and
      (Mksys = MKSYS_FILEMONIKER) and
      (CreateBindCtx(0, BindCtx) = 0) and
      (MkFirst.GetDisplayName(BindCtx, nil, P) = 0) and (P <> nil) then
    begin
      Result := WStrLen(P);
      CoTaskMemFree(P);
    end;
  end;
end;

function CoAllocCStr(const S: string): PChar;
begin
  Result := StrCopy(CoTaskMemAlloc(Length(S) + 1), PChar(S));
end;

function GetFullNameStr(const OleObject: IOleObject): string;
var
  P: PWideChar;
begin
  OleObject.GetUserType(USERCLASSTYPE_FULL, P);
  Result := P;
  CoTaskMemFree(P);
end;

function GetShortNameStr(const OleObject: IOleObject): string;
var
  P: PWideChar;
begin
  OleObject.GetUserType(USERCLASSTYPE_SHORT, P);
  Result := P;
  CoTaskMemFree(P);
end;

function GetDisplayNameStr(const OleLink: IOleLink): string;
var
  P: PWideChar;
begin
  OleLink.GetSourceDisplayName(P);
  Result := P;
  CoTaskMemFree(P);
end;

function GetVCLFrameForm(Form: TCustomForm): ICustomVCLFrameForm;
begin
  if Form.OleFormObject = nil then TCustomOleForm.Create(Form);
  Result := Form.OleFormObject as ICustomVCLFrameForm;
end;

function IsFormMDIChild(Form: TCustomForm): Boolean;
begin
  Result := (Form is TForm) and (TForm(Form).FormStyle = fsMDIChild);
end;

{�������� ���������� �����������}
function DecimSep:Char;
var Buffer:array[0..1]of Char;
begin
  if GetLocaleInfo(GetThreadLocale,LOCALE_SDECIMAL,Buffer,2)>0 then Result:=Buffer[0] else Result:='.';
end;

{������ ���������� �����������}
procedure SetDecimSep(DS:Char);
var DSS:String;
begin
  DSS:=DS;
  SetLocaleInfo(GetThreadLocale,LOCALE_SDECIMAL,PChar(DSS));
end;

{ TOleUILinkInfo - helper interface for Object Properties dialog }

type
  TOleUILinkInfo = class(TInterfacedObject, IOleUILinkInfo)
  private
    FContainer: TCustomOleContainer;
    FOleLink: IOleLink;
  public
    constructor Create(Container: TCustomOleContainer);
    function GetNextLink(dwLink: Longint): Longint; stdcall;
    function SetLinkUpdateOptions(dwLink: Longint;
      dwUpdateOpt: Longint): HResult; stdcall;
    function GetLinkUpdateOptions(dwLink: Longint;
      var dwUpdateOpt: Longint): HResult; stdcall;
    function SetLinkSource(dwLink: Longint; pszDisplayName: PChar;
      lenFileName: Longint; var chEaten: Longint;
      fValidateSource: BOOL): HResult; stdcall;
    function GetLinkSource(dwLink: Longint; var pszDisplayName: PChar;
      var lenFileName: Longint; var pszFullLinkType: PChar;
      var pszShortLinkType: PChar; var fSourceAvailable: BOOL;
      var fIsSelected: BOOL): HResult; stdcall;
    function OpenLinkSource(dwLink: Longint): HResult; stdcall;
    function UpdateLink(dwLink: Longint; fErrorMessage: BOOL;
      fErrorAction: BOOL): HResult; stdcall;
    function CancelLink(dwLink: Longint): HResult; stdcall;
    function GetLastUpdate(dwLink: Longint;
      var LastUpdate: TFileTime): HResult; stdcall;
  end;

procedure LinkError(const Ident: string);
begin
  Application.MessageBox(PChar(Ident), PChar(SLinkProperties),
    MB_OK or MB_ICONSTOP);
end;

constructor TOleUILinkInfo.Create(Container: TCustomOleContainer);
begin
  inherited Create;
  FContainer := Container;
  FContainer.FOleObject.QueryInterface(IOleLink, FOleLink);
end;

function TOleUILinkInfo.GetNextLink(dwLink: Longint): Longint;
begin
  if dwLink = 0 then Result := Longint(FContainer) else Result := 0;
end;

function TOleUILinkInfo.SetLinkUpdateOptions(dwLink: Longint;
  dwUpdateOpt: Longint): HResult;
begin
  Result := FOleLink.SetUpdateOptions(dwUpdateOpt);
  if Succeeded(Result) then FContainer.Changed;
end;

function TOleUILinkInfo.GetLinkUpdateOptions(dwLink: Longint;
  var dwUpdateOpt: Longint): HResult;
begin
  Result := FOleLink.GetUpdateOptions(dwUpdateOpt);
end;

function TOleUILinkInfo.SetLinkSource(dwLink: Longint; pszDisplayName: PChar;
  lenFileName: Longint; var chEaten: Longint;
  fValidateSource: BOOL): HResult;
var
  DisplayName: string;
  Buffer: array[0..255] of WideChar;
begin
  Result := E_FAIL;
  if fValidateSource then
  begin
    DisplayName := pszDisplayName;
    if Succeeded(FOleLink.SetSourceDisplayName(StringToWideChar(DisplayName,
      Buffer, SizeOf(Buffer) div 2))) then
    begin
      chEaten := Length(DisplayName);
      try
        FContainer.UpdateObject;
      except
        Application.HandleException(FContainer);
      end;
      Result := S_OK;
    end;
  end else
    LinkError(SInvalidLinkSource);
end;

function TOleUILinkInfo.GetLinkSource(dwLink: Longint; var pszDisplayName: PChar;
  var lenFileName: Longint; var pszFullLinkType: PChar;
  var pszShortLinkType: PChar; var fSourceAvailable: BOOL;
  var fIsSelected: BOOL): HResult;
var
  Moniker: IMoniker;
begin
  with FContainer do
  begin
    if @pszDisplayName <> nil then
      pszDisplayName := CoAllocCStr(GetDisplayNameStr(FOleLink));
    if @lenFileName <> nil then
    begin
      lenFileName := 0;
      FOleLink.GetSourceMoniker(Moniker);
      if Moniker <> nil then
        lenFileName := OleStdGetLenFilePrefixOfMoniker(Moniker);
    end;
    if @pszFullLinkType <> nil then
      pszFullLinkType := CoAllocCStr(GetFullNameStr(FOleObject));
    if @pszShortLinkType <> nil then
      pszShortLinkType := CoAllocCStr(GetShortNameStr(FOleObject));
  end;
  Result := S_OK;
end;

function TOleUILinkInfo.OpenLinkSource(dwLink: Longint): HResult;
begin
  try
    FContainer.DoVerb(ovShow);
  except
    Application.HandleException(FContainer);
  end;
  Result := S_OK;
end;

function TOleUILinkInfo.UpdateLink(dwLink: Longint; fErrorMessage: BOOL;
  fErrorAction: BOOL): HResult;
begin
  try
    FContainer.UpdateObject;
  except
    Application.HandleException(FContainer);
  end;
  Result := S_OK;
end;

function TOleUILinkInfo.CancelLink(dwLink: Longint): HResult;
begin
  LinkError(SCannotBreakLink);
  Result := E_NOTIMPL;
end;

function TOleUILinkInfo.GetLastUpdate(dwLink: Longint;
  var LastUpdate: TFileTime): HResult;
begin
  Result := S_OK;
end;

{ TEnumFormatEtc - format enumerator for TDataObject }

type
  PFormatList = ^TFormatList;
  TFormatList = array[0..255] of TFormatEtc;

type
  TEnumFormatEtc = class(TInterfacedObject, IEnumFormatEtc)
  private
    FFormatList: PFormatList;
    FFormatCount: Integer;
    FIndex: Integer;
  public
    constructor Create(FormatList: PFormatList; FormatCount, Index: Integer);
    { IEnumFormatEtc }
    function Next(celt: Longint; out elt; pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enum: IEnumFormatEtc): HResult; stdcall;
  end;

constructor TEnumFormatEtc.Create(FormatList: PFormatList;
  FormatCount, Index: Integer);
begin
  inherited Create;
  FFormatList := FormatList;
  FFormatCount := FormatCount;
  FIndex := Index;
end;

function TEnumFormatEtc.Next(celt: Longint; out elt; pceltFetched: PLongint): HResult;
var
  I: Integer;
begin
  I := 0;
  while (I < celt) and (FIndex < FFormatCount) do
  begin
    TFormatList(elt)[I] := FFormatList[FIndex];
    Inc(FIndex);
    Inc(I);
  end;
  if pceltFetched <> nil then pceltFetched^ := I;
  if I = celt then Result := S_OK else Result := S_FALSE;
end;

function TEnumFormatEtc.Skip(celt: Longint): HResult;
begin
  if celt <= FFormatCount - FIndex then
  begin
    FIndex := FIndex + celt;
    Result := S_OK;
  end else
  begin
    FIndex := FFormatCount;
    Result := S_FALSE;
  end;
end;

function TEnumFormatEtc.Reset: HResult;
begin
  FIndex := 0;
  Result := S_OK;
end;

function TEnumFormatEtc.Clone(out enum: IEnumFormatEtc): HResult;
begin
  enum := TEnumFormatEtc.Create(FFormatList, FFormatCount, FIndex);
  Result := S_OK;
end;

{ TDataObject - data object for use in clipboard transfers }

type
  TDataObject = class(TInterfacedObject, IDataObject)
  private
    FOleObject: IOleObject;
    function GetObjectDescriptor: HGlobal;
  public
    constructor Create(const OleObject: IOleObject);
    { IDataObject }
    function GetData(const formatetcIn: TFormatEtc;
      out medium: TStgMedium): HResult; stdcall;
    function GetDataHere(const formatetc: TFormatEtc;
      out medium: TStgMedium): HResult; stdcall;
    function QueryGetData(const formatetc: TFormatEtc): HResult; stdcall;
    function GetCanonicalFormatEtc(const formatetc: TFormatEtc;
      out formatetcOut: TFormatEtc): HResult; stdcall;
    function SetData(const formatetc: TFormatEtc; var medium: TStgMedium;
      fRelease: BOOL): HResult; stdcall;
    function EnumFormatEtc(dwDirection: Longint; out enumFormatEtc:
      IEnumFormatEtc): HResult; stdcall;
    function DAdvise(const formatetc: TFormatEtc; advf: Longint;
      const advSink: IAdviseSink; out dwConnection: Longint): HResult; stdcall;
    function DUnadvise(dwConnection: Longint): HResult; stdcall;
    function EnumDAdvise(out enumAdvise: IEnumStatData): HResult; stdcall;
  end;

constructor TDataObject.Create(const OleObject: IOleObject);
begin
  inherited Create;
  FOleObject := OleObject;
end;

function TDataObject.GetObjectDescriptor: HGlobal;
var
  DescSize, UTNCharLen, SOCCharLen: Integer;
  Descriptor: PObjectDescriptor;
  UserTypeName, SourceOfCopy: string;
  OleLink: IOleLink;
  P: PWideChar;
begin
  UserTypeName := GetFullNameStr(FOleObject);
  SourceOfCopy := UserTypeName;
  FOleObject.QueryInterface(IOleLink, OleLink);
  if OleLink <> nil then
  begin
    UserTypeName := Format(SLinkedObject, [UserTypeName]);
    SourceOfCopy := GetDisplayNameStr(OleLink);
  end;
  UTNCharLen := MultiByteToWideChar(0, 0, PChar(UserTypeName),
      Length(UserTypeName), nil, 0) + 1;
  SOCCharLen := MultiByteToWideChar(0, 0, PChar(SourceOfCopy),
      Length(SourceOfCopy), nil, 0) + 1;
  DescSize := SizeOf(TObjectDescriptor) +
    ((UTNCharLen + SOCCharLen) * Sizeof(WideChar));
  Result := GlobalAlloc(GMEM_MOVEABLE, DescSize);
  if Result <> 0 then
  begin
    Descriptor := GlobalLock(Result);
    FillChar(Descriptor^, DescSize, 0);
    with Descriptor^ do
    begin
      cbSize := DescSize;
      FOleObject.GetUserClassID(clsid);
      dwDrawAspect := DVASPECT_CONTENT;
      FOleObject.GetMiscStatus(DVASPECT_CONTENT, dwStatus);

      dwFullUserTypeName := SizeOf(TObjectDescriptor);
      P := PWideChar(Integer(Descriptor) + dwFullUserTypeName);
      MultiByteToWideChar(0, 0, PChar(UserTypeName), Length(UserTypeName),
        P, UTNCharLen);
      P[UTNCharLen-1] := #0;

      dwSrcOfCopy := dwFullUserTypeName + SOCCharLen * SizeOf(WideChar);
      P := PWideChar(Integer(Descriptor) + dwSrcOfCopy);
      MultiByteToWideChar(0, 0, PChar(SourceOfCopy), Length(SourceOfCopy),
        P, SOCCharLen);
      P[SOCCharLen-1] := #0;
    end;
    GlobalUnlock(Result);
  end;
end;

function TDataObject.GetData(const formatetcIn: TFormatEtc;
  out medium: TStgMedium): HResult;
var
  Descriptor: HGlobal;
begin
  Result := DV_E_FORMATETC;
  medium.tymed := 0;
  medium.hGlobal := 0;
  medium.unkForRelease := nil;
  with formatetcIn do
  begin
    if (cfFormat = CFObjectDescriptor) and (dwAspect = DVASPECT_CONTENT) and
      (tymed = TYMED_HGLOBAL) then
    begin
      Descriptor := GetObjectDescriptor;
      if Descriptor <> 0 then
      begin
        medium.tymed := TYMED_HGLOBAL;
        medium.hGlobal := Descriptor;
        Result := S_OK;
      end;
    end;
  end;
end;

function TDataObject.GetDataHere(const formatetc: TFormatEtc;
  out medium: TStgMedium): HResult;
var
  PersistStorage: IPersistStorage;
begin
  Result := DV_E_FORMATETC;
  with formatetc do
    if (cfFormat = CFEmbeddedObject) and (dwAspect = DVASPECT_CONTENT) and
      (tymed = TYMED_ISTORAGE) then
    begin
      medium.unkForRelease := nil;
      FOleObject.QueryInterface(IPersistStorage, PersistStorage);
      if PersistStorage <> nil then
      begin
        Result := OleSave(PersistStorage, IStorage(medium.stg), False);
        PersistStorage.SaveCompleted(nil);
      end;
    end;
end;

function TDataObject.QueryGetData(const formatetc: TFormatEtc): HResult;
begin
  Result := DV_E_FORMATETC;
  with formatetc do
    if dwAspect = DVASPECT_CONTENT then
      if (cfFormat = CFEmbeddedObject) and (tymed = TYMED_ISTORAGE) or
        (cfFormat = CFObjectDescriptor) and (tymed = TYMED_HGLOBAL) then
        Result := S_OK;
end;

function TDataObject.GetCanonicalFormatEtc(const formatetc: TFormatEtc;
  out formatetcOut: TFormatEtc): HResult;
begin
  formatetcOut.ptd := nil;
  Result := E_NOTIMPL;
end;

function TDataObject.SetData(const formatetc: TFormatEtc; var medium: TStgMedium;
  fRelease: BOOL): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDataObject.EnumFormatEtc(dwDirection: Longint; out enumFormatEtc:
  IEnumFormatEtc): HResult;
begin
  if dwDirection = DATADIR_GET then
  begin
    enumFormatEtc := TEnumFormatEtc.Create(@DataFormats, DataFormatCount, 0);
    Result := S_OK;
  end else
  begin
    enumFormatEtc := nil;
    Result := E_NOTIMPL;
  end;
end;

function TDataObject.DAdvise(const formatetc: TFormatEtc; advf: Longint;
  const advSink: IAdviseSink; out dwConnection: Longint): HResult;
begin
  Result := OLE_E_ADVISENOTSUPPORTED;
end;

function TDataObject.DUnadvise(dwConnection: Longint): HResult;
begin
  Result := OLE_E_ADVISENOTSUPPORTED;
end;

function TDataObject.EnumDAdvise(out enumAdvise: IEnumStatData): HResult;
begin
  Result := OLE_E_ADVISENOTSUPPORTED;
end;

{ TCustomOleContainer.IOleUIObjInfo - helper interface for Object Properties dialog }

function TCustomOleContainer.GetObjectInfo(dwObject: Longint;
  var dwObjSize: Longint; var lpszLabel: PChar;
  var lpszType: PChar; var lpszShortType: PChar;
  var lpszLocation: PChar): HResult;
begin
  if @dwObjSize <> nil then
    dwObjSize := GetObjectDataSize;
  if @lpszLabel <> nil then
    lpszLabel := CoAllocCStr(GetFullNameStr(FOleObject));
  if @lpszType <> nil then
    lpszType := CoAllocCStr(GetFullNameStr(FOleObject));
  if @lpszShortType <> nil then
    lpszShortType := CoAllocCStr(GetShortNameStr(FOleObject));
  if @lpszLocation <> nil then
    lpszLocation := CoAllocCStr(Caption);
  Result := S_OK;
end;

function TCustomOleContainer.GetConvertInfo(dwObject: Longint; var ClassID: TCLSID;
  var wFormat: Word; var ConvertDefaultClassID: TCLSID;
  var lpClsidExclude: PCLSID; var cClsidExclude: Longint): HResult;
begin
  FOleObject.GetUserClassID(ClassID);
  Result := S_OK;
end;

function TCustomOleContainer.ConvertObject(dwObject: Longint;
  const clsidNew: TCLSID): HResult;
begin
  Result := E_NOTIMPL;
end;

function TCustomOleContainer.GetViewInfo(dwObject: Longint; var hMetaPict: HGlobal;
  var dvAspect: Longint; var nCurrentScale: Integer): HResult;
begin
  if @hMetaPict <> nil then hMetaPict := GetIconMetaPict;
  if @dvAspect <> nil then dvAspect := FDrawAspect;
  if @nCurrentScale <> nil then nCurrentScale := 0;
  Result := S_OK;
end;

function TCustomOleContainer.SetViewInfo(dwObject: Longint; hMetaPict: HGlobal;
  dvAspect: Longint; nCurrentScale: Integer;
  bRelativeToOrig: BOOL): HResult;
var
  ShowAsIcon: Boolean;
begin
  case dvAspect of
    DVASPECT_CONTENT: ShowAsIcon := False;
    DVASPECT_ICON: ShowAsIcon := True;
  else
    ShowAsIcon := Iconic;
  end;
  SetDrawAspect(ShowAsIcon, hMetaPict);
  Result := S_OK;
end;

{ TCustomOleContainer.IOleClientSite }

function TCustomOleContainer.GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
  out mk: IMoniker): HResult;
begin
  mk := nil;
  Result := E_NOTIMPL;
end;

function TCustomOleContainer.GetContainer(out container: IOleContainer): HResult;
begin
  container := nil;
  Result := E_NOINTERFACE;
end;

function TCustomOleContainer.ShowObject: HResult;
begin
  Result := S_OK;
end;

function TCustomOleContainer.OnShowWindow(fShow: BOOL): HResult;
begin
  if FObjectOpen <> Boolean(fShow) then
  begin
    FObjectOpen := fShow;
    Invalidate;
  end;
  Result := S_OK;
end;

function TCustomOleContainer.RequestNewObjectLayout: HResult;
begin
  Result := E_NOTIMPL;
end;

{ TCustomOleContainer.IOleInPlaceSite }

function TCustomOleContainer.GetWindow(out wnd: HWnd): HResult;
begin
  if FDocObj then
    wnd := Handle
  else
    wnd := Parent.Handle;
  Result := S_OK;
end;

function TCustomOleContainer.ContextSensitiveHelp(fEnterMode: BOOL): HResult;
begin
  Result := S_OK;
end;

function TCustomOleContainer.CanInPlaceActivate: HResult;
begin
  Result := S_FALSE;
  if not (csDesigning in ComponentState) and Visible and
    AllowInPlace and not Iconic then
    Result := S_OK;
end;

function TCustomOleContainer.OnInPlaceActivate: HResult;
begin
  FOleObject.QueryInterface(IOleInPlaceObject, FOleInPlaceObject);
  FOleObject.QueryInterface(IOleInPlaceActiveObject, FOleInPlaceActiveObject);
  Result := S_OK;
end;

function TCustomOleContainer.OnUIActivate: HResult;
begin
  SetUIActive(True);
  Result := S_OK;
end;

function TCustomOleContainer.GetWindowContext(out frame: IOleInPlaceFrame;
  out doc: IOleInPlaceUIWindow; out rcPosRect: TRect;
  out rcClipRect: TRect; out frameInfo: TOleInPlaceFrameInfo): HResult;
var
  Origin: TPoint;
begin
  frame := FFrameForm;
  doc := nil;
  if FDocObj then
  begin
    rcPosRect := Rect(0,0,Width,Height);
    rcClipRect := rcPosRect;
  end
  else
  begin
    Origin := Parent.ScreenToClient(ClientOrigin);
    SetRect(rcPosRect, Origin.X, Origin.Y,
      Origin.X + ClientWidth, Origin.Y + ClientHeight);
      SetRect(rcClipRect, -16384, -16384, 16383, 16383);
  end;
  CreateAccelTable;
  with frameInfo do
  begin
    fMDIApp := False;
    FFrameForm.GetWindow(hWndFrame);
    hAccel := FAccelTable;
    cAccelEntries := FAccelCount;
  end;
  Result := S_OK;
end;

function TCustomOleContainer.Scroll(scrollExtent: TPoint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TCustomOleContainer.OnUIDeactivate(fUndoable: BOOL): HResult;
begin
  FFrameForm.SetMenu(0, 0, 0);
  FFrameForm.ClearBorderSpace;
  SetUIActive(False);
  Result := S_OK;
end;

function TCustomOleContainer.OnInPlaceDeactivate: HResult;
begin
  FOleInPlaceActiveObject := nil;
  FOleInPlaceObject := nil;
  Result := S_OK;
end;

function TCustomOleContainer.DiscardUndoState: HResult;
begin
  Result := E_NOTIMPL;
end;

function TCustomOleContainer.DeactivateAndUndo: HResult;
begin
  FOleInPlaceObject.UIDeactivate;
  Result := S_OK;
end;

function TCustomOleContainer.OnPosRectChange(const rcPosRect: TRect): HResult;
begin
  try
    ObjectMoved(rcPosRect);
    UpdateObjectRect;
  except
    Application.HandleException(Self);
  end;
  Result := S_OK;
end;

{ TCustomOleContainer.IAdviseSink }

procedure TCustomOleContainer.OnDataChange(const formatetc: TFormatEtc;
  const stgmed: TStgMedium);
begin
  Changed;
end;

procedure TCustomOleContainer.OnViewChange(dwAspect: Longint; lindex: Longint);
begin
  if dwAspect = FDrawAspect then UpdateView;
end;

procedure TCustomOleContainer.OnRename(const mk: IMoniker);
begin
end;

procedure TCustomOleContainer.OnSave;
begin
end;

procedure TCustomOleContainer.OnClose;
begin
end;

{ TCustomOleContainer.IOleDocumentSite }

function TCustomOleContainer.ActivateMe(View: IOleDocumentView): HRESULT;
var
  Doc: IOleDocument;
begin
  Result := E_FAIL;
  if View = nil then
  begin   // If we're given a nil view, try to get one from the document object.
    if FOleObject.QueryInterface(IOleDocument, Doc) <> 0 then Exit;
    if Doc = nil then Exit;
    Result := Doc.CreateView(Self, nil, 0, View);
    if Result <> 0 then Exit;
  end
  else
    View.SetInPlaceSite(Self);

  FDocObj := True;
  FDocView := View;
  View.UIActivate(TRUE);    //Set up toolbars and menus first
  UpdateObjectRect;         //Then set window size, after toolbars
  View.Show(TRUE);
  Result := NOERROR;
end;

{ TCustomOleContainer }

constructor TCustomOleContainer.Create(AOwner: TComponent);
const
  ContainerStyle = [csClickEvents, csSetCaption, csOpaque, csDoubleClicks];
begin
  inherited Create(AOwner);
  FRefCount := 1;
  if NewStyleControls then
    ControlStyle := ContainerStyle else
    ControlStyle := ContainerStyle + [csFramed];
  Width := 121;
  Height := 121;
  TabStop := True;
  ParentColor := False;
  FAllowInPlace := True;
  FAllowActiveDoc := True;
  FAutoActivate := aaDoubleClick;
  FAutoVerbMenu := True;
  FBorderStyle := bsSingle;
  FCopyOnSave := True;
  FDrawAspect := DVASPECT_CONTENT;
  FChangeDecimalSymbol:=False;
  FForcedDecimalSymbol:=',';
end;

destructor TCustomOleContainer.Destroy;
begin
  DestroyObject;
  inherited Destroy;
end;

function TCustomOleContainer._AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

procedure TCustomOleContainer.AdjustBounds;
var
  Size: TPoint;
  Extra: Integer;
begin
  if not (csReading in ComponentState) and (FSizeMode = smAutoSize) and
    (FOleObject <> nil) then
  begin
    Size := HimetricToPixels(FViewSize);
    Extra := GetBorderWidth * 2;
    SetBounds(Left, Top, Size.X + Extra, Size.Y + Extra);
  end;
end;

function TCustomOleContainer.ChangeIconDialog: Boolean;
var
  Data: TOleUIChangeIcon;
begin
  CheckObject;
  Result := False;
  FillChar(Data, SizeOf(Data), 0);
  Data.cbStruct := SizeOf(Data);
  Data.dwFlags := CIF_SELECTCURRENT;
  Data.hWndOwner := Application.Handle;
  Data.lpfnHook := OleDialogHook;
  OleCheck(FOleObject.GetUserClassID(Data.clsid));
  Data.hMetaPict := GetIconMetaPict;
  try
    if OleUIChangeIcon(Data) = OLEUI_OK then
    begin
      SetDrawAspect(True, Data.hMetaPict);
      Result := True;
    end;
  finally
    DestroyMetaPict(Data.hMetaPict);
  end;
end;

procedure TCustomOleContainer.CheckObject;
begin
  if FOleObject = nil then
    raise EOleError.CreateRes(@SEmptyContainer);
end;

procedure TCustomOleContainer.Close;
begin
  CheckObject;
  OleCheck(FOleObject.Close(OLECLOSE_SAVEIFDIRTY));
end;

procedure TCustomOleContainer.Copy;
begin
  Close;
  OleCheck(OleSetClipboard(TDataObject.Create(FOleObject) as IDataObject));
end;

procedure TCustomOleContainer.CreateAccelTable;
var
  Menu: TMainMenu;
begin
  if FAccelTable = 0 then
  begin
    Menu := FFrameForm.Form.Menu;
    if Menu <> nil then
      Menu.GetOle2AcceleratorTable(FAccelTable, FAccelCount, [0, 2, 4]);
  end;
end;

procedure TCustomOleContainer.CreateLinkToFile(const FileName: string;
  Iconic: Boolean);
var
  CreateInfo: TCreateInfo;
begin
  CreateInfo.CreateType := ctLinkToFile;
  CreateInfo.ShowAsIcon := Iconic;
  CreateInfo.IconMetaPict := 0;
  CreateInfo.FileName := FileName;
  CreateObjectFromInfo(CreateInfo);
end;

procedure TCustomOleContainer.CreateObject(const OleClassName: string;
  Iconic: Boolean);
var
  CreateInfo: TCreateInfo;
begin
  CreateInfo.CreateType := ctNewObject;
  CreateInfo.ShowAsIcon := Iconic;
  CreateInfo.IconMetaPict := 0;
  CreateInfo.ClassID := ProgIDToClassID(OleClassName);
  CreateObjectFromInfo(CreateInfo);
end;

procedure TCustomOleContainer.CreateObjectFromFile(const FileName: string;
  Iconic: Boolean);
var
  CreateInfo: TCreateInfo;
begin
  CreateInfo.CreateType := ctFromFile;
  CreateInfo.ShowAsIcon := Iconic;
  CreateInfo.IconMetaPict := 0;
  CreateInfo.FileName := FileName;
  CreateObjectFromInfo(CreateInfo);
end;

procedure TCustomOleContainer.CreateObjectFromInfo(const CreateInfo: TCreateInfo);
begin
  DestroyObject;
  try
    CreateStorage;
    with CreateInfo do begin
      case CreateType of
        ctNewObject:
          OleCheck(OleCreate(ClassID, IOleObject, OLERENDER_DRAW, nil,
            Self, FStorage, FOleObject));
        ctFromFile:
          OleCheck(OleCreateFromFile(GUID_NULL, PWideChar(FileName), IOleObject,
            OLERENDER_DRAW, nil, Self, FStorage, FOleObject));
        ctLinkToFile:
          OleCheck(OleCreateLinkToFile(PWideChar(FileName), IOleObject,
            OLERENDER_DRAW, nil, Self, FStorage, FOleObject));
        ctFromData:
          OleCheck(OleCreateFromData(DataObject, IOleObject,
            OLERENDER_DRAW, nil, Self, FStorage, FOleObject));
        ctLinkFromData:
          OleCheck(OleCreateLinkFromData(DataObject, IOleObject,
            OLERENDER_DRAW, nil, Self, FStorage, FOleObject));
      end;
      FDrawAspect := DVASPECT_CONTENT;
      InitObject;
      FOleObject.SetExtent(DVASPECT_CONTENT, PixelsToHimetric(
        Point(ClientWidth, ClientHeight)));
      SetDrawAspect(ShowAsIcon, IconMetaPict);
      UpdateView;
    end;
  except
    DestroyObject;
    raise;
  end;
end;

procedure TCustomOleContainer.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_CLIPCHILDREN;
    WindowClass.Style := WindowClass.Style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure TCustomOleContainer.CreateStorage;
begin
  OleCheck(CreateILockBytesOnHGlobal(0, True, FLockBytes));
  OleCheck(StgCreateDocfileOnILockBytes(FLockBytes, STGM_READWRITE
    or STGM_SHARE_EXCLUSIVE or STGM_CREATE, 0, FStorage));
end;

procedure TCustomOleContainer.DblClick;
begin
  if FAutoActivate = aaDoubleClick then
    DoVerb(ovPrimary)
  else
    inherited;
end;

procedure TCustomOleContainer.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Data', LoadFromStream, SaveToStream,
    FOleObject <> nil);
end;

procedure TCustomOleContainer.DesignModified;
var
  Form: TCustomForm;
begin
  Form := GetParentForm(Self);
  if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
end;

procedure TCustomOleContainer.DestroyAccelTable;
begin
  if FAccelTable<>0 then begin
    DestroyAcceleratorTable(FAccelTable);
    FAccelTable := 0;
    FAccelCount := 0;
  end;
end;

procedure TCustomOleContainer.DestroyObject;
var DataObject: IDataObject;
begin
  if FOleObject<>nil then begin
    SetViewAdviseSink(False);
    if FDataConnection<>0 then begin
      FOleObject.QueryInterface(IDataObject, DataObject);
      if DataObject<>nil then begin
        DataObject.DUnadvise(FDataConnection);
        DataObject:=nil;
      end;
      FDataConnection:=0;
    end;
    FOleObject.Close(OLECLOSE_SAVEIFDIRTY); //OLECLOSE_NOSAVE);
    Invalidate;
    Changed;
  end;
  FDocView:=nil;
  FOleObject:=nil;
  FStorage:=nil;
  FLockBytes:=nil;
  DestroyVerbs;
  DestroyAccelTable;
  if FDocForm<>nil then begin
    if FFrameForm<>FDocForm then FFrameForm.RemoveCustomContainer(Self);
    FDocForm.RemoveCustomContainer(Self);
    FFrameForm:=nil;
    FDocForm:=nil;
  end;
end;

procedure TCustomOleContainer.DestroyVerbs;
begin
  FPopupVerbMenu.Free;
  FPopupVerbMenu := nil;
  FObjectVerbs.Free;
  FObjectVerbs := nil;
end;

procedure TCustomOleContainer.DoEnter;
begin
  if FAutoActivate=aaGetFocus then DoVerb(ovShow);
  inherited;
end;

procedure TCustomOleContainer.DoVerb(Verb:Integer);
var H:THandle;
    R:TRect;
    DS:Char;
begin
  CheckObject;
  if Verb>0 then begin
    if FObjectVerbs=nil then UpdateVerbs;
    if Verb>=FObjectVerbs.Count then raise EOleError.CreateRes(@SInvalidVerb);
    Verb:=Smallint(Integer(FObjectVerbs.Objects[Verb]) and $0000FFFF);
  end
  else if Verb=ovPrimary then Verb:=0;
  if FDocObj then begin
    R:=ClientRect;
    H:=Handle;
  end
  else begin
    R:=BoundsRect;
    H:=Parent.Handle;
  end;
  {������� ����������� �� ������� �� ����� �������� MSWord (� ����� ��
   ����� ������ �������� ���������� ���� MSWord �� �����������)}
  DS:=',';
  if FChangeDecimalSymbol then begin
    DS:=DecimSep;
    if DS<>FForcedDecimalSymbol then SetDecimSep(FForcedDecimalSymbol);
  end;
  OleCheck(FOleObject.DoVerb(Verb, nil, Self, 0, H, R));
  if FChangeDecimalSymbol then
    if DS<>FForcedDecimalSymbol then SetDecimSep(DS); //������� ����������� �� �����
end;

function TCustomOleContainer.GetBorderWidth: Integer;
begin
  if FBorderStyle=bsNone then Result:=0
    else if NewStyleControls and Ctl3D then Result:=2 else Result:=1;
end;

function TCustomOleContainer.GetCanPaste: Boolean;
var
  DataObject: IDataObject;
begin
  Result := Succeeded(OleGetClipboard(DataObject)) and
    ((OleQueryCreateFromData(DataObject) = 0) or
     (OleQueryLinkFromData(DataObject) = 0));
end;

function TCustomOleContainer.GetIconic: Boolean;
begin
  Result := FDrawAspect = DVASPECT_ICON;
end;

function TCustomOleContainer.GetIconMetaPict: HGlobal;
var
  DataObject: IDataObject;
  FormatEtc: TFormatEtc;
  Medium: TStgMedium;
  ClassID: TCLSID;
begin
  CheckObject;
  Result := 0;
  if FDrawAspect = DVASPECT_ICON then
  begin
    FOleObject.QueryInterface(IDataObject, DataObject);
    if DataObject <> nil then
    begin
      FormatEtc.cfFormat := CF_METAFILEPICT;
      FormatEtc.ptd := nil;
      FormatEtc.dwAspect := DVASPECT_ICON;
      FormatEtc.lIndex := -1;
      FormatEtc.tymed := TYMED_MFPICT;
      if Succeeded(DataObject.GetData(FormatEtc, Medium)) then
        Result := Medium.hMetaFilePict;
    end;
  end;
  if Result = 0 then
  begin
    OleCheck(FOleObject.GetUserClassID(ClassID));
    Result := OleGetIconOfClass(ClassID, nil, True);
  end;
end;

function TCustomOleContainer.GetLinked: Boolean;
var
  OleLink: IOleLink;
begin
  CheckObject;
  FOleObject.QueryInterface(IOleLink, OleLink);
  Result := (OleLink <> nil);
end;

function TCustomOleContainer.GetObjectDataSize: Integer;
var
  DataHandle: HGlobal;
begin
  if Succeeded(GetHGlobalFromILockBytes(FLockBytes, DataHandle)) then
    Result := GlobalSize(DataHandle) else
    Result := 0;
end;

function TCustomOleContainer.GetObjectVerbs: TStrings;
begin
  if FObjectVerbs = nil then UpdateVerbs;
  Result := FObjectVerbs;
end;

function TCustomOleContainer.GetOleClassName: string;
var
  ClassID: TCLSID;
begin
  CheckObject;
  OleCheck(FOleObject.GetUserClassID(ClassID));
  Result := ClassIDToProgID(ClassID);
end;

function TCustomOleContainer.GetOleObject: Variant;
begin
  CheckObject;
  Result := Variant(FOleObject as IDispatch);
end;

function TCustomOleContainer.GetPopupMenu: TPopupMenu;
var
  I: Integer;
  Item: TMenuItem;
begin
  if FAutoVerbMenu and (FOleObject <> nil) and (ObjectVerbs.Count > 0) then
  begin
    if FPopupVerbMenu = nil then
    begin
      FPopupVerbMenu := TPopupMenu.Create(Self);
      for I := 0 to ObjectVerbs.Count - 1 do
      begin
        Item := TMenuItem.Create(Self);
        Item.Caption := ObjectVerbs[I];
        Item.Tag := I;
        Item.OnClick := PopupVerbMenuClick;
        FPopupVerbMenu.Items.Add(Item);
      end;
    end;
    Result := FPopupVerbMenu;
  end else
    Result := inherited GetPopupMenu;
end;

function TCustomOleContainer.GetPrimaryVerb: Integer;
begin
  if FObjectVerbs = nil then UpdateVerbs;
  for Result := 0 to FObjectVerbs.Count - 1 do
    if Integer(FObjectVerbs.Objects[Result]) and $0000FFFF = 0 then Exit;
  Result := 0;
end;

function TCustomOleContainer.GetSourceDoc: string;
var
  OleLink: IOleLink;
begin
  CheckObject;
  Result := '';
  FOleObject.QueryInterface(IOleLink, OleLink);
  if OleLink <> nil then
    Result := GetDisplayNameStr(OleLink);
end;

function TCustomOleContainer.GetState: TObjectState;
begin
  if FOleObject = nil then
    Result := osEmpty
  else if FObjectOpen then
    Result := osOpen
  else if FUIActive then
    Result := osUIActive
  else if OleIsRunning(FOleObject) then
    Result := osRunning
  else
    Result := osLoaded;
end;

procedure TCustomOleContainer.InitObject;

  function FindForm(Component: TComponent): TCustomForm;
  begin
    while Component <> nil do
      if Component is TCustomForm then
      begin
        Result := TCustomForm(Component);
        Exit;
      end
      else
        Component := Component.Owner;
    Result := nil;
  end;

var
  DataObject: IDataObject;
  FormatEtc: TFormatEtc;
  DocForm: TCustomForm;
begin
  DocForm := GetParentForm(Self);
  if DocForm = nil then
    DocForm := FindForm(Self);
  if DocForm = nil then ValidParentForm(Self);
  FDocForm := GetVCLFrameForm(DocForm);
  FFrameForm := FDocForm;
  FDocForm.AddCustomContainer(Self);
  if IsFormMDIChild(FDocForm.Form) then
  begin
    FFrameForm := GetVCLFrameForm(Application.MainForm);
    FFrameForm.AddCustomContainer(Self);
  end;
  SetViewAdviseSink(True);
  FOleObject.SetHostNames(PWideChar(WideString(Application.Title)),
    PWideChar(WideString(Caption)));
  OleSetContainedObject(FOleObject, True);
  FOleObject.QueryInterface(IDataObject, DataObject);
  if DataObject <> nil then
  begin
    FormatEtc.cfFormat := 0;
    FormatEtc.ptd := nil;
    FormatEtc.dwAspect := -1;
    FormatEtc.lIndex := -1;
    FormatEtc.tymed := -1;
    DataObject.DAdvise(FormatEtc, ADVF_NODATA, Self, FDataConnection);
  end;
end;

function TCustomOleContainer.InsertObjectDialog: Boolean;
var
  Data: TOleUIInsertObject;
  NameBuffer: array[0..255] of Char;
  CreateInfo: TCreateInfo;
begin
  Result := False;
  FNewInserted := False;
  FillChar(Data, SizeOf(Data), 0);
  FillChar(NameBuffer, SizeOf(NameBuffer), 0);
  Data.cbStruct := SizeOf(Data);
  Data.dwFlags := IOF_SELECTCREATENEW;
  Data.hWndOwner := Application.Handle;
  Data.lpfnHook := OleDialogHook;
  Data.lpszFile := NameBuffer;
  Data.cchFile := SizeOf(NameBuffer);
  try
    if OleUIInsertObject(Data) = OLEUI_OK then
    begin
      if Data.dwFlags and IOF_SELECTCREATENEW <> 0 then
      begin
        CreateInfo.CreateType := ctNewObject;
        CreateInfo.ClassID := Data.clsid;
      end else
      begin
        if Data.dwFlags and IOF_CHECKLINK = 0 then
          CreateInfo.CreateType := ctFromFile else
          CreateInfo.CreateType := ctLinkToFile;
        CreateInfo.FileName := NameBuffer;
      end;
      CreateInfo.ShowAsIcon := Data.dwFlags and IOF_CHECKDISPLAYASICON <> 0;
      CreateInfo.IconMetaPict := Data.hMetaPict;
      CreateObjectFromInfo(CreateInfo);
      if CreateInfo.CreateType = ctNewObject then FNewInserted := True;
      Result := True;
    end;
  finally
    DestroyMetaPict(Data.hMetaPict);
  end;
end;

procedure TCustomOleContainer.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (FAutoActivate <> aaManual) and (Key = VK_RETURN) then
  begin
    if ssCtrl in Shift then DoVerb(ovShow) else DoVerb(ovPrimary);
    Key := 0;
  end;
end;

procedure TCustomOleContainer.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TCustomOleContainer.LoadFromStream(Stream: TStream);
var
  DataHandle: HGlobal;
  Buffer: Pointer;
  Header: TStreamHeader;
begin
  DestroyObject;
  Stream.ReadBuffer(Header, SizeOf(Header));
  if (Header.Signature <> StreamSignature) and not FOldStreamFormat then
    raise EOleError.CreateRes(@SInvalidStreamFormat);
  DataHandle := GlobalAlloc(GMEM_MOVEABLE, Header.DataSize);
  if DataHandle = 0 then OutOfMemoryError;
  try
    Buffer := GlobalLock(DataHandle);
    try
      Stream.Read(Buffer^, Header.DataSize);
    finally
      GlobalUnlock(DataHandle);
    end;
    OleCheck(CreateILockBytesOnHGlobal(DataHandle, True, FLockBytes));
    DataHandle := 0;
    OleCheck(StgOpenStorageOnILockBytes(FLockBytes, nil, STGM_READWRITE or
      STGM_SHARE_EXCLUSIVE, nil, 0, FStorage));
    OleCheck(OleLoad(FStorage, IOleObject, Self, FOleObject));
    FDrawAspect := Header.DrawAspect;
    InitObject;
    UpdateView;
  except
    if DataHandle <> 0 then GlobalFree(DataHandle);
    DestroyObject;
    raise;
  end;
end;

procedure TCustomOleContainer.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then SetFocus;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TCustomOleContainer.Changed;
begin
  if not (csReading in ComponentState) then
  begin
    FModified := True;
    FModSinceSave := True;
    DesignModified;
  end;
end;

procedure TCustomOleContainer.ObjectMoved(const ObjectRect: TRect);
var
  R: TRect;
  I: Integer;
begin
  if Assigned(FOnObjectMove) then
  begin
    R := ObjectRect;
    I := GetBorderWidth;
    InflateRect(R, I, I);
    FOnObjectMove(Self, R);
  end;
end;

function TCustomOleContainer.ObjectPropertiesDialog: Boolean;
var
  ObjectProps: TOleUIObjectProps;
  PropSheet: TPropSheetHeader;
  GeneralProps: TOleUIGnrlProps;
  ViewProps: TOleUIViewProps;
  LinkProps: TOleUILinkProps;
  DialogCaption: string;
begin
  CheckObject;
  Result := False;
  FillChar(ObjectProps, SizeOf(ObjectProps), 0);
  FillChar(PropSheet, SizeOf(PropSheet), 0);
  FillChar(GeneralProps, SizeOf(GeneralProps), 0);
  FillChar(ViewProps, SizeOf(ViewProps), 0);
  FillChar(LinkProps, SizeOf(LinkProps), 0);
  ObjectProps.cbStruct := SizeOf(ObjectProps);
  ObjectProps.dwFlags := OPF_DISABLECONVERT;
  ObjectProps.lpPS := @PropSheet;
  ObjectProps.lpObjInfo := Self;
  if Linked then
  begin
    ObjectProps.dwFlags := ObjectProps.dwFlags or OPF_OBJECTISLINK;
    ObjectProps.lpLinkInfo := TOleUILinkInfo.Create(Self);  // acquire olelink
  end;
  ObjectProps.lpGP := @GeneralProps;
  ObjectProps.lpVP := @ViewProps;
  ObjectProps.lpLP := @LinkProps;
  PropSheet.dwSize := SizeOf(PropSheet);
  PropSheet.hWndParent := Application.Handle;
  PropSheet.hInstance := MainInstance;
  DialogCaption := Format(SPropDlgCaption, [GetFullNameStr(FOleObject)]);
  PropSheet.pszCaption := PChar(DialogCaption);
  GeneralProps.cbStruct := SizeOf(GeneralProps);
  GeneralProps.lpfnHook := OleDialogHook;
  ViewProps.cbStruct := SizeOf(ViewProps);
  ViewProps.dwFlags := VPF_DISABLESCALE;
  LinkProps.cbStruct := SizeOf(LinkProps);
  LinkProps.dwFlags := ELF_DISABLECANCELLINK;
  if OleUIObjectProperties(ObjectProps) = OLEUI_OK then Result := True;
end;

procedure TCustomOleContainer.Paint;
var
  W, H: Integer;
  S: TPoint;
  R, CR: TRect;
  Flags: Integer;
begin
  if FDocObj and FUIActive then Exit;
  CR := Rect(0,0,Width,Height);
  if FBorderStyle = bsSingle then
  begin
    if NewStyleControls and Ctl3D then
      Flags := BF_ADJUST or BF_RECT
    else
      Flags := BF_ADJUST or BF_RECT or BF_MONO;
  end
  else
    Flags := BF_FLAT;

  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := Color;
  DrawEdge(Canvas.Handle, CR, EDGE_SUNKEN, Flags or BF_MIDDLE);
  if FOleObject <> nil then
  begin
    W := CR.Right - CR.Left;
    H := CR.Bottom - CR.Top;
    S := HimetricToPixels(FViewSize);
    if (FDrawAspect = DVASPECT_CONTENT) and (FSizeMode = smScale) then
      if W * S.Y > H * S.X then
      begin
        S.X := S.X * H div S.Y;
        S.Y := H;
      end else
      begin
        S.Y := S.Y * W div S.X;
        S.X := W;
      end;
    if (FDrawAspect = DVASPECT_ICON) or (FSizeMode = smCenter) or
      (FSizeMode = smScale) then
    begin
      R.Left := (W - S.X) div 2;
      R.Top := (H - S.Y) div 2;
      R.Right := R.Left + S.X;
      R.Bottom := R.Top + S.Y;
    end
    else if FSizeMode = smClip then
    begin
      SetRect(R, CR.Left, CR.Top, S.X, S.Y);
      IntersectClipRect(Canvas.Handle, CR.Left, CR.Top, CR.Right, CR.Bottom);
    end
    else
      SetRect(R, CR.Left, CR.Top, W, H);
    OleDraw(FOleObject, FDrawAspect, Canvas.Handle, R);
    if FObjectOpen then ShadeRect(Canvas.Handle, CR);
  end;
  if FFocused then Canvas.DrawFocusRect(CR);
end;

procedure TCustomOleContainer.Paste;
var
  DataObject: IDataObject;
  Descriptor: PObjectDescriptor;
  FormatEtc: TFormatEtc;
  Medium: TStgMedium;
  CreateInfo: TCreateInfo;
begin
  if not CanPaste then Exit;
  OleCheck(OleGetClipboard(DataObject));
  try
    CreateInfo.CreateType := ctFromData;
    CreateInfo.ShowAsIcon := False;
    CreateInfo.IconMetaPict := 0;
    CreateInfo.DataObject := DataObject;
    FormatEtc.cfFormat := CFObjectDescriptor;
    FormatEtc.ptd := nil;
    FormatEtc.dwAspect := DVASPECT_CONTENT;
    FormatEtc.lIndex := -1;
    FormatEtc.tymed := TYMED_HGLOBAL;
    if Succeeded(DataObject.GetData(FormatEtc, Medium)) then
    begin
      Descriptor := GlobalLock(Medium.hGlobal);
      if Descriptor^.dwDrawAspect = DVASPECT_ICON then
        CreateInfo.ShowAsIcon := True;
      GlobalUnlock(Medium.hGlobal);
      ReleaseStgMedium(Medium);
    end;
    if CreateInfo.ShowAsIcon then
    begin
      FormatEtc.cfFormat := CF_METAFILEPICT;
      FormatEtc.ptd := nil;
      FormatEtc.dwAspect := DVASPECT_ICON;
      FormatEtc.lIndex := -1;
      FormatEtc.tymed := TYMED_MFPICT;
      if Succeeded(DataObject.GetData(FormatEtc, Medium)) then
        CreateInfo.IconMetaPict := Medium.hMetaFilePict;
    end;
    CreateObjectFromInfo(CreateInfo);
  finally
    DestroyMetaPict(CreateInfo.IconMetaPict);
  end;
end;

function TCustomOleContainer.PasteSpecialDialog: Boolean;
const
  PasteFormatCount = 2;
var
  Data: TOleUIPasteSpecial;
  PasteFormats: array[0..PasteFormatCount - 1] of TOleUIPasteEntry;
  CreateInfo: TCreateInfo;
begin
  Result := False;
  if not CanPaste then Exit;
  FillChar(Data, SizeOf(Data), 0);
  FillChar(PasteFormats, SizeOf(PasteFormats), 0);
  Data.cbStruct := SizeOf(Data);
  Data.hWndOwner := Application.Handle;
  Data.lpfnHook := OleDialogHook;
  Data.arrPasteEntries := @PasteFormats;
  Data.cPasteEntries := PasteFormatCount;
  Data.arrLinkTypes := @CFLinkSource;
  Data.cLinkTypes := 1;
  PasteFormats[0].fmtetc.cfFormat := CFEmbeddedObject;
  PasteFormats[0].fmtetc.dwAspect := DVASPECT_CONTENT;
  PasteFormats[0].fmtetc.lIndex := -1;
  PasteFormats[0].fmtetc.tymed := TYMED_ISTORAGE;
  PasteFormats[0].lpstrFormatName := '%s';
  PasteFormats[0].lpstrResultText := '%s';
  PasteFormats[0].dwFlags := OLEUIPASTE_PASTE or OLEUIPASTE_ENABLEICON;
  PasteFormats[1].fmtetc.cfFormat := CFLinkSource;
  PasteFormats[1].fmtetc.dwAspect := DVASPECT_CONTENT;
  PasteFormats[1].fmtetc.lIndex := -1;
  PasteFormats[1].fmtetc.tymed := TYMED_ISTREAM;
  PasteFormats[1].lpstrFormatName := '%s';
  PasteFormats[1].lpstrResultText := '%s';
  PasteFormats[1].dwFlags := OLEUIPASTE_LINKTYPE1 or OLEUIPASTE_ENABLEICON;
  try
    if OleUIPasteSpecial(Data) = OLEUI_OK then
    begin
      if Data.fLink then
        CreateInfo.CreateType := ctLinkFromData else
        CreateInfo.CreateType := ctFromData;
      CreateInfo.ShowAsIcon := Data.dwFlags and PSF_CHECKDISPLAYASICON <> 0;
      CreateInfo.IconMetaPict := Data.hMetaPict;
      CreateInfo.DataObject := Data.lpSrcDataObj;
      CreateObjectFromInfo(CreateInfo);
      Result := True;
    end;
  finally
    DestroyMetaPict(Data.hMetaPict);
  end;
end;

procedure TCustomOleContainer.PopupVerbMenuClick(Sender: TObject);
begin
  DoVerb((Sender as TMenuItem).Tag);
end;

function TCustomOleContainer.QueryInterface(const iid: TIID; out obj): HResult;
begin
  Pointer(obj) := nil;
  Result := E_NOINTERFACE;
  if IsEqualIID(iid, IOleDocumentSite) and
    (not FAllowActiveDoc or (csDesigning in ComponentState)) then Exit;
  if GetInterface(iid, obj) then Result := S_OK;
end;

function TCustomOleContainer._Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
end;

procedure TCustomOleContainer.Run;
begin
  CheckObject;
  OleCheck(OleRun(FOleObject));
end;

function TCustomOleContainer.SaveObject: HResult;
var
  PersistStorage: IPersistStorage;
begin
  Result := S_OK;
  if FOleObject = nil then Exit;
  PersistStorage := FOleObject as IPersistStorage;
  OleCheck(OleSave(PersistStorage, FStorage, True));
  PersistStorage.SaveCompleted(nil);
  PersistStorage := nil;
  OleCheck(FStorage.Commit(STGC_DEFAULT));
  FModSinceSave := False;
end;

procedure TCustomOleContainer.SaveAsDocument(const FileName: string);
var
  TempStorage: IStorage;
  PersistStorage: IPersistStorage;
begin
  CheckObject;
  if FModSinceSave then SaveObject;
  FOleObject.QueryInterface(IPersistStorage, PersistStorage);
  if PersistStorage <> nil then
  begin
    OleCheck(StgCreateDocFile(PWideChar(WideString(Filename)), STGM_READWRITE
      or STGM_SHARE_EXCLUSIVE or STGM_CREATE, 0, TempStorage));
    OleCheck(OleSave(PersistStorage, TempStorage, False));
    PersistStorage.SaveCompleted(nil);
  end;
end;

procedure TCustomOleContainer.SaveToFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TCustomOleContainer.SaveToStream(Stream: TStream);
var
  TempLockBytes: ILockBytes;
  TempStorage: IStorage;
  DataHandle: HGlobal;
  Buffer: Pointer;
  Header: TStreamHeader;
  R: TRect;
begin
  CheckObject;
  if FModSinceSave then SaveObject;
  if FCopyOnSave then
  begin
    OleCheck(CreateILockBytesOnHGlobal(0, True, TempLockBytes));
    OleCheck(StgCreateDocfileOnILockBytes(TempLockBytes, STGM_READWRITE
      or STGM_SHARE_EXCLUSIVE or STGM_CREATE, 0, TempStorage));
    OleCheck(FStorage.CopyTo(0, nil, nil, TempStorage));
    OleCheck(TempStorage.Commit(STGC_DEFAULT));
    OleCheck(GetHGlobalFromILockBytes(TempLockBytes, DataHandle));
  end else
    OleCheck(GetHGlobalFromILockBytes(FLockBytes, DataHandle));
  if FOldStreamFormat then
  begin
    R := BoundsRect;
    Header.PartRect.Left := R.Left;
    Header.PartRect.Top := R.Top;
    Header.PartRect.Right := R.Right;
    Header.PartRect.Bottom := R.Bottom;
  end else
  begin
    Header.Signature := StreamSignature;
    Header.DrawAspect := FDrawAspect;
  end;
  Header.DataSize := GlobalSize(DataHandle);
  Stream.WriteBuffer(Header, SizeOf(Header));
  Buffer := GlobalLock(DataHandle);
  try
    Stream.WriteBuffer(Buffer^, Header.DataSize);
  finally
    GlobalUnlock(DataHandle);
  end;
end;

procedure TCustomOleContainer.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    AdjustBounds;
    Invalidate;
  end;
end;

procedure TCustomOleContainer.SetDrawAspect(Iconic: Boolean;
  IconMetaPict: HGlobal);
var
  OleCache: IOleCache;
  EnumStatData: IEnumStatData;
  OldAspect, AdviseFlags, Connection: Longint;
  TempMetaPict: HGlobal;
  FormatEtc: TFormatEtc;
  Medium: TStgMedium;
  ClassID: TCLSID;
  StatData: TStatData;
begin
  OldAspect := FDrawAspect;
  if Iconic then
  begin
    FDrawAspect := DVASPECT_ICON;
    AdviseFlags := ADVF_NODATA;
  end else
  begin
    FDrawAspect := DVASPECT_CONTENT;
    AdviseFlags := ADVF_PRIMEFIRST;
  end;
  if (FDrawAspect <> OldAspect) or (FDrawAspect = DVASPECT_ICON) then
  begin
    OleCache := FOleObject as IOleCache;
    if FDrawAspect <> OldAspect then
    begin
      OleCheck(OleCache.EnumCache(EnumStatData));
      if EnumStatData <> nil then
        while EnumStatData.Next(1, StatData, nil) = 0 do
          if StatData.formatetc.dwAspect = OldAspect then
            OleCache.Uncache(StatData.dwConnection);
      FillChar(FormatEtc, SizeOf(FormatEtc), 0);
      FormatEtc.dwAspect := FDrawAspect;
      FormatEtc.lIndex := -1;
      OleCheck(OleCache.Cache(FormatEtc, AdviseFlags, Connection));
      SetViewAdviseSink(True);
    end;
    if FDrawAspect = DVASPECT_ICON then
    begin
      TempMetaPict := 0;
      if IconMetaPict = 0 then
      begin
        OleCheck(FOleObject.GetUserClassID(ClassID));
        TempMetaPict := OleGetIconOfClass(ClassID, nil, True);
        IconMetaPict := TempMetaPict;
      end;
      try
        FormatEtc.cfFormat := CF_METAFILEPICT;
        FormatEtc.ptd := nil;
        FormatEtc.dwAspect := DVASPECT_ICON;
        FormatEtc.lIndex := -1;
        FormatEtc.tymed := TYMED_MFPICT;
        Medium.tymed := TYMED_MFPICT;
        Medium.hMetaFilePict := IconMetaPict;
        Medium.unkForRelease := nil;
        OleCheck(OleCache.SetData(FormatEtc, Medium, False));
      finally
        DestroyMetaPict(TempMetaPict);
      end;
    end;
    if FDrawAspect = DVASPECT_CONTENT then UpdateObject;
    UpdateView;
  end;
end;

procedure TCustomOleContainer.SetFocused(Value: Boolean);
var
  R: TRect;
begin
  if FFocused <> Value then
  begin
    FFocused := Value;
    if GetUpdateRect(Handle, PRect(nil)^, False) then
      Invalidate
    else
    begin
      R := ClientRect;
      InflateRect(R, -GetBorderWidth, -GetBorderWidth);
      Canvas.DrawFocusRect(R);
    end;
  end;
end;

procedure TCustomOleContainer.SetIconic(Value: Boolean);
begin
  if GetIconic <> Value then
  begin
    CheckObject;
    SetDrawAspect(Value, 0);
  end;
end;

procedure TCustomOleContainer.SetSizeMode(Value: TSizeMode);
begin
  if FSizeMode <> Value then
  begin
    FSizeMode := Value;
    AdjustBounds;
    Invalidate;
  end;
end;

procedure TCustomOleContainer.SetUIActive(Active: Boolean);
var
  Form: TCustomForm;
begin
  try
    FUIActive := Active;
    Form := GetParentForm(Self);
    if Form <> nil then
      if Active then
      begin
        if (Form.ActiveOleControl <> nil) and
          (Form.ActiveOleControl <> Self) then
          Form.ActiveOleControl.Perform(CM_UIDEACTIVATE, 0, 0);
        Form.ActiveOleControl := Self;
        SetFocus;
        if Assigned(FOnActivate) then FOnActivate(Self);
      end else
      begin
        if Form.ActiveOleControl = Self then Form.ActiveOleControl := nil;
        if Form.ActiveControl = Self then Windows.SetFocus(Handle);
        DestroyAccelTable;
        if Assigned(FOnDeactivate) then FOnDeactivate(Self);
      end;
  except
    Application.HandleException(Self);
  end;
end;

procedure TCustomOleContainer.SetViewAdviseSink(Enable: Boolean);
var
  ViewObject: IViewObject;
  AdviseSink: IAdviseSink;
begin
  if FOleObject.QueryInterface(IViewObject, ViewObject) <> 0 then Exit;
  if Enable then AdviseSink := Self else AdviseSink := nil;
  ViewObject.SetAdvise(FDrawAspect, 0, AdviseSink);
end;

procedure TCustomOleContainer.UpdateObject;
begin
  if FOleObject <> nil then
  begin
    OleCheck(FOleObject.Update);
    Changed;
  end;
end;

procedure TCustomOleContainer.UpdateObjectRect;
var
  P: TPoint;
  R: TRect;
begin
  if FDocObj and (FDocView <> nil) then
    FDocView.SetRect(ClientRect)
  else
  begin
    P := Parent.ScreenToClient(ClientOrigin);
    R := Rect(P.X, P.Y, P.X + ClientWidth, P.Y + ClientHeight);
    if FOleInPlaceObject <> nil then
      FOleInPlaceObject.SetObjectRects(R, Rect(-16384, -16384, 16383, 16383));
  end;
end;

procedure TCustomOleContainer.UpdateVerbs;
var
  EnumOleVerb: IEnumOleVerb;
  OleVerb: TOleVerb;
  VerbInfo: TVerbInfo;
begin
  CheckObject;
  DestroyVerbs;
  FObjectVerbs := TStringList.Create;
  if FOleObject.EnumVerbs(EnumOleVerb) = 0 then
  begin
    while (EnumOleVerb.Next(1, OleVerb, nil) = 0) and
      (OleVerb.lVerb >= 0) and
      (OleVerb.grfAttribs and OLEVERBATTRIB_ONCONTAINERMENU <> 0) do
    begin
      VerbInfo.Verb := OleVerb.lVerb;
      VerbInfo.Flags := OleVerb.fuFlags;
      FObjectVerbs.AddObject(OleVerb.lpszVerbName, TObject(VerbInfo));
    end;
  end;
end;

procedure TCustomOleContainer.UpdateView;
var
  ViewObject2: IViewObject2;
begin
  if Succeeded(FOleObject.QueryInterface(IViewObject2, ViewObject2)) then
  begin
    ViewObject2.GetExtent(FDrawAspect, -1, nil, FViewSize);
    AdjustBounds;
  end;
  Invalidate;
  Changed;
end;

procedure TCustomOleContainer.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then
  begin
    AdjustBounds;
    Invalidate;
  end;
  inherited;
end;

procedure TCustomOleContainer.CMDocWindowActivate(var Message: TMessage);
begin
  if Assigned(FDocForm) and IsFormMDIChild(FDocForm.Form) then
  begin
    FOleInPlaceActiveObject.OnDocWindowActivate(LongBool(Message.WParam));
    if Message.WParam = 0 then
    begin
      FFrameForm.SetMenu(0, 0, 0);
      FFrameForm.ClearBorderSpace;
    end;
  end;
end;

procedure TCustomOleContainer.CMUIDeactivate(var Message: TMessage);
begin
  if (GetParentForm(Self).ActiveOleControl = Self) and (FOleInPlaceObject <> nil) then
    FOleInPlaceObject.UIDeactivate;
end;

procedure TCustomOleContainer.WMKillFocus(var Message: TWMSetFocus);
begin
  inherited;
  SetFocused(False);
end;

procedure TCustomOleContainer.WMSetFocus(var Message: TWMSetFocus);
var Window:HWnd;
begin
  inherited;
  if FUIActive and (FOleInPlaceObject.GetWindow(Window)=0) then
    Windows.SetFocus(Window)
  else SetFocused(True);
end;

procedure TCustomOleContainer.WMSize(var Message: TWMSize);
begin
  inherited;
  if not (csLoading in ComponentState) and Assigned(FOnResize) then
    FOnResize(Self);
  if not FDocObj or not FUIActive then Invalidate;
end;

procedure TCustomOleContainer.WMWindowPosChanged(var Message: TWMWindowPosChanged);
var
  R: TRect;
begin
  R := BoundsRect;
  inherited;
  if FUIActive and not EqualRect(BoundsRect, R) then UpdateObjectRect;
end;

{ TCustomOleForm.IOleForm }

procedure TCustomOleForm.OnDestroy;
var I:Integer;
begin
  for I:=FContainers.Count-1 downto 0 do
    TCustomOleContainer(FContainers[I]).DestroyObject;
end;

procedure TCustomOleForm.OnResize;
var BorderRect: TRect;
    SizeChanged:boolean;
begin
  SizeChanged:=((FForm.ClientWidth<>FSaveWidth)or(FForm.ClientHeight<>FSaveHeight));
  if (FActiveObject<>nil)and(FForm.WindowState<>wsMinimized)and SizeChanged then begin
    GetBorder(BorderRect);
    FActiveObject.ResizeBorder(BorderRect, Self, True);
    FSaveWidth:=FForm.ClientWidth;
    FSaveHeight:=FForm.ClientHeight;
  end;
end;

{ TCustomOleForm.ICustomOleForm }

procedure TCustomOleForm.ForcedResize;
begin
  FSaveWidth:=FForm.ClientWidth+1; //���������� ��������� ResizeBorder
  OnResize;
end;

{ TCustomOleForm.IOleInPlaceFrame }

function TCustomOleForm.GetWindow(out wnd: HWnd): HResult;
begin
  wnd := FForm.Handle;
  Result := S_OK;
end;

function TCustomOleForm.ContextSensitiveHelp(fEnterMode: BOOL): HResult;
begin
  Result := S_OK;
end;

function TCustomOleForm.GetBorder(out BorderRect: TRect): HResult;
var
  I: Integer;
  Control: TControl;
begin
  Result := S_OK;
  BorderRect := FForm.ClientRect;
  for I := 0 to FForm.ControlCount - 1 do
  begin
    Control := FForm.Controls[I];
    if Control.Visible and not IsSpacer(Control) and
      not IsToolControl(Control) then
      case Control.Align of
        alLeft: Inc(BorderRect.Left, Control.Width);
        alRight: Dec(BorderRect.Right, Control.Width);
        alTop: Inc(BorderRect.Top, Control.Height);
        alBottom: Dec(BorderRect.Bottom, Control.Height);
      end;
  end;
end;

function TCustomOleForm.RequestBorderSpace(const borderwidths: TRect): HResult;
var I:Integer;
begin
  Result:=S_OK;
  if (FForm is TForm) and (TForm(FForm).FormStyle=fsMDIForm) then Exit;
  for I:=0 to FForm.ControlCount-1 do
    with FForm.Controls[I] do
      if Visible and (Align=alClient) then Exit;
  Result:=INPLACE_E_NOTOOLSPACE;
end;

function TCustomOleForm.SetBorderSpace(pborderwidths: PRect): HResult;
type
  PRectArray = ^TRectArray;
  TRectArray = array[0..3] of Integer;
const
  Alignments: array[0..3] of TAlign = (alLeft, alTop, alRight, alBottom);
var
  I, J, Size: Integer;
  Control, Spacer: TControl;
begin
  Result := S_OK;
  if (pborderwidths = nil) then Exit;
  Result := RequestBorderSpace(pBorderWidths^);
  if Result <> S_OK then Exit;
  FForm.DisableAlign;
  for I := 0 to FForm.ControlCount - 1 do begin
    Control := FForm.Controls[I];
    if IsToolControl(Control) then begin
      Control.Visible := False;
      FHiddenControls.Add(Control);
    end;
  end;
  for I:=0 to 3 do begin
    Size := PRectArray(pBorderWidths)^[I];
    if Size>0 then begin
      Spacer:=FSpacers[I];
      if Spacer=nil then begin
        Spacer := TControl.Create(FForm);
        if I < 2 then J := 10000 else J := -10000;
        if Odd(I) then Spacer.Top := J else Spacer.Left := J;
        Spacer.Align := Alignments[I];
        Spacer.Parent := FForm;
        FSpacers[I] := Spacer;
      end;
      if Odd(I) then Spacer.Height:=Size else Spacer.Width:=Size;
    end;
  end;
  FForm.EnableAlign;
  Result:=S_OK;
end;

function TCustomOleForm.SetActiveObject(const ActiveObject: IOleInPlaceActiveObject;
  pszObjName: POleStr): HResult;
var
  Window, ParentWindow: HWnd;
begin
  Result := S_OK;
  FActiveObject := ActiveObject;
  if FActiveObject = nil then Exit;
  if FActiveObject.GetWindow(Window) = 0 then
    while True do
    begin
      ParentWindow := GetParent(Window);
      if ParentWindow = 0 then Break;
      if FindControl(ParentWindow) <> nil then
      begin
        SetWindowPos(Window, HWND_TOP, 0, 0, 0, 0,
          SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
        Break;
      end;
      Window := ParentWindow;
    end;
  FSaveWidth := FForm.ClientWidth;
  FSaveHeight := FForm.ClientHeight;
end;

function TCustomOleForm.InsertMenus(hmenuShared: HMenu;
  var menuWidths: TOleMenuGroupWidths): HResult;
var
  Menu: TMainMenu;
begin
  Menu := FForm.Menu;
  if Menu <> nil then
    Menu.PopulateOle2Menu(hmenuShared, [0, 2, 4], menuWidths.width);
  Result := S_OK;
end;

function TCustomOleForm.SetMenu(hmenuShared: HMenu; holemenu: HMenu;
  hwndActiveObject: HWnd): HResult;
var
  Menu: TMainMenu;
begin
  Menu := FForm.Menu;
  Result := S_OK;
  if Menu <> nil then
  begin
    Menu.SetOle2MenuHandle(hmenuShared);
    Result := OleSetMenuDescriptor(holemenu, Menu.WindowHandle,
      hwndActiveObject, nil, nil);
  end;
end;

function TCustomOleForm.RemoveMenus(hmenuShared: HMenu): HResult;
begin
  while GetMenuItemCount(hmenuShared) > 0 do
    RemoveMenu(hmenuShared, 0, MF_BYPOSITION);
  Result := S_OK;
end;

function TCustomOleForm.SetStatusText(pszStatusText: POleStr): HResult;
begin
  FForm.Hint := pszStatusText;
//  Application.Hint := pszStatusText;  // goes away too soon
  Result := S_OK;
end;

function TCustomOleForm.EnableModeless(fEnable: BOOL): HResult;
begin
  Result := S_OK;
end;

function TCustomOleForm.TranslateAccelerator(var msg: TMsg; wID: Word): HResult;
var
  Menu: TMainMenu;
begin
  Menu := FForm.Menu;
  if (Menu <> nil) and Menu.DispatchCommand(wID) then
    Result := S_OK else
    Result := S_FALSE;
end;

{ TCustomOleForm }

constructor TCustomOleForm.Create(Form: TCustomForm);
begin
  inherited Create;
  FForm := Form;
  FContainers := TList.Create;
  FHiddenControls := TList.Create;
  FForm.OleFormObject := Self;
end;

destructor TCustomOleForm.Destroy;
begin
  if FForm <> nil then FForm.OleFormObject := nil;
  FHiddenControls.Free;
  FContainers.Free;
  inherited Destroy;
end;

procedure TCustomOleForm.ClearBorderSpace;
var
  I: Integer;
begin
  FForm.DisableAlign;
  for I := 0 to 3 do
  begin
    FSpacers[I].Free;
    FSpacers[I] := nil;
  end;
  for I := 0 to FHiddenControls.Count - 1 do
    TControl(FHiddenControls[I]).Visible := True;
  FHiddenControls.Clear;
  FForm.EnableAlign;
end;

function TCustomOleForm.IsSpacer(Control: TControl): Boolean;
var
  I: Integer;
begin
  for I := 0 to 3 do
    if Control = FSpacers[I] then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

function TCustomOleForm.IsToolControl(Control: TControl): Boolean;
begin
  Result := Control.Visible and
    (Control.Align in [alTop, alBottom, alLeft, alRight]) and
    (Control.Perform(CM_ISTOOLCONTROL, 0, 0) <> 0);
end;

procedure TCustomOleForm.AddContainer(Instance: TOleContainer);
begin
  FContainers.Add(Instance);
end;

procedure TCustomOleForm.AddCustomContainer(Instance: TCustomOleContainer);
begin
  FContainers.Add(Instance);
end;

procedure TCustomOleForm.RemoveContainer(Instance: TOleContainer);
begin
  FContainers.Remove(Instance);
end;

procedure TCustomOleForm.RemoveCustomContainer(Instance: TCustomOleContainer);
begin
  FContainers.Remove(Instance);
end;

function TCustomOleForm.Form:TCustomForm;
begin
  Result:=FForm;
end;

{ Initialization }

procedure Initialize;
var
  DC: HDC;
begin
  DC := GetDC(0);
  PixPerInch.X := GetDeviceCaps(DC, LOGPIXELSX);
  PixPerInch.Y := GetDeviceCaps(DC, LOGPIXELSY);
  ReleaseDC(0, DC);
  CFObjectDescriptor := RegisterClipboardFormat('Object Descriptor');
  CFEmbeddedObject := RegisterClipboardFormat('Embedded Object');
  CFLinkSource := RegisterClipboardFormat('Link Source');
  DataFormats[0].cfFormat := CFEmbeddedObject;
  DataFormats[0].dwAspect := DVASPECT_CONTENT;
  DataFormats[0].lIndex := -1;
  DataFormats[0].tymed := TYMED_ISTORAGE;
  DataFormats[1].cfFormat := CFObjectDescriptor;
  DataFormats[1].dwAspect := DVASPECT_CONTENT;
  DataFormats[1].lIndex := -1;
  DataFormats[1].tymed := TYMED_HGLOBAL;
end;

procedure Register;
begin
  RegisterComponents('Advanced Controls', [TCustomOleContainer]);
end;

initialization
  OleInitialize(nil);
  Initialize;
finalization
  OleUninitialize;
end.

