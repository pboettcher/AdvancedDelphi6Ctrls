unit CharPick;

interface

uses
  Windows, TntGrids, Classes, Graphics, TntStdCtrls, TntExtCtrls, Forms,
  StdCtrls, ExtCtrls;

type
  TGlyphRanges = class
  private
    FList:TList;
    function GetCount:Integer;
    function GetItem(i:Integer):TWCRange;
    function GetCharCount:Integer;
    procedure SetItem(i:Integer; Value:TWCRange);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure DeleteItem(Index:Integer);
    function AddItem(Value:TWCRange):Integer;
    function InRange(Character:WideChar):boolean; overload;
    function InRange(Code:Word):boolean; overload;
    property Items[i:Integer]:TWCRange read GetItem write SetItem; default;
    property Count:Integer read GetCount;
    property CharCount:Integer read GetCharCount;
  end;
  
  TCharPickGrid = class(TTntStringGrid)
  private
    FGlyphRanges:TGlyphRanges;
    FStartChar:Word;
    FStopChar:Word;
    FRearrangeLevel: LongInt;
    FReaTimer: TTimer;
    FLikenessSample: WideString;
    FLikenessChars: WideString;
    function GetColCount:Integer;
    function GetRowCount:Integer;
    function GetDefColWidth:Integer;
    function GetDefRowHeight:Integer;
    function GetCharCount:Integer;
    procedure SetDefColWidth(Value:Integer);
    procedure SetDefRowHeight(Value:Integer);
    procedure SetStartChar(Value:Word);
    procedure GetFontRanges;
    procedure RearrangeTick(Sender: TObject);
    procedure SetLikenessSample(const Value: WideString);
    function CharIsLikeSample(CharCode: Word): Boolean;
    procedure UpdateLikenessSamples(const Value: WideString);
    procedure SetStopChar(const Value: Word);
  protected
    procedure Resize; override;
    procedure CreateWnd; override;
    procedure FillGrid; virtual;
  public
    procedure Rearrange;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    property RowCount:Integer read GetRowCount;
    property ColCount:Integer read GetColCount;
    property StartChar:Word read FStartChar write SetStartChar;
    property StopChar:Word read FStopChar write SetStopChar;
    property CharCount:Integer read GetCharCount;
    property LikenessSample: WideString read FLikenessSample write SetLikenessSample;
  published
    property DefaultColWidth:Integer read GetDefColWidth write SetDefColWidth;
    property DefaultRowHeight:Integer read GetDefRowHeight write SetDefRowHeight;
  end;

  TCharPickFavorites = class(TCharPickGrid)
  private
    FCharsList:WideString;
    procedure SetCharsList(Value:WideString);
  protected
    procedure FillGrid; override;
  public
    constructor Create(AOwner:TComponent); override;
    property CharsList:WideString read FCharsList write SetCharsList;
  end;

  TCharPickerField = class(TTntPanel)
  private
    FGrid:TCharPickGrid;
    FScrollBar:TTntScrollBar;
    procedure GridResize(Sender:TObject);
    procedure SBScroll(Sender:TObject; ScrollCode:TScrollCode; var ScrollPos:Integer);
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
  end;

  TCharPicker=class(TTntPanel)
  private
    FField:TCharPickerField;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
  end;

procedure Register;

implementation

uses Controls, Grids, SysUtils, Dialogs;

procedure Register;
begin
  RegisterComponents('Advanced Controls', [TCharPickGrid,TCharPicker,TCharPickerField]);
end;

function Limit(Value,Min,Max:Integer):Integer;
begin
  if Value<Min then Value:=Min;
  if Value>Max then Value:=Max;
  Result:=Value;
end;

procedure TCharPickGrid.RearrangeTick(Sender: TObject);
begin
  FReaTimer.Enabled := False;
  Rearrange;
end;

