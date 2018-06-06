unit FramePassportObjects;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, ExtCtrls, DbCtrls,
  ActnList, Menus, Dialogs, unit_types_and_const, unit_m_data, typepaspBranch,
  typepaspobj, typePaspElem, db, KGrids, KFunctions, ZDataset, Types;

type

  { TFramePassportObjects }

  TFramePassportObjects = class(TFrame)
    ActionElemColor: TAction;
    ActionElemReplace: TAction;
    ActionElemSplit: TAction;
    ActionElemOld: TAction;
    ActionObjMove: TAction;
    ActionElemDel: TAction;
    ActionElemAdd: TAction;
    ActionObjDel: TAction;
    ActionObjAdd: TAction;
    ActionListObjElem: TActionList;
    DBComboBoxElemTypeMinor: TDBLookupComboBox;
    DBComboBoxContiguity: TDBLookupComboBox;
    DBComboBoxTypeObj: TDBLookupComboBox;
    DSElemTypeMinor: TDataSource;
    DSPassObjType: TDataSource;
    DBComboBoxTypeEl: TDBLookupComboBox;
    DSElemType: TDataSource;
    EdPoint1: TEdit;
    EdPoint2: TEdit;
    EdRad: TEdit;
    EdTan: TEdit;
    GroupBoxObjProp: TGroupBox;
    GroupBoxObj: TGroupBox;
    GroupBoxElem: TGroupBox;
    KGridObj: TKGrid;
    KGridElem: TKGrid;
    LabPoint1: TLabel;
    Lab4: TLabel;
    LabPoint2: TLabel;
    LabRad1: TLabel;
    LabTan1: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuAddElem: TMenuItem;
    MenuDelElem: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem7: TMenuItem;
    PanelL2: TPanel;
    PanelL3: TPanel;
    PanelPoint: TPanel;
    PanelContiguity: TPanel;
    PanelL: TPanel;
    PanelL1: TPanel;
    PanelTurn: TPanel;
    PanelV: TPanel;
    PanelV1: TPanel;
    PanelV2: TPanel;
    PanelV3: TPanel;
    PopupMenuObj: TPopupMenu;
    PopupMenuElem: TPopupMenu;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter4: TSplitter;
    Splitter5: TSplitter;
    ZQObjects: TZQuery;
    //ZQElements: TZQuery;
    ZQPassObjType: TZQuery;
    ZQElemType: TZQuery;
    ZQElemTypeMinor: TZQuery;
    procedure ActionElemAddExecute(Sender: TObject);
    procedure ActionElemDelExecute(Sender: TObject);
    procedure ActionObjAddExecute(Sender: TObject);
    procedure ActionObjDelExecute(Sender: TObject);
    procedure DBComboBoxTypeElChange(Sender: TObject);
    procedure DBComboBoxTypeEl_minorChange(Sender: TObject);
    procedure DBComboBoxTypeObjChange(Sender: TObject);
    procedure EdPoint1Change(Sender: TObject);
    procedure EdPoint2Change(Sender: TObject);
    procedure EdRadChange(Sender: TObject);
    procedure EdTanChange(Sender: TObject);
    procedure KGridElemChanged(Sender: TObject; ACol, ARow: Integer);
    procedure KGridElemEditorCreate(Sender: TObject; ACol, ARow: Integer;
      var AEditor: TWinControl);
    procedure KGridElemRowMoved(Sender: TObject; FromIndex, ToIndex: Integer);
    procedure KGridObjClick(Sender: TObject);
    procedure KGridObjEditorCreate(Sender: TObject; ACol, ARow: Integer;
      var AEditor: TWinControl);
    procedure KGridObjRowMoved(Sender: TObject; FromIndex, ToIndex: Integer);
  private
    { private declarations }
    procedure AddObject({ARow: integer;}obj:TPassObj);
    procedure AddElement(elem:TPassElem);
    procedure GetObjects();
    procedure GetElements(obj_id,group_id:integer);
  public
    { public declarations }
    PassBranch:TPassBranch;
    pass_id:integer;
    active_obj_id:integer;
    active_obj_id_row:integer;
    active_obj:TPassObj;
    function getPasElem(elem_id:integer):TPassElem;
    constructor Create(TheOwner: TComponent;p_pass_id,pBranch_id:integer); //override;
  end;

implementation

{$R *.lfm}

{ TFramePassportObjects }

procedure TFramePassportObjects.KGridObjEditorCreate(Sender: TObject; ACol,
  ARow: Integer; var AEditor: TWinControl);
var
  InitialCol, InitialRow: Integer;
