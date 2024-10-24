unit RegTools;

interface

uses
  SysUtils, Classes,
  KrMath,
  FunctU, OPompa, PumpIntf;

type
  TPmpRegCharSelPomoc = class(IPumpCharSel)
  private
    FFunc    :TRealFunctObject;
    procedure SetFunc(const Value: TRealFunctObject);
  public
    Qw, Hw   :Double;

    destructor Destroy;                    override;

    function dH( Q :Double ) :Double;      override;
    function GetQw    :Double;             override;
    function GetHw    :Double;             override;
    function RngQIntsect( AQMin, AQMax :Double ) :Boolean;   override;
    function Accept( Qr, Hr :Double; Pump :IPump ): Boolean; override;
    procedure FreeFunc;

    property Func :TRealFunctObject read FFunc write SetFunc;
  end;

  TQHRegFunc = class (TRealFunctObject)
  public
    constructor CreateQH( AOwner :TComponent; AQ, AH :Double);  overload;
    constructor CreateQH( AQ, AH :Double);                      overload;
    procedure InitQH( AQ, AH :Double);                 virtual; abstract;
  end;

  TRegNFunct = class (TQHRegFunc)
  private
    A       :Double;
  public
    procedure InitQH( AQ, AH :Double);                          override;
    function Value( X :Real )    :Real;                         override;
    function InDomain( X :Real ) :Boolean;                      override;
  end;

  TRegDFunct = class (TQHRegFunc)
  private
    A       :Double;
  public
    procedure InitQH( AQ, AH :Double);                          override;
    function Value( X :Real )    :Real;                         override;
    function InDomain( X :Real ) :Boolean;                      override;
  end;

  TRegKFunct = class (TQHRegFunc)
  private
    FH       :Double;
  public
    procedure InitQH( AQ, AH :Double);                          override;
    function Value( X :Real )    :Real;                         override;
    function InDomain( X :Real ) :Boolean;                      override;
  end;



implementation

{ TPmpRegCharSelPomoc }

function TPmpRegCharSelPomoc.Accept(Qr, Hr: Double; Pump: IPump): Boolean;
begin
  result := true;
end;

destructor TPmpRegCharSelPomoc.Destroy;
begin
  FreeFunc;
  inherited;
end;

function TPmpRegCharSelPomoc.dH(Q: Double): Double;
begin
  result := FFunc.Value(Q);
end;

procedure TPmpRegCharSelPomoc.FreeFunc;
begin
  FFunc.Free;
  FFunc := NIL;
end;

function TPmpRegCharSelPomoc.GetHw: Double;
begin
  result := Hw;
end;

function TPmpRegCharSelPomoc.GetQw: Double;
begin
  result := Qw;
end;

function TPmpRegCharSelPomoc.RngQIntsect(AQMin, AQMax: Double): Boolean;
begin
  result := true;
end;

procedure TPmpRegCharSelPomoc.SetFunc(const Value: TRealFunctObject);
begin
  if FFunc <> NIL then
    FreeFunc;
  FFunc := Value;
end;

{ TRegNFunct }

function TRegNFunct.InDomain(X: Real): Boolean;
begin
  result := (X >=0);
end;

procedure TRegNFunct.InitQH(AQ, AH: Double);
begin
  if IsZero(AQ) then
    A := 1e50
  else
    A := F_DIV(AH , AQ*AQ);
end;

function TRegNFunct.Value(X: Real): Real;
begin
  result := A*X*X;
end;

{ TRegDFunct }

function TRegDFunct.InDomain(X: Real): Boolean;
begin
  result := (X >=0);
end;

procedure TRegDFunct.InitQH(AQ, AH: Double);
begin
  if IsZero(AQ) then
    A := 1e50
  else
    A := F_DIV(AH , AQ);
end;

function TRegDFunct.Value(X: Real): Real;
begin
  //if Pion then
    //raise EMathError.Create('');
  result := A*X;
end;



{ TQHRegFunc }

constructor TQHRegFunc.CreateQH(AOwner: TComponent; AQ, AH: Double);
begin
  Create(AOwner);
  InitQH(AQ, AH);
end;

constructor TQHRegFunc.CreateQH(AQ, AH: Double);
begin
  CreateQH(NIL, AQ, AH);
  
end;


{ TRegKFunct }

function TRegKFunct.InDomain(X: Real): Boolean;
begin
  Result := True;
end;

procedure TRegKFunct.InitQH(AQ, AH: Double);
begin
  FH := AH;
end;

function TRegKFunct.Value(X: Real): Real;
begin
  Result := FH;
end;

end.
