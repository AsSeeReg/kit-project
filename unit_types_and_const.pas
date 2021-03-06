unit unit_types_and_const;
{$mode objfpc}{$H+}

interface
//типы, слассы, константы, методы общего назначения
uses
  Classes, SysUtils, md5, ZDataset, ZConnection, Forms, Controls, Grids,
  StdCtrls, DBGrids, DbCtrls, ComCtrls, ActnList, Graphics, unit_m_data,
  FPCanvas, KGrids;

const
 const_pasNew = -1;
 RT_VERSION   = MakeIntResource(16);
 ObjStright = 0;
 ObjLeft = 1;
 ObjRigth = 2;
 //ObjPoint = 3;
 //ObjArc = 4;

type
  TMyField = record
    name : string;
    value : string;
    table : string;
  end;

type
  TCursor = record
    x :double;
    y :double;
    angle : double;
  end;

type
  TPointMem = record
    cursor :TCursor;
    id :Integer;
  end;

const
 Cursor_0: TCursor = (x: 0; y: 0; angle: 0); 

type
  TPaintObjectOld = record
    objType : integer; //const
//    0 - Line
//    1 - Text
//    2 - Rect
//    3 - Point
//    4 - Arc
    cursor : TCursor;
    penColor : TColor;
    penWidth : Integer;
    x1,y1,x2,y2,cx,cy,r:Single;
    text:string;
  end;

type
  TPaintObject = record
    objType : integer; //const
    cursor : TCursor;
    PenStyle : TFPPenStyle;
    penColor : TColor;
    penWidth : Integer;
    length, angle:Single;
    text:string;
  end;

type
  TLicRec = record
    Demo:Boolean;
    LicCount:Integer;
    LicName:String;
    UserID:Integer;
    UserName:String;
    competency1:Boolean;
    competency2:Boolean;
    competency3:Boolean;
    competency4:Boolean;
  end;

 function GetMyVersion:string;
 function GetSQL(iden:string;param1:integer;param2:integer = -1):string;
 function ShowFrame(owner:TForm;frame:TFrame):TForm;
 function CheckLic(Login,PasHash:string):String;
 function GetHash(Pas:string):string;
 procedure log(massage:string);
 Procedure MyExcept(Sender : TObject; E : Exception);
 Procedure FormSetEdit(propEdit:Boolean;frame:TWinControl);
 function PaintObjectOld(
   objType : integer;
   cursor : TCursor;
   x1 : Single = 0;
   y1 : Single = 0;
   x2 : Single = 0;
   y2 : Single = 0;
   cx : Single = 0;
   cy : Single = 0;
   r  : Single = 0;
   text:string = '';
   penColor : TColor = clBlack;
   penWidth : Integer = 1
):TPaintObjectOld;
 function PaintObject(
   objType : integer;
   cursor : TCursor;
   length : Single = 0;
   angle  : Single = 0;
   text:string = '';
   PenStyle : TFPPenStyle = psSolid;
   penWidth : Integer = 1;
   penColor : TColor = clBlack
):TPaintObject;
 var
   authorization :TLicRec;

implementation

function GetMyVersion:string;
type
  TVerInfo=packed record
    Nevazhno: array[0..47] of byte; // ненужные нам 48 байт
    Minor,Major,Build,Release: word; // а тут версия
  end;
var
  s:TResourceStream;
  v:TVerInfo;
begin
  result:='';
  try
    s:=TResourceStream.Create(HInstance,'#1',RT_VERSION); // достаём ресурс
    if s.Size>0 then begin
      s.Read(v,SizeOf(v)); // читаем нужные нам байты
      result:=IntToStr(v.Major)+'.'+IntToStr(v.Minor)+'.'+ // вот и версия...
              IntToStr(v.Release)+'.'+IntToStr(v.Build);
    end;
  s.Free;
  except; end;
end;

function ShowFrame(owner:TForm;frame:TFrame):TForm;
var form: TForm;
begin
  form:=TForm.Create(owner);
  form.Width:=frame.Width;
  form.Height:=frame.Height;
  frame.Parent:=TWinControl(form);
  form.caption := frame.Hint;
  form.BorderStyle:=bsToolWindow;
  form.FormStyle:=fsSystemStayOnTop;
  form.Position:=poScreenCenter;
  form.ShowInTaskBar:=stNever;
  form.show;
  result:=form;
end;