begin
 InitialCol := KGridObj.InitialCol(ACol); // map column indexes
 InitialRow := KGridObj.InitialRow(ARow); // map row indexes
 // do not create any editor in the 1.row
 if InitialRow = KGridObj.FixedRows then Exit
 // new feature: create TEdit in the fixed rows!
 else if InitialRow < KGridObj.FixedRows then
 begin
   if gxEditFixedRows in KGridObj.OptionsEx then
     AEditor := TEdit.Create(nil);
   Exit;
 end;
 // create custom editors
 case InitialCol of
   1:
   begin
     AEditor := TDBLookupComboBox.Create(nil{DBComboBoxElemTypeMinor.Owner});
     TDBLookupComboBox(AEditor).OnChange  :=DBComboBoxTypeObj.OnChange;
     TDBLookupComboBox(AEditor).DataField :=DBComboBoxTypeObj.DataField;
     TDBLookupComboBox(AEditor).DataSource:=DBComboBoxTypeObj.DataSource;
     TDBLookupComboBox(AEditor).KeyField  :=DBComboBoxTypeObj.KeyField;
     TDBLookupComboBox(AEditor).ListField :=DBComboBoxTypeObj.ListField;
     TDBLookupComboBox(AEditor).ListSource:=DBComboBoxTypeObj.ListSource;
   end;
 else
   if gxEditFixedCols in KGridObj.OptionsEx then
     AEditor := TEdit.Create(nil);
 end;
end;

procedure TFramePassportObjects.KGridObjRowMoved(Sender: TObject; FromIndex,
  ToIndex: Integer);
var
  Row,count,obj_id:integer;
  obj:TPassObj;
begin
 if  FromIndex > ToIndex then
 begin
  Row:=ToIndex;
  count:=FromIndex;
 end
 else
 begin
   Row:=FromIndex;
   count:=ToIndex;
 end;
  for Row:=0 to count do
  begin
    KGridObj.Cells[0,Row]:=inttostr(Row+1);
    obj_id:=StrToIntDef(KGridObj.Cells[3,Row],-1);
    obj:=PassBranch.getPasObject(obj_id);
    if obj<>nil
      then  obj.obj_pos:=inttostr(Row+1);
  end;
end;

procedure TFramePassportObjects.KGridObjClick(Sender: TObject);
var str:string;
  i:integer;
begin
 active_obj_id:= StrToIntDef(KGridObj.Cells[3,KGridObj.Row],-1);
 active_obj_id_row:=KGridObj.Row;
 active_obj:=PassBranch.getPasObject(active_obj_id);
  if (active_obj_id<0) then
  begin
    GroupBoxElem.Visible:=False;
    GroupBoxObjProp.Visible:=false;
    KGridElem.RowCount:=0;
    KGridElem.ClearGrid;
    exit;
  end;
  PanelContiguity.Visible:=(strtoint(active_obj.obj_type)=5);
  PanelPoint.Visible:=not (strtoint(active_obj.obj_type)=5);
  PanelTurn.Visible :=(strtoint(active_obj.obj_type)=2) or (strtoint(active_obj.obj_type)=3);

  GroupBoxObjProp.Visible:=True;
  GroupBoxObjProp.Caption:='Объект №'+KGridObj.Cells[0,KGridObj.Row]+': '+KGridObj.Cells[1,KGridObj.Row];
  GroupBoxElem.Visible:=True;
  EdRad.Text:= active_obj.obj_rad;
  EdTan.Text:= active_obj.obj_tan;
  EdPoint1.Text:= active_obj.point_1;
  EdPoint2.Text:= active_obj.point_2;
  GetElements(active_obj_id, integer(DBComboBoxTypeEl.KeyValue)); //object_id
end;

procedure TFramePassportObjects.ActionObjDelExecute(Sender: TObject);
var
  obj_id:integer;
  obj:TPassObj;
begin
   obj_id:=StrToIntDef(KGridObj.Cells[3,KGridObj.Row],-1);
   obj:=PassBranch.getPasObject(obj_id);
   obj.DelPasObj;
   if  KGridObj.RowCount<2
   then AddObject(nil);
   KGridObj.DeleteRow(KGridObj.Row);
   //Здесь удаляем объект и все элеметы
   KGridObjClick(nil);//обновляем элементы
end;

procedure TFramePassportObjects.DBComboBoxTypeElChange(Sender: TObject);
begin
 //////////
