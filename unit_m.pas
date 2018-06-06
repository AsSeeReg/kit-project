unit unit_m;

//{$mode objfpc}{$H+}
{$mode delphi}{$H+} //для TabCloseEvent

interface

uses
  Classes, SysUtils, FileUtil, LazHelpCHM, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, Menus, ActnList, Buttons, StdCtrls, DbCtrls, ExtDlgs,
  EditBtn, attabs, rxdbgrid, unit_m_data, db, unit_types_and_const,
  FramePassport, FrameSettingsElements, unit_set_repport, unit_frame_set_users,
  frameCad, ZDataset, KGrids;

type

  { TFormM }

  TFormM = class(TForm)
    ActionFindType: TAction;
    ActionShowEditDemo: TAction;
    ActionSetReports: TAction;
    ActionSetUsers: TAction;
    ActionPasspListRefresh: TAction;
    ActionPassportMAP: TAction;
    ActionPassportCAD: TAction;
    ActionPassportPost: TAction;
    ActionPassportEdit: TAction;
    ActionPassportDel: TAction;
    ActionPassportNew: TAction;
    ActionPassportOpen: TAction;
    ActionReconnect: TAction;
    ActionShowMap: TAction;
    ActionShowCad: TAction;
    ActionShowPasp: TAction;
    ActionList1: TActionList;
    ActionShowList: TAction;
    CheckGroupEditFind: TCheckGroup;
    CheckGroupEditFind1: TCheckGroup;
    CheckGroupFind1: TCheckGroup;
    DBLookupFilterType: TDBLookupComboBox;
    EditFind: TEdit;
    EditFind1: TEdit;
    Image1: TImage;
    Image3: TImage;
    MenuItemAddPas: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItemSetReports: TMenuItem;
    miSettingsSystemAll: TMenuItem;
    MenuItemDecor: TMenuItem;
    miSettingsUsers: TMenuItem;
    miSettingsConnect: TMenuItem;
    MenuItemEdPas: TMenuItem;
    MenuItemDelPas: TMenuItem;
    MenuItemApprovPas: TMenuItem;
    MenuItemGetCad: TMenuItem;
    MenuItemGetMap: TMenuItem;
    MenuItemOpenPas: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    miSettingsElements: TMenuItem;
    MI_Close: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    PanelFind: TPanel;
    PanelMap: TPanel;
    PanelTool: TPanel;
    PanelCAD: TPanel;
    PanelList: TPanel;
    PanelPassport: TPanel;
    PopupMenuSettings: TPopupMenu;
    PopupMenuList: TPopupMenu;
    PopupMenuTabs: TPopupMenu;
    RxDBGrid1: TRxDBGrid;
    BBNewPassport: TSpeedButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    TabSheet1: TTabSheet;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    procedure ActionPasspListRefreshExecute(Sender: TObject);
    procedure ActionPassportCADExecute(Sender: TObject);
    procedure ActionPassportDelExecute(Sender: TObject);
    procedure ActionPassportEditExecute(Sender: TObject);
    procedure ActionPassportNewExecute(Sender: TObject);
    procedure ActionPassportOpenExecute(Sender: TObject);
    procedure ActionSetReportsExecute(Sender: TObject);
    procedure ActionSetUsersExecute(Sender: TObject);
    procedure ActionShowEditDemoExecute(Sender: TObject);
    procedure CheckFilterClick(Sender: TObject; Index: integer);
    procedure DBLookupFilterTypeChange(Sender: TObject);
    procedure EditFindChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Image1DblClick(Sender: TObject);
    procedure Image3DblClick(Sender: TObject);
    procedure MenuItemSetEditElemClick(Sender: TObject);
    procedure PassportOpen(Pas_ID:integer;Edit:Boolean= false);
    procedure PassportOpenCad(Pas_ID:integer);
    procedure ActionReconnectExecute(Sender: TObject);
    procedure ActionShowCadExecute(Sender: TObject);
    procedure ActionShowListExecute(Sender: TObject);
    procedure ActionShowMapExecute(Sender: TObject);
    procedure ActionShowPaspExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PopupMenuSettingsPopup(Sender: TObject);
    procedure RxDBGrid1AfterQuickSearch(Sender: TObject; Field: TField;
      var AValue: string);
    procedure RxDBGrid1DblClick(Sender: TObject);
    procedure ToolButton10Click(Sender: TObject);
  private
    { private declarations }
    {TATTabs}
    procedure TabCloseEvent(Sender: TObject; ATabIndex: Integer; var ACanClose,
         ACanContinue: boolean);
    procedure TabChangeQueryEvent (Sender: TObject; ANewTabIndex: Integer;
    var ACanChange: boolean);
    {TATTabs - end}
  public
    PasTabs: TATTabs;
    { public declarations }
    AppIsInit:boolean;
    procedure PasspTypeListAfterUpdate();
  end;

