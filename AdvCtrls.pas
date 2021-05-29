unit AdvCtrls;

interface

uses
  Windows,Classes,TntStdCtrls,TntExtCtrls,Messages,Graphics,Controls,
  TntButtons,SysUtils,ExtCtrls,TntComCtrls, ComCtrls,TntControls,DB;

type
  TAlignedEdit=class(TTntEdit)
  published
    property Align;
  end;

  TFadeableEdit=class(TAlignedEdit)
  private
    FInactClr:TColor;
    FColor:TColor;
    FAFC:TColor;
    FIFC:TColor;
    procedure SetColor(C:TColor);
    procedure SetInactClr(C:TColor);
    procedure SetActFntClr(C:TColor);
    procedure SetInactFntClr(C:TColor);
    procedure UpdateLook;
  protected
    procedure SetEnabled(Value: Boolean); override;
    //procedure WMPaint(var Message:TWMPaint); message WM_PAINT;
  public
    constructor Create(AOwner:TComponent); override;
  published
    property InactiveColor:TColor read FInactClr write SetInactClr;
    property ActiveFontColor:TColor read FAFC write SetActFntClr;
    property InactiveFontColor:TColor read FIFC write SetInactFntClr;
    property Color:TColor read FColor write SetColor;
  end;

  {ѕоле ввода с заголовком}
  TTitledBox=class(TTntPanel)
  private
    FTitlePanel:TTntPanel;
    function GetCaptionWidth:Integer;
    procedure SetCaptionWidth(Value:Integer);
    function GetCaption: TWideCaption;
    procedure SetCaption(const Value: TWideCaption);
    function GetCaptionAlign:TAlignment;
    procedure SetCaptionAlign(Value:TAlignment);
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
  published
    property CaptionWidth:Integer read GetCaptionWidth write SetCaptionWidth;
    property Caption: TWideCaption read GetCaption write SetCaption;
    property CaptionAlignment:TAlignment read GetCaptionAlign write SetCaptionAlign;
  end;

  TInputMode=(imDefault, imExtLatin, imGreek);

  TSpecCharEdit=class(TFadeableEdit)
  private
    FInputMode:TInputMode;
    procedure SetInputMode(Value:TInputMode);
    procedure SwitchInputMode;
  protected
    procedure KeyDown(var Key:Word; Shift:TShiftState); override;
  public
    property InputMode:TInputMode read FInputMode write SetInputMode;
  end;

  TAlignedSpeedButton=class(TTntSpeedButton)
  private
    FMouseInControl:boolean;
  protected
    procedure WndProc(var Msg:TMessage); override;
  published
    property Align;
  end;

  TAlignedBitBtn=class(TTntBitBtn)
  published
    property Align;
  end;

  TBlinkingSpeedButton=class(TAlignedSpeedButton)
  private
    FTimer:TTimer;
    FGlyph,FAlterGlyph:TBitmap;
    FAltGlyphAct:boolean;
    procedure GlyphChange(Sender:TObject);
    procedure SetBlink(Value:boolean);
    procedure SetInterval(Value:Integer);
    procedure SetGlyph(Value:TBitmap);
    procedure SetAlterGlyph(Value:TBitmap);
    procedure TimerTick(Sender:TObject);
    procedure UpdateGlyphs;
    function GetBlink:boolean;
    function GetInterval:Integer;
  published
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    property Blink:boolean read GetBlink write SetBlink;
    property BlinkInterval:Integer read GetInterval write SetInterval;
    property Glyph:TBitmap read FGlyph write SetGlyph;
    property AlterGlyph: TBitmap read FAlterGlyph write SetAlterGlyph;
  end;

  TAlignedComboBox=class(TTntComboBox)
  published
    constructor Create(AOwner:TComponent); override;
    property Align;
  end;

  TDBAlignedComboBox=class(TAlignedComboBox)
  private
    FValueFieldName:WideString;
    FTextFieldName:WideString;
    FValueFieldType:TFieldType;
    FTextFieldType:TFieldType;
    procedure SetSelectedValue(Value:Variant);
    procedure SetValue(i:Integer; Value:Variant);
    function GetSelectedValue:Variant;
    function GetSelectedText:WideString;
    function GetValue(i:Integer):Variant;
  public
    constructor Create(AOwner:TComponent); override;
    procedure Clear; override;
    procedure Load(DataSet:TDataSet; ValueFieldName, TextFieldName:WideString);
    procedure InsertItem(Index:Integer; Value:OleVariant; AText:WideString);
    property Value[i:Integer]:Variant read GetValue write SetValue;
    property SelectedValue:Variant read GetSelectedValue write SetSelectedValue;
    property SelectedText:WideString read GetSelectedText;
    property ValueFieldName:WideString read FValueFieldName;
    property TextFieldName:WideString read FTextFieldName;
    property ValueFieldType:TFieldType read FValueFieldType;
    property TextFieldType:TFieldType read FTextFieldType;
  end;

  TScrollListBox=class(TTntListBox)
  private
    procedure WMMouseWheel(var Msg:TMessage); message WM_MOUSEWHEEL;
  end;

  TLinkPanel=class(TTntPanel)
  private
    //FPrevMIC:boolean;
    FMouseInControl:boolean;
    FAFColor:TColor;
    FIFColor:TColor;
  protected
    procedure WndProc(var Msg:TMessage); override;
  published
    constructor Create(AOwner:TComponent); override;
    property ActiveFontColor:TColor read FAFColor write FAFColor;
    property InactiveFontColor:TColor read FIFColor write FIFColor;
  end;

  TFadeablePanel=class(TTntPanel)
  protected
    procedure Paint; override;
    procedure SetEnabled(Value: Boolean); override;
  end;

  TAlignedCheckBox=class(TTntCheckBox)
  published
    property Align;
  end;

  TAlignedDateTimePicker=class(TTntDateTimePicker)
  published
    property Align;
  end;

  TOnGetFullMonthInfoEvent = procedure(Sender: TObject; Year:Word; Month:Byte;
    var MonthBoldInfo: LongWord) of object;

  {»справленный TMonthCalendar
   ¬ отличие от оригинала, передаЄт номер года и правильный номер мес€ца в
   событии OnGetMonthInfo}
  TModMonthCalendar = class(TMonthCalendar)
  private
    FOnGetMonthInfo: TOnGetFullMonthInfoEvent;
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
  published
    property OnGetMonthInfo: TOnGetFullMonthInfoEvent read FOnGetMonthInfo write FOnGetMonthInfo;
  end;

  TOkCancelPanel = class(TTntPanel)
  private
    FOkButton:TTntButton;
    FCancelButton:TTntButton;
    FOkButtonEnabled:Boolean;
    function GetOnOkClick:TNotifyEvent;
    function GetOnCancelClick:TNotifyEvent;
    function GetOkButtonCaption:WideString;
    function GetCancelButtonCaption:WideString;
    function GetModalBehaviour:boolean;
    function GetOkButtonEnabled:boolean;
    procedure SetOkButtonEnabled(Value:boolean);
    procedure SetOnOkClick(Value:TNotifyEvent);
    procedure SetOnCancelClick(Value:TNotifyEvent);
    procedure SetOkButtonCaption(Value:WideString);
    procedure SetCancelButtonCaption(Value:WideString);
    procedure SetModalBehaviour(Value:boolean);
    procedure AlignButtons;
    function GetBtnsWidth:Integer;
    procedure SetBtnsWidth(Value:Integer);
    function GetBtnsHeight:Integer;
    procedure SetBtnsHeight(Value:Integer);
    procedure SetButtonsEnabledState;
  protected
    procedure Resize; override;
    procedure CreateWnd; override;
    procedure SetEnabled(Value: Boolean); override;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
  published
    property OnOkClick:TNotifyEvent read GetOnOkClick write SetOnOkClick;
    property OnCancelClick:TNotifyEvent read GetOnCancelClick write SetOnCancelClick;
    property OkButtonCaption:WideString read GetOkButtonCaption write SetOkButtonCaption;
    property OkButtonEnabled:boolean read GetOkButtonEnabled write SetOkButtonEnabled;
    property CancelButtonCaption:WideString read GetCancelButtonCaption write SetCancelButtonCaption;
    property ModalBehaviour:boolean read GetModalBehaviour write SetModalBehaviour;
    property ButtonsWidth:Integer read GetBtnsWidth write SetBtnsWidth;
    property ButtonsHeight:Integer read GetBtnsHeight write SetBtnsHeight;
  end;
  
