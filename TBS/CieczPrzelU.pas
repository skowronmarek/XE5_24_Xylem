unit CieczPrzelU;

interface

uses
  SysUtils, Classes, Diagrams, Math, PumpIntf, OPompa, LinCharU, Ciecze,
  KrMath, PompMath;

type
  TPrzelCieczLepMet = (pclmNewYork, pclmSkowronski);

  TDaneDoApro = class
  private
    n:word;
    Z:array[1..20,1..2] of real;
    B:array[0..3] of real;
  end;

  TPompCieczCharData = class (TFuncCharData)
  private
    FCiecz: TCiecz;
    FBazCharData: TFuncCharData;
    procedure SetCiecz(const Value: TCiecz);
    procedure SetBazCharData(const Value: TFuncCharData);
  protected
    FWewnCharData :TFuncCharData;
    F_Ni_H :Double;
    F_Ni_Q :Double;
    F_Ni_P :Double;
    F_Ro_P :Double;
    DaneH,DaneP:TDaneDoApro;
    function FaktorQ :Double;    virtual;
    function FaktorH :Double;    virtual;
    function FaktorP :Double;    virtual;
    procedure ObliczFaktory(Q :Double);
    procedure PrzeliczNY;
    procedure PrzeliczSkowr;
  public
    QOpt, HOpt :Double;
    Metoda     :TPrzelCieczLepMet;
    Komunik    :string;
    constructor Create3( O :TComponent;
                         ACiecz :TCiecz;
                         ABazaChar :TFuncCharData );
    procedure Przelicz;                  virtual;
    //MoJA procedura
    procedure Apro_W2_(var D:TDaneDoApro);
    function  Get_W2_(Dane:TDaneDoApro;Q:real):real; //wartosc wielomianu
    function  PunktOptymalny(DaneH,DaneP:TDaneDoApro;
                                            minQ,maxQ:real):real;
    function Obl_nsQ(n,Q,H:real):real;
    function EtaVLomakin(nsQ:real):real;
    procedure PunktyWewnetrz(QsWod:real; var Dane:TDaneDoApro);
    PROCEDURE PrzeliczBezwym(Q,H,nsQ:real; bcd:TLPktCharData;
                             var wH,wQ,wP:real);
    FUNCTION  Kcm2(nsQ:real):real;
    PROCEDURE PynktyBezwymiaroweWoda(wH,wQ,wP:real;
                                  var DaH,DaP:TDaneDoApro);
    PROCEDURE RoznicePrzel(Re2Ni:real;
                           var D1,D2,D3,D4,D5,D6:real);
    procedure PrzeliczNaLep(FIk,D1,D2,D3,D4,D5,D6:real;
                             var DaneH,DaneP:TDaneDoApro);
    PROCEDURE CharLepka(wH,wQ,wP:real;var DaH,DaP:TDaneDoApro);

    function  WorkPoint( Sel :IPumpCharSel; var Qr, Hr :Double ) :Boolean;
                                                         override;
    function  GetQMin      :Double;           override;
    function  GetQMax      :Double;           override;
    function  GetCharQMin  :Double;           override;
    function  GetCharQMax  :Double;           override;
    function  GetHMin      :Double;           override;
    function  GetHMax      :Double;           override;
    function  GetCharHMin  :Double;           override;
    function  GetCharHMax  :Double;           override;

    function  H   ( Q :Double ) :Double;      override;
    function  P   ( Q :Double ) :Double;      override;
    function  NPSH( Q :Double ) :Double;      override;
    function  ETA ( Q :Double ) :Double;      override;

    property Ciecz :TCiecz read FCiecz write SetCiecz;
    property BazCharData :TFuncCharData read FBazCharData write SetBazCharData;
  end;


implementation

{ TPompCieczCharData }

constructor TPompCieczCharData.Create3(O: TComponent; ACiecz: TCiecz;
  ABazaChar: TFuncCharData);
begin
  inherited Create(O);
  FCiecz := ACiecz;
  FBazCharData := ABazaChar;
  FWewnCharData := ABazaChar.MakeCopy( self ) as TFuncCharData;
  Przelicz;
end;

