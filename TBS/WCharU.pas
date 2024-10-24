unit WCharU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DB,
  DGraph, TbsFormU, Diagrams, KR_Class,
  LinCharU, OPompa, PompySQL, PmpListU, Math;

type

  TWCharInfo = class (TComponent)
  private
    FChar: TSZCharDataCopy;

  public
    HFun       :TDiagFunction;
    HDrawer    :TFuncDiagFun;
    BM         :TBookmarkStr;
    NazwaPompy :string;
    Color      :TColor;
    constructor Create( AOwner :TComponent );              override;
    procedure   Assign( ASource : TPersistent);            override;
    function  CheckHit(R :TRealRectRec) :Boolean;
    property Char       :TSZCharDataCopy  read FChar;
  end;

  TWCharList = class (TComponentStreamableList)
  private
    function GetInfo(i: Integer): TWCharInfo;
  public
    constructor Create;
    function AddInfo(cd: TPompCharData; Diag :TDiagram) :Boolean;
    property Info[ i :Integer ] :TWCharInfo read GetInfo;
  end;



implementation

{ TWCharInfo }

procedure TWCharInfo.Assign(ASource: TPersistent);
begin
  if ASource is TFuncCharData then
  begin
    FChar.Assign(ASource);
    HDrawer := Char.GetDiagFun( 'H', HFun ) as TFuncDiagFun;;
    HDrawer.Legend := false;
  end
  else
    inherited;
end;

function TWCharInfo.CheckHit(R: TRealRectRec): Boolean;
var
  X, Y   :Double;
  dx     :Double;
  P1, P2 :TRealPointRec;
begin
  Result := False;
  X := FChar.GetCharQMin;
  Y := FChar.H(X);
  dx := HFun.DrawData.DX; 
  P1.X := X;
  P1.Y := Y;
  while not Result and (X <= FChar.GetCharQMax) do
  begin
    P2 := P1;
    X := X + dx;
    Y := FChar.H(X);
    P1.X := X;
    P1.Y := Y;
    Result := LineRectIsIntersect( P1, P2, R );
  end;
end;

constructor TWCharInfo.Create(AOwner: TComponent);
begin
  FChar := TSZCharDataCopy.Create(self);
  HFun := TDiagFunction.Create(self);
end;


{ TWCharList }

function TWCharList.AddInfo(cd: TPompCharData; Diag :TDiagram) :Boolean;
var
  inf     :TWCharInfo;

begin
  Result := false;
  if cd is TFuncCharData then
  begin
    //sprawdŸ charakterystykê na wywalanie
    try
      if IsNaN(TFuncCharData(cd).H(cd.GetQMin)) then
        EXIT;
      if IsNaN(TFuncCharData(cd).H(cd.GetQMax)) then
        EXIT;
    except
      EXIT;
    end;


    inf := TWCharInfo.Create(NIL);
    inf.HFun.Diagram := Diag;
    inf.Assign(cd);
    if (cd.Pompa <> NIL) and (cd.Pompa.DB <> NIL) then
    begin
      inf.BM := TBookmarkStr(cd.Pompa.DB.A.Bookmark);
      inf.NazwaPompy := cd.Pompa.Nazwa;
    end;
    Add(inf);
    Result := true;
  end;
end;

constructor TWCharList.Create;
begin
  inherited;
  ShldFreeItems := true;
end;

function TWCharList.GetInfo(i: Integer): TWCharInfo;
begin
  Result := TWCharInfo(Items[i]);
end;



end.