procedure Register;

implementation

uses
  TntWindows, TntSysUtils, TntGraphics, Forms, CommCtrl, DesignIntf, ACCommon,
  Variants;

procedure Register;
begin
  RegisterComponents('Advanced Controls', [TAlignedEdit, TFadeableEdit,
    TTitledBox,
    TSpecCharEdit, TAlignedComboBox, TAlignedBitBtn, TAlignedSpeedButton,
    TAlignedCheckBox, TScrollListBox, TLinkPanel, TFadeablePanel,
    TBlinkingSpeedButton, TAlignedDateTimePicker, TModMonthCalendar,
    TOkCancelPanel, TDBAlignedComboBox]);
  RegisterPropertyEditor(TypeInfo(TWideCaption), TOkCancelPanel, 'Caption', nil);
end;

{=========================== TFadeableEdit ==============================}

constructor TFadeableEdit.Create(AOwner:TComponent);
begin
  inherited;
  FColor:=inherited Color;
  FInactClr:=clBtnFace;
  FAFC:=Font.Color;
  FIFC:=clGray;
end;

procedure TFadeableEdit.UpdateLook;
begin
  if Enabled then begin
    inherited Color:=FColor;
    Font.Color:=FAFC;
  end
  else begin
    inherited Color:=FInactClr;
    Font.Color:=FIFC;
  end;
  Invalidate;
