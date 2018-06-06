unit typePaspObj;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,ZDataset, ZConnection, unit_types_and_const, typePaspElem;

type

  { TPassObj }

  TPassObj = class(TComponent)
  private
    { private declarations }
    f_obj_id     :TMyField;
    f_obj_branch :TMyField;
    f_obj_pos    :TMyField;
    f_obj_type   :TMyField;
    f_obj_len    :TMyField;
    f_obj_rad    :TMyField;
    f_obj_tan    :TMyField;
    f_pas_id     :TMyField;
    f_point_1    :TMyField;
    f_point_2    :TMyField;
    f_conn       :TZConnection;
    //propEdit: Boolean;
    ZQProp       : TZQuery;
    passElem     : TPassElem;
    function  getValue(Index:Integer):string;
    //procedure setEdit(AValue: Boolean);
    procedure setValue(Index:Integer; Value:string);
    function  getNewID:integer;
    function  loadOllElements() :integer;
  public
    { public declarations }
    connecting:boolean; //если да, то write сразу в БД
    property obj_id     :string          read f_obj_id.Value;  //write f_pass_id.Value;
    property obj_branch :string  Index 0 read getValue  write setValue;
    property obj_pos    :string  Index 1 read getValue  write setValue;
    property obj_type   :string  Index 2 read getValue  write setValue;
    property obj_len    :string  Index 3 read getValue  write setValue;
    property obj_rad    :string  Index 4 read getValue  write setValue;
    property obj_tan    :string  Index 5 read getValue  write setValue;
    property pas_id     :string  Index 6 read getValue  write setValue;
    property point_1    :string  Index 7 read getValue  write setValue;
    property point_2    :string  Index 8 read getValue  write setValue;
    //property Edit    :Boolean read propEdit  write setEdit; 

    constructor Create(TheOwner: TComponent;p_obj_id:integer;p_conn:TZConnection);
    function getPasObj():boolean;
    function DelPasObj():boolean;
    function getPasElem(elem_id:integer):TPassElem;
    function addPasElem(elem_id:integer=-1):TPassElem;
    procedure updateLen();
  end;

implementation

{ TPassProp }

function TPassObj.getValue(Index: Integer): string;
var
  fld:^TMyField;
begin
  try
    case index of
    0: fld:=addr(f_obj_branch);
    1: fld:=addr(f_obj_pos);
    2: fld:=addr(f_obj_type);
    3: fld:=addr(f_obj_len);
    4: fld:=addr(f_obj_rad);
    5: fld:=addr(f_obj_tan);
    6: fld:=addr(f_pas_id);
    7: fld:=addr(f_point_1);
    8: fld:=addr(f_point_2);
    else exit;
    end;
    result:=fld^.Value;
  except
    result:='';
  end;
end;

procedure TPassObj.setValue(Index: Integer; Value: string);
var
  fld:^TMyField;
  st:string;
  i:integer;
begin
  try
    case index of
    0: fld:=addr(f_obj_branch);
    1: fld:=addr(f_obj_pos);
    2: fld:=addr(f_obj_type);
    3: fld:=addr(f_obj_len);
    4: fld:=addr(f_obj_rad);
    5: fld:=addr(f_obj_tan);
    6: fld:=addr(f_pas_id);
    7: fld:=addr(f_point_1);
    8: fld:=addr(f_point_2);
    else exit;
    end;
    if Value=fld^.Value then exit;
    if (StrToIntDef(f_obj_id.Value,-1)<0) and (index in [2])
       then begin
         f_obj_id.Value:=inttostr(getNewID);
         st:=f_obj_branch.Value;
         f_obj_branch.Value:='';
         obj_branch:=st;//переписать по id
         st:=f_pas_id.Value;
         f_pas_id.Value:='';
         pas_id:=st;//переписать по id
       end;
    if (index = 6) then
    begin
      for i:=0 to self.ComponentCount-1 do try
       TPassElem(Components[i]).pas_id:= f_pas_id.Value;
      finally
      end;
    end;
    if connecting then
      begin
        st:='INSERT OR IGNORE INTO '+ fld^.table+' (id) VALUES ('+f_obj_id.Value+')';
        ZQProp.SQL.text:=(st);
        ZQProp.ExecSQL;
        st:='Update '+ fld^.table+' set '+fld^.name+'="'+Value+'" where id='+f_obj_id.Value;
        ZQProp.SQL.text:=(st);
        ZQProp.ExecSQL;
      end;
    fld^.Value:=Value;
  except
  end;
end;

function TPassObj.getNewID: integer;
var
  ZQ: TZQuery;
begin
    ZQ:= TZQuery.Create(nil);
    ZQ.Connection:=f_conn;
    ZQ.SQL.Text:=GetSQL('obj_new_id',0);
    ZQ.Open;
  try
    result:=ZQ.FieldByName('id').AsInteger;
  except
    result:=0;
  end;
  FreeAndNil(ZQ);
end;

