unit B4charU;

interface

uses
  WinTypes, WinProcs, SysUtils, Classes, Graphics, DB, DBTables,
  KrMath, DGraph, Diagrams, PumpIntf, OPompa;

type

  TB4Data  = class (TPompCharData)
    private
      FCountH    :Integer;
      ListH      :TList;
      FQMin      :Double;
      FQMax      :Double;
      FHMin      :Double;
      FHMax      :Double;

    protected
      function   getCurveH( i :Integer ): PRealPointRecArray;
    public
      constructor Create( AOwner :TComponent ); override;
      destructor  Destroy;                      override;

      procedure  ReadFromHTable( HT :TDataSet );override;
      function   GetDiagFun( id :string; Owner :TDiagFunction ) :TCharDataDiagFun;
                                                override;
      function  WorkPoint( Sel :IPumpCharSel; var Qr, Hr :Double ) :Boolean;
                                                override;
      function  GetQMin  :Double;               override;
      function  GetQMax  :Double;               override;
      function  GetCharQMin  :Double;           override;
      function  GetCharQMax  :Double;           override;
      function  GetHMin  :Double;               override;
      function  GetHMax  :Double;               override;
      function  GetCharHMin  :Double;           override;
      function  GetCharHMax  :Double;           override;
      function  GetCharPMax  :Double;           override;
      function  GetCharNPSHMax  :Double;        override;

      procedure  AddCurveH;
      property   CountH: Integer read FCountH;
      property   ListaKrzywH [i :Integer] :PRealPointRecArray read getCurveH;
      property   HMax :Double read FHMax;
  end;

  TB4HDiagFun = class (TCharDataDiagFun)
    protected
      procedure DrawFun  ( dt  :TSpecDrawData; bw :Boolean );  override;
      function  GetData  :TB4Data;
      procedure SetData( AData :TB4Data );
    public
      property  Data :TB4Data read GetData write SetData;

  end;



{=============================================================================}
implementation

{-----------------------------------------------------------------------------}
constructor TB4Data.Create( AOwner :TComponent );
begin
  inherited Create( AOwner );
  ListH   := TList.Create;
  FCountH := 0;
end;

{-----------------------------------------------------------------------------}
destructor  TB4Data.Destroy;
var
  i         :Integer;
begin
  for i := 0 to CountH-1 do
    FreeMem( ListH.Items[i], SizeOf(TRealPointRec)* 4 );
  ListH.Free;
end;


{----------------------------------------------------------------------------}
procedure  TB4Data.ReadFromHTable( HT :TDataSet );
var
  n, i     :Integer;
  nPt0     :Integer;
  pt       :Integer;
  maxH     :Double;
  MaxQ     :Double;
  minH     :Double;
  minQ     :Double;
  p        :PRealPointRecArray;
begin

  n    := HT.FieldByName('n_pt').AsInteger;
  //   MS wstawka   zmiana zamiast liczenia dodawania do listy
  FCountH:=n;

  nPt0 := HT.FieldByName('PT1').Index - 1;
  maxH := 0;
  MaxQ := 0;
  minH := 10000000;
  minQ := 10000000;

  for i := 0 to n-1 do
  begin
    AddCurveH;
    pt := i+1;
    with HT do
    begin
      p := ListaKrzywH[i];
      p^[0].x := Fields[ nPt0 + pt*2 - 1 ].AsFloat;
      ListaKrzywH[i]^[3].x := Fields[ nPt0 + pt*2 ].AsFloat;

      ListaKrzywH[i]^[0].y := Fields[ nPt0 + 2*n + pt*2 - 1 ].AsFloat;
      ListaKrzywH[i]^[3].y := Fields[ nPt0 + 2*n + pt*2 ].AsFloat;

      ListaKrzywH[i]^[1].x := Fields[ nPt0 + 4*n + pt*2 - 1 ].AsFloat;
      ListaKrzywH[i]^[2].x := Fields[ nPt0 + 4*n + pt*2 ].AsFloat;

      ListaKrzywH[i]^[1].y := Fields[ nPt0 + 6*n + pt*2 - 1 ].AsFloat;
      ListaKrzywH[i]^[2].y := Fields[ nPt0 + 6*n + pt*2 ].AsFloat;

      if p^[0].y > maxH then maxH := P^[0].y;
      if p^[1].y > maxH then maxH := P^[1].y;
      if p^[2].y > maxH then maxH := P^[2].y;
      if p^[3].y > maxH then maxH := P^[3].y;

      if p^[0].x > maxQ then maxQ := P^[0].x;
      if p^[1].x > maxQ then maxQ := P^[1].x;
      if p^[2].x > maxQ then maxQ := P^[2].x;
      if p^[3].x > maxQ then maxQ := P^[3].x;

      if p^[0].y < minH then minH := P^[0].y;
      if p^[1].y < minH then minH := P^[1].y;
      if p^[2].y < minH then minH := P^[2].y;
      if p^[3].y < minH then minH := P^[3].y;

      if p^[0].x < minQ then minQ := P^[0].x;
      if p^[1].x < minQ then minQ := P^[1].x;
      if p^[2].x < minQ then minQ := P^[2].x;
      if p^[3].x < minQ then minQ := P^[3].x;


    end;
  end;
  FHMin := minH;
  FQMin := minQ;
  FHMax := maxH;
  FQMax := MaxQ;

end;

{----------------------------------------------------------------------------}
function  TB4Data.GetQMin  :Double;
begin
  result := 0;
end;

