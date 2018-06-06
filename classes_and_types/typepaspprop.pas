unit typePaspProp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, ZConnection, unit_types_and_const, unit_m_data,
  typePaspBranch;

type

  { TPassProp }

  TPassProp = class(TComponent)
  private
    { private declarations }
    f_pass_type  :TMyField;
    f_pass_id    :TMyField;
    f_pass_name  :TMyField;
    f_year_built :TMyField;
    f_way        :TMyField;
    f_comment    :TMyField;
    f_contiguity :TMyField;
    f_reconst    :TMyField;
    f_last_edit  :TMyField;
    f_user_edit  :TMyField;
    //propEdit: Boolean;
    ZQProp       : TZQuery;
    LongitudinalProfile: TZQuery;
    f_user_id    : string;
    PassBranch   : TPassBranch;
    elementGroupsList : array of integer;
    elementGroupsCount : Integer;
    function  getValue(Index:Integer):string;
    //procedure setEdit(AValue: Boolean);
    procedure setValue(Index:Integer; Value:string);
    function  getNewID:integer;
    procedure rewValue(Index:Integer);
  public
    { public declarations }
    f_conn       : TZConnection;  //нужно переделать в гетер
    function getLongitudinalProfile(): TZQuery;//нужно переделать
    property pass_id     :string          read f_pass_id.Value  write f_pass_id.Value;
    property pass_type   :string  Index 0 read getValue  write setValue;
    property pass_name   :string  Index 1 read getValue  write setValue;
    property year_built  :string  Index 2 read getValue  write setValue;
    property way         :string  Index 3 read getValue  write setValue;
    property comment     :string  Index 4 read getValue  write setValue;
    property contiguity  :string  Index 5 read getValue  write setValue;
    property reconst     :string  Index 6 read getValue  write setValue;
    property last_edit   :string  Index 7 read getValue  write setValue;
    property user_edit   :string  Index 8 read getValue  write setValue;
    //property Edit    :Boolean read propEdit  write setEdit; 
    constructor Create(p_pass_id,p_user_id:integer;p_conn:TZConnection; createOllBranches:Boolean = false);
    function getData():boolean;
    function getElementGroupsCount: Integer;
    function getElementGroup(i:integer=0): integer;//use getElementGroupsCount and elementGroupsList
  end;

implementation

{ TPassProp }

function TPassProp.getValue(Index: Integer): string;
var
  fld:^TMyField;
begin
  try
    case index of
    0: fld:=addr(f_pass_type);
    1: fld:=addr(f_pass_name);
    2: fld:=addr(f_year_built);
    3: fld:=addr(f_way);
    4: fld:=addr(f_comment);
    5: fld:=addr(f_contiguity);
    6: fld:=addr(f_reconst);
    7: fld:=addr(f_last_edit);
    8: fld:=addr(f_user_edit);
    else exit;
    end;
    result:=fld^.Value;
  except
    result:='';
  end;
end;

procedure TPassProp.setValue(Index: Integer; Value: string);
var
  fld:^TMyField;
  st:string;
begin
  //if not(Edit) then exit;
  try
    ZQProp.SQL.Clear;
    case index of
      0: fld:=addr(f_pass_type);
      1: fld:=addr(f_pass_name);
      2: fld:=addr(f_year_built);
      3: fld:=addr(f_way);
      4: fld:=addr(f_comment);
      5: fld:=addr(f_contiguity);
      6: fld:=addr(f_reconst);
      7: fld:=addr(f_last_edit);
      8: fld:=addr(f_user_edit);
    else exit;
    end;
    if Value=fld^.Value then exit;
{    if (StrToIntDef(f_pass_id.Value,-1)<0) and (index in [0,1]) //ненужно пока
       then begin
         f_pass_id.Value:=inttostr(getNewID);
         st:='INSERT INTO passports (id) VALUES ('+f_pass_id.Value+')';
         rewValue(0);//переписать по id
         rewValue(1);//переписать по id
         rewValue(2);//переписать по id
         rewValue(3);//переписать по id
       end;     }
    if fld^.table='' then begin
