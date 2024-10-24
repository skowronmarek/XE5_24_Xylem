unit WieloPompaU;

interface

uses
  SysUtils, Classes,
  DGraph, Diagrams, LinCharU, OPompa;

type
  TWieloPompaFuncCharData = class;

  TWieloPompa = class (TPompa)
  private
    FPompaBazowa: TPompa;
    FRownolegle: Integer;
    FSzeregowo: Integer;
    procedure SetPompaBazowa(const Value: TPompa);
    procedure SetRownolegle(const Value: Integer);
    procedure SetSzeregowo(const Value: Integer);
    function GetWCharData: TWieloPompaFuncCharData;
  protected
  public
    constructor Create( Owner :TComponent );                 override;
    property PompaBazowa :TPompa read FPompaBazowa write SetPompaBazowa;
    property Rownolegle :Integer read FRownolegle write SetRownolegle;
    property Szeregowo  :Integer read FSzeregowo write SetSzeregowo;
    property WCharData :TWieloPompaFuncCharData read GetWCharData;
  end;

  TWieloPompaFuncCharData = class (TFuncCharData)
  private
    FBazowaCharData: TFuncCharData;
    FRownolegle: Integer;
    FSzeregowo: Integer;
    procedure SetRownolegle(const Value: Integer);
    procedure SetSzeregowo(const Value: Integer);
  protected
    procedure SetBazowaCharData( v :TFuncCharData);
    procedure UstawMinMax;
  public
    function  GetDiagFun( id :string;
                     Owner :TDiagFunction ):TCharDataDiagFun;  override;

    function  GetQMin      :Double;           override;
    function  GetQMax      :Double;           override;
    function  GetCharQMin  :Double;           override;
    function  GetCharQMax  :Double;           override;
    function  GetHMin      :Double;           override;
    function  GetHMax      :Double;           override;
    function  GetCharHMin  :Double;           override;
    function  GetCharHMax  :Double;           override;

    function  H   ( Q :Double ) :Double;        override;
    function  P   ( Q :Double ) :Double;        override;
    function  NPSH( Q :Double ) :Double;        override;

    function OblH( Q :Double; row, sz :Integer ): Double;
    function OblP( Q :Double; row, sz :Integer ): Double;
    function OblNPSH( Q :Double; row, sz :Integer ): Double;
    function OblETA( Q :Double; row, sz :Integer ): Double;

    property Rownolegle :Integer read FRownolegle write SetRownolegle;
    property Szeregowo  :Integer read FSzeregowo write SetSzeregowo;
  end;

  TWPFuncDiag = class (TFuncDiagFun)
  private
    FMinSzer: Integer;
    FMinRown: Integer;
    procedure SetMinRown(const Value: Integer);
    procedure SetMinSzer(const Value: Integer);
  protected
    sz, ro :Integer;
    function  DGetCharQMin :Double;    override;
    function  DGetCharQMax :Double;    override;
    function  DGetQMin :Double;    override;
    function  DGetQMax :Double;    override;

    function  GetData  :TWieloPompaFuncCharData;
    procedure SetData( AData :TWieloPompaFuncCharData );
  public
    constructor Create( Owner :TComponent );   override;
    property  Data :TWieloPompaFuncCharData read GetData write SetData;
    property  MinRown :Integer read FMinRown write SetMinRown;
    property  MinSzer :Integer read FMinSzer write SetMinSzer;
  end;

  TWPFuncDiagRown = class (TWPFuncDiag)
  protected
    procedure DrawFun  ( dt  :TSpecDrawData; bw :Boolean );  override;
  end;

  TWPFuncDiagSzRown = class (TWPFuncDiag)
  protected
    procedure DrawFun  ( dt  :TSpecDrawData; bw :Boolean );  override;
  end;


  THWPFuncDiag = class (TWPFuncDiagSzRown)
    protected
      function Value( Q :Double ): Double;                     override;
  end;

  TPWPFuncDiag = class (TWPFuncDiagSzRown)
    protected
      function Value( Q :Double ): Double;                     override;
  end;

  TNPSHWPFuncDiag = class (TWPFuncDiagRown)
    protected
      function Value( Q :Double ): Double;                     override;
  end;

  TETAWPFuncDiag = class (TWPFuncDiagRown)
    protected
      function Value( Q :Double ): Double;                     override;
  end;

implementation

{ TWieloPompa }

constructor TWieloPompa.Create(Owner: TComponent);
begin
  inherited;
  FPompa := TFizPompa.Create;
  FSzeregowo := 1;
  FRownolegle := 1;
end;

