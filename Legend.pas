unit Legend;

interface

uses Windows,Classes,ExtCtrls,Graphics;

type
  TLegendPanel=class(TPanel)
  private
    FClrPanel:TPanel;
    FClrHolder:TPanel;
    FClrBorder:TPanel;
    FTxtPanel:TPanel;
    procedure SetIC(Clr:TColor);
    procedure SetSampleText(Txt:String);
    procedure SetSTF(Fnt:TFont);
    procedure SetText(Txt:String);
    function GetIC:TColor;
    function GetSampleText:String;
    function GetSTF:TFont;
    function GetText:String;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    property ItemColor:TColor read GetIC write SetIC;
    property SampleText:String read GetSampleText write SetSampleText;
    property SampleTextFont:TFont read GetSTF write SetSTF;
    property Text:String read GetText write SetText;
  end;

  TLegendItem=class(TCollectionItem)
  private
    FColor:TColor;
    FSTFont:TFont;
    FSText:String;
    FText:String;
    procedure SetColor(Clr:TColor);
    procedure SetSTFont(Fnt:TFont);
    procedure SetSampleText(Txt:String);
    procedure SetText(Txt:String);
    procedure STFontChange(Sender:TObject);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property Color:TColor read FColor write SetColor;
    property SampleTextFont:TFont read FSTFont write SetSTFont;
    property SampleText:String read FSText write SetSampleText;
    property Text:String read FText write SetText;
  end;

  TLegend=class;

  TLegendItems=class(TCollection)
  private
    FOnUpdate:TNotifyEvent;
    FOwner:TLegend;
  protected
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
    procedure Update(Item:TCollectionItem); override;
    function GetOwner:TPersistent; override;
  public
    constructor Create(Legend:TLegend);
    property OnUpdate:TNotifyEvent read FOnUpdate write FOnUpdate;
  end;

  TLegend=class(TPanel)
  private
    FLI:array of TLegendPanel;
    FLIC:TLegendItems;
    procedure ItemsUpdate(Sender:TObject);
    procedure RefreshItems;
    procedure SetItems(LI:TLegendItems);
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
  published
    property Items:TLegendItems read FLIC write SetItems;
  end;

procedure Register;

implementation

uses Controls,SysUtils;

{$R *.res}

procedure Register;
begin
  RegisterComponents('Advanced Controls', [TLegend]);
end;

{============================ TLegendPanel =============================}

constructor TLegendPanel.Create(AOwner:TComponent);
begin
  inherited;
  FClrPanel:=TPanel.Create(Self);
  FClrBorder:=TPanel.Create(Self);
  FClrHolder:=TPanel.Create(Self);
  FTxtPanel:=TPanel.Create(Self);
  with FClrHolder do begin
    Parent:=Self;
    Align:=alLeft;
    BevelInner:=bvNone;
    BevelOuter:=bvNone;
    Caption:='';
    BorderWidth:=1;
    Width:=40;
  end;
  with FClrBorder do begin
    Parent:=FClrHolder;
    Align:=alClient;
    BevelInner:=bvNone;
    BevelOuter:=bvNone;
    Caption:='';
    BorderWidth:=1;
    Color:=clBlack;
  end;
  with FClrPanel do begin
    Parent:=FClrBorder;
    Align:=alClient;
    BevelInner:=bvNone;
    BevelOuter:=bvNone;
    Caption:='';
    Color:=clGreen;
  end;
  with FTxtPanel do begin
    Parent:=Self;
    Align:=alClient;
    BevelInner:=bvNone;
    BevelOuter:=bvNone;
    Alignment:=taLeftJustify;
    Caption:='Категория';
  end;
  BevelInner:=bvNone;
  BevelOuter:=bvNone;
  Height:=15;
  Caption:='';
end;

destructor TLegendPanel.Destroy;
begin
  FClrPanel.Free;
  FClrBorder.Free;
  FClrHolder.Free;
  FTxtPanel.Free;
  inherited;
end;

procedure TLegendPanel.SetText(Txt:String);
begin
  FTxtPanel.Caption:=Txt;
end;

function TLegendPanel.GetText:String;
begin
  Result:=FTxtPanel.Caption;
end;

procedure TLegendPanel.SetIC(Clr:TColor);
begin
  FClrPanel.Color:=Clr;
end;

function TLegendPanel.GetIC:TColor;
begin
  Result:=FClrPanel.Color;
end;

procedure TLegendPanel.SetSTF(Fnt:TFont);
begin
  if Fnt=nil then Exit;
  FClrPanel.Font:=Fnt;
end;

function TLegendPanel.GetSTF:TFont;
begin
  Result:=FClrPanel.Font;
end;

