unit FramePassportProperties;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ValEdit, StdCtrls, ExtCtrls,
  DbCtrls, DBGrids, ComCtrls, Menus, ActnList, Grids, unit_m_data,
  unit_types_and_const, FramePassportObjects, KGrids, typepaspprop,
  typepaspBranch, ZDataset, ZSqlUpdate, rxdbgrid, rxdbcurredit, db;

type

  { TFramePassportProperties }

  TFramePassportProperties = class(TFrame)
    ActionAddBranch: TAction;
    ActionDeleteBranch: TAction;
    ActionList: TActionList;
    DBComboBoxType: TDBLookupComboBox;
    DSProp: TDataSource;
    DSBranches: TDataSource;
    DBGridBranches: TDBGrid;
    EdName: TEdit;
    EdYearBuilt: TEdit;
    EdWay: TEdit;
    GroupBox1: TGroupBox;
    Lab10: TLabel;
    LbLastEdit: TLabel;
    LbUserEdit: TLabel;
    Lab13: TLabel;
    Lab2: TLabel;
    Lab4: TLabel;
    Lab3: TLabel;
    Lab1: TLabel;
    Lab5: TLabel;
    Lab6: TLabel;
    Lab7: TLabel;
    LbReconst: TLabel;
    LbContiguity: TLabel;
    MemoComment: TMemo;
    MenuItemAddBr: TMenuItem;
    MenuItemDelBr: TMenuItem;
    Panel1: TPanel;
    PanelL: TPanel;
    PanelV: TPanel;
    PanelVL0: TPanel;
    Splitter1: TSplitter;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ZQProp: TZQuery;
    ZTBranches: TZTable;
    ZTBranchesepure_key: TStringField;
    ZTBranchesid: TLargeintField;
    ZTBranchesname: TStringField;
    ZTBranchespass_id: TStringField;
    ZTBranchespos: TFloatField;
    ZTBranchespos_ang: TFloatField;
    ZTBranchespos_x: TFloatField;
    ZTBranchespos_y: TFloatField;
    procedure ActionAddBranchExecute(Sender: TObject);
    procedure ActionDeleteBranchExecute(Sender: TObject);
    procedure DBComboBoxTypeChange(Sender: TObject);
    procedure EdNameChange(Sender: TObject);
    procedure EdWayChange(Sender: TObject);
    procedure EdYearBuiltChange(Sender: TObject);
    procedure MemoCommentChange(Sender: TObject);
    procedure ZTBranchesAfterRefresh(DataSet: TDataSet);
    procedure ZTBranchesBeforePost(DataSet: TDataSet);
  private
    { private declarations }
    propEdit:Boolean;
  public
    { public declarations }
    PageControlPassport:TPageControl;
    pass_id:integer;
    user_id:integer;
    PassProp:TPassProp;
    procedure getDate;
    procedure AddBranchSheet(branch_id:integer;branch_name:string);
    procedure ClearBranchSheet();
  end;

implementation

{$R *.lfm}
var
  FPassportObjects   :TFramePassportObjects;
{ TFramePassportProperties }

procedure TFramePassportProperties.ZTBranchesBeforePost(DataSet: TDataSet);
begin
//  if pass_id<0 then exit;
  ZTBranches.FieldByName('pass_id').AsInteger:=pass_id;
  if    ZTBranches.FieldByName('branch_name').AsString=''
   then ZTBranches.FieldByName('branch_name').AsString:='Новый путь';
end;

procedure TFramePassportProperties.ZTBranchesAfterRefresh(DataSet: TDataSet);
begin
  ZTBranches.First;
  ClearBranchSheet;
  while not ZTBranches.EOF do begin
   AddBranchSheet(ZTBranches.FieldByName('id').AsInteger,ZTBranches.FieldByName('branch_name').AsString);
   ZTBranches.Next;
  end;
end;

procedure TFramePassportProperties.EdNameChange(Sender: TObject);
begin
 PassProp.pass_name:=EdName.Text;
 pass_id:=StrToIntDef(PassProp.pass_id,-1);