function TPompCieczCharData.ETA(Q: Double): Double;
begin
  if Ciecz = NIL then
    result := FWewnCharData.ETA(Q)
  else
    result := PompMath.Eta( Q, H(Q), P(Q), Ciecz.Ro );
end;

function TPompCieczCharData.FaktorH: Double;
begin
  result := 1;
  if FCiecz <> NIL then
  begin
    result := F_Ni_H;
  end;
end;

function TPompCieczCharData.FaktorP: Double;
begin
  result := 1;
  if FCiecz <> NIL then
  begin
    result := F_Ni_P*(FCiecz.Ro/1000);
  end;
end;

function TPompCieczCharData.FaktorQ: Double;
begin
  result := 1;
  if FCiecz <> NIL then
  begin
    result := F_Ni_Q;
  end;
end;

function TPompCieczCharData.GetCharHMax: Double;
begin
  result := FWewnCharData.GetCharHMax;
end;

function TPompCieczCharData.GetCharHMin: Double;
begin
  result := FWewnCharData.GetCharHMin;
end;

function TPompCieczCharData.GetCharQMax: Double;
begin
  result := FWewnCharData.GetCharQMax;
end;

function TPompCieczCharData.GetCharQMin: Double;
begin
  result := FWewnCharData.GetCharQMin;
end;


function TPompCieczCharData.GetHMax: Double;
begin
  result := FWewnCharData.GetHMax;
end;

function TPompCieczCharData.GetHMin: Double;
begin
  result := FWewnCharData.GetHMin;
end;

function TPompCieczCharData.GetQMax: Double;
begin
  result := FWewnCharData.GetQMax;
end;

function TPompCieczCharData.GetQMin: Double;
begin
  result := FWewnCharData.GetQMin;
end;

function TPompCieczCharData.H(Q: Double): Double;
begin
  result := FWewnCharData.H(Q);
end;

function TPompCieczCharData.NPSH(Q: Double): Double;
begin
  result := FWewnCharData.NPSH(Q);
end;

procedure TPompCieczCharData.ObliczFaktory(Q :Double);
// Qopt = Qn
// Hopt = Hn
// Qwzg = Q/Qn

var
  f_ni_ETA : real;
  lnRe     : real;
  QWzg     : Double;
  Re       : Double;

function FunNiH( QWzg :Double ):Double;
begin
 { result :=  -1.7048169613
            +1.0209121560*lnRe
            -0.4593197285*Qwzg
            -0.1468418298*lnRe*lnRe
            -0.1222461212*Qwzg*Qwzg
            +0.0093820756*lnRe*lnRe*lnRe
            -0.0142227032*Qwzg*Qwzg*Qwzg
            -0.0002181902*lnRe*lnRe*lnRe*lnRe
            +0.1158698206*lnRe*Qwzg
            -0.0073694276*lnRe*lnRe*Qwzg
            +0.0012924417*lnRe*lnRe*Qwzg*Qwzg;}

  {wersja 2000.02.12 }
  result := -0.9377431363
            +0.6401176129*lnRe
            -0.4466819063*Qwzg
            -0.0772838492*lnRe*lnRe
            -0.1362996112*Qwzg*Qwzg
            +0.0038094386*lnRe*lnRe*lnRe
            -0.0091257723*Qwzg*Qwzg*Qwzg
            -0.0000525293*lnRe*lnRe*lnRe*lnRe
            +0.1163880672*lnRe*Qwzg
            -0.0074769533*lnRe*lnRe*Qwzg
            +0.0013173892*lnRe*lnRe*Qwzg*Qwzg;

end;

begin
  if FCiecz = NIL then
    EXIT;

  //            --------------
  //       4   /               2
  //       -  / 2*g*Hopt * Qopt
  //        \/
  //  Re = ---------------------
  //              Ni
  Re := F_DIV( Power({2*9.81*}Hopt*sqr(Qopt/3600) , 0.25), FCiecz.Ni);
  lnRe:=ln( Re );
  QWzg := Q/Qopt;


{if (Re > 127000)}
{poprawka 2000.02.12 MS}
 if (Re > 88000)
      or ((Re > 50000) and (QWzg > 1))
      or ((Re > 34000) and (QWzg > 0.8))
      or ((Re > 23000) and (QWzg > 0.6)) then
    f_NI_H := 1
  else if QWzg >= 0.6 then
    f_ni_H := FunNiH(QWzg)
  else
    f_ni_H := Lin( QWzg, 0, 0.6, 1, FunNiH(0.6) );


