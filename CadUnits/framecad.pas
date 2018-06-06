unit frameCad;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, ComCtrls, ActnList,
  unit_m_data, unit_types_and_const, ZDataset, framePaint, typePaspProp,
  typePaspBranch, typePaspElem, typePaspObj, Type_directories, Graphics,
  StdCtrls;

const
  railBetween = 1.020;
  penAxisWidth = 1;
  penRailWidth = 2;
  
type

  { TFrameCad }

  TFrameCad = class(TFrame)
    ActionPaint3: TAction;
    ActionPaint2: TAction;
    ActionPaint1: TAction;
    ActionTest: TAction;
    ActionInit: TAction;
    ActionClear: TAction;
    ActionListCad: TActionList;
    CadCaption: TStaticText;
    PanelCad: TPanel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    procedure ActionClearExecute(Sender: TObject);
    procedure ActionInitExecute(Sender: TObject);
    procedure ActionPaint1Execute(Sender: TObject);
    procedure ActionPaint2Execute(Sender: TObject);
    procedure ActionPaint3Execute(Sender: TObject);
    procedure ActionTestExecute(Sender: TObject);
    procedure CadAreaDblClick(Sender: TObject);
    procedure CadAreaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure CadAreaMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure FrameResize(Sender: TObject);
    procedure ToolBar1Click(Sender: TObject);
  private
    { private declarations }
    moveX: integer;
    moveY: integer;
    function getCaption(): string;
    procedure setCaption(Value: string);
    //схема
    function toStright(a:TCursor;lenght:double; draw :boolean=true):TCursor;//TMyShape
    function toStrightRail(a:TCursor;lenght,RailBetween:double; draw :boolean=true):TCursor;//TMyShape
    function toLeft (a:TCursor;lenght,angle:double; draw :boolean=true; chording: boolean=false):TCursor;//TMyShape
    function toLeftRail (a:TCursor;lenght,angle,RailBetween:double; draw :boolean=true; chording: boolean=false):TCursor;//TMyShape
    function toRight(a:TCursor;lenght,angle:double; draw :boolean=true; chording: boolean=false):TCursor;//TMyShape
    function toRightRail (a:TCursor;lenght,angle,RailBetween:double; draw :boolean=true; chording: boolean=false):TCursor;//TMyShape
    function chord(a: TCursor; r, angle: double; draw :boolean=true): TCursor;
    //

  public
    { public declarations }
    CadPaint: TFrameCadPaint;
    CadCanvas: TCanvas;
    CadPen: TPen;
    CadBrush: TBrush;
    p_passport: TPassProp;
    property Caption: string read getCaption write setCaption;
    constructor Create(TheOwner: TComponent); //override;
    procedure setPassport(Pas_ID: integer; User_ID: integer = -1);
    procedure paintConditional(passport:TPassProp);
    procedure paintScheme(passport:TPassProp);
    procedure paintEpure(passport:TPassProp);
    
  end;

implementation

{$R *.lfm}

{ TFrameCad }

procedure TFrameCad.ActionClearExecute(Sender: TObject);
begin
  CadPaint.resizeCadCanvas(3000, 1000);
  CadPen := CadCanvas.Pen;
  CadPen.Color := clBlack;
  CadPen.Width := 2;
  CadBrush := CadCanvas.Brush;
  CadBrush.Color := backgroundColor;
  CadBrush.Style := bsSolid;
  CadCanvas.Clear;
  CadCanvas.Clear;
end;

procedure TFrameCad.ActionInitExecute(Sender: TObject);
begin
  //CadArea.Left:=     10;
  //CadArea.Top:=      10;
  //moveX:=0;
  //moveY:=0;
  ActionClear.Execute;
end;

procedure TFrameCad.ActionPaint1Execute(Sender: TObject);
begin
  if p_passport <> nil
    then paintConditional(p_passport);
end;

procedure TFrameCad.ActionPaint2Execute(Sender: TObject);
begin
  if p_passport <> nil
    then paintScheme(p_passport);
end;

procedure TFrameCad.ActionPaint3Execute(Sender: TObject);
begin
  if p_passport <> nil
    then paintEpure(p_passport);
end;

procedure TFrameCad.ActionTestExecute(Sender: TObject);
var
  pos:TCursor;
