unit framePaint;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, Dialogs,
  Spin, ActnList
, Graphics
, Clipbrd
, LCLIntf
, LCLType, unit_types_and_const
  ;

const
    backgroundColor:TColor = $e2f7df;
    ColorArr: Array [0..4] of TColor = (
    $00FF8080,
    $0037FF9B,
    $00FFFF80,
    $0095B8FF,
    $0088FFFF
    );

type
  
  { TFrameCadPaint }

  TFrameCadPaint = class(TFrame)
    ActionPicResize: TAction;
    ActionClpPaste: TAction;
    ActionClpCopy: TAction;
    ActionSave: TAction;
    ActionOpen: TAction;
    ActionNew: TAction;
    ActionList1: TActionList;
    btnCopy: TBitBtn;
    btnNew: TBitBtn;
    btnOpen: TBitBtn;
    btnPaste: TBitBtn;
    btnResize: TBitBtn;
    btnSave: TBitBtn;
    CanvasScroller: TScrollBox;
    ImageList1: TImageList;
    LineColor: TColorButton;
    MyCanvas: TPaintBox;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    SaveDialog1: TSaveDialog;
    SpinEdit1: TSpinEdit;
    ToolColorDropper: TSpeedButton;
    ToolFill: TSpeedButton;
    ToolMove: TSpeedButton;
    ToolLine: TSpeedButton;
    ToolText: TSpeedButton;
    ToolOval: TSpeedButton;
    ToolPencil: TSpeedButton;
    ToolRect: TSpeedButton;
    ToolTriangle: TSpeedButton;
    procedure ActionClpCopyExecute(Sender: TObject);
    procedure ActionNewExecute(Sender: TObject);
    procedure ActionOpenExecute(Sender: TObject);
    procedure ActionClpPasteExecute(Sender: TObject);
    procedure ActionPicResizeExecute(Sender: TObject);
    procedure ActionSaveExecute(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure LineColorColorChanged(Sender: TObject);
    procedure MyCanvasMouseDown(Sender: TObject; Button: TMouseButton; 
      Shift: TShiftState; X, Y: Integer);
    procedure MyCanvasMouseMove(Sender: TObject; Shift: TShiftState; X, 
      Y: Integer);
    procedure MyCanvasMouseUp(Sender: TObject; Button: TMouseButton; 
      Shift: TShiftState; X, Y: Integer);
    procedure MyCanvasPaint(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
  private
    { private declarations }
    MouseIsDown: Boolean;
    PrevX, PrevY: Integer;
  public
    { public declarations }
    paintbmp: TBitmap;
    constructor Create(TheOwner: TComponent); override;
    procedure resizeCadCanvas(pWidth,pHeight: integer);
    procedure paintLine(x1,y1,x2,y2:integer);
    procedure paintText(x1,y1:Double;pText:string);
    procedure paintRect(x1,y1,x2,y2:integer);
    //procedure paintRibbon(x1,x2,h:integer);
    procedure paintPoint(x1,y1,r:integer);
    procedure paintArc(ax,ay,bx,by,cx,cy:single);
  end;

implementation

{$R *.lfm}

{ TFrameCadPaint }

procedure TFrameCadPaint.ActionNewExecute(Sender: TObject);
begin
      // if our bitmap is already Create-ed (TBitmap.Create)
    // then start fresh
    if paintbmp <> nil then
      paintbmp.Destroy;

    paintbmp := TBitmap.Create;

    paintbmp.SetSize(Screen.Width, Screen.Height);
    paintbmp.Canvas.FillRect(0,0,paintbmp.Width,paintbmp.Height);

    paintbmp.Canvas.Brush.Style:=bsClear;
    MyCanvas.Canvas.Brush.Style:=bsClear;

    paintbmp.Canvas.Pen.Color:=LineColor.ButtonColor;
    paintbmp.Canvas.Pen.Width:=SpinEdit1.Value;

    MyCanvasPaint(Sender);
end;

procedure TFrameCadPaint.ActionClpCopyExecute(Sender: TObject);
begin
  Clipboard.Assign(paintbmp);
end;

procedure TFrameCadPaint.ActionOpenExecute(Sender: TObject);
begin
  OpenDialog1.Execute;

  if (OpenDialog1.Files.Count > 0) then begin

    if (FileExistsUTF8(OpenDialog1.FileName)) then begin
      paintbmp.LoadFromFile(OpenDialog1.FileName);
      MyCanvasPaint(Sender);

    end else begin
      ShowMessage('File is not found. You will have to open an existing file.');

    end;

  end;
end;

procedure TFrameCadPaint.ActionClpPasteExecute(Sender: TObject);
var
  tempBitmap: TBitmap;
  PictureAvailable: boolean = False;
begin

  // we determine if any image is on clipboard
  if (Clipboard.HasFormat(PredefinedClipboardFormat(pcfDelphiBitmap))) or
    (Clipboard.HasFormat(PredefinedClipboardFormat(pcfBitmap))) then
    PictureAvailable := True;


  if PictureAvailable then
  begin

    tempBitmap := TBitmap.Create;

    if Clipboard.HasFormat(PredefinedClipboardFormat(pcfDelphiBitmap)) then
      tempBitmap.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfDelphiBitmap));
    if Clipboard.HasFormat(PredefinedClipboardFormat(pcfBitmap)) then
      tempBitmap.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfBitmap));

    // so we use assign, it works perfectly
    paintbmp.Assign(tempBitmap);
    MyCanvasPaint(Sender);

    tempBitmap.Free;

  end else begin

    ShowMessage('No image is found on clipboard!');

  end;
