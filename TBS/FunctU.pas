unit FunctU;

interface

uses
  Classes, SysUtils, Math, KrMath, DB, ZadCompU;

type
  TRealFunctObject = class (TZadComponent)
  protected
    FXMin, FXMax :Double;
    FYMin, FYMax :Double;
  public
    function Value( X :Real )    :Real;      virtual; abstract;
    function Pochodna( X :Real )    :Real;      virtual; abstract;
    function InDomain( X :Real ) :Boolean;   virtual; abstract;
    property  XMin :Double read FXMin;
    property  XMax :Double read FXMax;
    property  YMin :Double read FYMin;
    property  YMax :Double read FYMax;
  end;

  EOutOfDomainError = class (Exception)
  end;

  TPointListFunctObject = class (TRealFunctObject)
  protected
    FXs, FYs :array of Double;
    FCount   :Integer;
    procedure SetMinMax;                       virtual;
    procedure ReadPoints(Reader: TReader);     virtual;
    procedure WritePoints(Writer: TWriter);
    procedure DefineProperties(Filer: TFiler); override;
  public
    procedure Init( const AXs, AYs :array of Double; ACnt :Integer ); virtual;
    function InDomain( X :Real ) :Boolean;         override;
    property  PointCount :Integer read FCount;
  end;



  TSplineFunctObj = class (TPointListFunctObject)
  protected
    A0, A1, A2, A3 :array of Double;
    procedure InitSpline;
    procedure ReadPoints(Reader: TReader);     override;
  public
    procedure Init( const AXs, AYs :array of Double; ACnt :Integer ); override;
    function Value( X :Real )    :Real;              override;
    function Pochodna( X :Real ) :Real;              override;
  end;

procedure ReadSZFunctsFromHTab( DB :TDataSet;
                                funs :array of TSplineFunctObj);

implementation

{ TPointListFunctObject }

procedure TPointListFunctObject.DefineProperties(Filer: TFiler);
begin
  Filer.DefineProperty( 'Points', ReadPoints, WritePoints, true );
end;

function TPointListFunctObject.InDomain(X: Real): Boolean;
begin
  result := (FXMin <= X) and (X <= FXMax);
end;

procedure TPointListFunctObject.Init(const AXs, AYs: array of Double;
  ACnt: Integer);
var
  i      :Integer;
begin
  FCount := ACnt;
  SetLength( FXs, ACnt );
  SetLength( FYs, ACnt );
  for i := 0 to ACnt-1 do
  begin
    FXs[i] := AXs[i];
    FYs[i] := AYs[i];
  end;
  SetMinMax;
end;


procedure TPointListFunctObject.ReadPoints(Reader: TReader);
var
  i       :Integer;
begin
  FCount := Reader.ReadInteger;
  SetLength( FXs, FCount );
  SetLength( FYs, FCount );
  for i := 0 to FCount-1 do
  begin
    FXs[i] := Reader.ReadFloat;
    FYs[i] := Reader.ReadFloat;
  end;
  SetMinMax;
end;

procedure TPointListFunctObject.SetMinMax;
begin
  if FCount = 0 then
    EXIT;
  FXMin := MinValue( FXs );
  FXMax := MaxValue( FXs );
  FYMin := MinValue( FYs );
  FYMax := MaxValue( FYs );
end;

procedure TPointListFunctObject.WritePoints(Writer: TWriter);
var
  i       :Integer;
begin
  Writer.WriteInteger(FCount);
  for i := 0 to FCount-1 do
  begin
    Writer.WriteFloat( FXs[i] );
    Writer.WriteFloat( FYs[i] );
  end;
end;

{ TSplineFunctObj }

procedure TSplineFunctObj.Init(const AXs, AYs: array of Double;
  ACnt: Integer);
begin
  inherited Init( AXs, AYs, ACnt );
  InitSpline;
end;

procedure TSplineFunctObj.InitSpline;
var
  D1y, D2y :array of Double;

begin
  SetLength( D1y, FCount );
  SetLength( D2y, FCount );
  SetLength( A0, FCount );
  SetLength( A1, FCount );
  SetLength( A2, FCount );
  SetLength( A3, FCount );
  if FCount = 0 then
    EXIT;
  SplineZT( FCount, FXs, FYs, D1y, D2y );
  PolySplineZT( FCount, FXs, FYs, D1y, D2y, A0, A1, A2, A3 );
end;


procedure TSplineFunctObj.ReadPoints(Reader: TReader);
begin
  inherited;
  InitSpline;
end;

function TSplineFunctObj.Value(X: Real): Real;
begin
  result := SplineValueZT( PointCount, X, FXs, A0, A1, A2, A3 );
end;

function TSplineFunctObj.Pochodna(X: Real): Real;
begin
  result := SplinePochodnaZT( PointCount, X, FXs, A0, A1, A2, A3 );
end;

procedure ReadSZFunctsFromHTab( DB :TDataSet;
                                funs :array of TSplineFunctObj);
var
  AX      :array of Double;
  AY      :array of Double;
  N       :Integer;
  i, j    :Integer;
  pt1     :Integer;
  //szF     :TSplineFunctObj;
begin

  if DB.FieldByName('H_MET').AsString = 'SZ' then
  begin
    N := DB.FieldByName('N_PT').AsInteger;
    pt1 := DB.FieldByName('PT1').Index;

    SetLength(AX, N);
    for i := 0 to N-1 do
    begin
      AX[i] := DB.Fields[pt1+i].AsFloat;
    end;

    SetLength(AY, N);
    for j := 0 to Length(funs)-1 do
    begin
      for i := 0 to N-1 do
      begin
        AY[i] := DB.Fields[((j+1)*N)+pt1+i].AsFloat;
      end;
      funs[j].Init(AX, AY, N);
    end;
  end;

end;

initialization
  RegisterClass( TSplineFunctObj );  

end.