//      донт сэйв
      fld^.Value:=Value;
      exit;
    end;
    if not(StrToIntDef(f_pass_id.Value,-1)<0) then
    begin
      ZQProp.SQL.Clear;
      if fld^.table='passports'
      then  st:='Update '+ fld^.table+' set '+fld^.name+'="'+Value+'" where id='+f_pass_id.Value
      else
        begin
          st:='INSERT OR IGNORE INTO '+ fld^.table+' (pass_id) VALUES ('+f_pass_id.Value+')';
          ZQProp.SQL.Add(st);
          ZQProp.ExecSQL;
          ZQProp.SQL.Clear;
          st:='Update '+ fld^.table+' set value ="'+Value+'" where pass_id='+f_pass_id.Value;
        end;
      ZQProp.SQL.Add(st);
      ZQProp.ExecSQL;
      DataM.passListRefresh();
    end;
    fld^.Value:=Value;
    if (Index<>8) then setValue(8,f_user_id);
  except
  end;
end;

function TPassProp.getNewID: integer;
var
  ZQ: TZQuery;
begin
    ZQ:= TZQuery.Create(nil);
    ZQ.Connection:=f_conn;
    ZQ.SQL.Text:=GetSQL('pass_new_id',0);
    ZQ.Open;
  try
    result:=ZQ.FieldByName('id').AsInteger;
  except
    result:=0;
  end;
  FreeAndNil(ZQ);
end;

procedure TPassProp.rewValue(Index: Integer);
var
  fld:^TMyField;
  st:string;
begin
  case index of
    0: fld:=addr(f_pass_type);
    1: fld:=addr(f_pass_name);
    2: fld:=addr(f_year_built);
    3: fld:=addr(f_way);
    4: fld:=addr(f_comment);
    5: fld:=addr(f_contiguity);
    6: fld:=addr(f_reconst);
    7: fld:=addr(f_last_edit);
    8: fld:=addr(f_user_edit);
  else exit;
  end;
  st:=fld^.Value;
  fld^.Value:='';
  setValue(Index,st); //переписать по id
end;

function TPassProp.getLongitudinalProfile: TZQuery;
begin
if LongitudinalProfile = nil then
begin
  LongitudinalProfile:= TZQuery.Create(self);
  LongitudinalProfile.Connection:=f_conn;
  LongitudinalProfile.sql.Text:='SELECT*FROM longitudinal_profile WHERE pass_id='+f_pass_id.Value+' ORDER BY pos';
  LongitudinalProfile.Open;
end;
LongitudinalProfile.First;
Result:= LongitudinalProfile;
end;

constructor TPassProp.Create(p_pass_id,p_user_id: integer;p_conn: TZConnection; createOllBranches:Boolean = false);
var
  ZQBranches,ZQObjects : TZQuery;
begin
  inherited Create(nil);
  elementGroupsCount := -1;
  ZQProp:= TZQuery.Create(nil);
  f_conn:= p_conn;
  ZQProp.Connection:=f_conn;
  f_pass_id.value:=inttostr(p_pass_id);
  f_user_id:=inttostr(p_user_id);
  LongitudinalProfile:=nil;
  getData();
    //Получаес список компанентов, создаём их по списку id
  if createOllBranches then
  begin
    ZQBranches:=TZQuery.Create(nil);
    ZQBranches.Connection:=f_conn;
    //ZQObjects :=TZQuery.Create(nil);
    //ZQObjects .Connection:=f_conn;
    ZQBranches.SQL.Add(GetSQL('branchs',p_pass_id));
    ZQBranches.Open;
    ZQBranches.First;
    while not ZQBranches.EOF do begin
      PassBranch:=TPassBranch.Create(p_pass_id,ZQBranches.FieldByName('id').AsInteger,f_conn,self);
      PassBranch.branch_name:= ZQBranches.FieldByName('branch_name').AsString;
      //PassBranch.addPasObject;
      ////перенести в ветки и убрать из frame passport obj
      //  ZQObjects.SQL.Text:=GetSQL('objects',PassBranch.branch_id);
      //  ZQObjects.Open;
      //  ZQObjects.First;
      //   while not(ZQObjects.EOF) do begin
      //     PassBranch.getPasObject(ZQObjects.FieldByName('id').AsInteger);
      //     ZQObjects.Next;
      //   end;
      //   ZQObjects.Close;
      ZQBranches.Next;
    end;
  end;