function TWieloPompa.GetWCharData: TWieloPompaFuncCharData;
begin
  result := FCharData as TWieloPompaFuncCharData;
end;

procedure TWieloPompa.SetPompaBazowa(const Value: TPompa);
var
  cd      :TWieloPompaFuncCharData;
begin
  FPompaBazowa := Value;
  FCharData.Free;
  FCharData := NIL;
  if FPompaBazowa <> NIL then
  begin
    if (FPompaBazowa.GetCharData <> NIL)
        and (FPompaBazowa.GetCharData is TFuncCharData) then
    begin
      // tu stworzyc CharData
      if (FPompaBazowa.GetCharData <> NIL)
         and (FPompaBazowa.GetCharData is TFuncCharData) then
      begin
        cd := TWieloPompaFuncCharData.Create(self);
        FCharData := cd;
        cd.FBazowaCharData := (FPompaBazowa.GetCharData) as TFuncCharData;
        cd.Szeregowo := Szeregowo;
        cd.Rownolegle := Rownolegle;        
      end;
    end;
  end;
end;

procedure TWieloPompa.SetRownolegle(const Value: Integer);
begin
  FRownolegle := Value;
  if WCharData <> NIL then
    WCharData.Rownolegle := Value;
end;

procedure TWieloPompa.SetSzeregowo(const Value: Integer);
begin
  FSzeregowo := Value;
  if WCharData <> NIL then
    WCharData.Szeregowo := Value;
end;

{ TWieloPompaFuncCharData }

function TWieloPompaFuncCharData.GetCharHMax: Double;
begin
  result := FBazowaCharData.GetCharHMax * Szeregowo;
end;

function TWieloPompaFuncCharData.GetCharHMin: Double;
begin
  result := FBazowaCharData.GetCharHMin * Szeregowo;
end;

function TWieloPompaFuncCharData.GetCharQMax: Double;
begin
  result := FBazowaCharData.GetCharQMax * Rownolegle;
end;

function TWieloPompaFuncCharData.GetCharQMin: Double;
begin
  result := FBazowaCharData.GetCharQMin * Rownolegle;
end;

function TWieloPompaFuncCharData.GetDiagFun(id: string;
  Owner: TDiagFunction): TCharDataDiagFun;
var
  r         :TWPFuncDiag;        // result
begin
  r := NIL;
  if id = 'H' then
  begin
    r := THWPFuncDiag.Create(Owner);
    Owner.Drawer := r;
    r.Bolded := true;
    r.CountMaxYR( GetHMax );
  end
  else if id = 'P' then
  begin
    r := TPWPFuncDiag.Create(Owner);
    Owner.Drawer := r;
    r.Bolded := true;
    r.CountMaxYR( FCharPMax );
  end
  else if id = 'NPSH' then
  begin
    r := TNPSHWPFuncDiag.Create(Owner);
    Owner.Drawer := r;
    r.Bolded := false;
    r.CountMaxYR( FCharNPSHMax );
  end
  else if id = 'ETA' then
  begin
    r := TETAWPFuncDiag.Create(Owner);
    Owner.Drawer := r;
    r.Bolded := false;
    r.MaxYR  := 1;
  end;
  if r <> NIL then
    r.Data := self;
  result := r;
end;

function TWieloPompaFuncCharData.GetHMax: Double;
begin
  result := FBazowaCharData.GetHMax * Szeregowo;
end;

function TWieloPompaFuncCharData.GetHMin: Double;
begin
  result := FBazowaCharData.GetHMin * Szeregowo;
end;

function TWieloPompaFuncCharData.GetQMax: Double;
begin
  result := FBazowaCharData.GetQMax * Rownolegle;
end;

function TWieloPompaFuncCharData.GetQMin: Double;
begin
  result := FBazowaCharData.GetQMin * Rownolegle;
end;

function TWieloPompaFuncCharData.H(Q: Double): Double;
begin
  result := OblH( Q, Rownolegle, Szeregowo );
end;

function TWieloPompaFuncCharData.NPSH(Q: Double): Double;
begin
  result := OblNPSH( Q, Rownolegle, Szeregowo );
end;

function TWieloPompaFuncCharData.OblETA(Q: Double; row,
  sz: Integer): Double;
//var
  //aq     :Double;
begin
  result := FBazowaCharData.ETA(q/row);
end;

function TWieloPompaFuncCharData.OblH(Q: Double; row, sz: Integer): Double;
begin
  result := FBazowaCharData.H(Q/row) * sz;
end;

function TWieloPompaFuncCharData.OblNPSH(Q: Double; row,
  sz: Integer): Double;