var
  FormM: TFormM;
  FilePath:string;
  ActivPaspID:integer= -1;
  DefaultSettings:record
   PanelList_Show:boolean;
   PanelList_Width:integer;
  end;
  userID:integer = 0;

  FPassport:TFramePassport;
  PassportsArr:array of TFramePassport;
  SettingsForm:TForm;
  FrameCad:TFrameCad;

implementation

{$R *.lfm}

{ TFormM }
uses
  unit_login;

procedure TFormM.FormShow(Sender: TObject);
begin
 DataM.ZConnection1.Disconnect;
 Caption:=Caption+' - '+GetMyVersion+' - alfa';
 //Firefox rectangle tabs
 PasTabs:= TATTabs.Create(PanelPassport);
 PasTabs.Parent:= PanelPassport;
 PasTabs.Align:= alTop;
 PasTabs.OnTabClose:= TabCloseEvent;
 PasTabs.OnTabChangeQuery:= TabChangeQueryEvent;
 PasTabs.Font.Size:= 8;

 PasTabs.TabShowPlus:= false;
 PasTabs.Height:= 42;
 PasTabs.TabAngle:= 0;
 PasTabs.TabIndentInter:= 2;
 PasTabs.TabIndentInit:= 2;
 PasTabs.TabIndentTop:= 4;
 PasTabs.TabIndentXSize:= 13;
 PasTabs.TabWidthMin:= 18;
 PasTabs.TabDragEnabled:= false;

 PasTabs.Font.Color:= clBlack;
 PasTabs.ColorBg:=PanelPassport.Color;// $F9EADB;
 PasTabs.ColorBorderActive:={PanelPassport.Color;//} $ACA196;
 PasTabs.ColorBorderPassive:= $ACA196;
 PasTabs.ColorTabActive:=PanelPassport.Color;// $FCF5ED;
 PasTabs.ColorTabPassive:= $E0D3C7;
 PasTabs.ColorTabOver:= $F2E4D7;
 PasTabs.ColorCloseBg:= clNone;
 PasTabs.ColorCloseBgOver:= $D5C9BD;
 PasTabs.ColorCloseBorderOver:= $B0B0B0;
 PasTabs.ColorCloseX:= $7B6E60;
 PasTabs.ColorArrow:= $5C5751;
 PasTabs.ColorArrowOver:= PasTabs.ColorArrow;

 SetLength(PassportsArr,0);
 if FormLogin.ShowModal<>mrOK then Close;
 ActionShowEditDemo.Execute;
 WindowState:=wsFullScreen;
 AppIsInit:=True;//конец инициализации приложения
end;

procedure TFormM.PopupMenuSettingsPopup(Sender: TObject);
var
  mi:TMenuItem;
  i:integer;
begin
  //формируем список элементов для настройки
  miSettingsElements.Clear;
  DataM.ZQtemp.SQL.Text:=(GetSQL('elements_group',-1));
  DataM.ZQtemp.Open;
  while not DataM.ZQtemp.EOF do
    begin
      mi:=  TMenuItem.Create(miSettingsElements);
      mi.Caption:=DataM.ZQtemp.FieldValues['group_name'];
      mi.tag:= DataM.ZQtemp.FieldValues['id'];
      mi.OnClick:= MenuItemSetEditElemClick;
      miSettingsElements.Add(mi);
      DataM.ZQtemp.next;
    end;
  mi:=  TMenuItem.Create(miSettingsElements);
  mi.Caption:='..редактировать список';
  mi.tag:= -1;
  mi.OnClick:= MenuItemSetEditElemClick;
  miSettingsElements.Add(mi);
end;

procedure TFormM.RxDBGrid1AfterQuickSearch(Sender: TObject; Field: TField;
  var AValue: string);
begin
end;

procedure TFormM.RxDBGrid1DblClick(Sender: TObject);
begin
 ActionPassportOpenExecute(Sender);
end;

procedure TFormM.ToolButton10Click(Sender: TObject);
begin

end;

procedure TFormM.TabCloseEvent(Sender: TObject; ATabIndex: Integer;
    var ACanClose, ACanContinue: boolean);
var
  i,i2:integer;
begin
 for i:=0 to High(PassportsArr) do
   if PassportsArr[i]<>nil then
    if ATabIndex=PassportsArr[i].TabIndex then
     begin
      PassportsArr[i].Destroy;
      PassportsArr[i]:=nil;
      for i2:=i to  High(PassportsArr) do
       if PassportsArr[i2]<>nil then
        PassportsArr[i2].TabIndex:=PassportsArr[i2].TabIndex-1;
      exit;
     end;
end;

procedure TFormM.TabChangeQueryEvent(Sender: TObject; ANewTabIndex: Integer;
  var ACanChange: boolean);
var
  i:integer;
begin
 if SettingsForm<>nil then FreeAndNil(SettingsForm);
 for i:=0 to High(PassportsArr) do
    if PassportsArr[i]<>nil then begin
     if ANewTabIndex=PassportsArr[i].TabIndex
     then PassportsArr[i].Show
     else PassportsArr[i].Hide;
    end;
 ACanChange:=true;
end;

procedure TFormM.PasspTypeListAfterUpdate;
begin
{  DataM.ZQPasspTypeList.First;
  FilterList.Items.Clear;
  While not(DataM.ZQPasspTypeList.EOF) do begin
   FilterList.Items.Add(DataM.ZQPasspTypeList.FieldByName('pass_type_name').AsString);
   DataM.ZQPasspTypeList.Next;
   FilterList.Checked[FilterList.Items.Count-1]:=true;
  end;                                     }
end;

procedure TFormM.ActionShowListExecute(Sender: TObject);
begin
   PanelList.Visible:=ActionShowList.Checked;
end;

procedure TFormM.ActionShowMapExecute(Sender: TObject);
begin
  //PanelCAD.Align:=alRight;
  //PanelMap.Align:=alRight;
 if (ActionShowCad.Checked)then
  begin
   if  FrameCad=nil then
    begin
     FrameCad:=TFrameCad.Create(PanelCAD);
     FrameCad.Parent:=PanelCAD;
    end;
  end 
 else 
  begin
    FreeAndNil(FrameCad);
  end;
  PanelCAD.Visible:=ActionShowCad.Checked;
  PanelMap.Visible:=ActionShowMap.Checked;
  //PanelCAD.Align:=alClient;
  //PanelMap.Align:=alClient;
end;

procedure TFormM.ActionShowCadExecute(Sender: TObject);
begin
  //PanelCAD.Align:=alRight;
  //PanelMap.Align:=alRight;
 if (ActionShowCad.Checked)then
  begin
   if  FrameCad=nil then
    begin
     FrameCad:=TFrameCad.Create(PanelCAD);
     FrameCad.Parent:=PanelCAD;
    end;
  end 
 else 
  begin
    FreeAndNil(FrameCad);
  end;
  PanelCAD.Visible:=ActionShowCad.Checked;
  PanelMap.Visible:=ActionShowMap.Checked;
  //PanelCAD.Align:=alClient;
  //PanelMap.Align:=alClient;
end;

procedure TFormM.ActionReconnectExecute(Sender: TObject);
  var
    filepath:string;
begin
    filepath:= ExtractFilePath(ParamStr(0));
   with DataM do
   begin
     ZConnection1.Disconnect;
     ZConnection1.Database:=filepath+'db\tramways.db';
     ZConnection1.LibraryLocation:='';//filepath+'dll\sqlite3.dll';
     ZConnection1.Connect;
     ZQPasspList.Open;
     ZQPasspTypeList.Open;
     ActionShowCadExecute(nil);
     ActionShowCadExecute(nil);
   end;
end;

procedure TFormM.ActionPassportOpenExecute(Sender: TObject);
begin
 ActivPaspID:=DataM.ZQPasspList.FieldByName('id').AsInteger;
 PassportOpen(ActivPaspID);
end;

procedure TFormM.ActionSetReportsExecute(Sender: TObject);
begin
  if (SettingsForm<>nil) then FreeAndNil(SettingsForm);
 SettingsForm:=ShowFrame(self,TFrame(TFrameSetReport.Create(nil)));
end;

procedure TFormM.ActionSetUsersExecute(Sender: TObject);
begin
  if (SettingsForm<>nil) then FreeAndNil(SettingsForm);
 SettingsForm:=ShowFrame(self,TFrame(TFrameSetUsers.Create(nil)));
end;

procedure TFormM.ActionShowEditDemoExecute(Sender: TObject);
begin
 if (AppIsInit) and authorization.Demo then authorization.CanEdit:=not(ActionShowEditDemo.Checked);
 ActionShowEditDemo.Visible :=authorization.Demo;
 ToolBar2.AutoSize :=not authorization.Demo;
 ActionShowEditDemo.Checked :=authorization.CanEdit;
 MenuItemAddPas.Enabled     :=authorization.CanEdit;
 MenuItemApprovPas.Enabled  :=authorization.CanEdit;
 MenuItemDelPas.Enabled     :=authorization.CanEdit;
 MenuItemEdPas.Enabled      :=authorization.CanEdit;
 miSettingsElements.Enabled :=authorization.CanEdit;
 MenuItemSetReports.Enabled :=authorization.CanEdit;
end;

procedure TFormM.CheckFilterClick(Sender: TObject; Index: integer);
var filt:string;
begin
 filt:='';
 if CheckGroupFind1.Checked[0]
 then filt:='type='''+DBLookupFilterType.Text+'''';
 if CheckGroupEditFind1.Checked[0] then
  begin
   if  filt<>'' then  filt:=filt+' AND ';
    filt:=filt+'name like''*'+EditFind1.Text+'''';
  end;
 if CheckGroupEditFind.Checked[0] then
  begin
   if  filt<>'' then  filt:=filt+' AND ';
    filt:=filt+'comment like''*'+EditFind.Text+'*''';
  end;
  DataM.ZQPasspList.Filter:=filt;
  DataM.ZQPasspList.Filtered:=(filt<>'')
  and ((CheckGroupFind1.Checked[0]) or (CheckGroupEditFind.Checked[0]) or (CheckGroupEditFind1.Checked[0]));
end;

procedure TFormM.DBLookupFilterTypeChange(Sender: TObject);
begin
   CheckFilterClick(nil,0);
end;

procedure TFormM.EditFindChange(Sender: TObject);
begin
  CheckFilterClick(nil,0);
end;

procedure TFormM.FormCreate(Sender: TObject);
begin
 SettingsForm:= nil;
 FrameCad:= nil;
 
 //Application.OnException := MyExcept; //{$mode objfpc}  
 end;

procedure TFormM.FormResize(Sender: TObject);
begin
 PanelList.Width:=round(FormM.Width*0.25);
 PanelCAD.Width:=round(FormM.Width*0.5);
 PanelMap.Width:=round(FormM.Width*0.5);
end;

procedure TFormM.Image1DblClick(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
end;

procedure TFormM.Image3DblClick(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then Image3.Picture.LoadFromFile(OpenPictureDialog1.FileName);
end;

procedure TFormM.MenuItemSetEditElemClick(Sender: TObject);
var
  ElementGroupID: Integer;
begin
 if (sender is TMenuItem)
  then ElementGroupID:= TMenuItem(Sender).Tag
  else ElementGroupID:= PopupMenuSettings.PopupComponent.Tag;
 if (SettingsForm<>nil) then FreeAndNil(SettingsForm);
 SettingsForm:=ShowFrame(self,TFrame(TFrameSettingsElements.Create(nil,ElementGroupID)));
 //SettingsFrame:= TFrameSettingsElements.Create(PanelPassport,ElementGroupID);
 //SettingsFrame.Align:= alClient;
 //SettingsFrame.Parent:= PanelPassport;
end;

procedure TFormM.PassportOpen(Pas_ID:Integer;Edit:Boolean = False);
  var
    i:integer;
    passpAlreadyExist:boolean=false;
begin
 for i:=0 to High(PassportsArr) do
   if PassportsArr[i]<>nil then begin
    if PassportsArr[i].PasspID=Pas_ID
    then
    begin
     PassportsArr[i].Show;
     PassportsArr[i].Edit:=Edit;
     PasTabs.TabIndex:=PassportsArr[i].TabIndex;
     passpAlreadyExist:=true;
    end
    else PassportsArr[i].Hide;
   end;
 if passpAlreadyExist then exit;
 SetLength(PassportsArr,Length(PassportsArr)+1);
 PassportsArr[High(PassportsArr)]:=TFramePassport.Create(PanelPassport,PasTabs,Pas_ID,userID);
 PassportsArr[High(PassportsArr)].Edit:=Edit;
end;

procedure TFormM.PassportOpenCad(Pas_ID: integer);
begin
 if FrameCad=nil then
  begin
   ActionShowCad.Execute;
  end;
  FrameCad.setPassport(Pas_ID,userID);
  FrameCad.Caption:=DataM.ZQPasspList.FieldByName('type').AsString+' №'+DataM.ZQPasspList.FieldByName('name').AsString+ ' - Условный план трассы';
end;

procedure TFormM.ActionPassportNewExecute(Sender: TObject);
begin
//  ActivPaspID:=const_pasNew;
  PassportOpen(const_pasNew,True);
  ActionPasspListRefresh.Execute;
end;

procedure TFormM.ActionPassportDelExecute(Sender: TObject);
  var
    ZQ: TZQuery;
    i:integer;
begin
 ActivPaspID:=DataM.ZQPasspList.FieldByName('id').AsInteger;
  for i:=0 to High(PassportsArr) do
    if PassportsArr[i]<>nil
       then
           if PassportsArr[i].PasspID=ActivPaspID
              then
                 begin
                  PasTabs.DeleteTab(PassportsArr[i].TabIndex, true, true);
                 end;

  ZQ:= TZQuery.Create(nil);
  ZQ.Connection:=DataM.ZConnection1;
//  ZQ.SQL.Text:=GetSQL('del_pass_id',ActivPaspID);
  ZQ.SQL.Text:=' delete from passport_prop_comment    where pass_id='+inttostr(ActivPaspID);
  ZQ.ExecSQL;
  ZQ.SQL.Text:=' delete from passport_prop_year_built where pass_id='+inttostr(ActivPaspID);
  ZQ.ExecSQL;
  ZQ.SQL.Text:=' delete from passport_prop_comment    where pass_id='+inttostr(ActivPaspID);
  ZQ.ExecSQL;
  ZQ.SQL.Text:=' delete from elements                 where pass_id='+inttostr(ActivPaspID);
  ZQ.ExecSQL;
  ZQ.SQL.Text:=' delete from objects                  where pass_id='+inttostr(ActivPaspID);
  ZQ.ExecSQL;
  ZQ.SQL.Text:=' delete from branch                   where pass_id='+inttostr(ActivPaspID);
  ZQ.ExecSQL;
  ZQ.SQL.Text:=' delete from passports                where      id='+inttostr(ActivPaspID);
  ZQ.ExecSQL;
  ActionPasspListRefresh.Execute;
  FreeAndNil(ZQ);
  ActivPaspID:=DataM.ZQPasspList.FieldByName('id').AsInteger;
end;

procedure TFormM.ActionPasspListRefreshExecute(Sender: TObject);
begin
  DataM.passListRefresh;
end;

procedure TFormM.ActionPassportCADExecute(Sender: TObject);
begin
 ActivPaspID:=DataM.ZQPasspList.FieldByName('id').AsInteger;
 PassportOpenCad(ActivPaspID);
end;

procedure TFormM.ActionPassportEditExecute(Sender: TObject);
begin
 ActivPaspID:=DataM.ZQPasspList.FieldByName('id').AsInteger;
 PassportOpen(ActivPaspID,True);
end;

procedure TFormM.ActionShowPaspExecute(Sender: TObject);
begin
   PanelPassport.Visible:=ActionShowPasp.Checked;
   if PanelPassport.Visible then
    begin
     PanelCAD.Align:=alRight;
     PanelMap.Align:=alRight;
    end
   else
   begin
     PanelCAD.Align:=alClient;
     PanelMap.Align:=alClient;
   end;
 end;
end.

