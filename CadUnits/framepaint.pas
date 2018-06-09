unit framePaint;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, Dialogs,
  Spin, ActnList
, Graphics
, Clipbrd
, LCLIntf
, LCLType, StdCtrls, unit_types_and_const
  ;

const
    backgroundColor:TColor =$f4fcf3;//$e2f7df;
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
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
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
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure LineColorColorChanged(Sender: TObject);
    procedure MyCanvasDblClick(Sender: TObject);
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
    paintHistory : array of TPaintObject;
    pointMem : array of TPointMem;
    limTop : single;
    limDown : single;
    limLeft : single;
    limRight : single;
    shiftDown : Integer;
    shiftRight : Integer;
    constructor Create(TheOwner: TComponent); override;
    procedure Clear();
    procedure resizeCadCanvas(pWidth,pHeight: Single);
    procedure paintLine(x1,y1,x2,y2:integer);
    procedure paintText(x1,y1:Double;pText:string);
    procedure paintRect(x1,y1,x2,y2:integer);
    //procedure paintRibbon(x1,x2,h:integer);
    procedure paintPoint(x1,y1,r:integer);
    procedure paintArc(ax,ay,bx,by,cx,cy:single;leftAr:boolean);
    
    function chord(a: TCursor; r, angle: double; draw :boolean=true): TCursor;
    function toStright(a:TCursor;lenght:double; draw :boolean=true):TCursor;//TMyShape
    function toLeft (a:TCursor;lenght,angle:double; draw :boolean=true; chording: boolean=false):TCursor;//TMyShape
    function toRight(a:TCursor;lenght,angle:double; draw :boolean=true; chording: boolean=false):TCursor;//TMyShape
    
    procedure limTest(a:TCursor);
    function cursorShift(a:TCursor):TCursor;
    procedure paintHistoryClear();
    procedure paintHistoryAdd(obj:TPaintObject);
    procedure paintHistoryRepeat();
    procedure AddPointMem(pCursor:TCursor;id:Integer);
    function GetPointMem(id:Integer):TCursor;
    function TestPointMem(id:Integer):Boolean;
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

procedure TFrameCadPaint.Button1Click(Sender: TObject);
begin
  MyCanvasPaint(Sender);
end;

procedure TFrameCadPaint.Button2Click(Sender: TObject);
begin
    paintbmp.SetSize(paintbmp.Width+20, paintbmp.Height+20);
    MyCanvasPaint(Sender);
    paintbmp.Canvas.Brush.Style:=bsSolid;
    paintbmp.Canvas.Brush.Color:=backgroundColor;
    paintbmp.Canvas.FloodFill(paintbmp.Width-1, paintbmp.Height-1, clBlack, fsSurface);
    MyCanvasPaint(Sender);
end;

procedure TFrameCadPaint.Button3Click(Sender: TObject);
var
  Cur :TCursor;
begin
  limDown:=500;
  limRight:=500;
  paintHistoryClear();
  Cur.x:=100;
  Cur.y:=100;
  Cur.angle:=30;
  paintHistoryAdd(PaintObject(ObjStright,cur,20));
  paintHistoryRepeat();
end;

procedure TFrameCadPaint.LineColorColorChanged(Sender: TObject);
begin
  paintbmp.Canvas.Pen.Color:=LineColor.ButtonColor;
  MyCanvas.Canvas.Pen.Color:=LineColor.ButtonColor;
end;

procedure TFrameCadPaint.MyCanvasDblClick(Sender: TObject);
begin
  ActionSave.Execute;
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

procedure TFrameCadPaint.Clear;
begin
  paintbmp.Canvas.Clear;
  MyCanvasPaint(nil);
end;

procedure TFrameCadPaint.resizeCadCanvas(pWidth, pHeight: Single);
var
  tempColor:TColor;
  iWidth,iHeight:integer;
begin
  iWidth:= round(pWidth);
  iHeight:= round(pHeight);
  
  if iWidth <1 then iWidth :=paintbmp.Width+1;
  if iHeight<1 then iHeight:=paintbmp.Height+1;
  
  
  paintbmp.Canvas.Brush.Color := backgroundColor;
  paintbmp.Canvas.Brush.Style := bsSolid;
  
  paintbmp.SetSize(iWidth, iHeight);
  paintbmp.Canvas.FloodFill(iWidth-1, iHeight-1, clBlack, fsSurface);
   
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

procedure TFrameCadPaint.paintArc(ax, ay, bx, by, cx, cy: single; 
  leftAr: boolean);
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
       //if (AY<OY)
       if leftAr//заглушка для совместимости, на больших углах ошибка 
       then paintbmp.Canvas.Arc(Round((oX-R)),Round((oY-R)),Round((oX+R)),Round((oY+R)),Round(CX),Round(CY),Round(AX),Round(AY))
       else paintbmp.Canvas.Arc(Round((oX-R)),Round((oY-R)),Round((oX+R)),Round((oY+R)),Round(AX),Round(AY),Round(CX),Round(CY));
    //end;