constructor TCharPickGrid.Create(AOwner:TComponent);
begin
  inherited;
  Name := 'TCharPickGrid';
  FRearrangeLevel := 0;
  inherited RowCount := 500;
  inherited ColCount := 16;
  inherited DefaultColWidth := 30;
  inherited DefaultRowHeight := 30;
  Font.Name := 'Arial Unicode MS';
  Font.Style := [fsBold];
  Font.Height := inherited DefaultRowHeight;
  FStartChar := 32;
  FStopChar := 65535;
  FixedCols := 0;
  FixedRows := 0;
  Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine,
    goDrawFocusSelected];
  FGlyphRanges := TGlyphRanges.Create;
  FReaTimer := TTimer.Create(Self);
  FReaTimer.Enabled := False;
  FReaTimer.Interval := 100;
  FReaTimer.OnTimer := RearrangeTick;
  FLikenessSample:='';
  FLikenessChars:='';
end;

destructor TCharPickGrid.Destroy;
begin
  FReaTimer.Free;
  FGlyphRanges.Free;
  inherited;
end;

procedure ErrMsg(Msg,Caption:String; Handle:LongWord);
begin
  MessageBox(Handle, PChar(Msg), PChar(Caption), MB_OK or MB_ICONERROR);
end;

procedure TCharPickGrid.GetFontRanges;
type
  TRangesArray = array[0..(MaxInt div SizeOf(TWCRange))-1] of TWCRange;
  PRangesArray = ^TRangesArray;
var GS:PGlyphSet;
    GSSize:LongWord;
    i, RngLow, RngHigh: Integer;
    rng:TWCRange;
begin
  FGlyphRanges.Clear;
  GSSize := GetFontUnicodeRanges(Canvas.Handle, nil);
  GetMem(Pointer(GS), GSSize);
  try
    GS.cbThis:=GSSize;
    GS.flAccel:=0;
    GS.cGlyphsSupported:=0;
    GS.cRanges:=0;
    if GetFontUnicodeRanges(Canvas.Handle, GS)<>0 then begin
      for i:=0 to GS.cRanges-1 do begin
        rng := PRangesArray(@GS.ranges)[i];
        RngLow := Word(rng.wcLow);
        RngHigh := RngLow + rng.cGlyphs - 1;
        if RngHigh < FStartChar then Continue;
        if RngLow > FStopChar then Continue;
        if RngLow < FStartChar then begin
          RngLow := FStartChar;
          rng.wcLow := WideChar(FStartChar);
          rng.cGlyphs := RngHigh - RngLow + 1;
        end;
        if RngHigh > FStopChar then rng.cGlyphs := FStopChar - RngLow + 1;
        FGlyphRanges.AddItem(rng);
      end;
    end;
  finally
    FreeMem(Pointer(GS), GSSize);
  end;
end;

function TCharPickGrid.CharIsLikeSample(CharCode:Word):Boolean;
begin
  if FLikenessSample='' then begin
    Result := True;
    Exit;
  end
  else begin
  end;
end;

procedure TCharPickGrid.UpdateLikenessSamples(const Value: WideString);
var ls: WideString;
begin
  ls := WideLowerCase(Trim(Value));
  FLikenessSample := ls;
  if ls='a' then FLikenessChars:='aA';
end;

procedure TCharPickGrid.FillGrid;
var x,y,i,ri:Integer;
    Range:TWCRange;
    CharCode: Word;
begin
  GetFontRanges;
  x:=0;
  y:=0;
  for i:=0 to FGlyphRanges.Count-1 do begin
    Range:=FGlyphRanges[i];
    for ri:=0 to Range.cGlyphs-1 do begin
      CharCode := Word(Range.wcLow)+ri;
      if FLikenessSample<>'' then
        if not CharIsLikeSample(CharCode) then Continue;
      Cells[x,y]:=WideChar(CharCode);
      Inc(x);
      if x>=ColCount then begin
        x:=0;
        Inc(y);
      end;
    end;
  end;
end;

function TCharPickGrid.GetRowCount:Integer;
begin
  Result:=inherited RowCount;
end;

function TCharPickGrid.GetColCount:Integer;
begin
  Result:=inherited ColCount;
end;

