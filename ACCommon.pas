unit ACCommon;

interface

uses DB, SysUtils, Dialogs;

function AutoStringField(Fld:TField):WideString;

implementation

function AutoStringField(Fld:TField):WideString;
begin
  Result:='';
  if Fld=nil then Exit;
  if Fld.IsNull then Exit;
  if Fld.IsBlob then Exit;
  if Fld.DataType=ftWideString then Result:=TWideStringField(Fld).Value
    else Result:=Fld.AsString;
end;

end.