function CheckLic(Login, PasHash: string): String;
begin
  result:='';
  //result:='Лицензия не прошла проверку';
  authorization.Demo:=True;
  //authorization.Demo:=False;
  authorization.LicCount:=15;
  authorization.LicName:='Kit-tech';
  authorization.UserID:=0;
  authorization.competency1:=False;
  authorization.competency2:=False;
  authorization.competency3:=False;
  authorization.competency4:=False;
  
  if not(result='') then exit;

  DataM.ZQtemp.SQL.Clear;
  DataM.ZQtemp.SQL.Add(' Select*from users');
  DataM.ZQtemp.SQL.Add(' where login = '''+Login+'''');
  DataM.ZQtemp.Open;
  result:='Ошибка авторизации';
  While not DataM.ZQtemp.EOF do begin
   if PasHash=DataM.ZQtemp.FieldByName('PasHash').AsString then
   begin
     authorization.UserID:=DataM.ZQtemp.FieldByName('id').AsInteger;
     authorization.UserName:=DataM.ZQtemp.FieldByName('short_name').AsString;
     authorization.competency1:=DataM.ZQtemp.FieldByName('competency1').AsBoolean;
     authorization.competency2:=DataM.ZQtemp.FieldByName('competency2').AsBoolean;
     authorization.competency3:=DataM.ZQtemp.FieldByName('competency3').AsBoolean;
     authorization.competency4:=DataM.ZQtemp.FieldByName('competency4').AsBoolean;
     if  authorization.competency1 or authorization.competency2
      or authorization.competency3 or authorization.competency4
      then result:=''
      else result:='У пользователя нет активных ролей';
   end;
   DataM.ZQtemp.Next;
  end;
  end;

function GetHash(Pas: string): string;
begin
  result:= MD5Print(MD5String('RealRoad%'+Pas))
end;

procedure log(massage: string);
var  E:Exception;
begin
 E:= Exception.Create(massage);
 MyExcept(nil,E);
 E.Free;
end;

procedure MyExcept(Sender: TObject; E: Exception);
var
  filelog:string;
  myFile:TextFile;
  st:string;
begin
 filelog :=ExtractFileDir(ParamStr(0))+ '\log.txt';
 AssignFile(myFile, filelog);
 if FileExists(filelog)
  then  Append(myFile)
  else ReWrite(myFile);
 DateTimeToString(st,'YYYY-MM-DD  hh:mm:ss',now);
 WriteLn(myFile, st+' - '+E.Message);
 CloseFile(myFile);
end;

procedure FormSetEdit(propEdit: Boolean; frame: TWinControl);
var i: integer;
begin
 with frame do begin
  for i := 0 to ComponentCount-1 do
  begin
   
   //log(Components[i].Name);
   
   if (Components[i] is TFrame) then
   FormSetEdit(propEdit,(Components[i] as TFrame));
   
   if (Components[i] is TPageControl) then
   FormSetEdit(propEdit,(Components[i] as TPageControl));
   if (Components[i] is TTabSheet) then
   FormSetEdit(propEdit,(Components[i] as TTabSheet));
    
   if (
    (Components[i] is TAction)
   and
    ((Components[i] as TAction).tag = 0)
    ) then
   (Components[i] as TAction).Enabled := propEdit;
   
   if (Components[i] is TEdit) then
   (Components[i] as TEdit).ReadOnly := not propEdit;
   if (Components[i] is TMemo) then
   (Components[i] as TMemo).ReadOnly := not propEdit;
   if (Components[i] is TDBGrid) then
   (Components[i] as TDBGrid).ReadOnly := not propEdit;
   if (Components[i] is TDBLookupComboBox) then
   (Components[i] as TDBLookupComboBox).Enabled := propEdit;
   if (Components[i] is TStringGrid) then
   (Components[i] as TStringGrid).EditorMode := propEdit;
   if (Components[i] is TKGrid) then
   //(Components[i] as TKGrid).EditorMode := propEdit;  убить нахер, сделать TStringGrid
   (Components[i] as TKGrid).Enabled := propEdit;
  end;
 end;
end;

function PaintObject(objType: integer; cursor: TCursor; length: Single; 
  angle: Single; text: string; PenStyle: TFPPenStyle; penWidth: Integer; 
  penColor: TColor): TPaintObject;
begin
 result.objType := objType;
 result.cursor := cursor;
 result.length := length;
 result.angle := angle;
 result.text := text;
 result.PenStyle := PenStyle;
 result.penColor := penColor;
 result.penWidth := penWidth;
end;

function PaintObjectOld(objType: integer; cursor: TCursor; x1: Single; 
  y1: Single; x2: Single; y2: Single; cx: Single; cy: Single; r: Single; 
  text: string; penColor: TColor; penWidth: Integer): TPaintObjectOld;
begin
  result.objType := objType;
  result.cursor := cursor;
  result.x1 := x1;
  result.y1 := y1;
  result.x2 := x2;
  result.y2 := y2;
  result.cx := cx;
  result.cy := cy;
  result.r := r;
  result.text := text;
  result.penColor := penColor;
  result.penWidth := penWidth;
end;

function GetSQL(iden: string; param1: integer; param2: integer): string;
var SQL:string;
begin
  //нужно переделать на внешнее хранение в файлах а iden на список значений(const:int)

  if iden='prop' then
  begin
    sql:=
     '     SELECT                                  '
    +'      pas.pass_type,                         '
    +'      pas.pass_name,                         '
    +'      val1.value year_built,                 '
    +'      val4.value way,                        '
    +'      val2.value comment,                    '
    +'      val3.value year_reconst,               '
    +'      pas.last_edit last_edit,               '
    +'      users.short_name user_edit,            '
    +'      '''' contiguity                        '
    +'      FROM passports pas                     '
    +'     LEFT JOIN passport_prop_year_built val1 '
    +'      ON val1.pass_id=pas.id                 '
    +'     LEFT JOIN passport_prop_comment val2    '
    +'      ON val2.pass_id=pas.id                 '
    +'     LEFT JOIN passport_prop_year_reconst val3'
    +'      ON val3.pass_id=pas.id                 '
    +'     LEFT JOIN passport_prop_way val4        '
    +'      ON val4.pass_id=pas.id                 '
    +'     LEFT JOIN users users                   '
    +'      ON users.id=pas.user_edit              '
    +'      Where pas.id='+inttostr(param1)
    ;
  end else
  //-----------------------
  if iden='prop0' then
  begin
    sql:=
     ' SELECT                             '
    +'  localiz.name_text name,           '
    +'  val.value value                   '
    +' FROM                               '
    +' passports pas                      '
    +' LEFT JOIN                          '
    +' passport_prop_year_built val       '
    +' ON val.pass_id=pas.id              '
    +' LEFT JOIN                          '
    +' localization_fields localiz        '
    +' ON localiz.id=1                    '
    +' WHERE pas.id='+inttostr(param1)
    +' UNION                              '
    +' SELECT                             '
    +'  localiz.name_text name,           '
    +'  val.value value                   '
    +' FROM                               '
    +' passports pas                      '
    +' LEFT JOIN                          '
    +' passport_prop_comment val          '
    +' ON val.pass_id=pas.id              '
    +' LEFT JOIN                          '
    +' localization_fields localiz        '
    +' ON localiz.id=2                    '
    +' WHERE pas.id='+inttostr(param1)
    ;
  end else
    //-----------------------
    if iden='branchs' then
    begin
      sql:=' select * from branch'
          +' where pass_id='+inttostr(param1)
          ;
    end else
    //-----------------------
    if iden='branch' then
    begin
      sql:=' select * from branch'
          +' where id='+inttostr(param1)
          ;
    end else
    //-----------------------
  if iden='obj_new_id' then
  begin
    sql:=' select (max(id)+1) id from objects'
        ;
  end else
  //-----------------------
  if iden='obj_del_id' then
  begin
    sql:=' delete from objects'
    +' where id='+inttostr(param1)
        ;
  end else
  //-----------------------
  if iden='elem_new_id' then
  begin
    sql:=' select (max(id)+1) id from elements'
        ;
  end else
  //-----------------------
  if iden='elem_del_id' then
  begin
    sql:=' delete from elements'
    +' where id='+inttostr(param1)
        ;
  end else
  //-----------------------
  if iden='elem_del_obj_id' then
  begin
    sql:=' delete from elements'
    +' where object_id='+inttostr(param1)
        ;
  end else
  //-----------------------
  if iden='objects' then
  begin
    sql:=' '
        //+' select objects.id id,  obj_type,'
        //+' point_1, point_2, epure_id,'
        //+' rad,length, pos, tan from objects '
        +' select * from objects '
        +' where branch_id='+inttostr(param1)
        +' order by pos                       '
        ;
  end else
  //-----------------------
  if iden='objects_old' then
  begin
    sql:=' '
        +' select objects.id id, objects_type.obj_type_name obj_type,'
        +' rad,length, pos, tan from objects '
        +' LEFT JOIN objects_type            '
        +' on objects.obj_type=objects_type.id'
        +' where branch_id='+inttostr(param1)
        +' order by pos                       '
        ;
  end else
  //------------------------
  if iden='obj_prop' then
  begin
    sql:=' '
        +' select*from objects'
        +' where branch_id='+inttostr(param1)
        +' order by pos                                              '
        ;
  end else
  //------------------------
  if iden='obj_len' then
  begin
    sql:=' '
        +' select sum(length) len from elements'
        +' where object_id='+inttostr(param1)
        +' and elem_type in (select id from elements_type where elem_group_id in(0,1))'
        ;
  end else
  //-----------------------
  if iden='objects_type' then
  begin
    sql:=' select * from objects_type'
        +' '
        ;
  end else
  //-----------------------
  if iden='elements_group' then
  begin
    sql:=' select * from elements_group'
        +' where id>'+inttostr(param1)
        ;
  end else
  //-----------------------
  if iden='elements_type' then
  begin
    sql:=' select id,elem_type_name from elements_type'
        +' where elem_group_id in(0,'+inttostr(param1)
        +' )'
        ;
  end else
  //-----------------------
  if iden='new_elements_type' then
  begin
    sql:=' INSERT INTO elements_type (elem_type_name,elem_group_id)'
        +' VALUES (''новый элемент'','+inttostr(param1)
        +' )'
        ;
  end else
  //-----------------------
  if iden='del_elements_types' then
  begin
    sql:=''
    +'  delete from elements_type    where elem_group_id='+inttostr(param1)
        ;
  end else
  //-----------------------
  if iden='new_elements_group' then
  begin
    sql:=' INSERT INTO elements_group (group_name)'
        +' VALUES (''новая группа'''
        +' )'
        ;
  end else
  //-----------------------
  if iden='elements' then
  begin
    sql:=' select * from elements'
        +' LEFT JOIN elements_type            '
        +' on elements.elem_type=elements_type.id'
        +' where object_id='+inttostr(param1)
        +' order by pos'
        ;
  end else
  //-----------------------
  if iden='year_reconst' then
  begin
    sql:=' select max(elements.year) year from elements'
        +' where pass_id='+inttostr(param1)
        ;
  end else
  //-----------------------
  if iden='pass_new_id' then
  begin
    sql:=' select (max(id)+1) id from passports'
        ;
  end else
  //-----------------------
  if iden='raport_branch' then
  begin
    sql:=' select id, pos, obj_type_name, length, rad, max(year) year, group_concat(elem_type_name ,'';'') elem from'
    +' (select obj.id id, obj.pos pos, obj_type_name, obj.length length, rad, year, elem_type_name  from objects obj'
    +' left join objects_type obt on obj.obj_type = obt.id'
    +' left join elements elem on obj.id = elem.object_id '
    +' left join elements_type elt on elem.elem_type= elt.id '
    +' where obj.branch_id = '+inttostr(param1) 
    +' order by obj.pos,obj.id, elem_group_id) tab'
    +' group by id, pos, obj_type_name, length, rad'
    ;
  end else
 //-----------------------
 if iden='del_pass_id' then
 begin
   sql:=''// delete from passports' //ON DELETE CASCADE br,obj,el !?!
       +'  delete from passport_prop_comment    where pass_id='+inttostr(param1)
       +'; delete from passport_prop_year_built where pass_id='+inttostr(param1)
       +'; delete from passport_prop_comment    where pass_id='+inttostr(param1)
       +'; delete from elements                 where pass_id='+inttostr(param1)
       +'; delete from objects                  where pass_id='+inttostr(param1)
       +'; delete from branch                   where pass_id='+inttostr(param1)
       +'; delete from passports                where      id='+inttostr(param1)
       +' '
       ;
 end else
//-----------------------
if iden='pass_element_groups_list' then
begin
  sql:=' SELECT DISTINCT et.elem_group_id elem_group_id FROM elements'
      +' LEFT JOIN elements_type et ON elem_type = et.id'
      +' WHERE pass_id ='+inttostr(param1)
      +' ORDER BY elem_group_id'
      ;
 end;
  //-----------------------
  result:=sql;
end;

end.