procedure TCharPickGrid.Rearrange;
var i, def, CharCount, CalcCols: Integer;
begin
  if csLoading in ComponentState then Exit;
  if FRearrangeLevel<>0 then Exit;
  Inc(FRearrangeLevel);
  try
    GetFontRanges;
    //–ассчитать количество строк и столбцов
    CharCount := FGlyphRanges.GetCharCount;
    CalcCols := (ClientWidth div DefaultColWidth)-1;
    if CalcCols<1 then CalcCols:=1;
    if CharCount<CalcCols then begin
      inherited ColCount := CharCount;
      inherited RowCount := 1;
    end
    else begin
      inherited ColCount := CalcCols;
      if (CharCount mod CalcCols) > 0 then
        inherited RowCount := (CharCount div CalcCols) + 1
      else
        inherited RowCount := CharCount div CalcCols;
    end;
    //Ўирины и высоты €чеек
    def := DefaultColWidth;
    for i:=0 to inherited ColCount-1 do ColWidths[i]  := def;
    def := DefaultRowHeight;
    for i:=0 to inherited RowCount-1 do RowHeights[i] := def;
    FillGrid;
  finally
    Dec(FRearrangeLevel);
  end;
end;

procedure TCharPickGrid.Resize;
begin
  FReaTimer.Enabled := True;
  inherited Resize;
end;

function TCharPickGrid.GetDefColWidth:Integer;
begin
  Result:=inherited DefaultColWidth;
end;

procedure TCharPickGrid.SetDefColWidth(Value:Integer);
begin
  inherited DefaultColWidth:=Value;
  FReaTimer.Enabled := True;
end;

function TCharPickGrid.GetDefRowHeight:Integer;
begin
  Result:=inherited DefaultRowHeight;
end;

procedure TCharPickGrid.SetDefRowHeight(Value:Integer);
begin
  inherited DefaultRowHeight:=Value;
  Font.Height:=inherited DefaultRowHeight;
  FReaTimer.Enabled := True;
end;

procedure TCharPickGrid.CreateWnd;
begin
  inherited;
  //GetFontRanges;
  FReaTimer.Enabled := True;
end;

procedure TCharPickGrid.SetStartChar(Value:Word);
begin
  FStartChar:=Value;
  FReaTimer.Enabled := True;
  //FillGrid;
end;

procedure TCharPickGrid.SetStopChar(const Value: Word);
begin
  FStopChar := Value;
  FReaTimer.Enabled := True;
  //FillGrid;
end;

function TCharPickGrid.GetCharCount:Integer;
begin
  Result:=FGlyphRanges.CharCount;
end;

procedure TCharPickGrid.SetLikenessSample(const Value: WideString);
begin
  UpdateLikenessSamples(Value);
  FReaTimer.Enabled := True;
end;

{======================== TCharPickFavorites ==========================}

//    FCharsList:WideString;

constructor TCharPickFavorites.Create(AOwner:TComponent);
begin
  inherited;
end;

procedure TCharPickFavorites.FillGrid;
begin
end;

procedure TCharPickFavorites.SetCharsList(Value:WideString);
begin
end;

{======================== TCharPickerField ==========================}

constructor TCharPickerField.Create(AOwner:TComponent);
begin
  inherited;
  Name:='TCharPickerField';
  FGrid:=TCharPickGrid.Create(Self);
  FScrollBar:=TTntScrollBar.Create(Self);
  with FScrollBar do begin
    Name:='FScrollBar';
    Parent:=Self;
    Kind:=sbVertical;
    Align:=alRight;
    Min:=0;
    Position:=0;
    OnScroll:=SBScroll;
    Visible:=False;
  end;
  with FGrid do begin
    Name:='FGrid';
    Parent:=Self;
    Align:=alClient;
    ScrollBars:=ssVertical;
    Options:=[goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected];
    OnResize:=GridResize;
  end;
  FScrollBar.Max:=Limit((FGrid.CharCount div FGrid.ColCount)-FGrid.RowCount, 0, FGrid.RowCount);
  BevelInner:=bvNone;
  BevelOuter:=bvNone;
  Width:=300;
  Height:=150;
