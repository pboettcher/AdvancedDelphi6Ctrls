unit CustomGrids;

interface

uses
  Windows,Messages,TntDBGrids,TntGrids,ExtCtrls,Classes,DBGrids,Grids,
  Graphics;

type
  TColumnTextEvent = procedure(Sender: TObject; Column: TTntColumn; var AText: WideString) of object;
  
  {Unicode-DBGrid с нормальной прокруткой мышью.
   Новая функциональность:
   - Прокрутка мышью с учётом скорости вращения колёсика
   - Окрашивание в InactiveColor при Enabled=False
   - Исправлена ошибка в OnDrawColumnCell}
  TScrollDBGrid=class(TTntDBGrid)
  private
    FColor:TColor;
    FInactColor:TColor;
    FOnColumnCellText: TColumnTextEvent;
    procedure WMMouseWheel(var Msg:TMessage); message WM_MOUSEWHEEL;
    procedure WMRButtonDown(var Msg:TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMKeyDown(var Msg:TWMKeyDown); message WM_KEYDOWN;
    procedure SetColor(Clr:TColor);
    procedure SetInactColor(Clr:TColor);
  protected
    procedure DrawColumnCell(const Rect:TRect; DataCol:Integer;
      Column:TColumn; State:TGridDrawState); override;
    {function HighlightCell(DataCol,DataRow:Integer; const Value:string;
      AState: TGridDrawState): Boolean; override;}
    procedure SetEnabled(Ena:boolean); override;
    function GetEnabled:boolean; override;
  public
    constructor Create(AOwner:TComponent); override;
    procedure DefaultDrawColumnCell(const Rect: TRect; DataCol: Integer;
      Column: TTntColumn; State: TGridDrawState); override;
    function DefaultGetColumnCellText(Column: TTntColumn): WideString;
    procedure DefaultDrawColumnCellText(const Rect: TRect;
      Column: TTntColumn; Value: WideString);
  published
    property Color:TColor read FColor write SetColor;
    property InactiveColor:TColor read FInactColor write SetInactColor;
    property OnColumnCellText: TColumnTextEvent read FOnColumnCellText write FOnColumnCellText;
  end;

  TColResizeEvent=procedure(Sender:TObject; ColIndex:Longint) of object;

  {Автоматическая подстройка ширины столбца:
   akCommon    - зависит от параметра AutoSizeKind таблицы
   akFixed     - фиксированный размер (изменяется пользователем)
   akPercent   - размер в процентах от ширины таблицы
   akFullWidth - подстройка по размеру наидлиннейшей строки
   akRest      - заполнение оставшегося пространства. может быть только у
                 одного столбца}
  TAutoSizeKind=(akCommon, akFixed, akPercent, akFullWidth, akRest);
  TGridAutoSizeKind=(gaFixed, gaPercent, gaFullWidth);

  TColPars=record
    AutoSizeKind:TAutoSizeKind;
    WidthPercent:byte;
  end;

  {Unicode-StringGrid с автоматической подстройкой ширины столбцов}
  TAutoSizeStringGrid=class(TTntStringGrid)
  private
    FColor:TColor;
    FInactColor:TColor;
    FOnColResize:TColResizeEvent;
    FMoveLevel:LongInt;
    FTimer:TTimer;
    FASK:TGridAutoSizeKind;
    FColPars:array of TColPars;
    FFollowRC:boolean;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMRButtonDown(var Msg:TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure TimerTick(Sender:TObject);
    procedure SetASK(ASK:TGridAutoSizeKind);
    function ColMaxWidth(ACol:Integer):Integer;
    procedure CalculateColWidths(PercentageOnly:boolean);
    function GetPollInt:LongWord;
    procedure SetPollInt(I:LongWord);
    function GetColAsk(Idx:LongInt):TAutoSizeKind;
    procedure SetColASK(Idx:LongInt; ASK:TAutoSizeKind);
    function GetColWP(Idx:LongInt):byte;
    procedure SetColWP(Idx:LongInt; WP:byte);
    procedure SetColCount(Value:LongInt);
    function GetColCount:LongInt;
    procedure SetColor(Clr:TColor);
    procedure SetInactColor(Clr:TColor);
  protected
    procedure Resize; override;
    procedure SetEnabled(Ena:boolean); override;
    function GetEnabled:boolean; override;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    property OnColResize:TColResizeEvent read FOnColResize write FOnColResize;
    property ColAutoSizes[Idx:LongInt]:TAutoSizeKind read GetColASK write SetColASK;
    property ColWidthPercents[Idx:LongInt]:byte read GetColWP write SetColWP;
    procedure PointerToCell(var ACol,ARow:Integer);
  published
    property AutoSizeKind:TGridAutoSizeKind read FASK write SetASK;
    property PollingInterval:LongWord read GetPollInt write SetPollInt;
    property ColCount:LongInt read GetColCount write SetColCount default 5;
    property FollowRightClick:boolean read FFollowRC write FFollowRC;
    property Color:TColor read FColor write SetColor;
    property InactiveColor:TColor read FInactColor write SetInactColor;
  end;

  TSortMarkerKind=(smNone, smAscending, smDescending);

  {Столбец с автоматической подстройкой ширины}
  TAutoSizeColumn=class(TTntColumn)
  private
    FASK:TAutoSizeKind;
    FWidthPercent:byte;
    FFitRest:boolean;
    FSortMarker:TSortMarkerKind;
    FWordWrap:boolean;
    procedure SetASK(ASK:TAutoSizeKind);
    procedure SetWidthPercent(WP:byte);
    procedure SetFitRest(FR:boolean);
    procedure SetSortMarker(SM:TSortMarkerKind);
    procedure SetWordWrap(Value:boolean);
  public
    constructor Create(Collection: TCollection); override;
  published
    property AutoSizeKind:TAutoSizeKind read FASK write SetASK;
    property WidthPercent:byte read FWidthPercent write SetWidthPercent;
    property FitRestSpace:boolean read FFitRest write SetFitRest;
    property SortMarker:TSortMarkerKind read FSortMarker write SetSortMarker;
    //Флаг переноса слов на следующую строчку. Пока это проект. Что если нам
    //надо переносить слова только в отдельной ячейке или отдельной строчке?
    property WordWrap:boolean read FWordWrap write SetWordWrap;
  end;

  TAutoSizeDBGrid=class;

  {Коллекция столбцов с автоподстройкой ширины}
  TDBAutoSizeColumns = class(TTntDBGridColumns)
  private
    function GetColumn(Index: Integer): TAutoSizeColumn;
    procedure SetColumn(Index: Integer; const Value: TAutoSizeColumn);
    function GetGrid:TAutoSizeDBGrid;
  protected
    procedure Update(Item:TCollectionItem); override;
  public
    function Add: TAutoSizeColumn;
    property Items[Index: Integer]:TAutoSizeColumn read GetColumn write SetColumn; default;
    property Grid:TAutoSizeDBGrid read GetGrid;
  end;

  {Unicode-DBGrid с автоматической подстройкой ширины столбцов}
  TAutoSizeDBGrid=class(TScrollDBGrid)
  private
    FASK:TGridAutoSizeKind;
    FTimer:TTimer;
    FAscMarker:TBitmap;
    FDescMarker:TBitmap;
    FAutoSizeLock:LongInt;
    FMAS:boolean;
    FPrevRecNo: Integer;
    FLinkUpdated: Boolean;
    procedure SetASK(ASK:TGridAutoSizeKind);
    function GetColumns: TDBAutoSizeColumns;
    procedure SetColumns(const Value:TDBAutoSizeColumns);
    procedure TimerTick(Sender:TObject);
    procedure DrawSortMarker(ARect:TRect);
    procedure LockAutoSize;
    procedure UnlockAutoSize;
    function InitSortMarker(SM:TSortMarkerKind):TBitmap;
  protected
    function CreateColumns: TDBGridColumns; override;
    procedure DrawCell(ACol,ARow:LongInt; ARect:TRect; AState:TGridDrawState); override;
    procedure LinkActive(Value: Boolean); override;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure AutoSizeColumns;
    procedure ClearSortMarkers;
    procedure Update; override;
  published
    property AutoSizeKind:TGridAutoSizeKind read FASK write SetASK;
    property Columns: TDBAutoSizeColumns read GetColumns write SetColumns stored False;
    property ManualAutoSize:boolean read FMAS write FMAS;
  end;

procedure Register;

implementation

uses
  DB, RTLConsts, StdCtrls, ACCommon, SysUtils, Controls, TntGraphics,
  TntWindows, TntDB, Math;

procedure Register;
begin
  RegisterComponents('Custom Grids',[TScrollDBGrid,TAutoSizeDBGrid,TAutoSizeStringGrid]);
end;

procedure InvalidOp(const id: string);
begin
  raise EInvalidGridOperation.Create(id);
end;

procedure ShowMessage(Msg:WideString);
begin
  MessageBoxW(0, PWideChar(Msg), 'CustomGrids', 0);
end;

var
  DrawBitmap: TBitmap = nil;

procedure WriteText(ACanvas: TCanvas; ARect: TRect; DX, DY: Integer;
  const Text: WideString; Alignment: TAlignment; ARightToLeft: Boolean);
const
  AlignFlags : array [TAlignment] of Integer =
    ( DT_LEFT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_RIGHT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX );
  RTL: array [Boolean] of Integer = (0, DT_RTLREADING);
var
  B, R: TRect;
  Hold, Left: Integer;
  I: TColorRef;
begin
  I := ColorToRGB(ACanvas.Brush.Color);
  if GetNearestColor(ACanvas.Handle, I) = I then
  begin                       { Use ExtTextOutW for solid colors }
    { In BiDi, because we changed the window origin, the text that does not
      change alignment, actually gets its alignment changed. }
    if (ACanvas.CanvasOrientation = coRightToLeft) and (not ARightToLeft) then
      ChangeBiDiModeAlignment(Alignment);
    case Alignment of
      taLeftJustify:
        Left := ARect.Left + DX;
      taRightJustify:
        Left := ARect.Right - WideCanvasTextWidth(ACanvas, Text) - 3;
    else { taCenter }
      Left := ARect.Left + (ARect.Right - ARect.Left) div 2
        - (WideCanvasTextWidth(ACanvas, Text) div 2);
    end;
    WideCanvasTextRect(ACanvas, ARect, Left, ARect.Top + DY, Text);
  end
  else begin                  { Use FillRect and Drawtext for dithered colors }
    DrawBitmap.Canvas.Lock;
    try
      with DrawBitmap, ARect do { Use offscreen bitmap to eliminate flicker and }
      begin                     { brush origin tics in painting / scrolling.    }
        Width := Max(Width, Right - Left);
        Height := Max(Height, Bottom - Top);
        R := Rect(DX, DY, Right - Left - 1, Bottom - Top - 1);
        B := Rect(0, 0, Right - Left, Bottom - Top);
      end;
      with DrawBitmap.Canvas do
      begin
        Font := ACanvas.Font;
        Font.Color := ACanvas.Font.Color;
        Brush := ACanvas.Brush;
        Brush.Style := bsSolid;
        FillRect(B);
        SetBkMode(Handle, TRANSPARENT);
        if (ACanvas.CanvasOrientation = coRightToLeft) then
          ChangeBiDiModeAlignment(Alignment);
        Tnt_DrawTextW(Handle, PWideChar(Text), Length(Text), R,
          AlignFlags[Alignment] or RTL[ARightToLeft]);
      end;
      if (ACanvas.CanvasOrientation = coRightToLeft) then  
      begin
        Hold := ARect.Left;
        ARect.Left := ARect.Right;
        ARect.Right := Hold;
      end;
      ACanvas.CopyRect(ARect, DrawBitmap.Canvas, B);
    finally
      DrawBitmap.Canvas.Unlock;
    end;
  end;
end;

{========================= TScrollDBGrid =========================}

constructor TScrollDBGrid.Create(AOwner:TComponent);
begin
  inherited;
  FColor:=clWindow;
  FInactColor:=clBtnFace;
  Options:=[dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines,
    dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit];
end;

procedure TScrollDBGrid.WMMouseWheel(var Msg:TMessage);
var i:SmallInt;
    Key:Integer;
begin
  i:=SmallInt(HiWord(LongWord(Msg.wParam))); //Количество строк прокрутки
  if i>0 then Key:=VK_UP else begin Key:=VK_DOWN; i:=i*-1; end;
  i:=(2*i)div(WHEEL_DELTA+2);
  repeat //Чем быстрее вращаем колесо, тем на большее количество строк прокручиваем
    SendMessage(Handle,WM_KEYDOWN,Key,0);
    Dec(i);
  until i<=0;
end;

procedure TScrollDBGrid.WMRButtonDown(var Msg:TWMRButtonDown);
begin
  SelectedRows.Clear;
  inherited;
end;

procedure TScrollDBGrid.WMKeyDown(var Msg:TWMKeyDown);
//var OldRow:Integer;
begin
(*
  if Msg.CharCode=VK_UP then begin
    OldRow:=Row;
    if TopRow>1 then begin
      Self.TopRow:=TopRow-1;
      Self.Repaint;
    end;
    Self.ScrollActiveToRow(OldRow);
    Msg.CharCode:=0;
  end;
  if Msg.CharCode=VK_DOWN then begin
    OldRow:=Row;
    Self.TopRow:=TopRow+1;
    Self.Repaint;
    Self.ScrollActiveToRow(OldRow);
    Msg.CharCode:=0;
  end;
*)
  inherited;
end;

procedure TScrollDBGrid.SetEnabled(Ena:boolean);
begin
  inherited;
  if Ena then inherited Color:=FColor else inherited Color:=FInactColor;
end;

function TScrollDBGrid.GetEnabled:boolean;
begin
  Result:=inherited GetEnabled;
end;

procedure TScrollDBGrid.SetColor(Clr:TColor);
begin
  FColor:=Clr;
  if inherited Enabled then inherited Color:=FColor else inherited Color:=FInactColor;
end;

procedure TScrollDBGrid.SetInactColor(Clr:TColor);
begin
  FInactColor:=Clr;
  if inherited Enabled then inherited Color:=FColor else inherited Color:=FInactColor;
end;

procedure TScrollDBGrid.DrawColumnCell(const Rect: TRect; DataCol: Integer;
  Column: TColumn; State: TGridDrawState);
begin
  {Исправляем ошибку TDBGrid:
   При нескольких отмеченных ячейках отмеченные ячейки не обозначаются как
   gdSelected в обработчике OnDrawColumnCell.
   Если отрисовываемая в данный момент ячейка находится в Bookmark'ах,
   добавляем gdSelected в State}
  if not Focused then begin
    //Exclude(State,gdSelected);
    SelectedRows.Clear;
  end;
  if (SelectedRows.IndexOf(DataSource.DataSet.Bookmark)>=0)and Focused then Include(State,gdSelected);
  inherited DrawColumnCell(Rect,DataCol,Column,State);
end;

{function TScrollDBGrid.HighlightCell(DataCol, DataRow: Integer;
  const Value: string; AState: TGridDrawState): Boolean;
begin
  Result:=inherited HighlightCell(DataCol, DataRow, Value, AState) and Focused;
end;}

function TScrollDBGrid.DefaultGetColumnCellText(Column: TTntColumn): WideString;
begin
  Result := '';
  if Assigned(Column.Field) then
    Result := GetWideDisplayText(Column.Field);
  if Assigned(FOnColumnCellText) then
    FOnColumnCellText(Self, Column, Result);
end;

procedure TScrollDBGrid.DefaultDrawColumnCellText(const Rect: TRect;
  Column: TTntColumn; Value: WideString);
begin
  WriteText(Canvas, Rect, 2, 2, Value, Column.Alignment,
    UseRightToLeftAlignmentForField(Column.Field, Column.Alignment));
end;

procedure TScrollDBGrid.DefaultDrawColumnCell(const Rect: TRect;
  DataCol: Integer; Column: TTntColumn; State: TGridDrawState);
var
  Value: WideString;
begin
  Value := DefaultGetColumnCellText(Column);
  DefaultDrawColumnCellText(Rect, Column, Value);
end;

{===================== TAutoSizeStringGrid =======================}

constructor TAutoSizeStringGrid.Create(AOwner:TComponent);
begin
  inherited;
  FColor:=clWindow;
  FInactColor:=clBtnFace;
  FFollowRC:=False;
  SetLength(FColPars,ColCount);
  FTimer:=TTimer.Create(Self);
  FTimer.Enabled:=False;
  FTimer.Interval:=500;
  FTimer.OnTimer:=TimerTick;
  FTimer.Enabled:=True;
  FOnColResize:=nil;
  FMoveLevel:=0;
end;

destructor TAutoSizeStringGrid.Destroy;
begin
  FTimer.Free;
  Finalize(FColPars);
  inherited;
end;

{Нужно при перетаскивании границы изменять размеры двух смежных ячеек}
procedure TAutoSizeStringGrid.WMMouseMove(var Message:TWMMouseMove);
{var CP:TPoint;
    LB:boolean;
    ACol,ARow:Integer;
    LeftSide:boolean;
    R:TRect;}
begin
  inherited;
{  if FMoveLevel<>0 then Exit;
  if (csNoStdEvents in ControlStyle) then Exit;
  Inc(FMoveLevel);
  LB:=(Message.Keys and MK_LBUTTON)>0;
  CP:=CalcCursorPos;
  MouseToCell(CP.X,CP.Y,ACol,ARow);
  if (ARow>=0)and(ARow<Self.FixedRows)and LB then begin
    R:=CellRect(ACol,ARow);
    LeftSide:=(CP.X>=R.Left)and(CP.X<((R.Left+R.Right)div 2)); //Находится ли курсор на левой или на правой границе колонки
    if LeftSide then Dec(ACol);
    ColWidths[ACol]:=CP.X-R.Left;
    Update;
    Cells[0,0]:=IntToStr(ACol);
    if Assigned(FOnColResize) then FOnColResize(Self,ACol);
  end;
  Dec(FMoveLevel);}
end;

function TAutoSizeStringGrid.ColMaxWidth(ACol:Integer):Integer;
var i,MW:integer;
    WS:WideString;
    Size:TSize;
begin
  Result:=20;
  if (ACol<0)or(ACol>=ColCount) then Exit;
  MW:=20;
  for i:=TopRow to TopRow+VisibleRowCount-1 do begin
    WS:=Cells[ACol,i];
    if GetTextExtentPoint32W(Canvas.Handle,PWideChar(WS),Length(WS),Size) then
      if Size.cx+5>=MW then MW:=Size.cx+5;
  end;
  WS:=Cells[ACol,0];
  if GetTextExtentPoint32W(Canvas.Handle,PWideChar(WS),Length(WS),Size) then
    if Size.cx+5>=MW then MW:=Size.cx+5;
  Result:=MW;
end;

procedure TAutoSizeStringGrid.CalculateColWidths(PercentageOnly:boolean);
var i,RestCol,ICW:integer;
    ASK:TAutoSizeKind;
begin
  RestCol:=-1;
  for i:=LeftCol to LeftCol+VisibleColCount-1 do begin
    ASK:=FColPars[i].AutoSizeKind;
    if FColPars[i].AutoSizeKind=akCommon then
      case FASK of
        gaFixed:     ASK:=akFixed;
        gaPercent:   ASK:=akPercent;
        gaFullWidth: ASK:=akFullWidth;
      end;
    case ASK of
      akFixed:;
      akPercent:   ColWidths[i]:=(ClientWidth*FColPars[i].WidthPercent)div 100;
      akFullWidth: if not PercentageOnly then ColWidths[i]:=ColMaxWidth(i);
      akRest: RestCol:=i;
    end;
    if ColWidths[i]<20 then ColWidths[i]:=20;
  end;
  if RestCol>0 then begin
    ICW:=0;
    for i:=0 to ColCount-1 do
      if i<>RestCol then ICW:=ICW+ColWidths[i];
    if (ICW+20)<=ClientWidth then ColWidths[RestCol]:=ClientWidth-ICW-2;
    if ColWidths[RestCol]<20 then ColWidths[RestCol]:=20;
  end;
end;

procedure TAutoSizeStringGrid.Resize;
begin
  inherited;
  {Для ускорения отрисовки пересчитываем ширину только тех колонок,
   у которых размер в процентах от ширины таблицы}
  CalculateColWidths(True);
  Invalidate;
end;

procedure TAutoSizeStringGrid.TimerTick(Sender:TObject);
begin
  FTimer.Enabled:=False; //На случай если пересчёт задержится
  CalculateColWidths(False); //Пересчитываем ширину всех колонок
  FTimer.Enabled:=True;
end;

procedure TAutoSizeStringGrid.SetASK(ASK:TGridAutoSizeKind);
begin
  FASK:=ASK;
  Update;
end;

function TAutoSizeStringGrid.GetPollInt:LongWord;
begin
  if FTimer<>nil then Result:=FTimer.Interval else Result:=500;
end;

procedure TAutoSizeStringGrid.SetPollInt(I:LongWord);
begin
  if FTimer<>nil then FTimer.Interval:=I;
end;

function TAutoSizeStringGrid.GetColAsk(Idx:LongInt):TAutoSizeKind;
begin
  Result:=akCommon;
  if (Idx<0)or(Idx>=ColCount) then Exit;
  Result:=FColPars[Idx].AutoSizeKind;
end;

procedure TAutoSizeStringGrid.SetColASK(Idx:LongInt; ASK:TAutoSizeKind);
begin
  if (Idx<0)or(Idx>=ColCount) then InvalidOp(SIndexOutOfRange)
    else FColPars[Idx].AutoSizeKind:=ASK;
end;

function TAutoSizeStringGrid.GetColWP(Idx:LongInt):byte;
begin
  Result:=20;
  if (Idx<0)or(Idx>=ColCount) then Exit;
  Result:=FColPars[Idx].WidthPercent;
end;

procedure TAutoSizeStringGrid.SetColWP(Idx:LongInt; WP:byte);
begin
  if (Idx<0)or(Idx>=ColCount) then InvalidOp(SIndexOutOfRange)
    else FColPars[Idx].WidthPercent:=WP;
end;

procedure TAutoSizeStringGrid.SetColCount(Value:LongInt);
var i,ICC:LongInt;
begin
  ICC:=inherited ColCount;
  if ICC=Value then inherited ColCount:=Value;
  if ICC<Value then begin
    {Увеличение количества столбцов}
    SetLength(FColPars,Value);
    {Инициализируем новые элементы массива}
    for i:=ICC to Value-1 do begin
      FColPars[i].AutoSizeKind:=akCommon;
      FColPars[i].WidthPercent:=20;
    end;
    inherited ColCount:=Value;
  end;
  if ICC>Value then begin
    {Уменьшение количества столбцов}
    inherited ColCount:=Value;
    SetLength(FColPars,ColCount);
  end;
end;

function TAutoSizeStringGrid.GetColCount:LongInt;
begin
  Result:=inherited ColCount;
end;

procedure TAutoSizeStringGrid.WMRButtonDown(var Msg:TWMRButtonDown);
var ACol,ARow:Integer;
begin
  if not FFollowRC then Exit;
  PointerToCell(ACol,ARow);
  if (ACol>=0)and(ARow>=0) then begin
    Row:=ARow;
    Col:=ACol;
  end;
end;

{Определяет, на какую ячейку наведена мышь}
procedure TAutoSizeStringGrid.PointerToCell(var ACol,ARow:Integer);
var CP:TPoint;
begin
  CP:=CalcCursorPos;
  MouseToCell(CP.X,CP.Y,ACol,ARow);
end;

procedure TAutoSizeStringGrid.SetColor(Clr:TColor);
begin
  FColor:=Clr;
  if inherited Enabled then inherited Color:=FColor else inherited Color:=FInactColor;
end;

procedure TAutoSizeStringGrid.SetInactColor(Clr:TColor);
begin
  FInactColor:=Clr;
  if inherited Enabled then inherited Color:=FColor else inherited Color:=FInactColor;
end;

procedure TAutoSizeStringGrid.SetEnabled(Ena:boolean);
begin
  inherited;
  if Ena then inherited Color:=FColor else inherited Color:=FInactColor;
end;

function TAutoSizeStringGrid.GetEnabled:boolean;
begin
  Result:=inherited GetEnabled;
end;

{=========================== TAutoSizeColumn ============================}

procedure TAutoSizeColumn.SetASK(ASK:TAutoSizeKind);
begin
  FASK:=ASK;
  Changed(False);
end;

constructor TAutoSizeColumn.Create(Collection: TCollection);
begin
  inherited;
  FASK:=akCommon;
  FWidthPercent:=20;
  FFitRest:=False;
  FSortMarker:=smNone;
end;

procedure TAutoSizeColumn.SetWidthPercent(WP:byte);
begin
  FWidthPercent:=WP;
  Changed(False);
end;

procedure TAutoSizeColumn.SetFitRest(FR:boolean);
begin
  FFitRest:=FR;
  //Changed(True); //FitRestSpace может быть взведён только у одной колонки
end;

procedure TAutoSizeColumn.SetSortMarker(SM:TSortMarkerKind);
begin
  FSortMarker:=SM;
  Changed(False);
end;

procedure TAutoSizeColumn.SetWordWrap(Value:boolean);
begin
  FWordWrap:=Value;
  Changed(False);
end;

{=========================== TDBAutoSizeColumns ============================}

function TDBAutoSizeColumns.Add:TAutoSizeColumn;
begin
  Result:=inherited Add as TAutoSizeColumn;
end;

function TDBAutoSizeColumns.GetColumn(Index:Integer):TAutoSizeColumn;
begin
  Result:=inherited Items[Index] as TAutoSizeColumn;
end;

procedure TDBAutoSizeColumns.SetColumn(Index:Integer; const Value:TAutoSizeColumn);
begin
  inherited Items[Index]:=Value;
end;

procedure TDBAutoSizeColumns.Update(Item:TCollectionItem);
begin
  inherited;
  if (Grid=nil)or(csLoading in Grid.ComponentState) then Exit;
end;

function TDBAutoSizeColumns.GetGrid:TAutoSizeDBGrid;
begin
  Result:=inherited Grid as TAutoSizeDBGrid;
end;

{=========================== TAutoSizeDBGrid ============================}

procedure TAutoSizeDBGrid.SetASK(ASK:TGridAutoSizeKind);
begin
  FASK:=ASK;
  Update;
end;

function TAutoSizeDBGrid.InitSortMarker(SM:TSortMarkerKind):TBitmap;
const BW=10;
      BH=10;
var Bmp:TBitmap;
    MP:array[0..2]of TPoint;
begin
  Bmp:=TBitmap.Create;
  Bmp.TransparentColor:=clFuchsia;
  Bmp.Transparent:=True;
  Bmp.Width:=BW;
  Bmp.Height:=BH;
  with Bmp.Canvas do begin
    Brush.Style:=bsSolid;
    Brush.Color:=clFuchsia;
    Pen.Style:=psSolid;
    FillRect(Rect(0,0,BW,BH));
    if SM=smAscending then begin
      {Указатель}
      Brush.Color:=clBtnFace;
      Pen.Color:=clBtnFace;
      MP[0]:=Point(0,0);
      MP[1]:=Point(BW-1,0);
      MP[2]:=Point((BW div 2)-1,BH-1);
      Polygon(MP);
      {Свет}
      Pen.Color:=clWhite;
      PenPos:=MP[1];
      LineTo(MP[2].X,MP[2].Y);
      {Тень}
      Pen.Color:=clBlack;
      PenPos:=Point(MP[2].X-1,MP[2].Y-1);
      LineTo(MP[0].X,MP[0].Y);
      LineTo(MP[1].X,MP[1].Y);
    end;
    if SM=smDescending then begin
      {Указатель}
      Brush.Color:=clBtnFace;
      Pen.Color:=clBtnFace;
      MP[0]:=Point(0,BH-1);
      MP[1]:=Point(BW-1,BH-1);
      MP[2]:=Point((BW div 2)-1,0);
      Polygon(MP);
      {Свет}
      Pen.Color:=clWhite;
      PenPos:=MP[0];
      LineTo(MP[1].X,MP[1].Y);
      {Тень}
      PenPos:=Point(MP[1].X-1,MP[1].Y-1);
      Pen.Color:=clGray;
      LineTo(MP[2].X,MP[2].Y);
      Pen.Color:=clBlack;
      LineTo(MP[0].X,MP[0].Y);
    end;
  end;
  Result:=Bmp;
end;

constructor TAutoSizeDBGrid.Create(AOwner:TComponent);
begin
  inherited;
  FPrevRecNo := -1;
  FLinkUpdated := True;
  FMAS:=False;
  FAutoSizeLock:=0;
  FAscMarker:=InitSortMarker(smAscending);
  FDescMarker:=InitSortMarker(smDescending);
  FASK:=gaFixed;
  FTimer:=TTimer.Create(Self);
  FTimer.Enabled:=False;
  FTimer.Interval:=500;
  FTimer.OnTimer:=TimerTick;
  FTimer.Enabled:=True;
end;

destructor TAutoSizeDBGrid.Destroy;
begin
  FTimer.Free;
  FAscMarker.Free;
  FDescMarker.Free;
  inherited;
end;

procedure TAutoSizeDBGrid.LockAutoSize;
begin
  Inc(FAutoSizeLock);
end;

procedure TAutoSizeDBGrid.UnlockAutoSize;
begin
  Dec(FAutoSizeLock);
end;

procedure TAutoSizeDBGrid.AutoSizeColumns;
var i,CW,OldActive,ARow,LC,MaxRow:Integer;
    ASK:TAutoSizeKind;
    //CF:TField;
    WS:WideString;
    Size:TSize;
    FCMW:array of Integer; //Columns Maximum Width
begin
  if (csLoading in ComponentState)or(csDestroying in ComponentState) then Exit;
  if FAutoSizeLock<>0 then Exit;
  LockAutoSize;
  LC:=LeftCol;
  SetLength(FCMW,Columns.Count);
  for i:=0 to Columns.Count-1 do FCMW[i]:=20;
  {Вычисление максимальной ширины каждой колонки в заголовочных ячейках}
  for i:=0 to Columns.Count-1 do begin
    WS:=Columns[i].Title.Caption;
    if GetTextExtentPoint32W(Canvas.Handle,PWideChar(WS),Length(WS),Size) then begin
      if Size.cx+10>=FCMW[i] then FCMW[i]:=Size.cx+10;
    end;
  end;
  {Вычисление максимальной ширины каждой колонки}
  if DataLink.Active then begin
    OldActive:=DataLink.ActiveRecord;
    MaxRow:=TopRow+VisibleRowCount-1;
    {Если все записи нормальные, а последняя - длинная, то при её отображении
     включается горизонтальная прокрутка. Запись закрывается полосой прокрутки,
     после чего ширины колонок считаются без этой записи. Полоса прокрутки
     пропадает, после чего ширины колонок считаются с последней записью.
     Включается полоса прокрутки. И так без конца.
     Поэтому когда выключена горизонтальная прокрутка, считаем ширины колонок
     без последней записи. Предполагаем, что полоса прокрутки вытесняет лишь
     одну последнюю запись (при достаточно мелком шрифте может и две).
     Лучше было бы посчитать ширины записей на одну больше, чем умещается на
     экране, но через DataLink доступны лишь видимые записи, а трогать
     позицию в DataSet - правило плохого тона}
    //if (VisibleColCount=ColCount)and(MaxRow>1) then MaxRow:=MaxRow-1;
    for ARow:=0 {TopRow} to MaxRow do begin
      DataLink.ActiveRecord:=ARow; //было ARow-1;
      for i:=0 to Columns.Count-1 do begin
        //CF:=Columns[i].Field;
        try
          WS:= DefaultGetColumnCellText(Columns[i]); // AutoStringField(CF);
        except
          WS:='';
        end;
        if GetTextExtentPoint32W(Canvas.Handle,PWideChar(WS),Length(WS),Size) then begin
          if Size.cx+10>=FCMW[i] then FCMW[i]:=Size.cx+10;
        end;
      end;
    end;
    {Возвращаем на место}
    DataLink.ActiveRecord:=OldActive;
  end;
  {Подстройка}
  for i:=0 to Columns.Count-1 do begin
    ASK:=Columns[i].AutoSizeKind;
    if ASK=akCommon then
      case AutoSizeKind of
        gaFixed:     ASK:=akFixed;
        gaPercent:   ASK:=akPercent;
        gaFullWidth: ASK:=akFullWidth;
      end;
    case ASK of
      akFixed:     CW:=Columns[i].Width; //Оставляем как есть
      akPercent:   CW:=(ClientWidth*Columns[i].WidthPercent)div 100;
      akFullWidth: CW:=FCMW[i];
    else
      CW:=20;
    end;
    if CW<>Columns[i].Width then Columns[i].Width:=CW;
  end;
  LeftCol:=LC;
  UnlockAutoSize;
end;

procedure TAutoSizeDBGrid.TimerTick(Sender:TObject);
var ds: TDataSet;
begin
  try
    FTimer.Enabled := False;
    ds := DataLink.DataSet;
    if (ds = nil) or FMAS or not ds.Active then Exit;
    if (FPrevRecNo = ds.RecNo) and not FLinkUpdated then Exit;
    FLinkUpdated := False;
    FPrevRecNo := ds.RecNo;
    AutoSizeColumns;
  finally
    FTimer.Enabled := True;
  end;
end;

procedure TAutoSizeDBGrid.Update;
begin
  inherited;
  AutoSizeColumns;
end;

function TAutoSizeDBGrid.CreateColumns:TDBGridColumns;
begin
  Result:=TDBAutoSizeColumns.Create(Self, TAutoSizeColumn);
end;

function TAutoSizeDBGrid.GetColumns:TDBAutoSizeColumns;
begin
  Result:=inherited Columns as TDBAutoSizeColumns;
end;

procedure TAutoSizeDBGrid.SetColumns(const Value:TDBAutoSizeColumns);
begin
  inherited Columns.Assign(Value);
end;

procedure TAutoSizeDBGrid.ClearSortMarkers;
var i:integer;
begin
  for i:=0 to Columns.Count-1 do Columns[i].SortMarker:=smNone;
end;

procedure TAutoSizeDBGrid.DrawSortMarker(ARect:TRect);
var Bmp:TBitmap;
    TP:Integer;
    ACol:Integer;
begin
  ACol:=MouseCoord(ARect.Left,ARect.Top).X; //Номер колонки на экране, а не в коллекции Columns
  if dgIndicator in Options then Dec(ACol); //Превратить номер экранной колонки в номер внутренней колонки
  if (ACol<0)or(ACol>Columns.Count-1) then Exit;
  case Columns[ACol].SortMarker of
    smAscending:  Bmp:=FAscMarker;
    smDescending: Bmp:=FDescMarker;
  else
    Exit;
  end;
  TP:=(RowHeights[0]-Bmp.Height)div 2;
  Canvas.Draw(ARect.Right-Bmp.Width-TP,TP,Bmp);
end;

{Отрисовка маркёров сортировки}
procedure TAutoSizeDBGrid.DrawCell(ACol,ARow:LongInt; ARect:TRect;
  AState: TGridDrawState);
begin
  inherited;
  {Если fixed row, но не индикатор}
  if (gdFixed in AState)and(ACol>=0)and(ARow=0) then DrawSortMarker(ARect);
end;

procedure TAutoSizeDBGrid.LinkActive(Value: Boolean);
begin
  inherited;
  FLinkUpdated := True;
end;

initialization
  DrawBitmap := TBitmap.Create;

finalization
  DrawBitmap.Free;

end.