procedure TLegendPanel.SetSampleText(Txt:String);
begin
  FClrPanel.Caption:=Txt;
end;

function TLegendPanel.GetSampleText:String;
begin
  Result:=FClrPanel.Caption;
end;

{============================== TLegend ===============================}

constructor TLegend.Create(AOwner:TComponent);
begin
  inherited;
  FLIC:=TLegendItems.Create(Self);
  FLIC.OnUpdate:=ItemsUpdate;
  Caption:='';
end;

destructor TLegend.Destroy;
var i:integer;
begin
  FLIC.Free;
  FLIC:=nil;
  for i:=0 to Length(FLI)-1 do FLI[i].Free;
  Finalize(FLI);
  inherited;
end;

procedure TLegend.RefreshItems;
var i,IH:integer;
begin
  IH:=0;
  if FLI=nil then begin
    SetLength(FLI,FLIC.Count);
    for i:=0 to Length(FLI)-1 do FLI[i]:=nil;
  end;
  if Length(FLI)<FLIC.Count then begin
    {Увеличение количества элементов}
    IH:=Length(FLI);
    SetLength(FLI,FLIC.Count);
    for i:=IH to FLIC.Count-1 do FLI[i]:=nil;
  end;
  if Length(FLI)>FLIC.Count then begin
    {Уменьшение количества элементов}
    for i:=FLIC.Count to Length(FLI)-1 do begin
      FLI[i].Free;
      FLI[i]:=nil;
    end;
    SetLength(FLI,FLIC.Count);
  end; 
  for i:=Length(FLI)-1 downto 0 do begin
    if FLI[i]=nil then FLI[i]:=TLegendPanel.Create(Self);
    FLI[i].Parent:=Self;
    FLI[i].Align:=alTop;
    FLI[i].Top:=0;
    FLI[i].ItemColor:=TLegendItem(FLIC.Items[i]).Color;
    FLI[i].Text:=TLegendItem(FLIC.Items[i]).Text;
    FLI[i].SampleText:=TLegendItem(FLIC.Items[i]).SampleText;
    FLI[i].SampleTextFont:=TLegendItem(FLIC.Items[i]).SampleTextFont;
    IH:=IH+FLI[i].Height;
  end;
  Height:=IH;
  Constraints.MinHeight:=IH;
  Constraints.MaxHeight:=IH;
end;

procedure TLegend.ItemsUpdate(Sender:TObject);
begin
  RefreshItems;
end;

procedure TLegend.SetItems(LI:TLegendItems);
begin
  {Фиктивный метод для write.
   IDE Delphi записывает в DFM только published+read+write свойства.
   С помощью фиктивного метода мы соблюдаем это условие, сохраняя
   неприкосновенность указателя FLIC.
   Ничего не делаем, пытаясь обмануть IDE}
end;

{============================ TLegendItems ===========================}

procedure TLegendItems.Notify(Item:TCollectionItem; Action:TCollectionNotification);
begin
  inherited;
  if Action=cnAdded then TLegendItem(Item).Text:='Item '+IntToStr(Item.Index);
  if Assigned(FOnUpdate) then FOnUpdate(Self);
end;

procedure TLegendItems.Update(Item:TCollectionItem);
begin
  inherited;
  if Assigned(FOnUpdate) then FOnUpdate(Self);
end;

function TLegendItems.GetOwner:TPersistent;
begin
  Result:=FOwner;
end;

constructor TLegendItems.Create(Legend:TLegend);
begin
  inherited Create(TLegendItem);
  FOwner:=Legend;
end;

{============================ TLegendItem ===========================}

constructor TLegendItem.Create(Collection: TCollection);
begin
  inherited;
  FColor:=clGreen;
  FSTFont:=TFont.Create;
  FSTFont.OnChange:=STFontChange;
  FSText:='';
  FText:='Item';
end;

destructor TLegendItem.Destroy;
begin
  FSTFont.OnChange:=nil;
  FSTFont.Free;
  FSTFont:=nil;
  inherited;
end;

procedure TLegendItem.SetColor(Clr:TColor);
begin
  FColor:=Clr;
  Changed(False);
end;

procedure TLegendItem.SetSTFont(Fnt:TFont);
begin
  if (Fnt=nil)or(FSTFont=nil) then Exit;
  FSTFont.Assign(Fnt);
end;

procedure TLegendItem.SetText(Txt:String);
begin
  FText:=Txt;
  Changed(False);
end;

procedure TLegendItem.SetSampleText(Txt:String);
begin
  FSText:=Txt;
  Changed(False);
end;

procedure TLegendItem.STFontChange(Sender:TObject);
begin
  Changed(False);
end;

end.

