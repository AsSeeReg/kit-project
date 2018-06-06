unit unit_set_repport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, Grids;

type
  
  { TFrameSetReport }

  TFrameSetReport = class(TFrame)
    Button1: TButton;
    StringGrid1: TStringGrid;
  private
    { private declarations }
  public
    { public declarations }
  end;

implementation

{$R *.lfm}

end.

