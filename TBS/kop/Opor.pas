unit opor;

interface

uses
  SysUtils, Math, KrMath, jezyki;

  // KR: 2001.03.09 - poprawki zabezpieczajace przd dzieleniem przez 0

Function Reynolds(d,v,ni : Real):Real;
Function V_przeplywu(Q,A : Real): Real;
function V_Przep_D( Q, d :Double) :Double;   // KR: 2001.03.09
Function Pole_przekroju(d : Real): Real;
{
Function PN_34034(Rej,d,k,v : Real; var egr : Real): Real;
Function Nikur(Rej,d,k,v : Real): Real;
Function Coleb(Rej,d,k,v : Real): Real;
Function Altsul(Rej,d,k,v : Real): Real;
Function Hazen(Rej,d,k,v,Ro,Ni : Double): Double;
Function Manning(Rej,d,k,v : Real): Real;
}
Function PN_34034(Rej,Sred,Nierowno,Pred : Real; var egr : Real): Real;
Function Nikur(Rej,Sred,Nierowno,Pred : Real): Real;
Function Coleb(Rej,Sred,Nierowno,Pred : Real): Real;
Function Altsul(Rej,Sred,Nierowno,Pred : Real): Real;
//Function Hazen(Rej,d,k,v,Ro,Ni : Double): Double;
Function Manning(Rej,Sred,Nierowno,Pred : Real): Real;


implementation
(*
Function Reynolds(d,v,ni : Real):Real;
          far; external'Opor32' name 'Re';
Function V_przeplywu(Q,A : Real): Real;
         far; external 'Opor32' name 'V';
Function Pole_przekroju(d : Real): Real;
         far; external 'Opor32' name 'A';
Function PN_34034(Rej,d,k,v : Real; var egr : Real): Real;
         far; external 'Opor32' name 'PN_34034';
Function Nikur(Rej,d,k,v : Real): Real;
         far; external 'Opor32' name 'Nikur';
Function Coleb(Rej,d,k,v : Real): Real;
         far; external 'Opor32' name 'Coleb';
Function Altsul(Rej,d,k,v : Real): Real;
         far; external 'Opor32' name 'Altsul';
Function Hazen(Rej,d,k,v,Ro,Ni : Double): Double;
         far; external 'Opor32' name 'Hazen';
Function Manning(Rej,d,k,v : Real): Real;
         far; external 'Opor32' name 'Manning';

*)

Function Reynolds(d,v,ni :Real) : Real; Export;
begin
  Reynolds := f_div(d*v, ni);
end;

Function V_przeplywu(Q,A : Real) : Real; Export;
begin
  if IsZero(A) then
    result := 0
  else
    V_przeplywu:=Q/A;
end;

function V_Przep_D( Q, d :Double) :Double;   // KR: 2001.03.09
begin
  result := V_przeplywu( Q, Pole_przekroju(d) );
end;

Function Pole_przekroju(d : Real): Real; Export;
begin
  Pole_przekroju := (PI*d*d)/4;
end;

{============Wzory Obliczania Opor¡w Przep¦ywu==========================}

FUNCTION Blas(Rej : Real) : Real; Export;
begin                                  { 1  Hydromech Troskol }
   Blas := 0.3164/Power(Rej,0.25);    { w przewodach gladkich}
end;                                   { Re=3000-100000 woda, powietrze}

FUNCTION Burk(Rej : Real) : Real; Export;
begin                                       // 2 Hydromech Troskol
   Burk := f_div(0.21,Power(Rej,0.21));     // w przewodach gladkich, burzliwych
end;

FUNCTION KSBlex(Rej,Sred,Nierowno,Pred : Real): Real; Export;
Var                                        // 3 KSB Centrifug Pump Lexicon
   L1, L2, L3, L4 : Real;
begin
   L1 := f_div(64, Rej);                     //         Re<      2 300
   L2 := 0.3164/Power(Rej,0.25);             //   2 300<Re<    100 000
   L3 := 0.0054+(0.396/Power(Rej,0.3));      //   2 300<Re<  2 000 000
   L4 := 0.0032+(0.221/Power(Rej,0.237));    // 100 000<Re<100 000 000
   If Rej<2300 then KSBlex:=L1;
   If (Rej>=2300) and (Rej<100000) then KSBlex:=Max(L2,L3);
   If (Rej>=100000) and (Rej<2000000) then KSBlex:=Max(L3,L4);
   If Rej>2000000 then KSBlex:=L4;
end;

// rury chropowate
FUNCTION Mize(Rej,Sred,Nierowno,Pred : Real) : Real; Export;
Var                                           // 5 Hydromech Troskol
   hi,L1, L2, L3 : Real;