begin
  ActionInit.Execute;
  pos.x:=300;
  pos.y:=300;
  //testcase линия
  //pos.angle:=0;
  //pos:=toStright(pos,200);
  //pos.angle:=pos.angle+30;
  //pos:=toStright(pos,200);
  //pos.angle:=pos.angle-30;
  //pos:=toStright(pos,200);
  //pos.angle:=pos.angle+30;
  //pos:=toStright(pos,200);
  //pos:=toRight(pos,200,30);
  //pos:=toStright(pos,200);
  //pos:=toLeft(pos,200,30);
  //pos:=toStright(pos,200);

  //testcase rail
  pos.angle:=0;
  pos:=toStrightRail(pos,200,railBetween*20);
  pos.angle:=pos.angle+30;
  pos:=toStrightRail(pos,200,railBetween*20);
  pos.angle:=pos.angle-30;
  pos:=toStrightRail(pos,200,railBetween*20);
  pos.angle:=pos.angle+30;
  pos:=toStrightRail(pos,200,railBetween*20);
  pos:=toRightRail(pos,200,30,railBetween*20);
  pos:=toStrightRail(pos,200,railBetween*20);
  pos:=toLeftRail(pos,200,30,railBetween*20);
  pos:=toStrightRail(pos,200,railBetween*20);

end;

procedure TFrameCad.CadAreaDblClick(Sender: TObject);
begin
  //CadArea.left:=CadArea.left-20;
  //CadArea.Top:=CadArea.Top+3;
  //CadArea.Height:=CadArea.Height+100;
  //resizeCadCanvas(-1,-1)
end;

procedure TFrameCad.CadAreaMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  //if (Button=mbMiddle){ and (move)} then   //для кнопки
  //begin
  // moveX:=x;
  // moveY:=y;
  // //toMove:=True;
  //end;
  ////if (moveX<>x) and  (moveY<>y) then   needRefresh:=true;
end;

procedure TFrameCad.CadAreaMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  //if needRefresh then
  //begin
  //  CAD_pas.Refresh;
  //end;
  //if (Shift = [ssCtrl]) {or toMove} then
  //  begin
  //   CadArea.Left:=Round(CadArea.Left -(moveX-X)/2);
  //   CadArea.Top :=Round(CadArea.Top  -(moveY-Y)/2);
  //   if CadArea.Left <PanelCad.Width-CadArea.Width then CadArea.Left:=PanelCad.Width-CadArea.Width;
  //   if CadArea.Top  <PanelCad.Height-CadArea.Height then CadArea.Top:=PanelCad.Height-CadArea.Height;
  //   if CadArea.Left >10 then CadArea.Left:=10;
  //   if CadArea.Top >10 then CadArea.Top:=10;
  //   //ActionTest.Execute;
  //   //CadArea.Repaint;
  //   self.Top:=1;
  //   //needRefresh:=true;
  //  end
  //else
  //  begin
  //   moveX:=x;
  //   moveY:=y;
  //  end;
end;

procedure TFrameCad.FrameResize(Sender: TObject);
begin
  //ActionTest.Execute;
end;

procedure TFrameCad.ToolBar1Click(Sender: TObject);
begin

end;

function TFrameCad.getCaption: string;
begin
  Result := CadCaption.Caption;
end;

procedure TFrameCad.setCaption(Value: string);
begin
  CadCaption.Caption := Value;
end;

function TFrameCad.toStright(a: TCursor; lenght: double; draw: boolean
  ): TCursor;
begin
  result.x:= a.x+cos(a.angle*pi/180)*lenght;
  result.y:= a.y+sin(a.angle*pi/180)*lenght;
  result.angle:= a.angle;
  if draw then
   CadPaint.paintLine(round(a.x),round(a.y),round(result.x),round(result.y));
end;

function TFrameCad.toStrightRail(a: TCursor; lenght, RailBetween: double; 
  draw: boolean): TCursor;
var
  a1,a2,b1,b2:TCursor;
