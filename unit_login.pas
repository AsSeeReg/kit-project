unit unit_login;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, ActnList, unit_m, unit_types_and_const, unit_m_data;

type

  { TFormLogin }

  TFormLogin = class(TForm)
    BitBtnOk: TBitBtn;
    BitBtn2: TBitBtn;
    EdLogin: TEdit;
    EdPas: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    procedure BitBtnOkClick(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormLogin: TFormLogin;

implementation

{$R *.lfm}

{ TFormLogin }

procedure TFormLogin.BitBtnOkClick(Sender: TObject);
var CheckLicRes:string;
begin
  FormM.ActionReconnectExecute(nil);
  CheckLicRes:=CheckLic(EdLogin.text,GetHash(EdPas.text));
  if CheckLicRes<>'' then
  begin
   ModalResult:=mrNone;
   Caption:=CheckLicRes;
   exit;
  end;
end;

procedure TFormLogin.BitBtn2Click(Sender: TObject);
begin
end;

procedure TFormLogin.FormKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  begin
     BitBtnOk.Click;
  end;
end;

end.