begin
  result := FBazowaCharData.NPSH(Q/row);
end;

function TWieloPompaFuncCharData.OblP(Q: Double; row, sz: Integer): Double;
begin
  result := FBazowaCharData.P(Q/row) * row * sz;
end;

function TWieloPompaFuncCharData.P(Q: Double): Double;
begin
  result := OblP(Q, Rownolegle, Szeregowo );
end;

procedure TWieloPompaFuncCharData.SetBazowaCharData(v: TFuncCharData);
begin
  FBazowaCharData := v;
  UstawMinMax;
end;

procedure TWieloPompaFuncCharData.SetRownolegle(const Value: Integer);
begin
  FRownolegle := Value;
  UstawMinMax;
end;

procedure TWieloPompaFuncCharData.SetSzeregowo(const Value: Integer);
begin
  FSzeregowo := Value;
  UstawMinMax;
end;

procedure TWieloPompaFuncCharData.UstawMinMax;
var
  v       :TFuncCharData;
begin
  v := FBazowaCharData;
  if v <> NIL then
  begin
    FCharQMin := v.FCharQMin * Rownolegle;
    FCharQMax := v.FCharQMax * Rownolegle;
    FCharHMin := v.FCharHMin * Szeregowo;
    FCharHMax := v.FCharHMax * Szeregowo;
    FCharPMax := v.FCharPMax * Szeregowo * Rownolegle;
    FCharNPSHMax := v.FCharNPSHMax;
  end;
end;

{ TWPFuncDiag }

constructor TWPFuncDiag.Create(Owner: TComponent);
begin
  inherited;
  MinRown := 1;
  MinSzer := 1;
end;

function TWPFuncDiag.DGetCharQMax: Double;
begin
  result := Data.FBazowaCharData.GetCharQMax * ro;
end;

function TWPFuncDiag.DGetCharQMin: Double;
begin
  result := Data.FBazowaCharData.GetCharQMin * ro;
end;

function TWPFuncDiag.DGetQMax: Double;
begin
  result := Data.FBazowaCharData.GetQMax * ro;
end;

function TWPFuncDiag.DGetQMin: Double;
begin
  result := Data.FBazowaCharData.GetQMin * ro;
end;


function TWPFuncDiag.GetData: TWieloPompaFuncCharData;
begin
  result := CharData as TWieloPompaFuncCharData;
end;

procedure TWPFuncDiag.SetData(AData: TWieloPompaFuncCharData);
begin
  CharData := AData;
end;

procedure TWPFuncDiag.SetMinRown(const Value: Integer);
begin
  FMinRown := Value;
  Invalidate;
end;

procedure TWPFuncDiag.SetMinSzer(const Value: Integer);
begin
  FMinSzer := Value;
  Invalidate;
end;

{ THWPFuncDiag }

function THWPFuncDiag.Value(Q: Double): Double;
begin
  result := Data.OblH(Q, ro, sz);
end;

{ TPWPFuncDiag }

function TPWPFuncDiag.Value(Q: Double): Double;
begin
  result := Data.OblP(Q, ro, sz);
end;

{ TNPSHWPFuncDiag }

function TNPSHWPFuncDiag.Value(Q: Double): Double;
begin
  result := Data.OblNPSH(Q, ro, sz);
end;

{ TETAWPFuncDiag }

function TETAWPFuncDiag.Value(Q: Double): Double;
begin
  result := Data.OblETA(Q, ro, sz);
end;

{ TWPFuncDiagRown }

procedure TWPFuncDiagRown.DrawFun(dt: TSpecDrawData; bw: Boolean);
var
  i, j      :Integer;
  svBolded  :Boolean;
begin
  svBolded := Bolded;
  Bolded := false;
  sz := 1;
  for j := MinRown to Data.Rownolegle do
  begin
    ro := j;
    if (j = Data.Rownolegle) then
      Bolded := svBolded;
    inherited DrawFun( dt, bw );
  end;
end;

{ TWPFuncDiagSzRown }

procedure TWPFuncDiagSzRown.DrawFun(dt: TSpecDrawData; bw: Boolean);
var
  i, j      :Integer;
  svBolded  :Boolean;
begin
  svBolded := Bolded;
  Bolded := false;
  for i := MinSzer to Data.Szeregowo do
  begin
    sz := i;
    for j := MinRown to Data.Rownolegle do
    begin
      ro := j;
      if (i = Data.Szeregowo) and (j = Data.Rownolegle) then
        Bolded := svBolded;
      inherited DrawFun( dt, bw );
    end;
  end;
end;

end.