end;

destructor TCharPickerField.Destroy;
begin
  FScrollBar.Free;
  FGrid.Free;
  inherited;
end;

procedure TCharPickerField.GridResize(Sender:TObject);
begin
  FScrollBar.Max:=Limit((FGrid.CharCount div FGrid.ColCount)-FGrid.RowCount, 0, FGrid.RowCount);
end;

procedure TCharPickerField.SBScroll(Sender:TObject; ScrollCode:TScrollCode;
  var ScrollPos:Integer);
begin
  FGrid.StartChar:=(FScrollBar.Position*FGrid.ColCount)+32;
end;

{======================== TCharPicker =======================}

constructor TCharPicker.Create(AOwner:TComponent);
begin
  inherited;
  FField:=TCharPickerField.Create(Self);
  FField.Parent:=Self;
  FField.Align:=alClient;
end;

destructor TCharPicker.Destroy;
begin
  FField.Free;
  inherited;
end;

{=========================== TGlyphRanges ===========================}

function TGlyphRanges.GetCount:Integer;
begin
  Result:=FList.Count;
end;

function TGlyphRanges.GetItem(i:Integer):TWCRange;
begin
  if (i<0)or(i>=FList.Count) then raise ERangeError.CreateFmt(
      'TGlyphRanges: %d is not within the valid range of %d..%d',
      [i, 0, FList.Count-1]);
  Result:=PWCRange(FList[i])^;
end;

procedure TGlyphRanges.SetItem(i:Integer; Value:TWCRange);
begin
  if (i<0)or(i>=FList.Count) then raise ERangeError.CreateFmt(
      'TGlyphRanges: %d is not within the valid range of %d..%d',
      [i, 0, FList.Count-1]);
  PWCRange(FList[i])^:=Value;
end;

constructor TGlyphRanges.Create;
begin
  FList:=TList.Create;
end;

destructor TGlyphRanges.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

procedure TGlyphRanges.Clear;
var i:Integer;
begin
  for i:=0 to FList.Count-1 do
    if FList[i]<>nil then Dispose(PWCRange(FList[i]));
  FList.Clear;
end;

procedure TGlyphRanges.DeleteItem(Index:Integer);
begin
  if (Index<0)or(Index>=FList.Count) then raise ERangeError.CreateFmt(
      'TGlyphRanges: %d is not within the valid range of %d..%d',
      [Index, 0, FList.Count-1]);
  if FList[Index]<>nil then Dispose(PWCRange(FList[Index]));
  FList.Delete(Index);
end;

function TGlyphRanges.AddItem(Value:TWCRange):Integer;
var WR:PWCRange;
begin
  New(WR);
  WR^:=Value;
  Result:=FList.Add(WR);
end;

function TGlyphRanges.InRange(Character:WideChar):boolean;
var i:Integer;
    LowCode,HighCode,CharCode:Word;
begin
  Result:=False;
  CharCode:=Word(Character);
  for i:=0 to FList.Count-1 do begin
    LowCode:=Word(Items[i].wcLow);
    HighCode:=LowCode+Word(Items[i].cGlyphs)-1;
    if (CharCode>=LowCode)and(CharCode<=HighCode) then begin
      Result:=True;
      Exit;
    end;
  end;
end;

function TGlyphRanges.InRange(Code:Word):boolean;
var i:Integer;
    LowCode,HighCode:Word;
begin
  Result:=False;
  for i:=0 to FList.Count-1 do begin
    LowCode:=Word(Items[i].wcLow);
    HighCode:=LowCode+Word(Items[i].cGlyphs)-1;
    if (Code>=LowCode)and(Code<=HighCode) then begin
      Result:=True;
      Exit;
    end;
  end;
end;

function TGlyphRanges.GetCharCount:Integer;
var CC,i:Integer;
begin
  CC:=0;
  for i:=0 to FList.Count-1 do CC:=CC+Items[i].cGlyphs;
  Result:=CC;
end;

end.