{  if Re > 158000 then
    f_ni_ETA := 1
  else
    f_ni_ETA := 0.774579
            -0.9725675   *lnRe
            +0.2635508   *lnRe*lnRe
            -0.0237208   *lnRe*lnRe*lnRe
            +0.0007202819*lnRe*lnRe*lnRe*lnRe;}

{poprawka 2000.02.12 MS}
  if Re > 141000 then
    f_ni_ETA := 1
  else
    f_ni_ETA := 0.70282327
               -0.90912778   *lnRe
               +0.24812860   *lnRe*lnRe
               -0.022290574  *lnRe*lnRe*lnRe
               +0.00067555319*lnRe*lnRe*lnRe*lnRe;


  if Re > 11000 then
    f_ni_Q := 1
  else
{    f_ni_Q := -4.5824232
            +1.765933    *lnRe
            -0.189612    *lnRe*lnRe
            +0.0069084181*lnRe*lnRe*lnRe;}
{poprawka 2000.02.12 MS}
    f_ni_Q := -4.0564583
              +1.5621349    *lnRe
              -0.16357128   *lnRe*lnRe
              +0.0058107886 *lnRe*lnRe*lnRe;

   f_ni_P := (f_ni_Q * f_ni_H) / f_ni_ETA;
end;


function TPompCieczCharData.P(Q: Double): Double;
begin
  result := FWewnCharData.P(Q);
end;

procedure TPompCieczCharData.Przelicz;
begin
  Komunik := '';
  case Metoda of
    pclmNewYork:
      PrzeliczNY;
    pclmSkowronski:
      PrzeliczSkowr ;
  end;

end;

procedure TPompCieczCharData.PrzeliczNY;
var
  i       :Integer;
  wcd, bcd:TLPktCharData; // Wewnetrzna i Bazowa CharData
                          // Wewnetrzna tzn. przeliczona
                          // Bazowa - oryginalna
begin
  if FWewnCharData is TLPktCharData then
  begin
    wcd := FWewnCharData as TLPktCharData;
    bcd := BazCharData as TLPktCharData;
    ObliczFaktory( bcd.FCharQMin );
    wcd.FCharQMin := bcd.FCharQMin * FaktorQ;
    ObliczFaktory( bcd.FCharQMax );
    wcd.FCharQMax := bcd.FCharQMax * FaktorQ;
    for i := 1 to bcd.Punkty.n_pt do
    begin
      ObliczFaktory( bcd.Punkty.Q[i] );
      wcd.Punkty.Q[i] := bcd.Punkty.Q[i] * FaktorQ;
      wcd.Punkty.H[i] := bcd.Punkty.H[i] * FaktorH;
      wcd.Punkty.P[i] := bcd.Punkty.P[i] * FaktorP;
    end;
    FCharPMax := 0;
    for i := 1 to bcd.Punkty.n_pt do
    begin
      if wcd.Punkty.P[i] > FCharPMax then
        FCharPMax := wcd.Punkty.P[i];
      if bcd.Punkty.P[i] > FCharPMax then
        FCharPMax := bcd.Punkty.P[i];
    end;
    if wcd is TSZCharData then
      TSZCharData(wcd).ObliczWsp;
  end;

end;

procedure TPompCieczCharData.PrzeliczSkowr;
var
  i       :Integer;
  wcd, bcd:TLPktCharData; // Wewnetrzna i Bazowa CharData
                          // Wewnetrzna tzn. przeliczona
                          // Bazowa - oryginalna
  DaneH, DaneP : TDaneDoApro;
  QoptWod     : real;     // Wydajnosc optymalna przy wodzie na podstawie
                          // aproksymacji H=f(Qr)
  HoptWod     : real;     // Wysokosc podnoszenia przy wodzie na podstawie
                          // aproksymacji H=f(Qr)
  nsQ, EtaV   : real;
  QsWod,QsLep : real;     // Przecieki przez uszczelnienia
  wH,wQ,wP    : real;
  FIoptWod    : real;     // Wyroznik optymalnej wydajnosci wewnetrznej
  FIthmaxWod  : real;     // Wyroznik maksymalnej teoretycznej wydajnosci
                          // dla wody
  FIthmaxLep  : real;     // Wyroznik maksymalnej teoretycznej wydajnosci
                          // dla wody
  WspQ        : real;     // przeliczenie wydajnosci
  WspH,WspP   : array[1..20] of real; //wspolczynniki poprawkowe przeciw wygladzaniu
  Re2Ni       : real;     // Liczba Reynoldsa dla lep
  D1,D2,D3,D4,D5,D6 : real;