end;

procedure TFadeableEdit.SetInactClr(C:TColor);
begin
  FInactClr:=C;
  UpdateLook;
end;

procedure TFadeableEdit.SetColor(C:TColor);
begin
  FColor:=C;
  UpdateLook;
end;

procedure TFadeableEdit.SetEnabled(Value:boolean);
begin
  inherited;
  UpdateLook;
end;

procedure TFadeableEdit.SetActFntClr(C:TColor);
begin
  FAFC:=C;
  UpdateLook;
end;

procedure TFadeableEdit.SetInactFntClr(C:TColor);
begin
  FIFC:=C;
  UpdateLook;
end;

{procedure TFadeableEdit.WMPaint(var Message:TWMPaint);
var MCanvas:TControlCanvas;
    DrawBounds:TRect;
begin
  inherited;
  if Ctl3D then Exit;
  MCanvas:=TControlCanvas.Create;
  DrawBounds:=ClientRect;
  try
   MCanvas.Control:=Self;
   if Enabled then MCanvas.Brush.Color:=FAFC else MCanvas.Brush.Color:=FIFC;
   MCanvas.FrameRect(DrawBounds);
   InflateRect(DrawBounds,-1,-1);
   if Enabled then MCanvas.Brush.Color:=FColor else MCanvas.Brush.Color:=FInactClr;
   MCanvas.FrameRect(DrawBounds);
  finally
    MCanvas.Free;
  end;
end;}

{=========================== TAlignedComboBox ==============================}

constructor TAlignedComboBox.Create(AOwner:TComponent);
begin
  inherited;
  Font.Name:='Arial Unicode MS';
end;

{========================== TDBAlignedComboBox =============================}

constructor TDBAlignedComboBox.Create(AOwner:TComponent);
begin
  inherited;
  FValueFieldName := '';
  FTextFieldName  := '';
  FValueFieldType := ftUnknown;
  FTextFieldType  := ftUnknown;
end;

procedure TDBAlignedComboBox.SetValue(i:Integer; Value:Variant);
begin
  PVariant(Items.Objects[i])^ := Value;
end;

function TDBAlignedComboBox.GetValue(i:Integer):Variant;
begin
  Result := PVariant(Items.Objects[i])^;
end;

procedure TDBAlignedComboBox.SetSelectedValue(Value:Variant);
var i:Integer;
begin
  ItemIndex := -1;
  for i:=0 to ItemCount-1 do
    if PVariant(Items.Objects[i])^ = Value then begin
      ItemIndex := i;
      Exit;
    end;
end;

