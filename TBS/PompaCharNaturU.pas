unit PompaCharNaturU;

interface

uses
  SysUtils, Math, KrMath,
  OPompa, LinCharU, MotorObjU;

procedure ObliczCharNatur( Res :TSZCharDataCopy; CharConstN :TFuncCharData;
                           Mot :TMotorElektr );

implementation

function MotNOdP( P :Double; M :Pointer ) :Double;
begin
  Result := TMotorElektr(M).N_OdP(P);
end;

function P_PrzezN3( P :Double; M :Pointer ) :Double;
var
  n      :Double;
begin
  n := TMotorElektr(M).N_OdP(P);
  Result := f_div( P, n*n*n );
end;

function PmpPOdQ( Q :Double; cd :Pointer ) :Double;
begin
  Result := TFuncCharData(cd).P(Q);
end;


procedure ObliczCharNatur( Res :TSZCharDataCopy; CharConstN :TFuncCharData;
                           Mot :TMotorElektr );
var
  i       :Integer;
  N0, P0  :Double;
  qc, hc, Pc  :Double;
  q, h, p, n  :Double;
  npn0        :Double;
  pmin, pmax  :Double;
  qmin, qmax  :Double;
begin
  pmin := Mot.FunN.XMin;
  pmax := Mot.FunN.XMax;

  if (CharConstN.P(CharConstN.GetCharQMin) >= pmin)
      and (CharConstN.CharPMax <= pmax) then
    Res.Assign(CharConstN)
  else
  begin
    if CharConstN.P(CharConstN.GetCharQMin) >= pmin then
      qmin := CharConstN.GetCharQMin
    else
      if not FuncBSearch( PmpPOdQ, CharConstN, CharConstN.GetCharQMin,
                   CharConstN.CharQMax, pmin, qmin, 0.001 ) then
        raise Exception.Create('Blad: nie mozna obliczyc Qmin');

    if CharConstN.P(CharConstN.CharQMax) <= pmax then
      qmax := CharConstN.GetCharQMax
    else
      if not FuncBSearch( PmpPOdQ, CharConstN, CharConstN.GetCharQMin,
                   CharConstN.CharQMax, pmax, qmax, 0.001 ) then
        raise Exception.Create('Blad: nie mozna obliczyc Qmax');
    Res.AssignRange( qmin, qmax, CharConstN );
  end;
  N0 := CharConstN.Obroty;
  //if not FuncBSearch( MotNOdP, Mot, Mot.FunN.XMin, Mot.FunN.XMax, N0, P0 ) then
  //  raise Exception.Create('Blad: nie mozna obliczyc P0');

  for i := 1 to Res.Punkty.n_pt do
  begin
    qc := Res.Punkty.Q[i];
    hc := Res.Punkty.H[i];
    Pc := Res.Punkty.P[i];
    if not FuncBSearch( P_PrzezN3, Mot, Mot.FunN.XMin, Mot.FunN.XMax,
                        F_DIV(Pc,N0*N0*N0), p ) then
      raise Exception.Create('Blad: nie mozna obliczyc P');

    n := Mot.N_OdP(p);
    npn0 := F_DIV(n, N0);
    q := npn0 * qc;
    h := npn0* npn0 * hc;

    Res.Punkty.Q[i] := q;
    if i = Res.Punkty.n_pt then
      Res.FCharQMax := q
    else if i = 1 then
      Res.FCharQMin := q;
    Res.Punkty.H[i] := h;
    Res.Punkty.P[i] := p;

  end;
  Res.ObliczWsp;
end;

end.
