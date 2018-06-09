unit unit_frame_raport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Grids, Buttons,
  ActnList, StdCtrls, ComCtrls, Dialogs, Graphics, frameCad, framePaint,
  typePaspProp, typePaspBranch, unit_types_and_const, unit_m_data, ZDataset,
  fpspreadsheetgrid, fpsTypes;

const
  THICK_BORDER: TsCellBorderStyle = (LineStyle: lsThick; Color: clNavy);
  MEDIUM_BORDER: TsCellBorderSTyle = (LineStyle: lsMedium; Color: clRed);
  DOTTED_BORDER: TsCellBorderSTyle = (LineStyle: lsDotted; Color: clRed);

type
  
  { TFrame_Raport }

  TFrame_Raport = class(TFrame)
    ActionRapDataBranch: TAction;
    ActionRapDataProp: TAction;
    ActionRapDataDemo: TAction;
    ActionSaveRap: TAction;
    ActionAddGraph: TAction;
    ActionSelectRap: TAction;
    ActionList1: TActionList;
    BitBtn1: TBitBtn;
    BitBtn3: TBitBtn;
    CheckBoxGraphAdd: TCheckBox;
    ComboBox1: TComboBox;
    GroupBox1: TGroupBox;
    PageControl1: TPageControl;
    Panel1: TPanel;
    SaveDialog: TSaveDialog;
    StringGrid1: TStringGrid;
    WorksheetGrid: TsWorksheetGrid;
    TabSheetGrid: TTabSheet;
    TabSheetGraph: TTabSheet;
    procedure ActionAddGraphExecute(Sender: TObject);
    procedure ActionRapDataBranchExecute(Sender: TObject);
    procedure ActionRapDataDemoExecute(Sender: TObject);
    procedure ActionRapDataPropExecute(Sender: TObject);
    procedure ActionSaveRapExecute(Sender: TObject);
    procedure ActionSelectRapExecute(Sender: TObject);
  private
    { private declarations }
    pPassProp:TPassProp;
  public
    { public declarations }
    FrameCad: TFrameCad;
    lastRow:integer;
    constructor Create(TheOwner: TComponent;PassProp:TPassProp); //override;
  end;

implementation

{$R *.lfm}

{ TFrame_Raport }

procedure TFrame_Raport.ActionSaveRapExecute(Sender: TObject);
var
  err, fn: String;
  row, col: Cardinal;
  offsetX, offsetY, scaleX, scaleY: Double;
  stream:TMemoryStream;