end;

procedure TFramePassportProperties.EdWayChange(Sender: TObject);
begin
  PassProp.way:=EdWay.Text;
end;

procedure TFramePassportProperties.EdYearBuiltChange(Sender: TObject);
begin
  PassProp.year_built:=EdYearBuilt.Text;
end;

procedure TFramePassportProperties.MemoCommentChange(Sender: TObject);
begin
  PassProp.comment:=MemoComment.Text;
end;

procedure TFramePassportProperties.ActionDeleteBranchExecute(Sender: TObject);
begin
  //удаляем объекты
    //элементы
  //Удаляем ветку
  ZTBranches.Delete;
end;

procedure TFramePassportProperties.ActionAddBranchExecute(Sender: TObject);
begin
  ZTBranches.Last;
  ZTBranches.Insert;
  ZTBranches.FieldByName('branch_name').AsString:='Ветка '+inttostr(ZTBranches.RecordCount+1);
  ZTBranches.FieldByName('pos').AsInteger:=ZTBranches.RecordCount+1;
  ZTBranches.Post;
end;

procedure TFramePassportProperties.DBComboBoxTypeChange(Sender: TObject);
begin
  PassProp.pass_type:=DBComboBoxType.KeyValue;
  pass_id:=StrToIntDef(PassProp.pass_id,-1);
end;

procedure TFramePassportProperties.getDate;
var
  st:string;
begin
{  ZQBranches.Close;
  ZQBranches.SQL.Clear;
  ZQBranches.SQL.Add(GetSQL('branchs', pass_id));
  ZQBranches.Open;   }
  PassProp:=TPassProp.Create(pass_id,user_id,DataM.ZConnection1);
  ZTBranches.Filter:='pass_id='+inttostr(pass_id);
  ZTBranches.Open;
  DBComboBoxType.KeyField:='id';
  DBComboBoxType.ListField:='pass_type_name';
  DBComboBoxType.KeyValue:=StrToIntDef(PassProp.pass_type,-1);
  EdName     .Text:=PassProp.pass_name;
  EdYearBuilt.Text:=PassProp.year_built;
  MemoComment.Text:=PassProp.comment;
  EdWay.Text:=PassProp.way;
  LbContiguity.Caption:=PassProp.contiguity;

  DataM.ZQtemp.SQL.Text:=(GetSQL('year_reconst',pass_id));
  DataM.ZQtemp.Open;
  if (DataM.ZQtemp.FieldValues['year']<>null)
   then PassProp.reconst:= DataM.ZQtemp.FieldValues['year'];

  LbReconst.Caption:=PassProp.reconst;
  LbLastEdit.Caption:=PassProp.last_edit;
  LbUserEdit.Caption:=PassProp.user_edit;
  ZTBranchesAfterRefresh(nil);
end;

procedure TFramePassportProperties.AddBranchSheet(branch_id: integer;
  branch_name: string);
var
  i:integer;
  TabSheet:TTabSheet;
begin
  for i:=0 to PageControlPassport.PageCount-1 do
  begin
   if PageControlPassport.Page[i].Tag=branch_id then
   begin
     PageControlPassport.Page[i].Caption:=branch_name;
     exit;
   end;
  end;
  TabSheet:=PageControlPassport.AddTabSheet;
  TabSheet.Caption:=branch_name;
  TabSheet.Tag:=branch_id;
  FPassportObjects:=TFramePassportObjects.Create(TabSheet,pass_id,branch_id);
  FPassportObjects.Name:='ObjectsBranch'+inttostr(branch_id);
  FPassportObjects.pass_id:=pass_id;
  FPassportObjects.Parent:=TabSheet;
end;

procedure TFramePassportProperties.ClearBranchSheet;
var i:integer;
begin
  for i:=PageControlPassport.PageCount-1 downto 3 do
  begin
   PageControlPassport.Page[i].Destroy;
  end;
end;

end.