end;

procedure TFrameCadPaint.ActionPicResizeExecute(Sender: TObject);
var
  ww, hh: string;
  pWidth, pHeight: Integer;
  Code: Integer;
begin
  
  ww:=InputBox('Resize Canvas', 'Please enter the desired new width:', IntToStr(paintbmp.Width));
  Val(ww, pWidth, Code);
  if Code <> 0 then begin
    ShowMessage('Error! Try again with an integer value of maximum '+inttostr(High(Integer)));
    Exit; // skip the rest of the code
  end;

  hh:=InputBox('Resize Canvas', 'Please enter the desired new height:', IntToStr(paintbmp.Height));
  Val(hh, pHeight, Code);
  if Code <> 0 then begin
    ShowMessage('Error! Try again with an integer value of maximum '+inttostr(High(Integer)));
    Exit; // skip the rest of the code
  end;
  resizeCadCanvas(pWidth,pHeight);
end;

procedure TFrameCadPaint.ActionSaveExecute(Sender: TObject);
begin
  SaveDialog1.Execute;

  if SaveDialog1.Files.Count > 0 then begin
    // if the user enters a file name without a .bmp
    // extension, we will add it
    if RightStr(SaveDialog1.FileName, 4) <> '.bmp' then
      SaveDialog1.FileName:=SaveDialog1.FileName+'.bmp';

    paintbmp.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TFrameCadPaint.btnCopyClick(Sender: TObject);
begin

end;

procedure TFrameCadPaint.LineColorColorChanged(Sender: TObject);
begin
  paintbmp.Canvas.Pen.Color:=LineColor.ButtonColor;
  MyCanvas.Canvas.Pen.Color:=LineColor.ButtonColor;
end;

