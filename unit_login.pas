unit unit_login;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, unit_m, unit_types_and_const;

type

  { TFormLogin }

  TFormLogin = class(TForm)
    BitBtn1: TBitBtn;
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
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
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

procedure TFormLogin.BitBtn1Click(Sender: TObject);
var CheckLicRes:string;
begin
  CheckLicRes:=CheckLic(EdLogin.text,GetHash(EdPas.text));
  if CheckLicRes<>'' then
  begin
   ModalResult:=mrNone;
   Caption:=CheckLicRes;
   exit;
  end;
  FormM.ActionReconnectExecute(nil);
end;

procedure TFormLogin.BitBtn2Click(Sender: TObject);
begin
end;

end.

