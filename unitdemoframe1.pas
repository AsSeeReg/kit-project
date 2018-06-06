unit unitDemoFrame1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, Forms, Controls, DBGrids, unit_m_data,
  ZDataset;

type
  
  { TDemoFrame1 }

  TDemoFrame1 = class(TFrame)
    DBGridBranches: TDBGrid;
    DSDemo1: TDataSource;
    ZTDemo1: TZTable;
    ZTDemo1id: TLargeintField;
    ZTDemo1length: TFloatField;
    ZTDemo1pass_id: TStringField;
    ZTDemo1pos: TFloatField;
    ZTDemo1value: TFloatField;
    procedure ZTDemo1BeforePost(DataSet: TDataSet);
  private
    { private declarations }
  public
    { public declarations }
    pass_id:integer;
    user_id:integer;
    constructor Create(TheOwner: TComponent;p_pass_id,p_user_id:integer); //override;
  end;

implementation

{$R *.lfm}

{ TDemoFrame1 }

procedure TDemoFrame1.ZTDemo1BeforePost(DataSet: TDataSet);
begin
    ZTDemo1.FieldByName('pass_id').AsInteger:=pass_id;
end;

constructor TDemoFrame1.Create(TheOwner: TComponent; p_pass_id, 
  p_user_id: integer);
begin
  inherited Create(TheOwner);
  pass_id:= p_pass_id;
  user_id:= p_user_id;
  ZTDemo1.Filter:='pass_id='+inttostr(pass_id);
  ZTDemo1.Open;
  self.Parent:=TWinControl(TheOwner);
end;

end.