// DBComboBoxElemTypeMinor.ListFieldIndex:=-1;
 ZQElemTypeMinor.SQL.Clear;
 ZQElemTypeMinor.SQL.Text:=(GetSQL('elements_type',integer(DBComboBoxTypeEl.KeyValue)));
 ZQElemTypeMinor.Open;
 DBComboBoxElemTypeMinor.KeyField       :='id';
 DBComboBoxElemTypeMinor.ListField      :='elem_type_name';
 //////////////
 KGridObjClick(nil);//обновляем элементы
end;

procedure TFramePassportObjects.DBComboBoxTypeEl_minorChange(Sender: TObject);
var
 InRow,InCol:integer;
 obj_id,elem_id:integer;
 obj:TPassObj;
 elem:TPassElem;
begin
if sender is TDBLookupComboBox then
 begin
  if TDBLookupComboBox(sender).ItemIndex<0 then exit;
  InCol := KGridElem.Selection.Col1; // map column indexes
  InRow := KGridElem.Selection.Row1; // map row indexes
  KGridElem.Cells[InCol,InRow]:= TDBLookupComboBox(sender).Text;
  obj_id:=active_obj_id;//StrToIntDef(KGridObj.Cells[3,InRow],-1);
  if obj_id<0 then exit;
  obj:=active_obj;//PassBranch.getPasObject(obj_id);
  if obj<>nil then
   begin
     elem_id:=StrToIntDef(KGridElem.Cells[4,InRow],-1);
     elem:=obj.addPasElem(elem_id);
     if elem<>nil then
      begin
        elem.elem_type:=inttostr(integer(TDBLookupComboBox(sender).KeyValue));
        KGridElem.Cells[4,InRow]:=elem.elem_id;
        KGridElem.Cells[0,InRow]:=inttostr(InRow+1);
      end;
   end;
 end;
end;

procedure TFramePassportObjects.DBComboBoxTypeObjChange(Sender: TObject);
var
 InRow,InCol:integer;
 obj_id:integer;
 obj:TPassObj;
begin
if sender is TDBLookupComboBox then
 begin
  if TDBLookupComboBox(sender).ItemIndex<0 then exit;
  InCol := KGridObj.Selection.Col1; // map column indexes
  InRow := KGridObj.Selection.Row1; // map row indexes
  KGridObj.Cells[InCol,InRow]:= TDBLookupComboBox(sender).Text;
  obj_id:=active_obj_id;//StrToIntDef(KGridObj.Cells[3,InRow],-1);
  obj:=active_obj;//PassBranch.getPasObject(obj_id);
  if obj<>nil then
   begin
     obj.obj_type:=inttostr(integer(TDBLookupComboBox(sender).KeyValue));
//     obj.obj_type:=inttostr(TComboBox(sender).ItemIndex+1);
     KGridObj.Cells[3,InRow]:=obj.obj_id;
     KGridObj.Cells[0,InRow]:=inttostr(InRow+1);
   end;
 end;
// KGridObjProp.SetFocus;
KGridObjClick(nil);//обновляем элементы
end;

procedure TFramePassportObjects.EdPoint1Change(Sender: TObject);
begin
  active_obj.point_1:=EdPoint1.Text;
end;

procedure TFramePassportObjects.EdPoint2Change(Sender: TObject);
begin
  active_obj.point_2:=EdPoint2.Text;
end;

procedure TFramePassportObjects.EdRadChange(Sender: TObject);
begin
  active_obj.obj_rad:=EdRad.Text;
end;

procedure TFramePassportObjects.EdTanChange(Sender: TObject);
begin
  active_obj.obj_tan:=EdTan.Text;
end;

procedure TFramePassportObjects.KGridElemChanged(Sender: TObject; ACol,
  ARow: Integer);
var
  elem:TPassElem;
  st:string;

begin
 try
  elem:=active_obj.getPasElem(strtointdef(KGridElem.Cells[4,ARow],-1));
  if elem=nil then exit;
  {if ACol=0 then} elem.elem_pos :=KGridElem.Cells[0,ARow];
  st:= KGridElem.Cells[ACol,ARow];
  if ACol=1 then elem.elem_year:=st;
  //if ACol=3 then elem.elem_len :=st;
  if ACol=3 then elem.elem_len :=StringReplace(st, ',', '.', [rfReplaceAll]);
  if ACol=3 then active_obj.updateLen();
  if ACol=3 then KGridObj.Cells[2,active_obj_id_row]:=active_obj.obj_len+' м.';
 except on E:Exception do
   ShowMessage(E.Message);
 end;
  if ACol=3 then DataM.passListRefresh();
end;