function TDBAlignedComboBox.GetSelectedValue:Variant;
begin
  if ItemIndex >= 0 then Result := PVariant(Items.Objects[ItemIndex])^ else Result := Null;
end;

function TDBAlignedComboBox.GetSelectedText:WideString;
begin
  if ItemIndex >= 0 then Result := Items[ItemIndex] else Result := '';
end;

procedure TDBAlignedComboBox.Clear;
var i:Integer;
begin
  for i:=0 to ItemCount-1 do
    if Items.Objects[i]<>nil then begin
      Dispose(PVariant(Items.Objects[i]));
      Items.Objects[i]:=nil;
    end;
  inherited;
end;

procedure TDBAlignedComboBox.Load(DataSet:TDataSet; ValueFieldName, TextFieldName:WideString);
var VP:PVariant;
    Txt:WideString;
begin
  FValueFieldName := ValueFieldName;
  FTextFieldName := TextFieldName;
  Clear;
  if DataSet.IsEmpty then Exit;
  FValueFieldType := DataSet.FieldDefs.Find(ValueFieldName).DataType;
  FTextFieldType := DataSet.FieldDefs.Find(TextFieldName).DataType;
  DataSet.First;
  while not DataSet.Eof do begin
    New(VP);
    VP^ := DataSet.FieldByName(ValueFieldName).Value;
    Txt := AutoStringField(DataSet.FieldByName(TextFieldName));
    AddItem(Txt, Pointer(VP));
    DataSet.Next;
  end;
end;

procedure TDBAlignedComboBox.InsertItem(Index:Integer; Value:OleVariant; AText:WideString);
var VP:PVariant;
begin
  New(VP);
  VP^ := Value;
  Items.InsertObject(Index, AText, Pointer(VP));
end;

{=========================== TScrollListBox ==============================}

procedure TScrollListBox.WMMouseWheel(var Msg:TMessage);
var i:SmallInt;
begin
  i:=HiWord(Msg.wParam); // оличество пикселей прокрутки
  i:=(2*i)div(WHEEL_DELTA+2);
  i:=i*3;
  TopIndex:=TopIndex-i;
end;

{=========================== TLinkPanel ==============================}

procedure TLinkPanel.WndProc(var Msg:TMessage);
var P:TPoint;
begin
  case Msg.Msg Of
    WM_MOUSEMOVE, WM_NCMOUSEMOVE:
    begin
      inherited;
      MouseCapture:=True;
      if not FMouseInControl then begin
        if Enabled and (DragMode<>dmAutomatic) then begin //эмул€ци€ CM_MOUSEENTER
          FMouseInControl:=True;
          MouseCapture:=True;
          Font.Color:=FAFColor;
          Repaint;
          Perform(CM_MOUSEENTER, 0, 0);
        end;
      end;
      P:=Point(Msg.LParamLo, Msg.LParamHi); //координаты курсора
      if not PtInRect(ClientRect,P) then begin
        if FMouseInControl and Enabled and (not Dragging) then begin //эмул€ци€ CM_MOUSELEAVE
          MouseCapture:=False;
          FMouseInControl:=False;
          Font.Color:=FIFColor;
          Invalidate;
          Perform(CM_MOUSELEAVE, 0, 0);
        end;
      end;
    end;
  else
    inherited;
  end;
end;

(*
procedure TLinkPanel.WndProc(var Msg:TMessage);
var MIC:boolean;
begin
  inherited;
  if (Msg.Msg<>WM_MOUSEMOVE)and(Msg.Msg<>WM_NCMOUSEMOVE) then Exit;
  MIC:=PtInRect(ClientRect,Point(Msg.LParamLo,Msg.LParamHi)); //Mouse In Control
  if (MIC<>FPrevMIC)and Enabled then begin
    FPrevMIC:=MIC;
    if MIC then Font.Color:=FAFColor else Font.Color:=FIFColor;
    if MIC {and (DragMode<>dmAutomatic)} then MouseCapture:=True;
    if not(MIC or Dragging) then MouseCapture:=False;
    Invalidate;
  end;
end;
*)

constructor TLinkPanel.Create(AOwner:TComponent);
begin
  inherited;
  FAFColor:=clBlue;
  FIFColor:=clWindowText;
  Font.Style:=[fsUnderline];
  Cursor:=crHandPoint;
  FMouseInControl:=False;
  //FPrevMIC:=False;
