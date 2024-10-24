unit TBS_Tool;

interface

uses
  Windows,
  SysUtils,
  Classes,
  Variants,
  Graphics,
  extctrls,
  DB,
  DBTables,
  KrMath,
  KR_Sys,
  KR_DB,
  ObjView,
  StrUtils;

procedure ObjViewFromBinBase( OV :TObjectView; BB :TDataSet );

function  MultiIdFilter( ADSet, FltDSet :TDataSet; N :Integer = 8 ) :Boolean;
function  MultiIdFindBest( ADSet, DestDSet :TDataSet; N :Integer = 8 ) :Boolean;

function FindKatalCD: string;


// przeniesione z KC_Dane
procedure Rzedna(c:TCanvas; x,y :Integer);
procedure RzednaLewa(c:TCanvas; x,y :Integer);
procedure GrotGora(c :TCanvas; x,y :integer);
procedure GrotDol(c :TCanvas; x,y :integer);
procedure GrotLewy(c :TCanvas; x,y :integer);

procedure BeginLog;
procedure AddLog( const s :string );
procedure AddLogFmt( const fmt :string; const a :array of const );

procedure PodstawTeksty(test : TStrings; co, naco : array of String);

{=============================================================================}
implementation


{--------------------------------------------------------------------------}
procedure ObjViewFromBinBase( OV :TObjectView; BB :TDataSet );
var
  stream  :TBlobStream;
begin
  stream := TBlobStream.Create(BB.FieldByName('DATA') as TBlobField, bmRead );
  OV.LoadFromStream( BB.FieldByName('ClassName').AsString,
                     BB.FieldByName('Param').AsString,
                     stream );
  stream.Free;

end;



function  MultiIdFilter( ADSet, FltDSet :TDataSet; N :Integer = 8 ) :Boolean;
  // true jesli   for i = 1..N  ADSet.ID<i> = FltDSet.ID<i>
  //                            OR FltDSet.ID<i> = '?'
  // gdzie ID<i> dla i = 1,2,... to pole w bazie o nazwie "ID1", "ID2", ...
var
  FldN    :string;
  FltV    :string;
  i       :Integer;
begin
  result := true;
  i := 1;
  while result and (i <= 8) do
  begin
    FldN := Format( 'ID%d', [i] );
    FltV := FltDSet.FieldByName(FldN).AsString;

    if not  (  (ADSet.FieldByName(FldN).AsString = FltV)
              or (FltV = '?') )  then
      result := false;

    inc(i);
  end;
end;


function  MultiIdFindBest( ADSet, DestDSet :TDataSet; N :Integer = 8 ) :Boolean;
var
  A       :Variant;
  s       :string;
  i       :Integer;
begin
  s := 'ID1';
  A := VarArrayCreate([0, N-1], varVariant);
  A[0] := ADSet.FieldValues['ID1'];
  for i := 2 to N do
  begin
    s := Format( '%s;ID%d', [s, i] );
    A[i-1] := ADSet.FieldValues[Format('ID%d', [i])];
  end;

  result := false;
  i := N;
  while (not result) and (i > 0) do
  begin
    result := DestDSet.Locate( s, A, [] );
    if not result then
      A[i-1] := '';
    dec(i);
  end;
end;


function FindKatalCD: string;
begin
  result := GetCDRomDrives;
  if pos( ';', result ) > 0 then
    result := StrBefore( ';', result );
end;

procedure Rzedna( c:TCanvas; x,y:Integer);
  // przeniesione z KC_Dane
const  sx=7;
       sy=7;
begin
  c.Polyline([Point(x+3*sx,y-sy),Point(x-sx,y-sy),
	    Point(x,y),Point(x,y-(4*sy div 2))]);
end;

procedure RzednaLewa( c:TCanvas; x,y:Integer);
  // przeniesione z KC_Dane
const  sx=7;
       sy=7;
begin
  c.Polyline([Point(x-3*sx,y-sy),Point(x+sx,y-sy),
	    Point(x,y),Point(x,y-(4*sy div 2))]);
end;

procedure GrotGora(c :TCanvas; x,y :integer);
var
  pkolor, bkolor :TColor;
begin
  with c do
    begin
    pkolor:=pen.color;
    bkolor:=Brush.Color;
    pen.color:=clBlack;
    Brush.Color := clBlack;
    Polygon([Point(x,y),Point(x-2,y+6),
	       Point(x+2,y+6)]);
    pen.color:=pkolor;
    Brush.Color:=bkolor;
    end;
end;

procedure GrotDol(c :TCanvas; x,y :integer);
var
  pkolor, bkolor :TColor;
begin
  with c do
    begin
    pkolor:=pen.color;
    bkolor:=Brush.Color;
    pen.color:=clBlack;
    Brush.Color := clBlack;
    Polygon([Point(x,y),Point(x-2,y-6),
               Point(x+2,y-6)]);
    pen.color:=pkolor;
    Brush.Color:=bkolor;
    end;
end;

procedure GrotLewy(c :TCanvas; x,y :integer);
var
  pkolor, bkolor :TColor;
begin
  with c do
    begin
    pkolor:=pen.color;
    bkolor:=Brush.Color;
    pen.color:=clBlack;
    Brush.Color := clBlack;
    Polygon([Point(x,y),Point(x+6,y-2),
               Point(x+6,y+2)]);
    pen.color:=pkolor;
    Brush.Color:=bkolor;
    end;
end;




const
  cLogFileName = 'errtbs.log';

var
  vLogFileName :string = '';


procedure BeginLog;
var
  F       :Integer;
begin
  vLogFileName := ExtractFilePath(ParamStr(0)) + cLogFileName;
  F := FileCreate( vLogFileName );
  FileClose(F);
end;

procedure AddLog( const s :string );
var
  F       :TextFile;
  v       :string;
  dNow    :TDateTime;
  sNow    :string;
begin

  if vLogFileName = '' then
    BeginLog;
  AssignFile( F, vLogFileName );
  try
    Append(F);
    dNow := Now;
    sNow := DateTimeToStr(dNow);
    WriteLn( F, '(', sNow, ')  ', s );
  finally
    CloseFile(F);
  end;

end;

procedure AddLogFmt( const fmt :string; const a :array of const );
begin
  AddLog( Format( fmt, a ) );
end;
{ do uruchomienia
function UcQ(val:double):double;
begin
  if UidQ='lns'
    then result := val*1000/3600 //zamienia m3/h na l/s
    else result := val;
end;

function LcQ:string;
begin
  if UidQ='lns'
    then result := 'l/s'
    else result := 'm3/h';
end;
}

procedure PodstawTeksty(Test : TStrings; co, naco : array of string);
var i,j,k : integer;
    przed, po : AnsiString;
begin
 for j:=low(co) to high(co) do
 begin
   i:=pos(co[j],test.Text);
   if i>0 then
   begin
     przed := LeftStr(test.GetText,i-1);
     po    := RightStr(test.GetText,length(test.GetText) - i - length(co[j]) + 1 );
     test.SetText(PWideChar(przed + naco[j] + po));
   end;
 end;
end;

end.
