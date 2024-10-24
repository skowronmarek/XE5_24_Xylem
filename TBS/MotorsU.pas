unit MotorsU;

interface

uses
  SysUtils, Classes, FunctU, DB;

type
  TMotorCharOdP = class (TComponent)
  private
    FPMin, FPMax :Double;
    FObrFunct   :TSplineFunctObj;
    FPradFunct  :TSplineFunctObj;
    FCosFFunct  :TSplineFunctObj;
  public
    U         :Double;
    procedure ReadFromH( Tab :TDataSet );
    function  Obroty( P :Double ) :Double;
    function  Prad( P :Double ) :Double;
    function  CosF( P :Double ) :Double;
    function  Eta( P :Double ) :Double;
    property  PMin :Double read FPMin;
    property  PMax :Double read FPMax;
  end;

implementation



{ TMotorCharOdP }

function TMotorCharOdP.CosF(P: Double): Double;
begin
  result := FCosFFunct.Value(P);
end;

function TMotorCharOdP.Eta(P: Double): Double;
begin
  result := (P*1000) / (sqrt(3) * U * Prad(P) *CosF(P) );
end;

function TMotorCharOdP.Obroty(P: Double): Double;
begin
  result := FObrFunct.Value(P);
end;

function TMotorCharOdP.Prad(P: Double): Double;
begin
  result := FPradFunct.Value(P);
end;

procedure TMotorCharOdP.ReadFromH(Tab: TDataSet);
begin
  FObrFunct.Free;
  FPradFunct.Free;
  FCosFFunct.Free;

  FObrFunct := TSplineFunctObj.Create(self);
  FPradFunct := TSplineFunctObj.Create(self);
  FCosFFunct := TSplineFunctObj.Create(self);

  ReadSZFunctsFromHTab( Tab, [FObrFunct, FPradFunct, FCosFFunct] );
  //U := Tab.FieldByName( 'NAP' ).AsFloat;
  FPMin := Tab.FieldByName( 'H_QMIN' ).AsFloat;
  FPMax := Tab.FieldByName( 'H_QMAX' ).AsFloat;
end;

end.