//procedury wewnetrzne
function ObliczQsWod(QoptWod,EtaV:real):real;
begin
  result:=QoptWod*(1/EtaV-1);
end;
function ObliczQsLep(Re2Ni,QsWod,Ni:real):real;
var lgRe:real;
begin
  lgRe:=ln(Re2Ni)/2.302585;
  if (ni>2e-6) and (lgRe>2.9) and (lgRe<4.5) then
      result:=QsWod*1/power(Ni*1e6,0.28){ni [cSt], Q [m2/h] }
    else
      result:=QsWod;
end;
function Re_2_(Q,n,Ni:real):real;
begin
   result:=power(sqr(Q)*2*Pi*n/60,0.3333)/Ni;
end;

//procedury wewnetrzne KONIEC
begin
  Komunik := '';
  if FWewnCharData is TLPktCharData then
  begin
    wcd := FWewnCharData as TLPktCharData;
    bcd := BazCharData as TLPktCharData;

    // OD TAD -----------------------
// KOMUNIKAT!!!
// IF logRe2<2.9 or logRe2>4.5 then
//zatrzymac
//komunikat: parametru cieczy poza zakresem stosowania metody
//
    DaneH:=TDaneDoApro.create;
    DaneP:=TDaneDoApro.create;
    DaneH.n := bcd.Punkty.n_pt;
    DaneP.n := bcd.Punkty.n_pt;
    for i:=1 to DaneH.n do
      begin
        DaneH.Z[i,1] := bcd.Punkty.Q[i];
        DaneH.Z[i,2] := bcd.Punkty.H[i];
        DaneP.Z[i,1] := bcd.Punkty.Q[i];
        DaneP.Z[i,2] := bcd.Punkty.P[i];
      end;
    Apro_W2_(DaneH);  // Qr
    Apro_W2_(DaneP);
    for i:=1 to DaneH.n do
      begin
        WspH[i]:=bcd.Punkty.H[i]/(DaneH.B[1]+
                                  DaneH.B[2]*DaneH.Z[i,1]+
                                  DaneH.B[3]*DaneH.Z[i,1]*DaneH.Z[i,1]);
        WspP[i]:=bcd.Punkty.P[i]/(DaneP.B[1]+
                                  DaneP.B[2]*DaneP.Z[i,1]+
                                  DaneP.B[3]*DaneP.Z[i,1]*DaneP.Z[i,1]);
      end;
    QoptWod := PunktOptymalny(DaneH,DaneP,bcd.FCharQMin,bcd.FCharQMax);
    nsQ := Obl_nsQ(bcd.Obroty,QoptWod,Get_W2_(DaneH,QoptWod));
    if (nsQ<5) or (nsQ>50) then
      begin
        //Komunikat poza granicami dopuszczalnego wyroznika szybkobieznosci
        //wyniki przeliczenia moga byc niepoprawne
        Komunik := Komunik +
                   'Poza granicami dopuszczalnego wyroznika szybkobieznosci'+#13#10+
                   'wyniki przeliczenia moga byc niepoprawne'+#13#10;
      end;
    EtaV := EtaVLomakin(nsQ);
    QsWod:=ObliczQsWod(QoptWod,EtaV);
    PunktyWewnetrz(QsWod,DaneH);  // Tu Wsp Apro jeszcze dla Qr
    PunktyWewnetrz(QsWod,DaneP);
    HoptWod := Get_W2_(DaneH,QoptWod);
    PrzeliczBezwym(QoptWod,HoptWod,nsQ,bcd,wH,wQ,wP);
    PynktyBezwymiaroweWoda(wH,wQ,wP,DaneH,DaneP);
    Apro_W2_(DaneH);
    Apro_W2_(DaneP);
    FIthmaxWod := -DaneP.B[2]/DaneP.B[3];
    If (FIthmaxWod<0) or (FIthmaxWod>2) then
      begin
        Komunik := Komunik +
                   'Anomalia w przebiegu charakterystyki mocy' +#13#10+
                   'wyniki przeliczenia moga byc niepoprawne' +#13#10;
      end;
    FIoptWod := PunktOptymalny(DaneH,DaneP,0,1);
    Re2Ni := Re_2_(QoptWod/3600,bcd.Obroty,ciecz.ni);
    QsLep:=ObliczQsLep(Re2Ni,QsWod,ciecz.ni);
    RoznicePrzel(Re2Ni,D1,D2,D3,D4,D5,D6);
    PrzeliczNaLep(FIoptWod,D1,D2,D3,D4,D5,D6,DaneH,DaneP);
    CharLepka(wH,wQ,wP,DaneH,DaneP);
    FIthmaxLep := -DaneP.B[2]/DaneP.B[3];
    WspQ:=FIthmaxLep/FIthmaxWod;
    for i := 1 to bcd.Punkty.n_pt do
    begin
      wcd.Punkty.Q[i] := DaneH.Z[i,1]*WspQ-QsLep;//FaktorQ;
      wcd.Punkty.H[i] := DaneH.Z[i,2]*WspH[i];
      wcd.Punkty.P[i] := DaneP.Z[i,2]*WspP[i]*(FCiecz.Ro/1000);
    end;
    wcd.FCharQMin := wcd.Punkty.Q[1];//DaneH.Z[1,1];
    wcd.FCharQMax := wcd.Punkty.Q[bcd.Punkty.n_pt];//DaneH.Z[bcd.Punkty.n_pt,1];
    // DO TAD -----------------------

    FCharPMax := 0;
    for i := 1 to bcd.Punkty.n_pt do
    begin
      if wcd.Punkty.P[i] > FCharPMax then
        FCharPMax := wcd.Punkty.P[i];
      if bcd.Punkty.P[i] > FCharPMax then
        FCharPMax := bcd.Punkty.P[i];
    end;
    if wcd is TSZCharData then
      TSZCharData(wcd).ObliczWsp;
  end;
  DaneH.free;
  DaneP.free;
