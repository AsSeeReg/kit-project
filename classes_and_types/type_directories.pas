unit Type_directories;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, ZConnection;

type

{ TDirectories }

TDirectories = class(TObject)
private
  { private declarations }
  elements : array of string;
  elements_group : array of string;
  f_conn : TZConnection;
  ZQuery : TZQuery;
public
  { public declarations }
  constructor Create(p_conn: TZConnection);
  procedure update(all:boolean=true);
  function getElementName(i:integer):String;
  function getElementGroupName(i:integer):String;
end;

implementation

{ TDirectories }

constructor TDirectories.Create(p_conn: TZConnection);
begin
  inherited Create();
  f_conn:= p_conn;
  update();
end;

procedure TDirectories.update(all: boolean);
var
  id:integer;
begin
  ZQuery := TZQuery.Create(nil);
  ZQuery.Connection:=f_conn;
  SetLength(elements,0);
  ZQuery.SQL.Text := ('select id,elem_type_name from elements_type order by id');
  ZQuery.Open;
  while not ZQuery.EOF do begin
    id := ZQuery.FieldByName('id').AsInteger;
    //if Length(elements)<id do 
    SetLength(elements,id+1);
    elements[id] := ZQuery.FieldByName('elem_type_name').AsString;
    ZQuery.Next;
  end;
  
  SetLength(elements_group,0);
  ZQuery.SQL.Text := ('select id,group_name from elements_group order by id');
  ZQuery.Open;
  while not ZQuery.EOF do begin
    id := ZQuery.FieldByName('id').AsInteger;
    //if Length(elements)<id do 
    SetLength(elements_group,id+1);
    elements_group[id] := ZQuery.FieldByName('group_name').AsString;
    ZQuery.Next;
  end;
  FreeAndNil(ZQuery);
end;

function TDirectories.getElementName(i: integer): String;
begin
  if (length(elements) > i)
  then result := elements[i]
  else result := 'Элемент ' + IntToStr(i);
end;

function TDirectories.getElementGroupName(i: integer): String;
begin
  if (length(elements_group) > i)
  then result := elements_group[i]
  else result := 'Покрытие ' + IntToStr(i);
end;

end.

