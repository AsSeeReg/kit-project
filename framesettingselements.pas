unit FrameSettingsElements;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, Forms, Controls, StdCtrls, DBGrids, DbCtrls,
  ActnList, ComCtrls, unit_m_data, unit_types_and_const, ZDataset;

type

  { TFrameSettingsElements }

  TFrameSettingsElements = class(TFrame)
    ActionElementDel: TAction;
    ActionElementGroupDel: TAction;
    ActionElementAdd: TAction;
    ActionElementGroupAdd: TAction;
    ActionList1: TActionList;
    DBSetElements: TDBGrid;
    DSSetElements: TDataSource;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ZTSetElements: TZTable;
    ZTSetElementselem_group_id: TLargeintField;
    ZTSetElementselem_group_id1: TLargeintField;
    ZTSetElementselem_type_name: TStringField;
    ZTSetElementselem_type_name1: TStringField;
    ZTSetElementsGroup: TZTable;
    ZTSetElementsgroup_name1: TStringField;
    ZTSetElementsid: TLargeintField;
    ZTSetElementsid1: TLargeintField;
    ZTSetElementsid2: TLargeintField;
    procedure ActionElementAddExecute(Sender: TObject);
    procedure ActionElementDelExecute(Sender: TObject);
    procedure ActionElementGroupAddExecute(Sender: TObject);
    procedure ActionElementGroupDelExecute(Sender: TObject);
  private
    { private declarations }
    ElementGroupID:integer;
  public
    { public declarations }
    constructor Create(TheOwner: TComponent;pElementGroupID:integer); //override;
  end;

implementation

{$R *.lfm}

{ TFrameSettingsElements }

procedure TFrameSettingsElements.ActionElementGroupAddExecute(Sender: TObject);
begin
  DataM.ZQtemp.SQL.Text:=(GetSQL('new_elements_group',ElementGroupID));
  DataM.ZQtemp.ExecSQL;
  ZTSetElementsGroup.Refresh;
end;

procedure TFrameSettingsElements.ActionElementGroupDelExecute(Sender: TObject);
begin
  DataM.ZQtemp.SQL.Text:=(GetSQL('del_elements_types',ZTSetElementsGroup.FieldValues['id']));
  DataM.ZQtemp.ExecSQL;
  ZTSetElementsGroup.Delete;
end;

procedure TFrameSettingsElements.ActionElementAddExecute(Sender: TObject);
begin
  DataM.ZQtemp.SQL.Text:=(GetSQL('new_elements_type',ElementGroupID));
  DataM.ZQtemp.ExecSQL;
  ZTSetElements.Refresh;
end;

procedure TFrameSettingsElements.ActionElementDelExecute(Sender: TObject);
begin
  ZTSetElements.Delete;
end;

constructor TFrameSettingsElements.Create(TheOwner: TComponent;
  pElementGroupID: Integer);
var
  column: TColumn;
  field:TField;
  i:integer;
begin
  inherited Create(TheOwner);
  ElementGroupID:= pElementGroupID;
  DBSetElements.Columns.Clear;
  //GroupBoxSetElements.Caption:= GroupBoxSetElements.Caption+' (ID='+IntToStr(ElementGroupID)+')';
  hint:='Редактирование справочника элементов';
  if (ElementGroupID = -1) then
  begin
    DSSetElements.DataSet:= ZTSetElementsGroup;
    column:= DBSetElements.Columns.Add;
    column.FieldName:='id';
    column.Title.Caption:='ID';
    column.Visible:=false;
    column:= DBSetElements.Columns.Add;
    column.FieldName:='group_name';
    column.Title.Caption:='Наименование группы элементов';
    ZTSetElementsGroup.Active:=True;
  end
  else
  begin
    DSSetElements.DataSet:= ZTSetElements;
    column:= DBSetElements.Columns.Add;
    column.FieldName:='id';
    column.Title.Caption:='ID';
    column.Visible:=false;
    column:= DBSetElements.Columns.Add;
    column.FieldName:='elem_group_id';
    column.Title.Caption:='elem_group_id';
    column.Visible:=false;
    column:= DBSetElements.Columns.Add;
    column.FieldName:='elem_type_name';
    column.Title.Caption:='Тип элемента';
    ZTSetElements.Filter:='elem_group_id = '+inttostr(ElementGroupID);
    ZTSetElements.Active:=True;
    if (ZTSetElements.RecordCount = 0) then ActionElementAddExecute(nil);
  end;
  ToolButton1.Visible:=not(ElementGroupID = -1);
  ToolButton2.Visible:=(ElementGroupID = -1);
  ToolButton3.Visible:=not(ElementGroupID = -1);
  ToolButton4.Visible:=(ElementGroupID = -1);

end;

end.