function TPassObj.loadOllElements: integer;
begin
  ZQProp.SQL.Add(GetSQL('elements',strtoint(f_obj_id.value)));
  ZQProp.Open;
  ZQProp.First;
  //if ZQProp.RecordCount=0
  //   then TPassElem.Create(self,-1,f_conn); //если -1 то новый
  while not ZQProp.EOF do begin
   passElem:=addPasElem(ZQProp.FieldByName('id').AsInteger);
   passElem.connecting :=false;
   passElem.elem_type  :=ZQProp.FieldByName('elem_type') .AsString;
   passElem.elem_len   :=ZQProp.FieldByName('length').AsString;
   passElem.elem_obj   :=ZQProp.FieldByName('object_id') .AsString;
   passElem.elem_colour:=ZQProp.FieldByName('colour')    .AsString;
   passElem.elem_year  :=ZQProp.FieldByName('year')      .AsString;
   passElem.elem_year  :=ZQProp.FieldByName('year')      .AsString;
   passElem.elem_group_id :=ZQProp.FieldByName('elem_group_id').AsString;
   passElem.connecting :=true;
   ZQProp.Next;
  end;
end;

constructor TPassObj.Create(TheOwner: TComponent; p_obj_id: integer;
  p_conn: TZConnection);
begin
  inherited Create(TheOwner);
  f_conn:=p_conn;
  ZQProp:= TZQuery.Create(nil);
  ZQProp.Connection:=f_conn;
  f_obj_id.value      :=inttostr(p_obj_id);
  f_obj_id.name       := 'id';
  f_obj_id.table      := 'objects';
  f_obj_branch.Value  := '';
  f_obj_branch.name   := 'branch_id';
  f_obj_branch.table  := 'objects';
  f_obj_pos.Value     := '0';
  f_obj_pos.name      := 'pos';
  f_obj_pos.table     := 'objects';
  f_obj_type.Value    := '';
  f_obj_type.name     := 'obj_type';
  f_obj_type.table    := 'objects';
  f_obj_len.Value     := '0';
  f_obj_len.name      := 'length';
  f_obj_len.table     := 'objects';
  f_obj_rad.Value     := '0';
  f_obj_rad.name      := 'rad';
  f_obj_rad.table     := 'objects';
  f_obj_tan.Value     := '0';
  f_obj_tan.name      := 'rad';
  f_obj_tan.table     := 'objects';
  f_pas_id.Value      := '';
  f_pas_id.name       := 'pass_id';
  f_pas_id.table      := 'objects';
  f_point_1.Value     := '';
  f_point_1.name      := 'point_1';
  f_point_1.table     := 'objects';
  f_point_2.Value     := '';
  f_point_2.name      := 'point_2';
  f_point_2.table     := 'objects';
  loadOllElements;
  connecting:=true;
end;

function TPassObj.getPasObj: boolean;
begin
  try
    result:=True;
    ZQProp.SQL.Text:=(GetSQL('obj_prop',StrToIntDef(f_obj_id.value,-1)));
    ZQProp.Open;
  //  f_obj_branch.value  :=При создании;// ZQProp.FieldByName('pass_name') .AsString;
    f_obj_pos .value :=ZQProp.FieldByName(f_obj_pos .name).AsString;
    f_obj_type.value :=ZQProp.FieldByName(f_obj_type.name).AsString;
    f_obj_rad .value :=ZQProp.FieldByName(f_obj_rad .name).AsString;
    f_obj_len .value :=ZQProp.FieldByName(f_obj_len .name).AsString;
    f_obj_tan .value :=ZQProp.FieldByName(f_obj_tan .name).AsString;
    f_pas_id  .value :=ZQProp.FieldByName(f_pas_id  .name).AsString;
    f_point_1 .value :=ZQProp.FieldByName(f_point_1 .name).AsString;
    f_point_2 .value :=ZQProp.FieldByName(f_point_2 .name).AsString;
  except
    result:=false;
  end;
//    connecting:=result;
end;

function TPassObj.DelPasObj: boolean;
var
  ZQ: TZQuery;
begin
    result:=false;
    ZQ:= TZQuery.Create(nil);
    ZQ.Connection:=f_conn;
  try
   ZQ.SQL.Text:=GetSQL('elem_del_obj_id',StrToIntDef(f_obj_id.value,-1));
   ZQ.ExecSQL;
   ZQ.SQL.Text:=GetSQL('obj_del_id',StrToIntDef(f_obj_id.value,-1));
   ZQ.ExecSQL;
  except
    result:=true;
  end;
  FreeAndNil(ZQ);
end;

function TPassObj.getPasElem(elem_id: integer): TPassElem;
var
  i:integer;
begin
  result:=nil;
  for i:=0 to self.ComponentCount-1 do try
   if TPassElem(Components[i]).elem_id=inttostr(elem_id)
   then result:=TPassElem(Components[i]);
  except end;
end;

function TPassObj.addPasElem(elem_id: integer): TPassElem;
begin
  PassElem:=TPassElem.Create(self,elem_id,f_conn);
  PassElem.connecting:=false;
  PassElem.elem_obj:=f_obj_id.value;
  PassElem.pas_id  :=f_pas_id.value;
  PassElem.connecting:=true;
end;

procedure TPassObj.updateLen;
var
  st:string;
begin
  try
    ZQProp.SQL.Text:=(GetSQL('obj_len',StrToIntDef(f_obj_id.value,-1)));
    ZQProp.Open;
    st:= ZQProp.FieldByName('len').AsString;
    if (st='') then st:= '0';
    obj_len :=st;
  except
  end;
end;

end.