end;

procedure TPompCieczCharData.SetBazCharData(const Value: TFuncCharData);
begin
  FBazCharData := Value;
end;

procedure TPompCieczCharData.SetCiecz(const Value: TCiecz);
begin
  FCiecz := Value;
end;

function TPompCieczCharData.WorkPoint(Sel: IPumpCharSel; var Qr,
  Hr: Double): Boolean;
begin
  result := FWewnCharData.WorkPoint( Sel, Qr, Hr );
end;

//MOJE PROCEDURY
procedure TPompCieczCharData.Apro_W2_(var D:TDaneDoApro);
var i,j,k : integer;
    X     : array[1..20,0..3] of real; //zmienne
    Mp    : array[0..3,0..4] of real; //macierz poszerzona
    Tmp   : real;
    Sum   : real;
CONST r=2;        {Liczba zmiennych niezaleznych
                   nie wystepuje w programie}
      s=2;        {Liczba wsoolczynnikow -1}

begin
  {sprowadzenie do zagadnienia liniowego}
  For i:=1 To D.n Do
    Begin
      X[i,0]:=1;                     { A0 }
      X[i,1]:=D.Z[i,1];              { A1 }
      X[i,2]:=D.Z[i,1]*D.Z[i,1];     { A2 }
      X[i,3]:=D.Z[i,2];              { wynik}
    end;

  {MacierzPoszerzona}
  For k:=0 To s Do
    For i:=0 To s+1 do Mp[k,i]:=0; //Zerowanie tablicy
  For k:=0 To s Do
    For i:=0 To s+1 do
      FOR j:=1 To D.n do Mp[k,i]:=Mp[k,i]+X[j,i]*X[j,k];
  For k:=s Downto 0 do
    For i:=s+1 downto 0 do Mp[k+1,i+1]:=Mp[k,i];

  {Zerowanie}
  For j:=1 to s do
    begin
      if Mp[j,j]=0 then //ZamianaWierszy;
        begin
          k:=j;       {wskazniki z zerowania}
          Repeat
            k:=k+1;
            if k>s+2 then
              begin
                {uklad nie ma rozwiazania}
              end;
          until Mp[k,j]<>0;
          For i:=j to s+2 do
            begin
              Tmp:=Mp[j,i];
              Mp[j,i]:=Mp[k,i];
              Mp[k,i]:=Tmp;
            end;
        end;
      For k:=j+1 to s+1 do
        for i:=j+1 to (s+2) do
          Mp[k,i]:=Mp[k,i]-Mp[k,j]*Mp[j,i]/Mp[j,j];
    end;
  {ObliczanieNiewiadomych}
  for j:=s+1 downto 1 do  {n = s+1 = 3  lokalne w procedurze Gauss}
    begin
      Sum:=0;
      for i:=j+1 to s+1 do          // za pierwszym razem nie liczy
        Sum:=Sum+D.B[i]*Mp[j,i];
      D.B[j]:=(Mp[j,s+2]-Sum)/Mp[j,j];  {Wspolczynniki rownanoa B0, B1, B2}
    end;

