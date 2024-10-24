unit ObszarWCharU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DB,
  DGraph, TbsFormU, Diagrams, KR_Class,
  LinCharU, OPompa, PompySQL, PmpListU, Math, WCharU;

type
  TObszWCharDiagFun = class (TDiagFunDrawer)
  private
    FLewePkty  :array of TRealPointRec;
    FPrawePkty :array of TRealPointRec;
    FCharList  :TWCharList;
    Points     :TRealPointRecArrDyn;
    FLastDiagDX :Double;
    FBorderColor: TColor;
    FDrawBorder: Boolean;
    FDrawInterior: Boolean;

    procedure SetCharList(const Value: TWCharList);
    procedure Sort( var A :array of TRealPointRec );
    procedure SetBorderColor(const Value: TColor);
    procedure SetDrawBorder(const Value: Boolean);
    procedure SetDrawInterior(const Value: Boolean);

  protected
    procedure DrawFun  ( dt  :TSpecDrawData; bw :Boolean ); override;

    procedure CreatePoints;
    procedure Prepare;
  public
    constructor Create( o: TComponent );            override;

    function CheckHit( AX, AY :Double; const R :TRealRectRec ) :Boolean;
    function FindCharXY( AX, AY :Double; const R :TRealRectRec ) :TWCharInfo;

    property CharList :TWCharList read FCharList write SetCharList;

    property BorderColor :TColor read FBorderColor write SetBorderColor;
    property DrawBorder   :Boolean read FDrawBorder write SetDrawBorder;
    property DrawInterior :Boolean read FDrawInterior write SetDrawInterior;
  end;

implementation

{ TObszWCharDiagFun }

function TObszWCharDiagFun.CheckHit(AX, AY: Double;
                                    const R :TRealRectRec): Boolean;
var
  P         :TRealPointRec;
  i         :Integer;
begin
  Result := False;
  if DrawInterior then
  begin
    if (FCharList <> NIL) and (FCharList.Count > 0) then
    begin
      if Length(Points) < 1 then
        CreatePoints;
      P.X := AX;
      P.Y := AY;
      Result := PointInPolygon( P, Points );
    end;
  end
  else if DrawBorder then
  begin
    i := 0;
    while not Result and (i < (Length(Points)-1)) do
    begin
      Result := LineRectIsIntersect( Points[i], Points[i+1], R );
      inc(i);
    end;
  end;
end;

constructor TObszWCharDiagFun.Create(o: TComponent);
begin
  inherited;
  FDrawInterior := True;
  FDrawBorder   := False;
end;

procedure TObszWCharDiagFun.CreatePoints;
var
  i         :Integer;
  x, y      :Double;
  dx, xkon  :Double;
  PntCnt    :Integer;
begin
  if (FCharList <> NIL) and (FCharList.Count > 0) then
  begin
    Points := NewArrayPoint( PntCnt, 100 );
    for i := 0 to High(FLewePkty) do
      ArrayPointAdd( Points, PntCnt, FLewePkty[i] );
    x    := FLewePkty[High(FLewePkty)].X;
    xkon := FPrawePkty[High(FPrawePkty)].X;
    dx := DrawData.DX;
    while x <= xkon do
    begin
      y := 0;
      for i := 0 to CharList.Count-1 do with CharList.Info[i].Char do
        if (GetQMin <= x) and (x <= GetQMax) then
          y := max( y, H(x) );
      //dt.LineTo(x, y);
      ArrayPointAddXY( Points, PntCnt, x, y );
      x := x + dx;
    end;
    for i := High(FPrawePkty) downto Low(FPrawePkty) do
      //dt.LineTo( FPrawePkty[i].X, FPrawePkty[i].Y );
      ArrayPointAdd( Points, PntCnt, FPrawePkty[i] );
    x    := FPrawePkty[Low(FPrawePkty)].X;
    xkon := FLewePkty[Low(FLewePkty)].X;
    while x >= xkon do
    begin
      y := CharList.Info[0].Char.H(x);
      for i := 0 to CharList.Count-1 do with CharList.Info[i].Char do
        if (GetQMin <= x) and (x <= GetQMax) then
          y := min( y, H(x) );
      //dt.LineTo(x, y);
      ArrayPointAddXY( Points, PntCnt, x, y );
      x := x - dx;
    end;
    FinishArrayPoint( Points, PntCnt );
    FLastDiagDX := dx;
  end;
end;

procedure TObszWCharDiagFun.DrawFun(dt: TSpecDrawData; bw: Boolean);
begin
  if (FCharList <> NIL) and (FCharList.Count > 0) then
  begin
    if (Length(Points) > 2) or (FLastDiagDX <> dt.dx) then
      CreatePoints;
    if DrawInterior then
      dt.PolygonFill( Points, Self.Color );
    if DrawBorder then
    begin
      dt.ParentData.SetLineWidth(LineWidth);
      dt.Canvas.Pen.Color := BorderColor;
      dt.Polygon( Points )
    end;
    //dt.LineTo( FLewePkty[0].X, FLewePkty[0].Y );
  end;
end;

function TObszWCharDiagFun.FindCharXY(AX, AY: Double;
  const R: TRealRectRec): TWCharInfo;
var
  i      :Integer;
begin
  Result := NIL;
  i := FCharList.Count;
  while (i>0) and (Result = NIL) do
  begin
    dec(i);
    if FCharList.Info[i].CheckHit(R) then
      Result := FCharList.Info[i];
  end;
end;

procedure TObszWCharDiagFun.Prepare;
var
  i       :Integer;
begin
  if FCharList <> NIL then
  begin
    SetLength(FLewePkty,  FCharList.Count );
    SetLength(FPrawePkty, FCharList.Count );
    for i := 0 to FCharList.Count-1 do with FCharList.Info[i] do
    begin
      FLewePkty[i].X  := Char.GetQMin;
      FLewePkty[i].Y  := Char.H(Char.GetQMin);
      FPrawePkty[i].X := Char.GetQMax;
      FPrawePkty[i].Y := Char.H(Char.GetQMax);
    end;
    Sort(FLewePkty);
    Sort(FPrawePkty);
  end
  else
  begin
    SetLength(FLewePkty,  0 );
    SetLength(FPrawePkty, 0 )
  end;
  SetLength( Points, 0 );
end;

procedure TObszWCharDiagFun.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
end;

procedure TObszWCharDiagFun.SetCharList(const Value: TWCharList);
begin
  FCharList := Value;
  Prepare;
end;

procedure QSort(var A: array of TRealPointRec; L, R :Integer);
var
  I, J: Integer;
  P, T: TRealPointRec;
begin
  if L >= R then
    EXIT;
  repeat
    I := L;
    J := R;
    P := A[(L + R) shr 1];
    repeat
      while A[I].Y < P.Y do Inc(I);
      while A[J].Y > P.Y do Dec(J);
      if I <= J then
      begin
        T := A[I];
        A[I] := A[J];
        A[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QSort(A, L, J );
    L := I;
  until I >= R;
end;

procedure TObszWCharDiagFun.SetDrawBorder(const Value: Boolean);
begin
  FDrawBorder := Value;
end;

procedure TObszWCharDiagFun.SetDrawInterior(const Value: Boolean);
begin
  FDrawInterior := Value;
end;

procedure TObszWCharDiagFun.Sort(var A: array of TRealPointRec);
begin
  QSort( A, Low(A), High(A) );
end;

end.
