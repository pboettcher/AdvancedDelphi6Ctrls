unit AdvDBCtrls;

interface

uses
  Windows, AdvCtrls, Classes, DB, StdCtrls;

type
  TDataBoundComboBox = class(TAlignedComboBox)
  private
    FDataSet:TDataSet;
    FDataTextFld:String;
    FDataValueFld:String;
    procedure SetDataTextFld(Name:String);
    procedure SetDataValueFld(Name:String);
    procedure SetDataSet(DS:TDataSet);
    function GetSelectedValue:WideString;
    procedure SetSelectedValue(Value:WideString);
    function GetValue(i:Integer):WideString;
    procedure SetValue(i:Integer; Value:WideString);
  published
    property DataSet:TDataSet read FDataSet write SetDataSet;
    property DataTextField:String read FDataTextFld write SetDataTextFld;
    property DataValueField:String read FDataValueFld write SetDataValueFld;
  public
    constructor Create(AOwner:TComponent); override;
    procedure DataBind;
    procedure Clear; override;
    property SelectedValue:WideString read GetSelectedValue write SetSelectedValue;
    property Values[i:Integer]:WideString read GetValue write SetValue;
  end;

procedure Register;

implementation

uses DesignIntf, TntStdCtrls, ACCommon, SysUtils;

procedure Register;
begin
  RegisterComponents('Advanced Data Controls', [TDataBoundComboBox]);
  RegisterPropertyEditor(TypeInfo(TComboBoxStyle), TDataBoundComboBox, 'Style', nil);
end;

procedure TDataBoundComboBox.SetDataSet(DS:TDataSet);
begin
  FDataSet:=DS;
  //DataBind;
end;

constructor TDataBoundComboBox.Create(AOwner:TComponent);
begin
  inherited;
  Style:=csDropDownList;
end;

procedure TDataBoundComboBox.DataBind;
var Text, DTF, DVF:WideString;
    Data:PWideString;
begin
  Clear;
  if (FDataSet=nil) then Exit;
  if (FDataSet.IsEmpty) or (FDataSet.Fields.Count=0) then Exit;
  if (FDataSet.FindField(FDataValueFld)<>nil) then DVF:=FDataValueFld else DVF:=FDataSet.Fields.Fields[0].FieldName;
  if (FDataSet.FindField(FDataTextFld)<>nil) then DTF:=FDataTextFld else DTF:=FDataSet.Fields.Fields[0].FieldName;
  FDataSet.FindFirst;
  while not FDataSet.Eof do begin
    Text:=AutoStringField(FDataSet.FieldByName(DTF));
    New(Data);
    Data^:=AutoStringField(FDataSet.FieldByName(DVF));
    Items.AddObject(Text, Pointer(Data));
    FDataSet.Next;
  end;
  if ItemCount>0 then ItemIndex:=0;
end;

procedure TDataBoundComboBox.SetDataTextFld(Name:String);
begin
  FDataTextFld:=Name;
  //DataBind;
end;

procedure TDataBoundComboBox.SetDataValueFld(Name:String);
begin
  FDataValueFld:=Name;
  //DataBind;
end;

procedure TDataBoundComboBox.Clear;
var i:Integer;
begin
  for i:=0 to ItemCount-1 do begin
    if (Items.Objects[i]<>nil) then Dispose(PWideString(Items.Objects[i]));
    Items.Objects[i]:=nil;
  end;
  inherited;
end;

function TDataBoundComboBox.GetValue(i:Integer):WideString;
begin
  if (i<0) or (i>=ItemCount) then raise ERangeError.CreateFmt('Index (%d) is out of %d..%d DataBoundComboBox items range', [i, 0, ItemCount]);
  if (Items.Objects[i]<>nil) then Result:=PWideString(Items.Objects[i])^ else Result:='';
end;

procedure TDataBoundComboBox.SetValue(i:Integer; Value:WideString);
begin
  if (i<0) or (i>=ItemCount) then raise ERangeError.CreateFmt('Index (%d) is out of %d..%d DataBoundComboBox items range', [i, 0, ItemCount]);
  PWideString(Items.Objects[i])^:=Value;
end;

function TDataBoundComboBox.GetSelectedValue:WideString;
begin
  if ItemIndex<0 then begin Result:=''; Exit; end;
  Result:=Values[ItemIndex];
end;

procedure TDataBoundComboBox.SetSelectedValue(Value:WideString);
var i:Integer;
begin
  for i:=0 to ItemCount-1 do
    if Value=Values[i] then begin ItemIndex:=i; Exit; end; 
end;

end.