procedure TFramePassportObjects.KGridElemEditorCreate(Sender: TObject; ACol,
  ARow: Integer; var AEditor: TWinControl);
var
  InitialCol, InitialRow: Integer;
begin
 InitialCol := KGridElem.InitialCol(ACol); // map column indexes
 InitialRow := KGridElem.InitialRow(ARow); // map row indexes
 // do not create any editor in the 1.row
 if InitialRow = KGridElem.FixedRows then Exit
 // new feature: create TEdit in the fixed rows!
 else if InitialRow < KGridElem.FixedRows then
 begin
   if gxEditFixedRows in KGridElem.OptionsEx then
     AEditor := TEdit.Create(nil);
   Exit;
 end;
 // create custom editors
 case InitialCol of
   2:
   begin
     AEditor := TDBLookupComboBox.Create(nil{DBComboBoxElemTypeMinor.Owner});
     TDBLookupComboBox(AEditor).OnChange  :=DBComboBoxElemTypeMinor.OnChange;
     TDBLookupComboBox(AEditor).DataField :=DBComboBoxElemTypeMinor.DataField;
     TDBLookupComboBox(AEditor).DataSource:=DBComboBoxElemTypeMinor.DataSource;
     TDBLookupComboBox(AEditor).KeyField  :=DBComboBoxElemTypeMinor.KeyField;
     TDBLookupComboBox(AEditor).ListField :=DBComboBoxElemTypeMinor.ListField;
     TDBLookupComboBox(AEditor).ListSource:=DBComboBoxElemTypeMinor.ListSource;
    end;
 else
     AEditor := TEdit.Create(nil);
 end;
end;

procedure TFramePassportObjects.KGridElemRowMoved(Sender: TObject; FromIndex,
  ToIndex: Integer);
var
  Row,count,elem_id:integer;
  elem:TPassElem;
begin
 if  FromIndex > ToIndex then
 begin
  Row:=ToIndex;
  count:=FromIndex;
 end
 else
 begin
   Row:=FromIndex;
   count:=ToIndex;
 end;
  for Row:=0 to count do
  begin
    KGridElem.Cells[0,Row]:=inttostr(Row+1);
    elem_id:=StrToIntDef(KGridElem.Cells[4,Row],-1);
    elem:=active_obj.getPasElem(elem_id);
    if elem<>nil
      then  elem.elem_pos:=inttostr(Row+1);
  end;
end;

procedure TFramePassportObjects.ActionObjAddExecute(Sender: TObject);
var
  obj:TPassObj;
begin
 obj:=PassBranch.addPasObject();
 obj.obj_type:='0';//KGridObj.Cells[1,KGridObj.Row];
 AddObject({-1,}obj);
end;

procedure TFramePassportObjects.ActionElemAddExecute(Sender: TObject);
var
  elem:TPassElem;
begin
 if active_obj<>nil
  then elem:=active_obj.addPasElem();
 if elem<>nil then
//  then elem.elem_type:=KGridElem.Cells[2,KGridElem.Row];
 AddElement({-1,}elem);
end;

procedure TFramePassportObjects.ActionElemDelExecute(Sender: TObject);
 var elem:TPassElem;
begin
 if active_obj=nil then exit;
 elem:=active_obj.getPasElem(StrToIntDef(KGridElem.Cells[4,KGridElem.Row],-1));
 if elem=nil  then exit;
 elem.DelPasElem;
 active_obj.updateLen();
 KGridObj.Cells[2, KGridObj.Row] :=(active_obj.obj_len)+' м.';
 KGridObjClick(nil);//обновляем элементы
end;

procedure TFramePassportObjects.AddObject({ARow: integer; }obj:TPassObj);
var ARow:integer;
begin
 if  KGridObj.Cells[0, 0]=''
  then ARow:=0
  else
  begin
    KGridObj.RowCount:=KGridObj.RowCount+1;
    ARow:=KGridObj.RowCount-1;
  end;
  if (obj<>nil) and (obj.obj_type<>'') then
  begin
    KGridObj.Cells[0, ARow] := inttostr(ARow+1);
    DBComboBoxTypeObj.KeyValue:=obj.obj_type;
    KGridObj.Cells[1, ARow] :=DBComboBoxTypeObj.Text;
//    KGridObj.Cells[1, ARow] :=(obj.obj_type);
    KGridObj.Cells[2, ARow] :=(obj.obj_len)+' м.';
    KGridObj.Cells[3, ARow] :=(obj.obj_id);
  end
  else
  begin
    KGridObj.Cells[0, ARow] :='';
    KGridObj.Cells[1, ARow] :='';
    KGridObj.Cells[2, ARow] :='0 м.';
    KGridObj.Cells[3, ARow] :='-1';
  end;
