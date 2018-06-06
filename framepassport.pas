unit FramePassport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ComCtrls, ActnList,
  StdCtrls, attabs, FramePassportObjects, FramePassportProperties,
  unit_types_and_const, unit_m_data, unitDemoFrame1, typePaspProp, KGrids;

type

  { TFramePassport }

  TFramePassport = class(TFrame)
    ActionPassExport: TAction;
    ActionPassPaint: TAction;
    ActionPassEdit: TAction;
    ActionList1: TActionList;
    PageControlPassport: TPageControl;
    TabSheet2: TTabSheet;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    procedure ActionPassEditExecute(Sender: TObject);
  private
    { private declarations }
    propEdit:Boolean;
    procedure setEdit(AValue: Boolean);
  public
    { public declarations }
    TabIndex:integer;
    PasspID:integer;
    UserID :integer;
    property Edit    :Boolean read propEdit  write setEdit; 
    constructor Create(TheOwner: TComponent;TabOwner:TATTabs;pPasspID,pUserID:integer); //override;
  end;

implementation

{$R *.lfm}

{ TFramePassport }
var
  FPassportProperties:TFramePassportProperties;

procedure TFramePassport.ActionPassEditExecute(Sender: TObject);
begin
  ActionPassEdit.Checked:= not ActionPassEdit.Checked;
  Edit:=ActionPassEdit.Checked;
end;

procedure TFramePassport.setEdit(AValue: Boolean);
begin
  if propEdit=AValue then Exit;
  propEdit:=AValue;
  FormSetEdit(propEdit,self);
  ActionPassEdit.Checked:=propEdit;
  //FPassportProperties.Edit:=propEdit;
end;

constructor TFramePassport.Create(TheOwner: TComponent; TabOwner: TATTabs;
  pPasspID,pUserID: integer);
var
  i:integer;
  TabSheet:TTabSheet;
  pass:TPassProp;
  FDemoFrame1:TDemoFrame1;
  strCap:string;
begin
  inherited Create(TheOwner);
  self.Parent:=TWinControl(TheOwner);
  pass:= TPassProp.Create(pPasspID,pUserID,DataM.ZConnection1);
  pPasspID:=strtoint(pass.pass_id);
  self.Name:='FramePassportID'+inttostr(pPasspID);
  self.PasspID:=pPasspID;
  self.UserID :=pUserID;
  self.propEdit:= True;
  self.ActionPassEdit.Enabled := (authorization.CanEdit);
  { TODO : Заглушка - переделать тиб из БД }
  //TabOwner.AddTab(-1,'Тип-'+pass.pass_type+': '+pass.pass_name+' (ред.)');
  case StrToInt(pass.pass_type) of
  1:strCap:='Участок '+': '+pass.pass_name;   
  2:strCap:='Узел '+': '+pass.pass_name;   
  3:strCap:='Эпюр '+': '+pass.pass_name;    
  end;
  TabOwner.AddTab(-1,strCap);
  TabOwner.TabIndex:=TabOwner.TabCount-1;
  freeandnil(pass); //  pass.Destroy;
   for i:=(PageControlPassport.PageCount-1) downto 0
    do PageControlPassport.Pages[i].Destroy;
   self.TabIndex:= TabOwner.TabIndex;
   TabSheet:=PageControlPassport.AddTabSheet;
   TabSheet.Caption:='Свойства';
   FPassportProperties:=TFramePassportProperties.Create(TabSheet);
   FPassportProperties.pass_id:=PasspID;
   FPassportProperties.user_id:=UserID;
   FPassportProperties.Parent:=TabSheet;
   //FPassportProperties.Edit:=Edit;
   
   TabSheet:=PageControlPassport.AddTabSheet;
   TabSheet.Caption:='Продольный профиль';
   FDemoFrame1:=  TDemoFrame1.Create(TabSheet,PasspID,UserID);
   TabSheet:=PageControlPassport.AddTabSheet;
   TabSheet.Caption:='Специальные объекты';
   
   FPassportProperties.PageControlPassport:=PageControlPassport;
   FPassportProperties.getDate;
end;

end.

