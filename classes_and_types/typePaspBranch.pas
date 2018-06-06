unit typePaspBranch;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, ZConnection, unit_types_and_const, typepaspobj;

type

{ TPassBranch }

TPassBranch = class(TComponent)
private
  { private declarations }
  f_conn          : TZConnection;
  f_pas_id        : integer;
  f_branch_id     : integer;
  PassObj         : TPassObj;
  //propEdit: Boolean;
  ZQObjects       : TZQuery;
  f_branch_name   : string;
    function  get_count_pasObj():integer;
    //procedure setEdit(AValue: Boolean);
public
  { public declarations }
  property count_pasObj :integer read get_count_pasObj;
  property branch_id    :integer read f_branch_id;
  property branch_name  :string read f_branch_name write f_branch_name;
  //property Edit    :Boolean read propEdit  write setEdit; 
  constructor Create(p_pas_id,p_branch_id:integer;conn:TZConnection; TheOwner: TComponent = nil);
  function getPasObject(obj_id:integer):TPassObj;
  function addPasObject: TPassObj;
end;

implementation

{ TPassBranch }

function TPassBranch.get_count_pasObj: integer;
begin
 result:=self.ComponentCount;
end;

constructor TPassBranch.Create(p_pas_id,p_branch_id: integer; conn: TZConnection; TheOwner: TComponent = nil);
begin
  //Получаес список компанентов, создаём их по списку id
  inherited Create(TheOwner);
  f_conn:=conn;
  f_branch_id:=p_branch_id;
  f_pas_id   :=p_pas_id;
  ZQObjects:=TZQuery.Create(nil);
  ZQObjects.Connection:=f_conn;
  ZQObjects.SQL.Add(GetSQL('objects',f_branch_id));
  ZQObjects.Open;
  ZQObjects.First;
  if ZQObjects.RecordCount=0
     then TPassObj.Create(self,-1,f_conn); //если -1 то новый
  while not ZQObjects.EOF do begin
    PassObj:=TPassObj.Create(self,ZQObjects.FieldByName('id').AsInteger,f_conn);
    PassObj.connecting:=false;
    PassObj.obj_branch:=inttostr(f_branch_id);
    PassObj.obj_pos  :=ZQObjects.FieldByName('pos').AsString;
    PassObj.pas_id   :=inttostr(f_pas_id);
    PassObj.obj_type :=ZQObjects.FieldByName('obj_type').AsString;
    PassObj.obj_len  :=ZQObjects.FieldByName('length').AsString;
    PassObj.obj_rad  :=ZQObjects.FieldByName('rad').AsString;
    PassObj.obj_tan  :=ZQObjects.FieldByName('tan').AsString;
    PassObj.point_1  :=ZQObjects.FieldByName('point_1').AsString;
    PassObj.point_2  :=ZQObjects.FieldByName('point_2').AsString;
    PassObj.connecting:=true;
   ZQObjects.Next;
  end;
end;

function TPassBranch.getPasObject(obj_id: integer): TPassObj;
var i:integer;
begin
  result:=nil;
  for i:=0 to self.ComponentCount-1 do try
   if TPassObj(Components[i]).obj_id=inttostr(obj_id)
   then result:=TPassObj(Components[i]);
  except end;
end;

function TPassBranch.addPasObject: TPassObj;
begin
  PassObj:=TPassObj.Create(self,-1,f_conn);
  result:=PassObj;
  if PassObj=nil then exit;
  PassObj.connecting:=false;
  PassObj.obj_branch:=inttostr(f_branch_id);
  PassObj.pas_id    :=inttostr(f_pas_id);
  PassObj.connecting:=true;
end;

end.