{----------------------------------------------------------------------------}
function  TB4Data.GetQMax  :Double;
begin
  result := FQMax;
end;

{----------------------------------------------------------------------------}
function  TB4Data.GetCharQMin  :Double;
begin
  result := 0;
end;

{----------------------------------------------------------------------------}
function  TB4Data.GetCharQMax  :Double;
begin
  result := FQMax;
end;

{----------------------------------------------------------------------------}
function  TB4Data.GetHMin  :Double;
begin
  result := FHMin;
end;

{----------------------------------------------------------------------------}
function  TB4Data.GetHMax  :Double;
begin
  result := FHMax;
end;

{----------------------------------------------------------------------------}
function  TB4Data.GetCharHMin  :Double;
begin
  result := FHMin;
end;

{----------------------------------------------------------------------------}
function  TB4Data.GetCharHMax  :Double;
begin
  result := FHMax;
end;

function TB4Data.GetCharNPSHMax: Double;
begin
  result := 0;
end;

function TB4Data.GetCharPMax: Double;
begin
  result :=  0;
end;



{----------------------------------------------------------------------------}
function   TB4Data.GetDiagFun( id :string; Owner :TDiagFunction ) :TCharDataDiagFun;
begin
  result := NIL;
  if UpperCase( id ) = 'H' then
  begin
    result := TB4HDiagFun.Create(Owner);
    if result <> NIL then
    begin
      TB4HDiagFun(result).Data := self;
      Owner.Drawer := result;
      result.CountMaxYR( GetCharHMax );
    end;
  end;
end;

{----------------------------------------------------------------------------}
function  TB4Data.WorkPoint( Sel :IPumpCharSel; var Qr, Hr :Double ) :Boolean;

var
  x1, y1  :Double;
  ind     :Integer;

{----------------------------------------------------------}
function B4Left( var A :TRealPointRecArray; xt, yt :Double ): Longint;

type
  TDouble4 = array [1..4] of Double;

var
  X, Y             :TDouble4;
  i, j, m, n       :Longint;
  t, dt            :Double;
  sum              :Longint;
  x2, y2           :Double;
  Rx, Ry, Qx, Qy   :TDouble4;

begin

  m   := 4;
  sum := 0;
  dt  := 0.0625;   { 1 / 16 }

  for i := 1 to 4 do
  begin
    X[i] := A[i-1].x;
    Y[i] := A[i-1].y;
  end;


  { punkt startowy }
  x2 := x[1];
  y2 := y[1];

  { GLOWNY ALGORYTM }
  t := 0;
  j := 0;
  while t <= 1 do
  begin
    for i := 1 to m do
    begin
      Rx[i] := X[i];
      Ry[i] := Y[i];
    end;
    n := m;
    while n > 1 do
    begin
      for i := 1 to n-1 do
      begin
        Qx[i] := Rx[i] + t*(Rx[i+1]-Rx[i]);
        Qy[i] := Ry[i] + t*(Ry[i+1]-Ry[i]);
      end;
      dec(n);
      for i := 1 to n do
      begin
        Rx[i] := Qx[i];
        Ry[i] := Qy[i];
      end;
    end;

    if ((y2 <> yt) or (ind = 0)) then
    begin
       x1 := x2;
       x2 := Rx[1];
       y1 := y2;
       y2 := Ry[1];
    end
    else
    begin
       x2 := Rx[1];
       y2 := Ry[1];
    end;

    if ((y1 <= yt) and (yt < y2)) or ((y1 >= yt) and (yt > y2)) then
    begin
      if Lin( yt, y1, y2, x1, x2 ) <= xt then
      begin
        inc(sum);
      end;
    end;

    inc(j);
    t := j*dt;
  end;     { while t <= 1 }

  result := sum;
end;

var
  n       :Integer;
begin
  if (Sel.GetQw < GetQMin) or (GetQMax < Sel.GetQw)
     or (Sel.GetHw < GetHMin) or (GetHMax < Sel.GetHw) then
  begin
    result := false;
    EXIT;
  end;

  n := 0;
  for ind := 0 to CountH-1 do
  begin
    n := n + B4Left( ListaKrzywH[ind]^, Sel.GetQw, Sel.GetHw );
  end;
  result := ((n mod 2) <> 0);
  if result then
  begin
    Qr := Sel.GetQw;
    Hr := Sel.GetHw;
  end;
end;

{----------------------------------------------------------------------------}
function   TB4Data.getCurveH( i :Integer ): PRealPointRecArray;
begin
  result := ListH.Items[i];
end;


{----------------------------------------------------------------------------}
procedure  TB4Data.AddCurveH;
var
  p        :PRealPointRecArray;
begin
  GetMem(p, SizeOf(p^[0])*4 );
  ListH.Add(p);
  //?????? MS   Dodaje do istniejacej listy
 // inc(FCountH);
end;



{----------------------------------------------------------------------------}
function  TB4HDiagFun.GetData  :TB4Data;
begin
  result  := (CharData as TB4Data);
end;

{----------------------------------------------------------------------------}
procedure TB4HDiagFun.SetData( AData :TB4Data );
begin
  CharData := AData;
end;



{----------------------------------------------------------------------------}
procedure TB4HDiagFun.DrawFun  ( dt  :TSpecDrawData; bw :Boolean );
var
  i       :Integer;
begin
  if IsOn then
  begin
    for i := 0 to Data.CountH-1 do
      dt.Bezier( Data.ListaKrzywH[i]^, 4 );
  end;
end;


BEGIN
  RegisterCharData( 'B4', TB4Data );
END.