end;

{========================== TFadeablePanel =======================}

procedure TFadeablePanel.Paint;
const Alignments: array[TAlignment] of Longint = (DT_LEFT, DT_RIGHT, DT_CENTER);
var Rect: TRect;
    TopColor, BottomColor: TColor;
    FontHeight: Integer;
    Flags: Longint;

  procedure AdjustColors(Bevel: TPanelBevel);
  begin
    TopColor := clBtnHighlight;
    if Bevel = bvLowered then TopColor := clBtnShadow;
    BottomColor := clBtnShadow;
    if Bevel = bvLowered then BottomColor := clBtnHighlight;
  end;

begin
  if (not Win32PlatformIsUnicode) then inherited
  else begin
    Rect := GetClientRect;
    if BevelOuter<>bvNone then begin
      AdjustColors(BevelOuter);
      Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
    end;
    {$IFDEF COMPILER_7_UP}
    if ThemeServices.ThemesEnabled and ParentBackground then
      InflateRect(Rect, -BorderWidth, -BorderWidth)
    else
    {$ENDIF}
    begin
      Frame3D(Canvas, Rect, Color, Color, BorderWidth);
    end;
    if BevelInner <> bvNone then begin
      AdjustColors(BevelInner);
      Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
    end;
    with Canvas do begin
      {$IFDEF COMPILER_7_UP}
      if not ThemeServices.ThemesEnabled or not ParentBackground then
      {$ENDIF}
      begin
        Brush.Color := Color;
        FillRect(Rect);
      end;
      Brush.Style := bsClear;
      Font := Self.Font;
      FontHeight := WideCanvasTextHeight(Canvas, 'W');
      with Rect do begin
        Top := ((Bottom + Top) - FontHeight) div 2;
        Bottom := Top + FontHeight;
      end;
      Flags := DT_EXPANDTABS or DT_VCENTER or Alignments[Alignment];
      Flags := DrawTextBiDiModeFlags(Flags);
      if Enabled then Tnt_DrawTextW(Handle, PWideChar(Caption), -1, Rect, Flags)
      else begin
        OffsetRect(Rect, 1, 1);
        Canvas.Font.Color := clBtnHighlight;
        Tnt_DrawTextW(Handle, PWideChar(Caption), -1, Rect, Flags);
        OffsetRect(Rect, -1, -1);
        Canvas.Font.Color := clBtnShadow;
        Tnt_DrawTextW(Handle, PWideChar(Caption), -1, Rect, Flags);
      end;
    end;
  end;
end;

procedure TFadeablePanel.SetEnabled(Value: Boolean);
begin
  inherited;
  Invalidate;
end;

{============================= TTitledBox ===============================}

constructor TTitledBox.Create(AOwner:TComponent);
begin
  inherited;
  BorderWidth:=5;
  Height:=34;
  FTitlePanel:=TTntPanel.Create(Self);
  with FTitlePanel do begin
    Parent:=Self;
    Align:=alLeft;
    BevelOuter:=bvNone;
    Width:=50;
    BorderWidth:=2;
    Caption:=inherited Caption;
  end;
  inherited Caption:='';
end;

destructor TTitledBox.Destroy;
begin
  FTitlePanel.Free;
  inherited;
end;

function TTitledBox.GetCaptionWidth:Integer;
begin
  Result:=FTitlePanel.Width;
end;

procedure TTitledBox.SetCaptionWidth(Value:Integer);
begin
  FTitlePanel.Width:=Value;
end;

function TTitledBox.GetCaption: TWideCaption;
begin
  Result:=FTitlePanel.Caption;
end;

procedure TTitledBox.SetCaption(const Value: TWideCaption);
begin
  FTitlePanel.Caption:=Value;
end;

function TTitledBox.GetCaptionAlign:TAlignment;
begin
  Result:=FTitlePanel.Alignment;
end;

procedure TTitledBox.SetCaptionAlign(Value:TAlignment);
begin
  FTitlePanel.Alignment:=Value;
end;

{============================= TSpecCharEdit =============================}