end;

function TPassProp.getData: boolean;
var
  st:string;
begin
  try
  if  (StrToIntDef(f_pass_id.Value,-1)<0) then
  begin
     f_pass_id.Value:=inttostr(getNewID);
     st:='INSERT INTO passports (id) VALUES ('+f_pass_id.Value+')';
     ZQProp.SQL.Clear;
     ZQProp.SQL.text:=st;
     ZQProp.Open;
  end;

  ZQProp.Close;
  ZQProp.SQL.Clear;
  ZQProp.SQL.Add(GetSQL('prop',StrToInt(pass_id)));
  ZQProp.Open;

  f_pass_type.name   := 'pass_type';
  f_pass_type.table  := 'passports';
  f_pass_type.value  := ZQProp.FieldByName('pass_type') .AsString;

  f_pass_name.name   := 'pass_name';
  f_pass_name.table  := 'passports';
  f_pass_name.value  := ZQProp.FieldByName('pass_name') .AsString;

  f_year_built.name  := 'year_built';
  f_year_built.table := 'passport_prop_year_built';
  f_year_built.value := ZQProp.FieldByName('year_built').AsString;

  f_way.name         := 'way';
  f_way.table        := 'passport_prop_way';
  f_way.value        := ZQProp.FieldByName('way').AsString;

  f_comment.name     := 'comment';
  f_comment.table    := 'passport_prop_comment';
  f_comment.value    := ZQProp.FieldByName('comment').AsString;

  f_contiguity.name  := 'contiguity';
  f_contiguity.table := '';
  f_contiguity.value := ZQProp.FieldByName('contiguity').AsString;

  f_reconst.name     := 'year_reconst';
  f_reconst.table    := 'passport_prop_year_reconst';
  f_reconst.value    := ZQProp.FieldByName('year_reconst').AsString;

  f_last_edit.name   := 'last_edit';
  f_last_edit.table  := 'passports';
  f_last_edit.value  := ZQProp.FieldByName('last_edit').AsString;

  f_user_edit.name   := 'user_edit';
  f_user_edit.table  := 'passports';
  f_user_edit.value  := ZQProp.FieldByName('user_edit').AsString;
  except
    result:=false;
  end;
  result:=True;
end;

function TPassProp.getElementGroupsCount: Integer;
begin
  if elementGroupsCount<0 then getElementGroup;
  result := elementGroupsCount;
end;

function TPassProp.getElementGroup(i:integer=0): integer;
begin
  if elementGroupsCount<0 then
  begin
    ZQProp.Close;
    ZQProp.SQL.Clear;
    ZQProp.SQL.Add(GetSQL('pass_element_groups_list',StrToInt(pass_id)));
    ZQProp.Open;
    elementGroupsCount := ZQProp.RecordCount;
    SetLength(elementGroupsList,integer(ZQProp.RecordCount));
    While not ZQProp.EOF do
    begin
      elementGroupsList[ZQProp.RecNo-1] := ZQProp.FieldByName('elem_group_id').AsInteger;
      ZQProp.Next;
    end;
  end;
  //result := @elementGroupsList;
  if i<elementGroupsCount 
   then result:= elementGroupsList[i]
   else result:= -1;
end;

end.