End;

function  TPompCieczCharData.Get_W2_(Dane:TDaneDoApro;
                                            Q:real):real;
begin
  result:= Dane.B[1]+
           Dane.B[2]*Q+
           Dane.B[3]*Q*Q;
end;

function  TPompCieczCharData.PunktOptymalny(DaneH,DaneP:TDaneDoApro;
                                          minQ,maxQ:real):real;

var
  Q,krok    : Double;
  eta1,eta2 : double;
begin
  if maxQ>minQ then
      begin
        krok:=(maxQ-minQ)/100;
        Q:=minQ;
        eta2:=Q*Get_W2_(DaneH,Q)/Get_W2_(DaneP,Q);

        repeat
          eta1:=eta2;
          Q:=Q+krok;
          eta2:=Q*Get_W2_(DaneH,Q)/Get_W2_(DaneP,Q);
        until ((eta2<eta1) or (Q>maxQ));
        result := Q-krok;
      end
    else
      result:=maxQ;
end;

function TPompCieczCharData.Obl_nsQ(n,Q,H:real):real;
begin
  result:=n*sqrt(Q/3600)/sqrt(sqrt(H*H*H));
end;

function TPompCieczCharData.EtaVLomakin(nsQ:real):real;
begin
  result:=1/(1+0.287*power(nsQ,-2/3));
end;

procedure TPompCieczCharData.PunktyWewnetrz(QsWod:real; var Dane:TDaneDoApro);
var  i      :integer;
begin
  For i:=1 to dane.n do Dane.Z[i,1] := Dane.Z[i,1]+QsWod;
end;

PROCEDURE TPompCieczCharData.PrzeliczBezwym(Q,H,nsQ:real;
                             bcd:TLPktCharData;
                             var wH,wQ,wP:real);
var
   u2, cm2 :real;
const
   Ro_w=1000;
begin
   u2:=Pi*bcd.Srednica/1000 * bcd.Obroty/60;
   cm2:=Kcm2(nsQ)*SQRT(2*9.81*H);
   wH:=u2*u2/2/9.81;
   wQ:=u2*Q/3600/cm2;
   wP:=Ro_w*u2*u2*u2*Q/3600/cm2/2;
end;

FUNCTION TPompCieczCharData.Kcm2(nsQ:real):real;
VAR A:array[0..15,1..2] of real;
    i:integer;
Begin
   A[0,1] := 5;     A[0,2] :=  0.06 ;
   A[1,1] :=12;     A[1,2] :=  0.082;
   A[2,1] :=15;     A[2,2] :=  0.09 ;
   A[3,1] :=20;     A[3,2] :=  0.102;
   A[4,1] :=30;     A[4,2] :=  0.125;
   A[5,1] :=40;     A[5,2] :=  0.145;
   A[6,1] :=60;     A[6,2] :=  0.178;
   A[7,1] :=100;    A[7,2] :=  0.255;
   A[8,1] :=150;    A[8,2] :=  0.355;
   A[9,1] :=200;    A[9,2] :=  0.44 ;
   A[10,1]:=300;    A[10,2]:=  0.64 ;
   A[11,1]:=500;    A[11,2]:=  1.05 ;
   i:=1;
   WHILE nsQ>a[i,1] DO i:=i+1;
   result:=A[i-1,2]+(nsQ-A[i-1,1])*(A[i,2]-A[i-1,2])/(A[i,1]-A[i-1,1]);