{procedure TWinControl.WMKeyDown(var Message: TWMKeyDown);
begin
  if not DoKeyDown(Message) then inherited;
end;

procedure TWinControl.WMSysKeyDown(var Message: TWMKeyDown);
begin
  if not DoKeyDown(Message) then inherited;
end;

function TWinControl.DoKeyDown(var Message: TWMKey): Boolean;
var
  ShiftState: TShiftState;
  Form: TCustomForm;
begin
  Result := True;
  Form := GetParentForm(Self);
  if (Form <> nil) and (Form <> Self) and Form.KeyPreview and
    TWinControl(Form).DoKeyDown(Message) then Exit;
  with Message do
  begin
    ShiftState := KeyDataToShiftState(KeyData);
    if not (csNoStdEvents in ControlStyle) then
    begin
      KeyDown(CharCode, ShiftState);
      if CharCode = 0 then Exit;
    end;
  end;
  Result := False;
end;}

procedure TSpecCharEdit.SetInputMode(Value:TInputMode);
begin
  FInputMode:=Value;
end;

procedure TSpecCharEdit.SwitchInputMode;
begin
  case FInputMode of
    imDefault:  FInputMode:=imExtLatin;
    imExtLatin: FInputMode:=imGreek;
    imGreek:    FInputMode:=imDefault;
  end;
end;

procedure TSpecCharEdit.KeyDown(var Key:Word; Shift:TShiftState);
var C:Word;
begin
  C:=0;
  if (ssAlt in Shift)and(ssCtrl in Shift)and(ssCtrl in Shift) then begin
    SwitchInputMode;
    Exit;
  end;
  if FInputMode=imExtLatin then begin
    {—делать реакцию на Caps Lock}
    if ssShift in Shift then begin
      case Key of
        65: C:=$C4;
        79: C:=$D6;
        83: C:=$DF;
        85: C:=$DC;
      end;
    end
    else begin
      case Key of
        65: C:=$E4;
        79: C:=$F6;
        83: C:=$DF;
        85: C:=$FC;
      end;
    end;
  end;
  if FInputMode=imGreek then begin
    {—делать реакцию на Caps Lock}
    if ssShift in Shift then begin
      case Key of
        65: C:=$C4;
        79: C:=$D6;
        83: C:=$DF;
        85: C:=$DC;
      end;
    end
    else begin
      case Key of
        65: C:=$E4;
        79: C:=$F6;
        83: C:=$DF;
        85: C:=$FC;
      end;
    end;
  end;
  if C>0 then begin SendMessage(Handle, WM_CHAR, C, 0); Key:=0; end;
  //if C=0 then inherited KeyDown(Key, Shift);
end;

{======================== TBlinkingBitBtn =========================}

constructor TBlinkingSpeedButton.Create(AOwner:TComponent);
begin
  inherited;
  FTimer:=TTimer.Create(Self);
  FTimer.Enabled:=False;
  FTimer.Interval:=500;
  FTimer.OnTimer:=TimerTick;
  FGlyph:=TBitmap.Create;
  FAlterGlyph:=TBitmap.Create;
  FAltGlyphAct:=False;
  FGlyph.OnChange:=GlyphChange;
  FAlterGlyph.OnChange:=GlyphChange;
  FMouseInControl:=False;
end;

destructor TBlinkingSpeedButton.Destroy;
begin
  FTimer.Enabled:=False;
  FTimer.OnTimer:=nil;
  FTimer.Free;
  FGlyph.Free;
  FAlterGlyph.Free;
  inherited;
end;

procedure TBlinkingSpeedButton.SetBlink(Value:boolean);
begin
  FTimer.Enabled:=Value;
  if not Value then begin
    FAltGlyphAct:=False;
    UpdateGlyphs;
  end;
end;

function TBlinkingSpeedButton.GetBlink:boolean;
begin
  Result:=FTimer.Enabled;
end;

procedure TBlinkingSpeedButton.SetInterval(Value:Integer);
begin
  FTimer.Interval:=Value;
end;

function TBlinkingSpeedButton.GetInterval:Integer;
begin
  Result:=FTimer.Interval;
end;