begin
  if WorksheetGrid.Workbook = nil then
    exit;

  if WorksheetGrid.Workbook.Filename <>'' then begin
    fn := AnsiToUTF8(WorksheetGrid.Workbook.Filename);
    SaveDialog.InitialDir := ExtractFileDir(fn);
    SaveDialog.FileName := ChangeFileExt(ExtractFileName(fn), '');
  end;

  if SaveDialog.Execute then
  begin
    Screen.Cursor := crHourglass;
    try
      if ActionAddGraph.Checked then
      begin
        row:=lastRow+1;
        col:=0;
        offsetX:=0;
        offsetY:=0;
        scaleX:=0.02;
        scaleY:=0.02;
        stream:= TMemoryStream.Create;
        FrameCad.CadPaint.paintbmp.SaveToStream(stream);
        WorksheetGrid.Worksheet.WriteImage(row, col, stream, offsetX, offsetY, scaleX, scaleY);
        FreeAndNil(stream);
      end;
      WorksheetGrid.SaveToSpreadsheetFile(UTF8ToAnsi(SaveDialog.FileName));
      //WorksheetGrid.WorkbookSource.SaveToSpreadsheetFile(UTF8ToAnsi(SaveDialog.FileName));     // works as well
    finally
      Screen.Cursor := crDefault;
      // Show a message in case of error(s)
      err := WorksheetGrid.Workbook.ErrorMsg;
      if err <> '' then
        MessageDlg(err, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TFrame_Raport.ActionSelectRapExecute(Sender: TObject);
begin
  pPassProp := TPassProp.Create(strtoint(pPassProp.pass_id), 0, DataM.ZConnection1, True);
  //ActionRapDataDemo.Execute;
  ActionRapDataProp.Execute;
  ActionRapDataBranch.Execute;
end;

constructor TFrame_Raport.Create(TheOwner: TComponent; PassProp: TPassProp);
begin
  inherited Create(TheOwner);
  FrameCad := nil;
  pPassProp:= PassProp;
end;

procedure TFrame_Raport.ActionAddGraphExecute(Sender: TObject);
begin
  if ActionAddGraph.Checked then
  begin
    ActionAddGraph.Enabled:=false;
    if  FrameCad=nil then
     begin
      FrameCad:=TFrameCad.Create(TabSheetGraph);
      FrameCad.Parent:=TabSheetGraph;
      FrameCad.setPassport(strtoint(pPassProp.pass_id),authorization.UserID);
      FrameCad.Caption:='Построение прикреплено к таблице';
     end;
  end;
end;

procedure TFrame_Raport.ActionRapDataBranchExecute(Sender: TObject);
var
  i: integer;
  branch:TPassBranch;
  ZQBranches : TZQuery;
begin
  for i := 0 to pPassProp.ComponentCount - 1 do
  begin
    if not(pPassProp.Components[i] is TPassBranch) then Continue;
    branch := TPassBranch(pPassProp.Components[i]);
  
    WorksheetGrid.Cells[1,lastRow] := branch.branch_name;
    WorksheetGrid.MergeCells(1,lastRow, 2,lastRow);
    WorksheetGrid.HorAlignment[1,lastRow] := haCenter;
    WorksheetGrid.CellBorders[1,lastRow, 2,lastRow] := [cbSouth];
    WorksheetGrid.CellBorderStyles[1,lastRow, 2,lastRow, cbSouth] := THICK_BORDER;
    WorksheetGrid.BackgroundColors[1,lastRow, 2,lastRow] := RGBToColor(230, 230, 230);
    WorksheetGrid.CellFontColor[1,lastRow] := clNavy;
    WorksheetGrid.CellFontStyle[1,lastRow] := [fssBold];
    lastRow:=lastRow+1;
    
    WorksheetGrid.Cells[1,lastRow] := 'ID';
    WorksheetGrid.HorAlignment[1,lastRow] := haCenter;
    WorksheetGrid.CellFontStyle[1,lastRow] := [fssItalic];
    WorksheetGrid.CellFontColor[1,lastRow] := clNavy;
    WorksheetGrid.Cells[2,lastRow] := 'Объект';
    WorksheetGrid.HorAlignment[2,lastRow] := haCenter;
    WorksheetGrid.CellFontStyle[2,lastRow] := [fssItalic];
    WorksheetGrid.CellFontColor[2,lastRow] := clNavy;
    WorksheetGrid.Cells[3,lastRow] := 'Длина';
    WorksheetGrid.HorAlignment[3,lastRow] := haCenter;
    WorksheetGrid.CellFontStyle[3,lastRow] := [fssItalic];
    WorksheetGrid.CellFontColor[3,lastRow] := clNavy;
    WorksheetGrid.Cells[4,lastRow] := 'Радиус';
    WorksheetGrid.HorAlignment[4,lastRow] := haCenter;
    WorksheetGrid.CellFontStyle[4,lastRow] := [fssItalic];
    WorksheetGrid.CellFontColor[4,lastRow] := clNavy;
    WorksheetGrid.Cells[5,lastRow] := 'Год';
    WorksheetGrid.HorAlignment[5,lastRow] := haCenter;
    WorksheetGrid.CellFontStyle[5,lastRow] := [fssItalic];
    WorksheetGrid.CellFontColor[5,lastRow] := clNavy;
    WorksheetGrid.Cells[6,lastRow] := 'Элементы';
    WorksheetGrid.HorAlignment[6,lastRow] := haCenter;
    WorksheetGrid.CellFontStyle[6,lastRow] := [fssItalic];
    WorksheetGrid.CellFontColor[6,lastRow] := clNavy;
    lastRow:=lastRow+1;

    
    ZQBranches:=TZQuery.Create(nil);
    ZQBranches.Connection:=DataM.ZConnection1;
    ZQBranches.SQL.Add(GetSQL('raport_branch',branch.branch_id));
    ZQBranches.Open;
    ZQBranches.First;
    while not ZQBranches.EOF do begin
      WorksheetGrid.Cells[1,lastRow] := ZQBranches.FieldByName('id').AsString;
      WorksheetGrid.Cells[2,lastRow] := ZQBranches.FieldByName('obj_type_name').AsString; 
      WorksheetGrid.Cells[3,lastRow] := ZQBranches.FieldByName('length').AsString; 
      WorksheetGrid.Cells[4,lastRow] := ZQBranches.FieldByName('rad').AsString; 
      WorksheetGrid.Cells[5,lastRow] := ZQBranches.FieldByName('year').AsString; 
      WorksheetGrid.Cells[6,lastRow] := ZQBranches.FieldByName('elem').AsString; 
      lastRow:=lastRow+1;
      ZQBranches.Next;
    end;
  FreeAndNil(ZQBranches);
  end;
end;

procedure TFrame_Raport.ActionRapDataDemoExecute(Sender: TObject);
begin
  // Add some cells and formats
  WorksheetGrid.ColWidths[1] := 180;
  WorksheetGrid.ColWidths[2] := 100;

  WorksheetGrid.Cells[1,1] := 'This is a demo';
  WorksheetGrid.MergeCells(1,1, 2,1);
  WorksheetGrid.HorAlignment[1,1] := haCenter;
  WorksheetGrid.CellBorders[1,1, 2,1] := [cbSouth];
  WorksheetGrid.CellBorderStyles[1,1, 2,1, cbSouth] := THICK_BORDER;
  WorksheetGrid.BackgroundColors[1,1, 2,1] := RGBToColor(220, 220, 220);
  WorksheetGrid.CellFontColor[1,1] := clNavy;
  WorksheetGrid.CellFontStyle[1,1] := [fssBold];

  WorksheetGrid.Cells[1,2] := 'Number:';
  WorksheetGrid.HorAlignment[1,2] := haRight;
  WorksheetGrid.CellFontStyle[1,2] := [fssItalic];
  WorksheetGrid.CellFontColor[1,2] := clNavy;
  WorksheetGrid.Cells[2,2] := 1.234;

  WorksheetGrid.Cells[1,3] := 'Date:';
  WorksheetGrid.HorAlignment[1,3] := haRight;
  WorksheetGrid.CellFontStyle[1,3] := [fssItalic];
  WorksheetGrid.CellFontColor[1,3] := clNavy;
  WorksheetGrid.NumberFormat[2,3] := 'mmm dd, yyyy';
  WorksheetGrid.Cells[2,3] := date;

  WorksheetGrid.Cells[1,4] := 'Time:';
  WorksheetGrid.HorAlignment[1,4] := haRight;
  WorksheetGrid.CellFontStyle[1,4] := [fssItalic];
  WorksheetGrid.CellFontColor[1,4] := clNavy;
  WorksheetGrid.NumberFormat[2,4] := 'hh:nn';
  WorksheetGrid.Cells[2,4] := now();

  WorksheetGrid.Cells[1,5] := 'Rich text:';
  WorksheetGrid.HorAlignment[1,5] := haRight;
  WorksheetGrid.CellFontStyle[1,5] := [fssItalic];
  WorksheetGrid.CellFontColor[1,5] := clNavy;
  WorksheetGrid.Cells[2,5] := '100 cm<sup>2</sup>';

  WorksheetGrid.Cells[1,6] := 'Formula:';
  WorksheetGrid.HorAlignment[1,6] := haRight;
  WorksheetGrid.CellFontStyle[1,6] := [fssItalic];
  WorksheetGrid.CellFontColor[1,6] := clNavy;
  WorksheetGrid.Cells[2,6] := '=B2^2*PI()';
  WorksheetGrid.CellComment[2,6] := 'Area of the circle with radius given in cell B2';
  WorksheetGrid.NumberFormat[2,6] := '0.000';
  lastRow:=6;
end;

procedure TFrame_Raport.ActionRapDataPropExecute(Sender: TObject);
var
  pasType:string;
begin
  WorksheetGrid.ColWidths[1] := 150;
  WorksheetGrid.ColWidths[2] := 150;
  lastRow:=1;
  
  WorksheetGrid.Cells[1,lastRow] := pPassProp.pass_name;
  WorksheetGrid.MergeCells(1,lastRow, 2,lastRow);
  WorksheetGrid.HorAlignment[1,lastRow] := haCenter;
  WorksheetGrid.CellBorders[1,lastRow, 2,lastRow] := [cbSouth];
  WorksheetGrid.CellBorderStyles[1,lastRow, 2,lastRow, cbSouth] := THICK_BORDER;
  WorksheetGrid.BackgroundColors[1,lastRow, 2,lastRow] := RGBToColor(220, 220, 220);
  WorksheetGrid.CellFontColor[1,lastRow] := clNavy;
  WorksheetGrid.CellFontStyle[1,lastRow] := [fssBold];
  lastRow:=lastRow+1;
  
  WorksheetGrid.Cells[1,lastRow] := 'Дата формирования:';
  WorksheetGrid.HorAlignment[1,lastRow] := haRight;
  WorksheetGrid.CellFontStyle[1,lastRow] := [fssItalic];
  WorksheetGrid.CellFontColor[1,lastRow] := clNavy;
  WorksheetGrid.HorAlignment[2,lastRow] := haCenter;
  WorksheetGrid.NumberFormat[2,lastRow] := 'hh:nn dd.mm.yyyy';
  WorksheetGrid.Cells[2,lastRow] := now();
  lastRow:=lastRow+1;
  
  WorksheetGrid.Cells[1,lastRow] := 'Тип паспорта:';
  WorksheetGrid.HorAlignment[1,lastRow] := haRight;
  WorksheetGrid.CellFontStyle[1,lastRow] := [fssItalic];
  WorksheetGrid.CellFontColor[1,lastRow] := clNavy;
  WorksheetGrid.HorAlignment[2,lastRow] := haLeft;
  case StrToInt(pPassProp.pass_type)of
  0: pasType:='Фрагмент';
  1: pasType:='Участок';
  2: pasType:='Узел';
  3: pasType:='Эпюр';
  end;
  WorksheetGrid.Cells[2,lastRow] := pasType;
  lastRow:=lastRow+1;
  
  WorksheetGrid.Cells[1,lastRow] := 'Год постройки:';
  WorksheetGrid.HorAlignment[1,lastRow] := haRight;
  WorksheetGrid.CellFontStyle[1,lastRow] := [fssItalic];
  WorksheetGrid.CellFontColor[1,lastRow] := clNavy;
  WorksheetGrid.HorAlignment[2,lastRow] := haLeft;
  WorksheetGrid.Cells[2,lastRow] := pPassProp.year_built;
  lastRow:=lastRow+1;

  WorksheetGrid.Cells[1,lastRow] := 'Пути трамвая по:';
  WorksheetGrid.HorAlignment[1,lastRow] := haRight;
  WorksheetGrid.CellFontStyle[1,lastRow] := [fssItalic];
  WorksheetGrid.CellFontColor[1,lastRow] := clNavy;
  WorksheetGrid.HorAlignment[2,lastRow] := haLeft;
  WorksheetGrid.Cells[2,lastRow] := pPassProp.way;
  lastRow:=lastRow+1;

  WorksheetGrid.Cells[1,lastRow] := 'Комментарии:';
  WorksheetGrid.HorAlignment[1,lastRow] := haRight;
  WorksheetGrid.CellFontStyle[1,lastRow] := [fssItalic];
  WorksheetGrid.CellFontColor[1,lastRow] := clNavy;
  WorksheetGrid.HorAlignment[2,lastRow] := haLeft;
  WorksheetGrid.Cells[2,lastRow] := pPassProp.comment;
end;

end.