procedure TFrameCadPaint.MyCanvasMouseDown(Sender: TObject; 
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseIsDown := True;
  PrevX := X;
  PrevY := Y;
end;

procedure TFrameCadPaint.MyCanvasMouseMove(Sender: TObject; Shift: TShiftState; 
  X, Y: Integer);
begin
  if MouseIsDown = true then begin

    //// Pencil Tool ////
    if ToolPencil.Down = true then begin
      paintbmp.Canvas.Line(PrevX, PrevY, X, Y);
      MyCanvas.Canvas.Line(PrevX, PrevY, X, Y);

      PrevX:=X;
      PrevY:=Y;

    //// Line Tool ////
    end else if ToolLine.Down = true then begin
      // we are clearing previous preview drawing
      MyCanvasPaint(Sender);
      // we draw a preview line
      MyCanvas.Canvas.Line(PrevX, PrevY, X, Y);

    //// Rectangle Tool ////
    end else if ToolRect.Down = true then begin
      MyCanvasPaint(Sender);
      MyCanvas.Canvas.Rectangle(PrevX, PrevY, X, Y);

    //// Oval Tool ////
    end else if ToolOval.Down = true then begin
      MyCanvasPaint(Sender);
      MyCanvas.Canvas.Ellipse(PrevX, PrevY, X, Y);

    //// Triangle Tool ////
    end else if ToolTriangle.Down = true then begin
      MyCanvasPaint(Sender);
      MyCanvas.Canvas.Line(PrevX,Y,PrevX+((X-PrevX) div 2), PrevY);
      MyCanvas.Canvas.Line(PrevX+((X-PrevX) div 2),PrevY,X,Y);
      MyCanvas.Canvas.Line(PrevX,Y,X,Y);
      //MyCanvas.Canvas.Ellipse(PrevX, PrevY, X, Y);
    end else if ToolText.Down = true then begin
      MyCanvasPaint(Sender);
      MyCanvas.Canvas.TextOut(PrevX, PrevY,'Текст');
    end;
  end;
end;

procedure TFrameCadPaint.MyCanvasMouseUp(Sender: TObject; Button: TMouseButton; 
  Shift: TShiftState; X, Y: Integer);
var
  TempColor: TColor;
begin
  if MouseIsDown then begin

    //// Line tool
    if ToolLine.Down = true then begin
      paintbmp.Canvas.Line(PrevX, PrevY, X, Y);
    //// Rect
    end else if ToolRect.Down = true then begin
      paintbmp.Canvas.Rectangle(PrevX, PrevY, X, Y);
    //// Oval tool
    end else if ToolOval.Down = true then begin
      paintbmp.Canvas.Ellipse(PrevX, PrevY, X, Y);
    //// Triangle tool
    end else if ToolTriangle.Down = true then begin
      paintbmp.Canvas.Line(PrevX,Y,PrevX+((X-PrevX) div 2), PrevY);
      paintbmp.Canvas.Line(PrevX+((X-PrevX) div 2),PrevY,X,Y);
      paintbmp.Canvas.Line(PrevX,Y,X,Y);
    //// Color Dropper Tool ////
    end else if ToolColorDropper.Down = true then begin
      LineColor.ButtonColor:=MyCanvas.Canvas.Pixels[X,Y];
    //// (Flood) Fill Tool ////
    end else if ToolFill.Down = true then begin
      TempColor := paintbmp.Canvas.Pixels[X, Y];
      paintbmp.Canvas.Brush.Style := bsSolid;
      paintbmp.Canvas.Brush.Color := LineColor.ButtonColor;
      paintbmp.Canvas.FloodFill(X, Y, TempColor, fsSurface);
      paintbmp.Canvas.Brush.Style := bsClear;
      MyCanvasPaint(Sender);
    end else if ToolText.Down = true then begin
      paintbmp.Canvas.TextOut(PrevX, PrevY,'Текст');
      MyCanvasPaint(Sender);
    end;

  end;
  MouseIsDown:=False;
end;

procedure TFrameCadPaint.MyCanvasPaint(Sender: TObject);
begin
  if MyCanvas.Width<>paintbmp.Width then begin
    MyCanvas.Width:=paintbmp.Width;
    // the resize will run this function again
    // so we skip the rest of the code
    Exit;
  end;
  if MyCanvas.Height<>paintbmp.Height then begin
    MyCanvas.Height:=paintbmp.Height;
    // the resize will run this function again
    // so we skip the rest of the code
    Exit;
  end;
  MyCanvas.Canvas.Draw(0,0,paintbmp);
end;

procedure TFrameCadPaint.SpinEdit1Change(Sender: TObject);
begin
  paintbmp.Canvas.Pen.Width:=SpinEdit1.Value;
  MyCanvas.Canvas.Pen.Width:=SpinEdit1.Value;
end;

constructor TFrameCadPaint.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  // We create a new file/canvas/document when
  // it starts up
  ActionNew.Execute;
end;

procedure TFrameCadPaint.resizeCadCanvas(pWidth, pHeight: integer);
var
  tempColor:TColor;
begin
  if pWidth <0 then pWidth :=paintbmp.Width;
  if pHeight<0 then pHeight:=paintbmp.Height;
  tempColor:= paintbmp.Canvas.Brush.Color;
  paintbmp.Canvas.Brush.Color:= backgroundColor;
  //MyCanvas.Canvas.Brush.Color:= backgroundColor;
  //paintbmp.Canvas.Pen.Color:= backgroundColor;
  MyCanvas.Color:= backgroundColor;
  paintbmp.SetSize(pWidth, pHeight);
  paintbmp.Canvas.Brush.Color:= tempColor;
  MyCanvas.Color:= tempColor;  
  MyCanvasPaint(nil);
end;

procedure TFrameCadPaint.paintLine(x1, y1, x2, y2: integer);
begin
      MyCanvasPaint(nil);
      paintbmp.Canvas.Line(x1, y1, x2, y2);
      //MyCanvas.Canvas.Line(x1, y1, x2, y2);
end;

procedure TFrameCadPaint.paintText(x1, y1: Double; pText: string);
begin
  MyCanvasPaint(nil);
  paintbmp.Canvas.TextOut(round(x1), round(y1),pText);
end;

procedure TFrameCadPaint.paintRect(x1, y1, x2, y2: integer);
begin
  MyCanvasPaint(nil);
  paintbmp.Canvas.Rectangle(x1, y1, x2, y2);
end;

procedure TFrameCadPaint.paintPoint(x1, y1, r: integer);
begin
  MyCanvasPaint(nil);
  paintbmp.Canvas.Ellipse(x1-r, y1-r, x1+r, y1+r); 
end;

procedure TFrameCadPaint.paintArc(ax, ay, bx, by, cx, cy: single);
var
  ta,tb,tc,td,te,tf,tg,R,Ox,Oy:Single;
  //O:TPoint;
begin
    //  if shape is TMyElliArc then
    //begin
      //A:=shape.GetPoint(0);
      //A.X:=A.X*zoom;
      //A.Y:=A.Y*zoom;
      //B:=shape.GetPoint(1);
      //B.X:=B.X*zoom;
      //B.Y:=B.Y*zoom;
      //C:=shape.GetPoint(2);
      //C.X:=C.X*zoom;
      //C.Y:=C.Y*zoom;
       tA := Bx - Ax;
       tB := By - Ay;
       tC := Cx - Ax;
       tD := Cy - Ay;
       tE := tA * (Ax + Bx) + tB * (Ay + By);
       tF := tC * (Ax + Cx) + tD * (Ay + Cy);
       tG := 2 * (tA * (Cy - By) - tB * (Cx - Bx));
       if tG = 0 then Exit;
       Ox := Round((tD * tE - tB * tF) / tG);
       Oy := Round((tA * tF - tC * tE) / tG);
       R:=sqrt(sqr(oX-ax)+sqr(oY-ay));
      if AY<OY
       then paintbmp.Canvas.Arc(Round((oX-R)),Round((oY-R)),Round((oX+R)),Round((oY+R)),Round(CX),Round(CY),Round(AX),Round(AY))
       else paintbmp.Canvas.Arc(Round((oX-R)),Round((oY-R)),Round((oX+R)),Round((oY+R)),Round(AX),Round(AY),Round(CX),Round(CY));
    //end;
end;

end.