end;

function TFrameCadPaint.chord(a: TCursor; r, angle: double; draw: boolean
  ): TCursor;
var lenghtCord:double;
begin
  lenghtCord := 2*r*sin((angle*pi/180)/2);
  a.angle := a.angle+angle/2;
  result := toStright(a,lenghtCord,draw);
  result.angle:=result.angle+angle/2;
end;

function TFrameCadPaint.toStright(a: TCursor; lenght: double; draw: boolean
  ): TCursor;
begin
  result.x:= a.x+cos(a.angle*pi/180)*lenght;
  result.y:= a.y+sin(a.angle*pi/180)*lenght;
  result.angle:= a.angle;
  if draw then
  paintLine(round(a.x),round(a.y),round(result.x),round(result.y));
  limTest(result);
end;

function TFrameCadPaint.toLeft(a: TCursor; lenght, angle: double; 
  draw: boolean; chording: boolean): TCursor;
var
  r:double;
  b,c:TCursor;
begin
  if angle<>0
  then r:= lenght*180/Pi/angle
  else r:=MaxCurrency;
  if chording then
  begin
    result:=a;
    result:=chord(result,r,angle/3,draw);
    result:=chord(result,r,angle/3,draw);
    result:=chord(result,r,angle/3,draw);
  end
  else
  begin
    b:=chord(a,r,angle/2,false);
    c:=chord(a,r,angle,false);
    result:=c;
    if draw
    then paintArc(a.x,a.y,b.x,b.y,c.x,c.y,angle>0);
  end;
  limTest(result);
end;

function TFrameCadPaint.toRight(a: TCursor; lenght, angle: double; 
  draw: boolean; chording: boolean): TCursor;
begin
  result := toLeft(a, lenght, -angle, draw,chording);
  limTest(result);
end;

procedure TFrameCadPaint.limTest(a: TCursor);
begin
  if a.x > limRight then limRight := a.x;
  if a.x < limLeft then limLeft := a.x;
  if a.y > limDown then limDown := a.y;
  if a.y < limTop then limTop := a.y;
end;

function TFrameCadPaint.cursorShift(a: TCursor): TCursor;
begin
  result.x:=a.x+shiftRight+50;
  result.y:=a.y+shiftDown+50;
  result.angle:=a.angle;
end;

procedure TFrameCadPaint.paintHistoryClear;
begin
  limTop:=0;
  limDown:=100;
  limLeft:=0;
  limRight:=100;
  shiftDown:=0;
  shiftRight:=0;
  SetLength(paintHistory,0);
  SetLength(pointMem,0);
end;

procedure TFrameCadPaint.paintHistoryAdd(obj: TPaintObject);
begin
  SetLength(paintHistory,length(paintHistory)+1);
  paintHistory[High(paintHistory)] := obj;
end;

procedure TFrameCadPaint.paintHistoryRepeat;
var
  i: integer;
begin
  if limTop<>0 then
  begin
    limDown := limDown - limTop;
    shiftDown:= round(- limTop);
    limTop := 0;
  end;
  if limLeft<>0 then
  begin
    limRight := limRight - limLeft;
    shiftRight:= round(- limLeft);
    limLeft := 0;
  end;
  resizeCadCanvas(limRight+100,limDown+100);
  Clear();
  for i:=0 to length(paintHistory)-1 do
  with paintHistory[i] do
    begin
      cursor:=cursorShift(cursor);
      paintbmp.Canvas.Pen.Style:=PenStyle;
      paintbmp.Canvas.Pen.Width:=penWidth;
      paintbmp.Canvas.Pen.Color:=penColor;
      case objType of
        ObjStright : toStright(cursor,length,True);
        ObjLeft : toLeft(cursor,length,angle,True,false);
        ObjRigth : toRight(cursor,length,angle,True,false);
      end;
  end;
end;

procedure TFrameCadPaint.AddPointMem(pCursor: TCursor; id: Integer);
begin
  if TestPointMem(id) then exit;
  SetLength(pointMem,length(pointMem)+1);
  pointMem[High(pointMem)].cursor := pCursor;
  pointMem[High(pointMem)].id := id;
end;

function TFrameCadPaint.GetPointMem(id: Integer): TCursor;
var
  i: integer;
begin
  for i:=0 to length(pointMem)-1 do
    if pointMem[i].id = id
     then
     begin
       result := pointMem[i].cursor;
       exit;
     end;
end;

function TFrameCadPaint.TestPointMem(id: Integer): Boolean;
var
  i: integer;
begin
  result:= false;
  for i:=0 to length(pointMem)-1 do
    if pointMem[i].id = id
     then 
     begin
       result := true;
       exit;
     end;
end;

end.