end;

procedure TFramePassportObjects.AddElement(elem:TPassElem);
  var
    ARow:integer;
begin
 if  KGridElem.Cells[0, 0]=''
  then ARow:=0
  else
  begin
    KGridElem.RowCount:=KGridElem.RowCount+1;
    ARow:=KGridElem.RowCount-1;
  end;
 if (elem<>nil) and (elem.elem_type<>'') then
 begin
   KGridElem.Cells[0, ARow] := inttostr(ARow+1);
   KGridElem.Cells[1, ARow] :=(elem.elem_year);
   DBComboBoxElemTypeMinor.KeyValue:=elem.elem_type;
   KGridElem.Cells[2, ARow] :=DBComboBoxElemTypeMinor.Text;
   KGridElem.Cells[3, ARow] :=(elem.elem_len){+' м.'};
   KGridElem.Cells[4, ARow] :=(elem.elem_id);
 end
 else
 begin
   KGridElem.Cells[0, ARow] :='';
   KGridElem.Cells[1, ARow] :='1905';
   KGridElem.Cells[2, ARow] :='';
   KGridElem.Cells[3, ARow] :='0';
   KGridElem.Cells[4, ARow] :='-1';
 end;
end;

procedure TFramePassportObjects.GetObjects;
var
  obj:TPassObj;
  i:integer;
begin
AddObject(nil); //пустая строка форматированная
KGridObj.Rows[0].Destroy; //пустая строка неформатированная
ZQObjects.SQL.Text:=GetSQL('objects',PassBranch.branch_id);
ZQObjects.Open;
ZQObjects.First;
 if ZQObjects.RecordCount=0
 then   begin
   obj:=PassBranch.addPasObject();
   AddObject(obj);
end;
 while not(ZQObjects.EOF) do begin
   obj:=PassBranch.getPasObject(ZQObjects.FieldByName('id').AsInteger);
   AddObject(obj);
   ZQObjects.Next;
 end;
 ZQObjects.Close;
end;

procedure TFramePassportObjects.GetElements(obj_id,group_id: integer);
var
  obj :TPassObj;
  elem:TPassElem;
  i:integer;
begin
 KGridElem.RowCount:=0;
 KGridElem.ClearGrid;
 KGridElem.EditorMode:=false;
 obj:=PassBranch.getPasObject(obj_id);
 if obj.ComponentCount<1
    then ActionElemAddExecute(nil);//пустая для пустого списка
// !!! дальше не формат
 KGridElem.Rows[0].Destroy; //пустая строка неформатированная
 for i:=0 to obj.ComponentCount-1 do
 begin
   elem := TPassElem(obj.Components[i]);
   if strtoint(elem.elem_group_id) = group_id
   then AddElement(elem);
 end;
end;

function TFramePassportObjects.getPasElem(elem_id: integer): TPassElem;
begin
  result:=nil;
end;

constructor TFramePassportObjects.Create(TheOwner: TComponent; p_pass_id,
  pBranch_id: integer);
begin
  inherited Create(TheOwner);
  pass_id:=p_pass_id;
  PassBranch:=TPassBranch.Create(pass_id,pBranch_id,DataM.ZConnection1);
  active_obj_id:=-1;
  active_obj:=nil;
  ZQPassObjType.SQL.Clear;
  ZQPassObjType.SQL.Add(GetSQL('objects_type',0));
  ZQPassObjType.Open;
  ZQElemType.SQL.Clear;
  ZQElemType.SQL.Add(GetSQL('elements_group',0));
  ZQElemType.Open;
  DBComboBoxTypeEl.KeyField             :='id';
  DBComboBoxTypeEl.ListField            :='group_name';
  DBComboBoxTypeEl.ItemIndex:=-1;
  DBComboBoxTypeEl.ItemIndex:=0;
  DBComboBoxTypeEl.EditingDone;
  DBComboBoxTypeElChange(nil);

  KGridObj.ColWidths[0]:=30;
  KGridObj.ColWidths[1]:=300;
  KGridObj.Cols[3].Visible:=false;
  KGridObj.RowCount:=0;

  KGridElem.ColWidths[0]:=30;
  KGridElem.ColWidths[1]:=50;
  KGridElem.ColWidths[2]:=300;
  KGridElem.Cols[4].Visible:=false;
  KGridElem.RowCount:=0;

  GetObjects;
  KGridObjClick(nil);//показать свойства

end;

end.