begin
  CadPen.Width:=penAxisWidth;
  result:=toStright(a,lenght,draw);
  a1.x:= a.x+cos((a.angle+90)*pi/180)*RailBetween/2;
  a1.y:= a.y+sin((a.angle+90)*pi/180)*RailBetween/2;
  a1.angle:= a.angle;
  a2.x:= a.x+cos((a.angle-90)*pi/180)*RailBetween/2;
  a2.y:= a.y+sin((a.angle-90)*pi/180)*RailBetween/2;
  a2.angle:= a.angle;
  CadPen.Width:=penRailWidth;
  toStright(a1,lenght,draw);
  toStright(a2,lenght,draw);
end;

function TFrameCad.toLeft(a: TCursor; lenght, angle: double; draw: boolean; 
  chording: boolean): TCursor;
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
    then CadPaint.paintArc(a.x,a.y,b.x,b.y,c.x,c.y);
  end;
end;

function TFrameCad.toLeftRail(a: TCursor; lenght, angle, RailBetween: double; 
  draw: boolean; chording: boolean): TCursor;
var
  r,r1,r2,lenght1,lenght2:Double;
  a1,a2,b1,b2,c1,c2:TCursor;
begin
  result:=a;
  if angle<>0
  then r:= lenght*180/Pi/angle
  else r:=MaxCurrency;
  r1:=r-RailBetween/2;
  r2:=r+RailBetween/2;
  lenght1:=r1*Pi*angle/180;
  lenght2:=r2*Pi*angle/180;
  a1.x:= a.x+cos((a.angle+90)*pi/180)*RailBetween/2;
  a1.y:= a.y+sin((a.angle+90)*pi/180)*RailBetween/2;
  a1.angle:=a.angle;
  a2.x:= a.x+cos((a.angle-90)*pi/180)*RailBetween/2;
  a2.y:= a.y+sin((a.angle-90)*pi/180)*RailBetween/2;
  a2.angle:=a.angle;
  CadPen.Width:=penAxisWidth;
  result:=toLeft(a ,lenght , angle, draw, chording);
  CadPen.Width:=penRailWidth;
  toLeft(a1,lenght1, angle, draw, chording);
  toLeft(a2,lenght2, angle, draw, chording);
end;

function TFrameCad.toRight(a: TCursor; lenght, angle: double; draw: boolean; 
  chording: boolean): TCursor;
begin
  result := toLeft(a, lenght, -angle, draw,chording)
end;

function TFrameCad.toRightRail(a: TCursor; lenght, angle, RailBetween: double; 
  draw: boolean; chording: boolean): TCursor;
begin
  result := toLeftRail(a, lenght, -angle, RailBetween, draw, chording);
end;

function TFrameCad.chord(a: TCursor; r, angle: double; draw: boolean): TCursor;
var lenghtCord:double;
begin
  lenghtCord := 2*r*sin((angle*pi/180)/2);
  a.angle := a.angle+angle/2;
  result := toStright(a,lenghtCord,draw);
  result.angle:=result.angle+angle/2;
end;

constructor TFrameCad.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  //frame.Parent:=TheOwner;
  CadPaint := TFrameCadPaint.Create(PanelCad);
  CadPaint.Parent := PanelCad;
  CadCanvas := CadPaint.paintbmp.Canvas;
  p_passport := nil;
end;

procedure TFrameCad.setPassport(Pas_ID: integer; User_ID: integer);
var
  passType:integer;
begin
  if p_passport <> nil
  then FreeAndNil(p_passport);
  p_passport := TPassProp.Create(Pas_ID, User_ID, DataM.ZConnection1, True);
  ActionInit.Execute;
  passType:=strtoint(p_passport.pass_type);
   if passType = 0//фрагмент
    then paintConditional(p_passport) 
    else
   if passType = 1//участок
    then paintConditional(p_passport) 
    else
   if passType = 2//узел
    then paintScheme(p_passport) 
    else
   if passType = 3//эпюр
    then paintEpure(p_passport);
  //ActionTest.Execute;
end;

procedure TFrameCad.paintConditional(passport: TPassProp);
type
  elemTemp = record 
    x: integer;
    y: integer;
    elemCount :Double;
    elemType  :integer;
end;
type
  TLongProf = record 
    lenght :Double;
    value  :Double;