procedure TBlinkingSpeedButton.UpdateGlyphs;
begin
  if FAltGlyphAct then inherited Glyph:=FAlterGlyph
    else inherited Glyph:=FGlyph;
end;

procedure TBlinkingSpeedButton.SetGlyph(Value:TBitmap);
begin
  FGlyph.Assign(Value);
  UpdateGlyphs;
end;

procedure TBlinkingSpeedButton.SetAlterGlyph(Value:TBitmap);
begin
  FAlterGlyph.Assign(Value);
  UpdateGlyphs;
end;

procedure TBlinkingSpeedButton.TimerTick(Sender:TObject);
begin
  if csDesigning in ComponentState then Exit;
  FAltGlyphAct:=not FAltGlyphAct;
  UpdateGlyphs;
end;

procedure TBlinkingSpeedButton.GlyphChange(Sender:TObject);
begin
  UpdateGlyphs;
end;

{====================== TAlignedSpeedButton =======================}

procedure TAlignedSpeedButton.WndProc(var Msg:TMessage);
var P:TPoint;
begin
  case Msg.Msg Of
    WM_MOUSEMOVE, WM_NCMOUSEMOVE:
    begin
      inherited;
      if csDesigning in ComponentState then Exit;
      MouseCapture:=True;
      if not FMouseInControl then begin
        if Enabled and (DragMode<>dmAutomatic) then begin //эмул€ци€ CM_MOUSEENTER
          FMouseInControl:=True;
          MouseCapture:=True;
          Perform(CM_MOUSEENTER, 0, 0);
        end;
      end;
      P:=Point(Msg.LParamLo, Msg.LParamHi); //координаты курсора
      if not PtInRect(ClientRect,P) then begin
        if FMouseInControl and Enabled and (not Dragging) then begin //эмул€ци€ CM_MOUSELEAVE
          MouseCapture:=False;
          FMouseInControl:=False;
          Perform(CM_MOUSELEAVE, 0, 0)
        end;
      end;
    end;
  else
    inherited;
  end;
end;

{========================= TModMonthCalendar ==================================}

{function IsBlankSysTime(const ST: TSystemTime): Boolean;
type
  TFast = array [0..3] of DWORD;
begin
  Result := (TFast(ST)[0] or TFast(ST)[1] or TFast(ST)[2] or TFast(ST)[3]) = 0;
end;}

procedure TModMonthCalendar.CNNotify(var Message: TWMNotify);
var
//  ST: PSystemTime;
  I, MonthNo, YearNo: Integer;
  CurState: PMonthDayState;
begin
  case Message.NMHdr^.code of
    MCN_GETDAYSTATE:
      with PNmDayState(Message.NMHdr)^ do begin
        FillChar(prgDayState^, cDayState * SizeOf(TMonthDayState), 0);
        if Assigned(FOnGetMonthInfo) then begin
          CurState := prgDayState;
          for I := 0 to cDayState - 1 do begin
            MonthNo := stStart.wMonth + I;
            YearNo  := stStart.wYear;
            if MonthNo > 12 then begin
              YearNo := YearNo + Trunc(Abs(MonthNo-1)) div 12;
              MonthNo := MonthNo - (Trunc(Abs(MonthNo-1)) div 12)*12;
            end;
            FOnGetMonthInfo(Self, YearNo, MonthNo, CurState^);
            Inc(CurState);
          end;
        end;
      end;
{      MCN_SELECT, MCN_SELCHANGE:
        begin
          ST := @PNMSelChange(Message.NMHdr).stSelStart;
          if not IsBlankSysTime(ST^) then
            DateTime := SystemTimeToDateTime(ST^);
          if MultiSelect then
          begin
            ST := @PNMSelChange(Message.NMHdr).stSelEnd;
            if not IsBlankSysTime(ST^) then
              EndDate := SystemTimeToDateTime(ST^);
          end;
        end;}
  end;
  inherited;
end;

{=============================== TOkCancelPanel ==============================}

