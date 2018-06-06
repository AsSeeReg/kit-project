unit unit_frame_set_users;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, Forms, Controls, ExtCtrls, StdCtrls, Grids,
  ComCtrls, ActnList, KGrids, ZDataset, rxdbgrid, DBGrids, Graphics,
  unit_types_and_const;

type
  
  { TFrameSetUsers }

  TFrameSetUsers = class(TFrame)
    ActionPostEdit: TAction;
    ActionSelectUser: TAction;
    ActionDelUser: TAction;
    ActionAddUser: TAction;
    ActionList1: TActionList;
    ButtonPost: TButton;
    CheckBoxComp4: TCheckBox;
    CheckBoxComp3: TCheckBox;
    CheckBoxComp2: TCheckBox;
    CheckBoxComp1: TCheckBox;
    CheckBoxPassword: TCheckBox;
    DSUsers: TDataSource;
    EditPas1: TEdit;
    EditPas2: TEdit;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    Memo5: TMemo;
    PanelEdit: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    RxDBGridUsers: TRxDBGrid;
    StringGridUserSett: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ZTUsers: TZTable;
    ZTUserscompetency1: TBooleanField;
    ZTUserscompetency2: TBooleanField;
    ZTUserscompetency3: TBooleanField;
    ZTUserscompetency4: TBooleanField;
    ZTUsersfirst_name: TStringField;
    ZTUsersfirst_name_2: TStringField;
    ZTUsersid: TLargeintField;
    ZTUserslast_name: TStringField;
    ZTUserslogin: TStringField;
    ZTUserspasHash: TStringField;
    ZTUsersshort_name: TStringField;
    procedure ActionAddUserExecute(Sender: TObject);
    procedure ActionDelUserExecute(Sender: TObject);
    procedure ActionPostEditExecute(Sender: TObject);
    procedure ActionSelectUserExecute(Sender: TObject);
    procedure ButtonPostClick(Sender: TObject);
    procedure CheckBoxPasswordChange(Sender: TObject);
    procedure PasswordChange(Sender: TObject);
    procedure RxDBGridUsersCellClick(Column: TColumn);
    procedure RxDBGridUsersColEnter(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); //override;
  end;

implementation

{$R *.lfm}

{ TFrameSetUsers }

procedure TFrameSetUsers.ActionAddUserExecute(Sender: TObject);
begin
  ZTUsers.Last;
  ZTUsers.Insert;
  ZTUsers.FieldByName('login').AsString:='User '+inttostr(ZTUsers.RecordCount+1);
  ZTUsers.Post;
end;

procedure TFrameSetUsers.ActionDelUserExecute(Sender: TObject);
begin
  if ZTUsers.FieldByName('id').AsInteger<1 then exit;//системная учётка
  ZTUsers.Delete;
end;

procedure TFrameSetUsers.ActionPostEditExecute(Sender: TObject);
begin
  ZTUsers.Edit;
  try
    if CheckBoxComp1.Enabled
    then ZTUsers.FieldByName('competency1').AsBoolean := CheckBoxComp1.Checked;
    if CheckBoxComp2.Enabled
    then ZTUsers.FieldByName('competency2').AsBoolean := CheckBoxComp2.Checked;
    if CheckBoxComp3.Enabled
    then ZTUsers.FieldByName('competency3').AsBoolean := CheckBoxComp3.Checked;
    if CheckBoxComp4.Enabled
    then ZTUsers.FieldByName('competency4').AsBoolean := CheckBoxComp4.Checked;
    
    if  CheckBoxPassword.Checked then 
    begin
      if (EditPas1.Text = EditPas2.Text) and (EditPas1.Text <>'') then
      ZTUsers.FieldByName('PasHash').AsString := GetHash(EditPas1.Text);
    end;
    
    ZTUsers.FieldByName('login').AsString := StringGridUserSett.Cells[1,0];
    ZTUsers.FieldByName('last_name').AsString := StringGridUserSett.Cells[1,1];
    ZTUsers.FieldByName('first_name').AsString := StringGridUserSett.Cells[1,2];
    ZTUsers.FieldByName('first_name_2').AsString := StringGridUserSett.Cells[1,3];
    ZTUsers.FieldByName('short_name').AsString := StringGridUserSett.Cells[1,4];
    
    ZTUsers.Post;
  except
   ZTUsers.Cancel;
  end;
end;

procedure TFrameSetUsers.ActionSelectUserExecute(Sender: TObject);
var
  CanEdit:Boolean;
  FirstUser:Boolean;
begin
  StringGridUserSett.Cells[1,0]:=ZTUsers.FieldByName('login').AsString;
  StringGridUserSett.Cells[1,1]:=ZTUsers.FieldByName('last_name').AsString;
  StringGridUserSett.Cells[1,2]:=ZTUsers.FieldByName('first_name').AsString;
  StringGridUserSett.Cells[1,3]:=ZTUsers.FieldByName('first_name_2').AsString;
  StringGridUserSett.Cells[1,4]:=ZTUsers.FieldByName('short_name').AsString;
  
  CheckBoxComp1.Checked:=ZTUsers.FieldByName('competency1').AsBoolean;
  CheckBoxComp1.Enabled:=authorization.competency1;
  CheckBoxComp2.Checked:=ZTUsers.FieldByName('competency2').AsBoolean;
  CheckBoxComp2.Enabled:=authorization.competency1;
  CheckBoxComp3.Checked:=ZTUsers.FieldByName('competency3').AsBoolean;
  CheckBoxComp3.Enabled:=authorization.competency1;
  CheckBoxComp4.Checked:=ZTUsers.FieldByName('competency4').AsBoolean;
  CheckBoxComp4.Enabled:=authorization.competency1;
  FirstUser:= ZTUsers.FieldByName('id').AsInteger<1;
  CanEdit:= (ZTUsers.FieldByName('id').AsInteger=authorization.UserID) or (authorization.competency1);
  PanelEdit.Enabled:=CanEdit and not FirstUser;
end;

procedure TFrameSetUsers.ButtonPostClick(Sender: TObject);
begin
  ActionPostEdit.Execute;
end;

procedure TFrameSetUsers.CheckBoxPasswordChange(Sender: TObject);
begin
  if  CheckBoxPassword.Checked then 
  begin
    EditPas1.Clear;
    EditPas2.Clear;
  end;
end;

procedure TFrameSetUsers.PasswordChange(Sender: TObject);
begin
  if EditPas1.text = EditPas2.text 
  then EditPas2.Color:=clDefault
  else EditPas2.Color:=clRed;
end;

procedure TFrameSetUsers.RxDBGridUsersCellClick(Column: TColumn);
begin
  ActionSelectUser.Execute;
end;

procedure TFrameSetUsers.RxDBGridUsersColEnter(Sender: TObject);
begin
end;

constructor TFrameSetUsers.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  ZTUsers.Open;
  ActionAddUser.Enabled:=authorization.competency1;
  ActionDelUser.Enabled:=authorization.competency1;
  ActionSelectUser.Execute;
end;

end.