Begin
   if IsZero(Rej) or IsZero(Sred) then
     raise EMathError.Create(TTlumacz.DajObiekt.ZnajdzTlumaczenie('BLAD OBLICZEN'));
   hi := 16*Nierowno;
   // ogolny
   L1 := (0.0096+Power((hi/Sred),0.5))*(1-2000/Rej)+(1.7/Power(Rej,0.5))*
          Power((1-2000/Rej),0.5)+32/Rej;
   // dla srednich predkosci
   L2:= 0.0096+Power((hi/Sred),0.5)+1.7/Power(Rej,0.5);
   // dla wody o temp 5 C
   L3:= 0.01  +Power((hi/Sred),0.5)+0.0023/Power((Pred*Sred),0.5);
   Mize:=L1;
End;

//---------------------------------------------------------------------------
FUNCTION Nikur(Rej,Sred,Nierowno,Pred : Real): Real; Export;
Var                                     // 6 Hydromech Troskol
   L1, L2, L3 : Double;
Begin
  if IsZero(Rej) or IsZero(Sred) then
    raise EMathError.Create(TTlumacz.DajObiekt.ZnajdzTlumaczenie('BLAD OBLICZEN'));
  if IsZero( Nierowno ) then
    L1 := 0
  else
    L1 := (1/Sqr((2*log10(Sred/Nierowno)+1.138)));// w obszarze turbulentnym
  L2 := 0.3164/Power(Rej,0.25);                       // w przewodach gladkich
  L3 := 64/Rej;                                 // w obszarze laminarnym
  Nikur :=Max(L1,Max(L2,L3));
End;

//---------------------------------------------------------------------------
FUNCTION Coleb(Rej,Sred,Nierowno,Pred : Real): Real; Export;
Var                                     // 7 Hydromech Troskol
   a, b, Ya, Yx, x :Real;
Begin
  if IsZero(Rej) or IsZero(Sred) then
    raise EMathError.Create(TTlumacz.DajObiekt.ZnajdzTlumaczenie('BLAD OBLICZEN'));

  a:=0.005;
  b:=0.3;
  Ya:= -a + power(-2 * log10(2.51/(Rej*sqrt(a)) + Nierowno/Sred/3.72),-2);

  WHILE abs(a-b)>0.0001 do
  begin
    x:=(a+b)/2;
    Yx:= -x + power(-2 * log10(2.51/(Rej*sqrt(x)) + Nierowno/Sred/3.72),-2);
   IF Ya*Yx>0 then
     begin
       a:=x;
       Ya:=Yx
     end
     else
       b:=x;
  end;  //end od While
  Coleb:=x      // obliczony wspolczynnik
End;

//---------------------------------------------------------------------------
FUNCTION Walden(Rej,Sred,Nierowno,Pred : Real): Real; Export;
//                     -----------------------------------------------|
//  2                 /                     1
//  -                / ----------------------------------------------
//   \              /
//    \            /                   6.1         0.134*Nierowno
//     \          /       -2 * log  ( ---------  + -------------- )
//      \        /                10      0.915       Sred
//       \      /                      Rej            ----
//        \    /                                       2
//         \  /            ---------------------------------------
//          \/                               2

Begin                                  // 8 Hydraul Czetwertynski
   if IsZero(Rej) or IsZero(Sred) then
     raise EMathError.Create(TTlumacz.DajObiekt.ZnajdzTlumaczenie('BLAD OBLICZEN'));
  Walden:=sqrt( F_DIV( 1,
                //----------------------------
                      -2 * log10( 6.1 / Power(Rej,0.915)
                                  + 0.134*Nierowno / (Sred/2)
                                )
                       / 2.3025851)
              ); // </SQRT>
End;

FUNCTION Altsul(Rej,Sred,Nierowno,Pred : Real): Real; Export;
Begin                                   // 9 Mech plyn Jezowiecka
  if IsZero(Rej) or IsZero(Sred) then
    raise EMathError.Create(TTlumacz.DajObiekt.ZnajdzTlumaczenie('BLAD OBLICZEN'));
  Altsul := 0.11 * Power((Nierowno/Sred+68/Rej),0.25);
End;

FUNCTION Manning(Rej,Sred,Nierowno,Pred : Real): Real; Export;
Var                                     // 10 Hydraul Czetwertynski
   n,d,rh : Real;
Begin                            // n - wspolczynnik szorstkosci
   n:=Nierowno*1000;
   d :=Sred;
   //rh :=(d/2)/2;    //KR:2001.08.14 ???
   //rh := d/4;       // (CD) i tak nie uzywane
  // Manning:=2*9.81*sqr(n)*d/Power(rh,4/6);
  if IsZero(d) then
    raise EZeroDivide.Create('Dzielenie przez zero w funkcji Manning');
  Manning := 2*9.81*sqr(n)/(Power(d,0.33333)*Power(1/16,0.33333));
End;

FUNCTION PN_34034(Rej,Sred,Nierowno,Pred : Real; var egr : Real): Real; Export;
Var                                               // PN-76/M-34034
    a, b, Ya, Yx, x : Real;