constructor TOkCancelPanel.Create(AOwner:TComponent);
begin
  inherited;
  FOkButtonEnabled := True;
  FOkButton := TTntButton.Create(Self);
  with FOkButton do begin
    Parent := Self;
    Name := 'FOkButton';
    Caption := 'Ok';
    ModalResult := mrOk;
    Default := True;
  end;
  FCancelButton := TTntButton.Create(Self);
  with FCancelButton do begin
    Parent := Self;
    Name := 'FCancelButton';
    Caption := 'Cancel';
    ModalResult := mrCancel;
    Cancel := True;
  end;
end;

destructor TOkCancelPanel.Destroy;
begin
  FOkButton.Free;
  FOkButton:=nil;
  FCancelButton.Free;
  FCancelButton:=nil;
  inherited;
end;

function TOkCancelPanel.GetOnOkClick:TNotifyEvent;
begin
  Result:=FOkButton.OnClick;
end;

procedure TOkCancelPanel.SetOnOkClick(Value:TNotifyEvent);
begin
  FOkButton.OnClick:=Value;
end;

function TOkCancelPanel.GetOnCancelClick:TNotifyEvent;
begin
  Result:=FCancelButton.OnClick;
end;

procedure TOkCancelPanel.SetOnCancelClick(Value:TNotifyEvent);
begin
  FCancelButton.OnClick:=Value;
end;

function TOkCancelPanel.GetOkButtonCaption:WideString;
begin
  Result:=FOkButton.Caption;
end;

procedure TOkCancelPanel.SetOkButtonCaption(Value:WideString);
begin
  FOkButton.Caption:=Value;
end;

function TOkCancelPanel.GetCancelButtonCaption:WideString;
begin
  Result:=FCancelButton.Caption;
end;

procedure TOkCancelPanel.SetCancelButtonCaption(Value:WideString);
begin
  FCancelButton.Caption:=Value;
end;

function TOkCancelPanel.GetModalBehaviour:boolean;
begin
  Result:=(FOkButton.ModalResult<>mrNone)or(FCancelButton.ModalResult<>mrNone);
end;

procedure TOkCancelPanel.SetModalBehaviour(Value:boolean);
begin
  if Value then begin
    FOkButton.ModalResult:=mrOk;
    FCancelButton.ModalResult:=mrCancel;
  end
  else begin
    FOkButton.ModalResult:=mrNone;
    FCancelButton.ModalResult:=mrNone;
  end;
end;

procedure TOkCancelPanel.AlignButtons;
const Gap:Integer=10;
var FHW,FHH:Integer;
begin
  FHW:=ClientWidth div 2;
  FHH:=ClientHeight div 2;
  FOkButton.Left:=FHW-FOkButton.Width-Gap;
  FOkButton.Top:=FHH-(FOkButton.Height div 2);
  FCancelButton.Left:=FHW+Gap;
  FCancelButton.Top:=FHH-(FCancelButton.Height div 2);
  inherited;
end;

procedure TOkCancelPanel.Resize;
begin
  AlignButtons;
  inherited;
end;

procedure TOkCancelPanel.CreateWnd;
begin
  inherited;
  inherited Caption:='';
  AlignButtons;
end;

function TOkCancelPanel.GetBtnsWidth:Integer;
begin
  Result:=FOkButton.Width;
end;

procedure TOkCancelPanel.SetBtnsWidth(Value:Integer);
begin
  FOkButton.Width:=Value;
  FCancelButton.Width:=Value;
  AlignButtons;
end;

function TOkCancelPanel.GetBtnsHeight:Integer;
begin
  Result:=FOkButton.Height;
end;

procedure TOkCancelPanel.SetBtnsHeight(Value:Integer);
begin
  FOkButton.Height:=Value;
  FCancelButton.Height:=Value;
  AlignButtons;
end;

function TOkCancelPanel.GetOkButtonEnabled:boolean;
begin
  Result := FOkButtonEnabled;
end;

procedure TOkCancelPanel.SetOkButtonEnabled(Value:boolean);
begin
  FOkButtonEnabled := Value;
  SetButtonsEnabledState;
end;

procedure TOkCancelPanel.SetButtonsEnabledState;
begin
  FOkButton.Enabled := Enabled and FOkButtonEnabled;
  FCancelButton.Enabled := Enabled;
end;

procedure TOkCancelPanel.SetEnabled(Value: Boolean);
begin
  inherited;
  SetButtonsEnabledState;
end;

end.