end;

PROCEDURE TPompCieczCharData.PynktyBezwymiaroweWoda(wH,wQ,wP:real;
                                  var DaH,DaP:TDaneDoApro);
var i:integer;
begin
  For i:=1 to DaH.n do
    begin
      DaH.Z[i,1] :=DaH.Z[i,1]/3600/wQ;
      DaP.Z[i,1] :=DaP.Z[i,1]/3600/wQ;
      DaH.Z[i,2] :=DaH.Z[i,2]/wH;
      DaP.Z[i,2] :=DaP.Z[i,2]*1000/wP;
    end;
end;

PROCEDURE TPompCieczCharData.RoznicePrzel(Re2Ni:real;
                         var D1,D2,D3,D4,D5,D6:real);
var
  lgRe :real;
begin
  lgRe:=ln(Re2Ni)/2.302585;
  if (lgRe>2.9) and (lgRe<4.5) then
      begin
        D1:=0.2503-0.04517*lgRe;
        D2:=(1.2754*exp(-0.045138*lgRe))-(31000*exp(-3.6176*lgRe))-1;
        D3:=0;{   -29.63+7.51*lgRe;}
        D4:= 0.1541-0.03345*lgRe;
          IF D4<0 Then D4:=0;
        D5:=1.632-0.3682*lgRe;
          IF D5<0 Then D5:=0;
        D6:=0.5945-0.1389*lgRe;
          IF D6<0 Then D6:=0;
      end
    else
       begin
         D1:=0; D2:=0; D3:=0; D4:=0; D5:=0; D6:=0;
         Komunik := Komunik+'parametry cieczy poza zakresem stosowania metody'#13#10;
       end;
end;

procedure TPompCieczCharData.PrzeliczNaLep(FIk,D1,D2,D3,D4,D5,D6:real;
                             var DaneH,DaneP:TDaneDoApro);
                             {A[2],B[2] wspolczynniki rownan bezwymiarowych dla wody}
                             {A[3],B[3] wspolczynniki rownan bezwymiarowych dla lepkiej}
begin
  DaneH.B[1]:=DaneH.B[1]+D1;
  DaneH.B[3]:=DaneH.B[3]+D3;
  DaneH.B[2]:=DaneH.B[2]+(D2-D1-D3*FIk*FIk)/FIk;

  DaneP.B[1]:=DaneP.B[1]+D4;
  DaneP.B[2]:=DaneP.B[2]+D5;
  DaneP.B[3]:=DaneP.B[3]*DaneP.B[2]/(DaneP.B[3]*D6+DaneP.B[2]-D5);
end;

PROCEDURE TPompCieczCharData.CharLepka(wH,wQ,wP:real;
                                       var DaH,DaP:TDaneDoApro); {wewnetrzna}

var i:integer;
begin
  For i:=1 to DaH.n do
    begin
      DaH.Z[i,2] := DaH.B[1]+
                    DaH.B[2]*DaH.Z[i,1]+
                    DaH.B[3]*DaH.Z[i,1]*DaH.Z[i,1];
      DaH.Z[i,1] := DaH.Z[i,1]*3600*wQ;
      DaH.Z[i,2] := DaH.Z[i,2]*wH;

      DaP.Z[i,2] := DaP.B[1]+
                    DaP.B[2]*DaP.Z[i,1]+
                    DaP.B[3]*DaP.Z[i,1]*DaP.Z[i,1];
      DaP.Z[i,1] :=DaP.Z[i,1]*3600*wQ;
      DaP.Z[i,2] :=DaP.Z[i,2]/1000*wP;
    end;
   //wP_ni:=wP*ro_ni/ro_w; //czy zmiana ro jest uwzgledniana automatycznie
end;

end.