Begin
  if IsZero(Rej) or IsZero(Sred) then
    raise EMathError.Create(TTlumacz.DajObiekt.ZnajdzTlumaczenie('BLAD OBLICZEN'));
  egr:=(18*log10(Rej)-16.4)/Rej;    //  wg Filonienko - Altsula
//   egr:=17.85*Rej^-0.875                //wg Blasiusa
//   egr:=23/Rej                         //wg Altsula - Ljacera
  If Rej<2300 then PN_34034:=64/Rej;    //Re<2 300 wg Hagena-Poliseuillea
  If (Rej>=2300) and (Rej<4000) then   //2300<Re<4 000 wg Zajcenki
         PN_34034:=0.0025*Power(Rej,0.3333);
  If (Rej>4000) and ((Nierowno/Sred)<=egr) then
    begin                            //4000<Re<e<egr wg Prandtla-Karmana
      a:=0.005;
      b:=0.3;
      Ya:= -a + power((2*log10(sqrt(a)*Rej/2.51)),-2);
      WHILE abs(a-b)>0.0001 do
        begin
          x:=(a+b)/2;
          Yx:=-x + power((2*log10(sqrt(x)*Rej/2.51)),-2);
          IF Ya*Yx>0 then
            begin
              a:=x;
              Ya:=Yx;
            end
            else
              b:=x;
        end;             // end od While
      PN_34034:=x;      // obliczony wspolczynnik
    end;               // end od IF-a
  If (Rej>4000) and ((Nierowno/Sred)>egr) Then
    begin
      a:=0.005;
      b:=0.3;
      Ya:= -a + power(-2 * log10(2.51/(Rej*sqrt(a)) + Nierowno/Sred/3.72),-2);
      WHILE abs(a-b)>0.0001 do
        begin
          x:=(a+b)/2;
          Yx:=-x + power(-2 * log10(2.51/(Rej*sqrt(x)) + Nierowno/Sred/3.72),-2);
          IF Ya*Yx>0 THEN
            BEGIN
              a:=x;
              Ya:=Yx;
            END
            ELSE
              b:=x;
        END;                // end od While
     PN_34034:=x           // obliczony wspolczynnik
    END;                  // end od IF-a
END;

//-----------------------------------------------------
FUNCTION Hazen(Rej,Sred,Nierowno,Pred,Ro,Ni : Double): Double; Export;
Var                                            // PN-76/M-34034
 Q_ls,Rop,dmm : Double;
 A,V          : Double;
BEGIN
  if IsZero(Rej) or IsZero(Sred) then
    raise EMathError.Create(TTlumacz.DajObiekt.ZnajdzTlumaczenie('BLAD OBLICZEN'));
  A:=Pole_Przekroju(Sred);
  V:=(Rej*ni)/sred;
  Q_ls:=A*V*1000; // Wydajnosc w [l/s]
  dmm := Sred*1000;  // Srednica w mm
  Rop := 3468.85*Power(100/Nierowno,1.852)*Power(Q_ls,1.852)*
         Power(0.04*dmm,-4.8655);
  Hazen:=Rop/(9.81*Ro);
END;



{FUNCTION OblOpor(op,s_t)
LOCAL rowL:=0
LOCAL rowP:=0
LOCAL eleP:=1
LOCAL opoL:=1
LOCAL wys,ele,opo
LOCAL el[6,400]
LOCAL SumOpo:=0
   For i:=1 to 400    //tablica elementow
      el[1,i]:=element
      el[2,i]:=srednica
      el[3,i]:=cisnienie
      el[4,i]:=mat
      el[5,i]:=w_oporu
      el[6,i]:=cena
      skip
      SumOpo:=0
      for i:=1 to 200
         SumOpo=SumOpo+op[3,i]*8/(9.81*3.14*3.14*3600*3600*(op[4,i]/1000)^4)
      next
   while .T.
      Do CASE
      SumOpo=SumOpo+op[3,i]*8/(9.81*3.14*3.14*;
      3600*3600*(op[4,i]/1000)^4)
 }
 {  FUNCTION SumOp( aOpory )
   // Sumuj opory
LOCAL nSuma := 0, c
   c:=9.81*3.14*3.14*3600*3600
   AEval( aOpory, |it| nSuma += it[3]*it[4]*8/(c*(it[5]/1000)^4) )
 }
 {FUNCTION  OpRurDlug( aOpory )
   // Oblicz dlugosc rurociagu
   LOCAL nSuma := 0

   AEval( aOpory, |it| nSuma += it[3]  )
 {FUNCTION  Opor_LRe( q, d )
   LOCAL v := Opor_V( q, d )

RETURN v * d * 1000  // (1000 = 1000000/1000)
 }
{FUNCTION  OporZWsp( it )
   /*--------------------------------
   // Zastepczy wspolczynnik
   //--------------------------------
   */ }


end.
