unit PompMath;

interface

uses
  KR_Sys,
  KRMath;



FUNCTION  Eta( q, h, p : Double; Ro :Double = 1000 ):Double;

FUNCTION  pv( t :Double ): Double;

function Przedzial( x :Double; var aPkty :TFloatArray;
                    n_pt :integer; lRosn, lWstecz :Boolean  ): integer;


function  WartTab( x: Double; var XPkty, YPkty :TFloatArray;
                   n_pt :integer; metoda :String ): Double;


implementation

{---------------------------------------------------------------------------}
FUNCTION  Eta( q, h, p : Double; Ro :Double = 1000 ):Double;
  {----------------------------------------
  |                                    3  
  |         q       h * g * Ro       m        m     kg
  |  Eta = ----- * ------------     --- * m * --  * --
  |        3600     p * 1000         s         2     3
  |          ^[s/h]                           s     m
  |                                [ ------------------ ] =  [-]
  |                                         W
  -----------------------------------------}
begin
  if IsZero(p) then
    result := 0
  else
    result := q/3600 * h*9.81* Ro / (p*1000);
end;


{---------------------------------------------------------------------------}
FUNCTION pv( t :Double ): Double;
begin
  result :=   641.9
            +  23.94       * t
            +   3.46627    * t*t
            -   0.033555   * t*t*t
            +   0.00097156 * t*t*t*t;
end;

{-----------------------------------------------------------------------------}
function Przedzial( x :Double; var aPkty :TFloatArray;
                    n_pt :integer; lRosn, lWstecz :Boolean  ): integer;

var
  i      :integer;

begin
  {DEFAULT n_pt TO len(aPkty), lRosn TO .t., lWstecz TO .f.}
  if not lWstecz then
  begin
    i := 1;
    if lRosn then
      while (i<n_pt-1) and (aPkty[i+1] < x) do inc(i)
    else                         {ciag malejacy}
      while (i<n_pt-1) and (aPkty[i+1] > x) do inc(i);
  end
  else
  begin
    i := n_pt-1;
    if lRosn then
      while (i>1) and (aPkty[i] >= x) do dec(i)
    else                         {ciag malejacy}
      while (i>1) and (aPkty[i] <= x) do dec(i);
  end;

  result := i;
end;

{-----------------------------------------------------------------------------}
function  WartTab( x: Double; var XPkty, YPkty :TFloatArray;
                   n_pt :integer; metoda :String ): Double;
   {--------------------------------------------------
   | Zwraca wartosc wg tablicy i zadanej metody
   ---------------------------------------------------}
var
   y        :Double;
   przedz   :integer;
   D1y,D2y  :PFloatArray;
   A0,A1,A2,A3 :PFloatArray;
begin
   metoda := upper(metoda);
   przedz := Przedzial(x,XPkty,n_pt,true,false);

   if (metoda = 'LZ') or (metoda = 'LR') then
   begin
     y := Lin( x, XPkty[przedz], XPkty[przedz+1],
                  YPkty[przedz], YPkty[przedz+1]);
   end
   else if (metoda = 'SZ') then
   begin
     D1y := NewFloatArray( n_pt );
     D2y := NewFloatArray( n_pt );
     A0  := NewFloatArray( n_pt );
     A1  := NewFloatArray( n_pt );
     A2  := NewFloatArray( n_pt );
     A3  := NewFloatArray( n_pt );
     Spline( n_pt, XPkty, YPkty, D1y^, D2y^ );
     PolySpline( n_pt, XPkty, YPkty, D1y^, D2y^, A0^, A1^, A2^, A3^ );
     y :=  A0^[przedz] + x*
          (A1^[przedz] + x*
          (A2^[przedz] + x*
          (A3^[przedz] )));
     FreeFloatArray( D1y, n_pt );
     FreeFloatArray( D2y, n_pt );
     FreeFloatArray( A0 , n_pt );
     FreeFloatArray( A1 , n_pt );
     FreeFloatArray( A2 , n_pt );
     FreeFloatArray( A3 , n_pt );
   end
   else if (metoda = 'P3') then
   begin
     y := YPkty[1] + x*(YPkty[2] + x*YPkty[3]);
   end;

   result := y;
end;




end.