end;
var
  obj, pen, prof: TPoint;
  elem: array [0..1] of array of elemTemp;
  i, j, k, m, len, spin, p_rad, scale, group_id, color_id: integer;
  branch: TPassBranch;
  passObj: TPassObj;
  passElem: TPassElem;
  st: string;
  n: double;
  test: array of integer;
  defColor: TColor;
  directories:TDirectories; { TODO : //нужно проверить освобождение памяти  }
  longitudinalProfile:TZQuery;
  longProf:TLongProf;
begin
  // Обновляем или заполняем объекты-справочники
  if passport = nil then exit;
  directories := TDirectories.Create(passport.f_conn); //вынисти в общие и не пересоздавать
  ActionClear.Execute;
  p_rad := 2;
  scale := 2;
  spin := 10 * scale;
  pen.x := 20 * scale;
  pen.y := 0;
  //Определяем кол-во покрытий
  //путь 1
  SetLength(elem[0], passport.getElementGroupsCount);
  for i := 0 to Length(elem[0]) - 1 do
  begin
    elem[0,i].x := pen.x;
    elem[0,i].y := pen.y;
    CadPaint.paintText(10 * scale, elem[0,i].y,
    directories.getElementGroupName(passport.getElementGroup(i)));
    //IntToStr(passport.getElementGroup(i)));
    //ресуем покрытия вместе с объектами
    pen.y := pen.y + 40 * scale;
  end;
  //путь 2
  SetLength(elem[1], passport.getElementGroupsCount);
  for i := 0 to Length(elem[0]) - 1 do
  begin
    elem[1,i].x := pen.x;
    elem[1,i].y := pen.y + (40 * scale * 4) + (40 * scale*(Length(elem[0]) - 1 - i));
    CadPaint.paintText(10 * scale, elem[1,i].y,
    directories.getElementGroupName(passport.getElementGroup(i)));
    //ресуем покрытия вместе с объектами
  end;

  begin
    for i := 0 to passport.ComponentCount - 1 do
    begin
      try
        CadPen.Width := 2;
        branch := TPassBranch(passport.Components[i]);
        obj.x := pen.x;
        obj.y := pen.y;
        //CadPaint.paintLine(10 * scale, obj.y, CadCanvas.Width, obj.y);
        CadPaint.paintText(10 * scale, obj.y+spin, 'Ветка ' + branch.branch_name);
        obj.y := obj.y + 40 * scale;
        if CadCanvas.Height < obj.y + 20 * scale then
          CadPaint.resizeCadCanvas(-1, obj.y + 20 * scale);
        CadPen.Width := 1;
        for j := 0 to branch.ComponentCount - 1 do
          try
            if i>1 then break;//только первых 2 пути пока
            passObj := TPassObj(branch.Components[j]);
            //ресуем покрытия вместе с объектами
            defColor:=CadPen.Color;
            for m := 0 to Length(elem[i]) - 1 do
              elem[i,m].x := obj.x;
            for k := 0 to passObj.ComponentCount - 1 do
            begin
              passElem := TPassElem(passObj.Components[k]);
              group_id := StrToInt(passElem.elem_group_id);
              for m := 0 to Length(elem[i]) - 1 do
                if  passport.getElementGroup(m) = group_id then break;
              len := round(StrToCurrDef(passElem.elem_len, 0)) * scale;
              color_id:= strtoint(passElem.elem_type);
              while (color_id>length(ColorArr)-1) do color_id:= color_id - length(ColorArr);
              CadBrush.Color:=ColorArr[color_id];
              CadPen.Color:=ColorArr[color_id];
              CadBrush.Style:=bsSolid;
              CadPaint.paintRect(
                elem[i,m].x,
                elem[i,m].y+spin,
                elem[i,m].x + len,
                elem[i,m].y+spin*2);
                elem[i,m].x:= elem[i,m].x + len;
                if (elem[i,m].elemCount=2.1) 
                 then elem[i,m].elemCount:= 2.9
                 else elem[i,m].elemCount:= 2.1;
                
                CadPen.Color:=defColor;
                CadPaint.paintRect(
                  elem[i,m].x - 1,
                  elem[i,m].y+spin,
                  elem[i,m].x,
                  elem[i,m].y+spin*2);
                CadPen.Color:=ColorArr[color_id];
              CadPaint.paintText((elem[i,m].x - len/2), elem[i,m].y+spin*elem[i,m].elemCount,passElem.elem_year + ' - ' + directories.getElementName(strtoint(passElem.elem_type)));
            end;
            
            CadBrush.Color:=defColor;
            CadPen.Color:=defColor;
            CadBrush.Style:=bsClear;
            st := passObj.obj_len;
            len := round(StrToCurrDef(st, 0)) * scale;
            CadPaint.paintPoint(obj.x, obj.y, p_rad);
            if CadCanvas.Width < obj.x + len + 20 * scale then
              CadPaint.resizeCadCanvas(obj.x + len + 20 * scale, -1);
            
            if passObj.obj_type = '1' then //прямой
            begin
              CadPaint.paintText(round(obj.x + len * 0.45), obj.y - 20, 'L= ' +
                CurrToStr((StrToCurrDef(st, 0))) + 'м.');
              CadPaint.paintLine(obj.x, obj.y, obj.x + len, obj.y);
              obj.x := obj.x + len;
            end
            else
            if passObj.obj_type = '3' then //лево
            begin
              CadPaint.paintLine(obj.x, obj.y, obj.x, obj.y - spin);
              CadPaint.paintText(round(obj.x + len * 0.45), obj.y - 20 - spin, 'L= ' +
                CurrToStr((StrToCurrDef(st, 0))) + 'м.');
              CadPaint.paintLine(obj.x, obj.y - spin, obj.x + len, obj.y - spin);
              CadPaint.paintLine(obj.x + len, obj.y - spin, obj.x + len, obj.y);
              obj.x := obj.x + len;
            end
            else
            if passObj.obj_type = '2' then //право
            begin
              CadPaint.paintLine(obj.x, obj.y, obj.x, obj.y + spin);
              CadPaint.paintText(round(obj.x + len * 0.45), obj.y + 5 + spin, 'L= ' +
                CurrToStr((StrToCurrDef(st, 0))) + 'м.');
              CadPaint.paintLine(obj.x, obj.y + spin, obj.x + len, obj.y + spin);
              CadPaint.paintLine(obj.x + len, obj.y + spin, obj.x + len, obj.y);
              obj.x := obj.x + len;
            end
            else
            begin
              obj.x := obj.x + len;
            end;
          except
          end;
      except
      end;
      CadPaint.paintPoint(obj.x, obj.y, p_rad);
      pen.y := pen.y + 40 * scale;
    end;
  end;
  //Продольный профиль
  longitudinalProfile:=passport.getLongitudinalProfile;
  pen.y := pen.y + 40 * scale;
  prof.x := pen.x;
  prof.y := pen.y;
  CadPaint.paintText(10 * scale, prof.y-spin*2, 'Продольный профиль ');
  while not longitudinalProfile.EOF do
  begin
    longProf.value := longitudinalProfile.FieldByName('value').AsFloat;
    longProf.lenght:= longitudinalProfile.FieldByName('length').AsFloat;
    if longitudinalProfile.FieldByName('value').AsString <> '' then
    begin
      CadPaint.paintRect(
        prof.x,
        prof.y,
        round(prof.x + longProf.lenght * scale+1),
        prof.y+spin*2);
      if longitudinalProfile.FieldByName('value').AsString <> '' then
      if longProf.value<0 
       then CadPaint.paintLine(prof.x, prof.y, round(prof.x + longProf.lenght * scale), prof.y + spin*2)
       else if longProf.value>0
        then CadPaint.paintLine(prof.x, prof.y + spin*2, round(prof.x + longProf.lenght * scale), prof.y)
        else CadPaint.paintLine(prof.x, round(prof.y + spin), round(prof.x + longProf.lenght * scale), round(prof.y + spin));
        
       CadPaint.paintText(round(prof.x + len * 0.1), prof.y - 15, CurrToStr(longProf.value));
       CadPaint.paintText(round(prof.x + len * 0.1), prof.y + spin*2 + 5, CurrToStr(longProf.lenght));
     end;
     prof.x := round(prof.x + longProf.lenght * scale);
     prof.y := pen.y;
     longitudinalProfile.Next;
  end;
  CadPen.Color := clRed;
end;

procedure TFrameCad.paintScheme(passport: TPassProp);
var
  pen,pos0: TCursor;
  i,j,scale: integer;
  len,rad,angle:single;
  branch: TPassBranch;
  passObj: TPassObj;
begin
  // Обновляем или заполняем объекты-справочники
  if passport = nil then exit;
  ActionClear.Execute;
  scale := 20;
  pos0.x := 20;
  pos0.y := 900;
  pos0.angle := 0;
  begin
    for i := 0 to passport.ComponentCount - 1 do
    begin
      try
        branch := TPassBranch(passport.Components[i]);
        pen:=pos0;
        for j := 0 to branch.ComponentCount - 1 do
          try
            //if i>0 then break;//только 1 ветка
            //ресуем покрытия вместе с объектами
            
            passObj := TPassObj(branch.Components[j]);
            len := round(StrToCurrDef(passObj.obj_len, 0)) * scale;
            rad := round(StrToCurrDef(passObj.obj_rad, 0)) * scale;
            if rad<>0
            then angle:= len*180/Pi/rad
            else angle:=0;

            //CadPaint.paintPoint(obj.x, obj.y, p_rad);
            
            if passObj.obj_type = '1' then //прямой
            begin
              //CurrToStr((StrToCurrDef(st, 0))) + 'м.');
              //CadPaint.paintText(round(obj.x + len * 0.45), obj.y - 20, 'L= ' +
              pen:=toStrightRail(pen,len,railBetween* scale);
            end
            else
            if passObj.obj_type = '2' then //право
            begin
              pen:=toRightRail(pen,len,angle,railBetween* scale);
            end
            else
            if passObj.obj_type = '3' then //лево
            begin
              pen:=toLeftRail(pen,len,angle,railBetween* scale);
            end
            else
            if passObj.obj_type = '5' then //примыкание
            begin
              CadPen.Style:=psDash;
              pen:=toStrightRail(pen,len,railBetween* scale);
              CadPen.Style:=psSolid;
            end;
          except
          end;
      except
      end;
      //CadPaint.paintPoint(obj.x, obj.y, p_rad);
      pen.y := pen.y + 40 * scale;
    end;
  end;
end;

procedure TFrameCad.paintEpure(passport: TPassProp);
var
  pen,pos0: TCursor;
  i,j,scale: integer;
  len,rad,angle:single;
  branch: TPassBranch;
  passObj: TPassObj;
begin
  // Обновляем или заполняем объекты-справочники
  if passport = nil then exit;
  ActionClear.Execute;
  scale := 100;
  pos0.x := 20;
  pos0.y := 400;
  pos0.angle := 0;
  begin
    for i := 0 to passport.ComponentCount - 1 do
    begin
      try
        branch := TPassBranch(passport.Components[i]);
        pen:=pos0;
        for j := 0 to branch.ComponentCount - 1 do
          try
            //if i>0 then break;//только 1 ветка
            //ресуем покрытия вместе с объектами
            
            passObj := TPassObj(branch.Components[j]);
            len := round(StrToCurrDef(passObj.obj_len, 0)) * scale;
            rad := round(StrToCurrDef(passObj.obj_rad, 0)) * scale;
            if rad<>0
            then angle:= len*180/Pi/rad
            else angle:=0;

            //CadPaint.paintPoint(obj.x, obj.y, p_rad);
            
            if passObj.obj_type = '1' then //прямой
            begin
              //CurrToStr((StrToCurrDef(st, 0))) + 'м.');
              //CadPaint.paintText(round(obj.x + len * 0.45), obj.y - 20, 'L= ' +
              pen:=toStrightRail(pen,len,railBetween* scale);
            end
            else
            if passObj.obj_type = '2' then //право
            begin
              pen:=toRightRail(pen,len,angle,railBetween* scale);
            end
            else
            if passObj.obj_type = '3' then //лево
            begin
              pen:=toLeftRail(pen,len,angle,railBetween* scale);
            end
            else
            if passObj.obj_type = '5' then //примыкание
            begin
              CadPen.Style:=psDash;
              pen:=toStrightRail(pen,len,railBetween* scale);
              CadPen.Style:=psSolid;
            end;
          except
          end;
      except
      end;
      //CadPaint.paintPoint(obj.x, obj.y, p_rad);
      pen.y := pen.y + 40 * scale;
    end;
  end;
end;

end.
